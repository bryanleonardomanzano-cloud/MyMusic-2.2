import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/playlists/presentation/playlist_providers.dart';

class PlaylistsTabPage extends ConsumerWidget {
  const PlaylistsTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playlistNotifierProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref
                    .read(playlistNotifierProvider.notifier)
                    .loadPlaylists(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(playlistNotifierProvider.notifier).loadPlaylists(),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Playlists (${state.playlistCount})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (state.playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No tienes playlists creadas.')),
            )
          else
            ...state.playlists.map(
              (playlist) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.queue_music)),
                  title: Text(playlist.name),
                  subtitle: Text(
                    '${playlist.songIds.length} canciones'
                    '${playlist.description != null ? ' • ${playlist.description}' : ''}',
                  ),
                  onTap: () => ref
                      .read(playlistNotifierProvider.notifier)
                      .selectPlaylist(playlist.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
