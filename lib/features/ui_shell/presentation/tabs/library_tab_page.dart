import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/auth/domain/auth_state.dart';
import 'package:mymusic/features/auth/presentation/providers.dart';
import 'package:mymusic/features/google_drive/domain/google_drive_state.dart';
import 'package:mymusic/features/google_drive/presentation/google_drive_providers.dart';
import 'package:mymusic/features/library/presentation/library_providers.dart';
import 'package:mymusic/features/player/presentation/player_providers.dart';
import 'package:mymusic/features/ui_shell/presentation/ui_shell_providers.dart';

class LibraryTabPage extends ConsumerWidget {
  const LibraryTabPage({super.key});

  String _formatDuration(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    return '${(bytes / kb).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryNotifierProvider);
    final auth = ref.watch(authProvider);
    final isAuthenticated = auth is AuthAuthenticated;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(libraryNotifierProvider.notifier).loadLibrary();
        if (isAuthenticated) {
          await ref.read(googleDriveNotifierProvider.notifier).listAudioFiles();
        }
      },
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
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref
                        .read(libraryNotifierProvider.notifier)
                        .loadLibrary(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else if (state.songs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Tu biblioteca local está vacía.')),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Google Drive',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _GoogleDriveSection(
            formatSize: _formatSize,
          ),
        ],
      ),
    );
  }
}

class _GoogleDriveSection extends ConsumerWidget {
  final String Function(int) formatSize;

  const _GoogleDriveSection({required this.formatSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Inicia sesión con Google para ver tu música de Google Drive.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final driveState = ref.watch(googleDriveNotifierProvider);

    if (driveState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (driveState.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              driveState.error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref
                  .read(googleDriveNotifierProvider.notifier)
                  .listAudioFiles(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (driveState.files.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No se encontraron archivos de audio en tu Google Drive.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: driveState.files.map((file) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.cloud)),
            title: Text(file.name),
            subtitle: Text(
              '${file.mimeType}${file.size > 0 ? ' • ${formatSize(file.size)}' : ''}',
            ),
            trailing: const Icon(Icons.play_arrow),
            onTap: () async {
              final token = auth.accessToken;
              if (token.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No hay token de acceso para reproducir.'),
                  ),
                );
                return;
              }

              final url =
                  'https://www.googleapis.com/drive/v3/files/${file.id}?alt=media';
              await ref.read(playerNotifierProvider.notifier).loadTrack(
                    trackId: file.id,
                    title: file.name,
                    artist: 'Google Drive',
                    duration: 0,
                    playlist: [file.id],
                    sourceUrl: url,
                    headers: {'Authorization': 'Bearer $token'},
                  );

              final shellState = ref.read(uiShellNotifierProvider);
              final playerIndex = shellState.tabs.indexWhere(
                (tab) => tab.id == 'player',
              );
              if (playerIndex >= 0) {
                ref
                    .read(uiShellNotifierProvider.notifier)
                    .changeTab(playerIndex);
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
