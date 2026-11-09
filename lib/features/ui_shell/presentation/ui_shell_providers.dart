/// Proveedores del módulo UI Shell (Riverpod).
library mymusic.features.ui_shell.presentation.ui_shell_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ui_shell_repository.dart';
import '../data/ui_shell_data_source.dart';
import '../domain/ui_shell_state.dart';
import 'ui_shell_notifier.dart';

/// Proveedor del data source de UI Shell.
final uiShellDataSourceProvider = Provider<UiShellDataSource>((ref) {
  return UiShellRepository();
});

/// Proveedor del notificador de UI Shell.
final uiShellNotifierProvider =
    StateNotifierProvider<UiShellNotifier, UiShellState>((ref) {
  final dataSource = ref.watch(uiShellDataSourceProvider);
  return UiShellNotifier(dataSource: dataSource);
});
