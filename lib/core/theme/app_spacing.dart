/// Escala de espaçamento do VIS (07_DESIGN_SYSTEM.md).
///
/// Muito espaço entre componentes é um princípio de design do VIS,
/// portanto todo padding/gap deve usar estes tokens — nunca valores
/// mágicos soltos no código.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Padding padrão de tela (04_FLUTTER_ARCHITECTURE.md).
  static const double screen = 16;
}

/// Raios de borda do VIS (07_DESIGN_SYSTEM.md).
abstract final class AppRadius {
  const AppRadius._();

  static const double input = 12;
  static const double button = 16;
  static const double card = 20;
  static const double modal = 24;
  static const double bottomSheet = 28;
}
