import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:mymusic/features/auth/domain/auth_state.dart';
import 'package:mymusic/features/auth/presentation/providers.dart';
import 'package:mymusic/features/google_drive/data/google_drive_data_source.dart';
import 'package:mymusic/features/google_drive/data/google_drive_repository.dart';
import 'package:mymusic/features/google_drive/domain/google_drive_state.dart';
import 'package:mymusic/features/google_drive/presentation/google_drive_notifier.dart';

/// Proveedor de archivos de Google Drive para el usuario autenticado.
/// Si no hay sesión o no hay access token, devuelve un estado con error informativo.
final googleDriveNotifierProvider = StateNotifierProvider.autoDispose<
    GoogleDriveNotifier, GoogleDriveState>((ref) {
  final auth = ref.watch(authProvider);

  if (auth is! AuthAuthenticated) {
    return GoogleDriveNotifier(dataSource: _UnauthenticatedGoogleDriveDataSource())
      ..state = GoogleDriveState(
        error:
            'Inicia sesión con Google para ver tu música de Google Drive.',
      );
  }

  final token = auth.accessToken;
  if (token.isEmpty) {
    return GoogleDriveNotifier(dataSource: _UnauthenticatedGoogleDriveDataSource())
      ..state = GoogleDriveState(
        error: 'No hay un token de acceso válido para Google Drive.',
      );
  }

  final dataSource = GoogleDriveRepository(
    httpClient: http.Client(),
    accessToken: token,
  );
  final notifier = GoogleDriveNotifier(dataSource: dataSource);
  notifier.listAudioFiles();
  return notifier;
});

class _UnauthenticatedGoogleDriveDataSource implements GoogleDriveDataSource {
  @override
  Future<void> dispose() async {}

  @override
  Future<GoogleDriveFile?> getFile(String fileId) async => null;

  @override
  Future<String?> getDownloadUrl(String fileId) async => null;

  @override
  Future<List<GoogleDriveFile>> listAudioFiles(
      {int? pageSize, String? pageToken}) async {
    return const [];
  }
}
