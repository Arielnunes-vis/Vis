/// Formatação de números para a tela de Analytics (PROMPT 16).
///
/// Mantém a apresentação consistente sem espalhar `toStringAsFixed` pelas
/// telas. Usa separador de milhar simples (pt-BR: ponto).
abstract final class AnalyticsFormat {
  const AnalyticsFormat._();

  /// Ex.: 12540 → "12.540 kg".
  static String kg(double value) => '${_thousands(value.round())} kg';

  /// Ex.: 135 → "2h15" · 45 → "45 min".
  static String minutes(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes min';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
  }

  /// Ex.: 12.4 → "12,4 km".
  static String km(double value) =>
      '${value.toStringAsFixed(1).replaceAll('.', ',')} km';

  /// Insere separador de milhar (ponto) em um inteiro.
  static String _thousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }
}
