import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/library/presentation/library_providers.dart';
import 'package:mymusic/features/playlists/presentation/playlist_providers.dart';

class HomeTabPage extends ConsumerWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryNotifierProvider);
    final playlists = ref.watch(playlistNotifierProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Bienvenido a MyMusic',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu música, organizada y lista para reproducir.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.library_music,
                label: 'Canciones',
                value: library.isLoading ? '…' : '${library.songCount}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.playlist_play,
                label: 'Playlists',
                value: playlists.isLoading ? '…' : '${playlists.playlistCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Canciones recientes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        if (library.isLoading)
          const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ))
        else if (library.songs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay canciones en tu biblioteca todavía.'),
            ),
          )
        else
          ...library.songs.take(5).map(
                (song) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.music_note)),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                ),
              ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
