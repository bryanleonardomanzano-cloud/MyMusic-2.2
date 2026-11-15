import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/auth/presentation/providers.dart';

class ProfileTabPage extends ConsumerWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 40,
          child: Icon(
            user != null ? Icons.person : Icons.person_outline,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? user?.email ?? 'Invitado',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (user?.email != null)
          Text(
            user!.email!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('Google Drive'),
                subtitle: Text(
                  user != null ? 'Conectado' : 'No conectado',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de MyMusic'),
                subtitle: const Text('Versión de aplicación'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (authState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (user != null)
          FilledButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          )
        else
          FilledButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signIn();
            },
            icon: const Icon(Icons.login),
            label: const Text('Iniciar sesión'),
          ),
        if (authState.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            authState.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
