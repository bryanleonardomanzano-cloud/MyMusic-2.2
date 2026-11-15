/// Proveedores del módulo Player (Riverpod).
library mymusic.features.player.presentation.player_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_data_source.dart';
import '../data/player_repository.dart';
import '../domain/player_state.dart';
import 'player_notifier.dart';

final playerDataSourceProvider = Provider<PlayerDataSource>((ref) {
  return PlayerRepository();
});

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final dataSource = ref.watch(playerDataSourceProvider);
  return PlayerNotifier(dataSource: dataSource);
});
