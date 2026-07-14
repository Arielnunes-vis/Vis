import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Tema central do VIS.
///
/// O VIS não utiliza o Material padrão: define um tema próprio,
/// Dark por padrão (07_DESIGN_SYSTEM.md). O Light Mode está
/// previsto e o método [light] fica reservado para o futuro.
abstract final class AppTheme {
  const AppTheme._();

  static const SystemUiOverlayStyle systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlay,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.m,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.disabled),
        labelStyle: AppTypography.caption,
        errorStyle: AppTypography.small.copyWith(color: AppColors.danger),
        enabledBorder: _inputBorder(AppColors.divider),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.5),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.elevated,
        contentTextStyle: AppTypography.body,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
