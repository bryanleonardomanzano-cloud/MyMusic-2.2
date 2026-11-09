/// Widget raíz de la aplicación MyMusic.
/// Configura el tema, la navegación (go_router) y el estado (Riverpod).
library mymusic.app_widget;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mymusic/core/routes/app_routes.dart';
import 'package:mymusic/features/auth/presentation/login_page.dart';
import 'package:mymusic/features/ui_shell/presentation/ui_shell_page.dart';

/// Configuración de rutas de la aplicación.
final GoRouter _router = GoRouter(
  initialLocation: initialRoute,
  routes: [
    GoRoute(
      path: loginRoute,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const UiShellPage(),
    ),
    GoRoute(
      path: '/library',
      builder: (context, state) => const UiShellPage(),
    ),
    GoRoute(
      path: '/playlists',
      builder: (context, state) => const UiShellPage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const UiShellPage(),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const UiShellPage(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const UiShellPage(),
    ),
  ],
  // Redirige al login si no hay ruta definida.
  errorBuilder: (context, state) => const LoginPage(),
);

/// Widget raíz de MyMusic.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MyMusic',
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
