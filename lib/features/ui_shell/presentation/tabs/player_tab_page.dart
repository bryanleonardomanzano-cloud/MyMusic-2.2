import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/player/presentation/player_providers.dart';

class PlayerTabPage extends ConsumerWidget {
  const PlayerTabPage({super.key});

  String _formatDuration(int? ms) {
    if (ms == null) return '--:--';
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerNotifierProvider);
    final notifier = ref.read(playerNotifierProvider.notifier);

    final hasTrack = state.currentTrack != null;
    final isPlaying = hasTrack && (state.duration ?? 0) > 0 && state.message == null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.album,
            size: 140,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            state.currentTrack ?? 'Nada en reproducción',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            state.artist ?? 'Selecciona una canción para comenzar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (state.message != null) ...[
            const SizedBox(height: 12),
            Text(
              state.message!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          if (hasTrack) ...[
            Slider(
              value: (state.position ?? 0)
                  .clamp(0, (state.duration ?? 1))
                  .toDouble(),
              max: ((state.duration ?? 1) <= 0 ? 1 : state.duration!).toDouble(),
              onChanged: (value) {
                notifier.seek(position: value.toInt());
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(state.position)),
                  Text(_formatDuration(state.duration)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                iconSize: 36,
                onPressed: hasTrack ? () => notifier.togglePause() : null,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 16),
              IconButton.outlined(
                iconSize: 28,
                onPressed: hasTrack ? () => notifier.stop() : null,
                icon: const Icon(Icons.stop),
              ),
            ],
          ),
          if (!hasTrack) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                notifier.loadTrack(
                  trackId: 'demo_track',
                  title: 'Mi canción favorita',
                  artist: 'Artista Uno',
                  duration: 240000,
                  playlist: const ['demo_track'],
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Reproducir demo'),
            ),
          ],
        ],
      ),
    );
  }
}
