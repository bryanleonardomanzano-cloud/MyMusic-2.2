import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/library/presentation/library_providers.dart';

class LibraryTabPage extends ConsumerWidget {
  const LibraryTabPage({super.key});

  String _formatDuration(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryNotifierProvider);

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
                onPressed: () =>
                    ref.read(libraryNotifierProvider.notifier).loadLibrary(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(libraryNotifierProvider.notifier).loadLibrary(),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Biblioteca (${state.songCount} canciones)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (state.songs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Tu biblioteca está vacía.')),
            )
          else
            ...state.songs.map(
              (song) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.music_note)),
                  title: Text(song.title),
                  subtitle: Text(
                    '${song.artist}${song.album != null ? ' • ${song.album}' : ''}',
                  ),
                  trailing: Text(_formatDuration(song.durationMs)),
                  selected: state.selectedSong?.id == song.id,
                  onTap: () => ref
                      .read(libraryNotifierProvider.notifier)
                      .selectSong(song.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
