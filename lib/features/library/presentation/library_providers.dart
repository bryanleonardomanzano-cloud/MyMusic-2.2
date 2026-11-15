/// Proveedores del módulo Library (Riverpod).
library mymusic.features.library.presentation.library_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/library_data_source.dart';
import '../data/library_repository.dart';
import '../domain/library_state.dart';
import 'library_notifier.dart';

final libraryDataSourceProvider = Provider<LibraryDataSource>((ref) {
  return LibraryRepository();
});

final libraryNotifierProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  final dataSource = ref.watch(libraryDataSourceProvider);
  final notifier = LibraryNotifier(dataSource: dataSource);
  notifier.loadLibrary();
  return notifier;
});
