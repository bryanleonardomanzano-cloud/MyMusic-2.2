/// Proveedores del módulo Search (Riverpod).
library mymusic.features.search.presentation.search_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/search_data_source.dart';
import '../data/search_repository.dart';
import '../domain/search_state.dart';
import 'search_notifier.dart';

final searchDataSourceProvider = Provider<SearchDataSource>((ref) {
  return SearchRepository();
});

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final dataSource = ref.watch(searchDataSourceProvider);
  return SearchNotifier(dataSource: dataSource);
});
