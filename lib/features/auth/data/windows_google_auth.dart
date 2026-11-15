import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:mymusic/core/errors/app_error.dart';
import 'package:mymusic/features/auth/domain/auth_state.dart';
import 'package:mymusic/features/auth/domain/auth_user.dart';

/// Resultado intermedio del flujo OAuth de escritorio (loopback).
class _TokenResponse {
  final String accessToken;
  final String? idToken;
  final String? refreshToken;
  final int expiresIn;

  _TokenResponse({
    required this.accessToken,
    required this.expiresIn,
    this.idToken,
    this.refreshToken,
  });
}

/// Implementa login real con Google en Windows usando OAuth 2.0 + loopback.
///
/// Requiere un OAuth Client ID (tipo "Desktop app" recomendado).
/// Configúralo al ejecutar con:
///   --dart-define=GOOGLE_DESKTOP_CLIENT_ID=TU_CLIENT_ID
///   --dart-define=GOOGLE_DESKTOP_CLIENT_SECRET=TU_CLIENT_SECRET (si aplica)
class WindowsGoogleAuth {
  static const String _clientId =
      String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_ID');
  static const String _clientSecret =
      String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_SECRET');

  static const String _authEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const String _userinfoEndpoint =
      'https://www.googleapis.com/oauth2/v3/userinfo';
  static const List<String> _scopes = [
    'openid',
    'email',
    'profile',
  ];

  static bool get isConfigured => _clientId.isNotEmpty;

  static Future<AuthState> signIn() async {
    if (!isConfigured) {
      return AuthError(authError(
        'loginWithGoogle',
        'Falta configurar GOOGLE_DESKTOP_CLIENT_ID. '
            'Ejecuta con --dart-define=GOOGLE_DESKTOP_CLIENT_ID=TU_CLIENT_ID '
            '(y GOOGLE_DESKTOP_CLIENT_SECRET si tu cliente lo requiere).',
      ));
    }

    HttpServer? server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      final redirectUri = 'http://127.0.0.1:$port';

      final authUri = Uri.parse(_authEndpoint).replace(queryParameters: {
        'client_id': _clientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': _scopes.join(' '),
        'access_type': 'offline',
        'prompt': 'consent',
      });

      final launched = await launchUrl(
        authUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        return AuthError(authError(
          'loginWithGoogle',
          'No se pudo abrir el navegador para iniciar sesión.',
        ));
      }

      final code = await _waitForAuthCode(server);
      if (code == null || code.isEmpty) {
        return AuthUninitialized();
      }

      final token = await _exchangeCodeForToken(code, redirectUri);
      final userInfo = await _fetchUserInfo(token.accessToken);

      final user = AuthUser(
        id: (userInfo['sub'] ?? userInfo['id'] ?? userInfo['email'] ?? '')
            .toString(),
        email: (userInfo['email'] ?? '').toString(),
        displayName: userInfo['name']?.toString(),
      );

      final expiration = DateTime.now().add(Duration(seconds: token.expiresIn));
      return AuthAuthenticated(user, token.accessToken, expiration);
    } on TimeoutException {
      return AuthError(authError(
        'loginWithGoogle',
        'Tiempo de espera agotado durante el inicio de sesión.',
      ));
    } catch (e) {
      return AuthError(authError('loginWithGoogle', e.toString()));
    } finally {
      await server?.close(force: true);
    }
  }

  static Future<String?> _waitForAuthCode(HttpServer server) async {
    try {
      final request = await server.first.timeout(const Duration(minutes: 3));
      final code = request.uri.queryParameters['code'];
      final error = request.uri.queryParameters['error'];

      final html = (error != null)
          ? '<html><body><h3>Inicio de sesión cancelado o fallido.</h3>'
              '<p>Puedes cerrar esta ventana.</p></body></html>'
          : '<html><body><h3>Inicio de sesión completado.</h3>'
              '<p>Puedes cerrar esta ventana y volver a MyMusic.</p></body></html>';

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(html);
      await request.response.close();

      if (error != null) return null;
      return code;
    } catch (_) {
      return null;
    }
  }

  static Future<_TokenResponse> _exchangeCodeForToken(
    String code,
    String redirectUri,
  ) async {
    final body = <String, String>{
      'client_id': _clientId,
      'code': code,
      'grant_type': 'authorization_code',
      'redirect_uri': redirectUri,
    };
    if (_clientSecret.isNotEmpty) {
      body['client_secret'] = _clientSecret;
    }

    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al intercambiar el código por tokens: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Respuesta de token inválida: falta access_token.');
    }

    return _TokenResponse(
      accessToken: accessToken,
      idToken: data['id_token'] as String?,
      refreshToken: data['refresh_token'] as String?,
      expiresIn: (data['expires_in'] as num?)?.toInt() ?? 3600,
    );
  }

  static Future<Map<String, dynamic>> _fetchUserInfo(String accessToken) async {
    final response = await http.get(
      Uri.parse(_userinfoEndpoint),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo obtener el perfil de usuario: ${response.statusCode} ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
