/// Proveedores del módulo Playlists (Riverpod).
library mymusic.features.playlists.presentation.playlist_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/playlist_data_source.dart';
import '../data/playlist_repository.dart';
import '../domain/playlist_state.dart';
import 'playlist_notifier.dart';

final playlistDataSourceProvider = Provider<PlaylistDataSource>((ref) {
  return PlaylistRepository();
});

final playlistNotifierProvider =
    StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
  final dataSource = ref.watch(playlistDataSourceProvider);
  final notifier = PlaylistNotifier(dataSource: dataSource);
  notifier.loadPlaylists();
  return notifier;
});
