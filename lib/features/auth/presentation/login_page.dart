library mymusic.features.auth.presentation.login_page;

/// Pantalla de login con cuenta Google.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymusic/features/auth/domain/auth_state.dart';
import 'package:mymusic/features/auth/presentation/providers.dart';

/// Pantalla de login con cuenta Google.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    // Si ya hay sesión (p.ej. estado restaurado), ir al home.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth is AuthAuthenticated && mounted) {
        context.go('/home');
      }
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _isSigningIn = true);
    await ref.read(authProvider.notifier).login();
    if (mounted) setState(() => _isSigningIn = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go('/home');
      }
    });

    final auth = ref.watch(authProvider);
    final isError = auth is AuthError;
    final errorText = isError ? auth.error.toString() : null;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.music_note, size: 72),
                const SizedBox(height: 16),
                Text(
                  'MyMusic',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión con Google para continuar',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_isSigningIn) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 12),
                  const Text(
                    'Conectando con Google...',
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: _handleLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Continuar con Google'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Continuar sin iniciar sesión'),
                  ),
                ],
                if (errorText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorText,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}