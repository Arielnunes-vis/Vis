import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logger central do VIS.
///
/// Regra 14 (10_DEVELOPMENT_RULES.md): NUNCA utilizar `print()`.
/// Toda comunicação com Supabase e todo evento relevante deve
/// passar por aqui. Em release, logs de debug são silenciados.
///
/// Uso:
/// ```dart
/// AppLogger.i('Sessão iniciada');
/// AppLogger.e('Falha ao sincronizar', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  const AppLogger._();

  static final Logger _logger = Logger(
    filter: _VisLogFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 6,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kReleaseMode ? Level.warning : Level.trace,
  );

  static void t(dynamic message) => _logger.t(message);
  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void f(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}

class _VisLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Em release, apenas warning ou acima.
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
