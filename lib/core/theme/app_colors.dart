import 'package:flutter/material.dart';

/// Paleta de cores do VIS.
///
/// Fonte de verdade: 07_DESIGN_SYSTEM.md (Dark Mode).
/// O Light Mode está previsto para o futuro, portanto os tokens
/// são expostos de forma semântica para facilitar a expansão.
abstract final class AppColors {
  const AppColors._();

  // ----- Superfícies (Dark) -----
  static const Color background = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF111111);
  static const Color card = Color(0xFF1A1A1A);
  static const Color elevated = Color(0xFF1C1C1E);

  // ----- Marca -----
  static const Color primary = Color(0xFF3A86FF);
  static const Color secondary = Color(0xFF6C63FF);

  // ----- Feedback -----
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFCC00);
  static const Color danger = Color(0xFFFF453A);

  // ----- Texto -----
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color disabled = Color(0xFF707070);

  // ----- Estrutura -----
  static const Color divider = Color(0xFF2A2A2A);

  // ----- Aliases semânticos -----
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;
}
