import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia do VIS — fonte Inter (07_DESIGN_SYSTEM.md).
///
/// A hierarquia (Display, Headline, Title, Subtitle, Body, Caption,
/// Small) é mapeada para o [TextTheme] do Material para que os
/// componentes padrão herdem o estilo automaticamente.
abstract final class AppTypography {
  const AppTypography._();

  // Estilos calculados uma única vez (static final, init preguiçoso) para
  // evitar re-alocar o TextStyle + refazer o lookup do GoogleFonts a cada
  // acesso — antes eram getters e recalculavam em todo build (Regra 009).
  static final TextStyle _base =
      GoogleFonts.inter(color: AppColors.textPrimary);

  static final TextStyle display = _base.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    height: 1.1,
  );

  static final TextStyle headline = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.15,
  );

  static final TextStyle title = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle subtitle = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle body = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle caption = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle small = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Monta o [TextTheme] utilizado pelo [ThemeData].
  static TextTheme get textTheme => TextTheme(
        displayLarge: display,
        displayMedium: display.copyWith(fontSize: 34),
        headlineLarge: headline,
        headlineMedium: headline.copyWith(fontSize: 28),
        titleLarge: title,
        titleMedium: subtitle,
        titleSmall: subtitle.copyWith(fontSize: 16),
        bodyLarge: body,
        bodyMedium: body.copyWith(fontSize: 14),
        bodySmall: caption,
        labelLarge: body.copyWith(fontWeight: FontWeight.w600),
        labelMedium: caption,
        labelSmall: small,
      );
}
