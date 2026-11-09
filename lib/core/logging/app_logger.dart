import 'dart:developer' as developer;

/// Logger simple y modular para toda la aplicación.
/// Usa el logger de Dart con fecha/hora; en producción se puede reemplazar
/// por un servicio remoto o Firebase Crashlytics.
class AppLogger {
  /// Línea con marca de tiempo.
  static void d(String message, {String? component}) {
    final now = DateTime.now();
    developer.log(
      '[${_formatDate(now)}] $message',
      time: now,
      name: component ?? 'MyMusic',
    );
  }

  static void e(dynamic error, {String? component, String? message}) {
    final now = DateTime.now();
    final prefix = message == null ? '' : '$message: ';
    developer.log(
      '[ERROR ${_formatDate(now)}] $prefix$error',
      time: now,
      name: component ?? 'MyMusic',
      level: 1000,
      error: error,
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';

  /// Para tests: capturar log y retornar string (opcional).
  static String? capture() =>
      null; // En producción real podría retornar lo impreso.
}
