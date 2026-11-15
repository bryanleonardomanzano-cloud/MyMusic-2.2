import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/search/presentation/search_providers.dart';

class SearchTabPage extends ConsumerStatefulWidget {
  const SearchTabPage({super.key});

  @override
  ConsumerState<SearchTabPage> createState() => _SearchTabPageState();
}

class _SearchTabPageState extends ConsumerState<SearchTabPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(int? ms) {
    if (ms == null) return '';
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Buscar canciones, artistas o álbumes',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchNotifierProvider.notifier).clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: (value) {
              ref.read(searchNotifierProvider.notifier).search(query: value);
            },
          ),
        ),
        if (state.isLoading) const LinearProgressIndicator(),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (state.query == null || state.query!.isEmpty) {
                return const Center(
                  child: Text('Escribe algo para buscar en tu música.'),
                );
              }
              final results = state.results ?? const [];
              if (!state.isLoading && results.isEmpty) {
                return Center(
                  child: Text('Sin resultados para "${state.query}".'),
                );
              }
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final track = results[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.music_note)),
                    title: Text(track.title),
                    subtitle: Text(
                      '${track.artist}${track.album != null ? ' • ${track.album}' : ''}',
                    ),
                    trailing: Text(_formatDuration(track.duration)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
