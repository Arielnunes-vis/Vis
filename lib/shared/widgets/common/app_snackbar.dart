import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tipos de feedback via SnackBar (07_DESIGN_SYSTEM.md).
enum SnackType { success, error, info, warning }

/// Helper para exibir SnackBars padronizados (3 segundos).
abstract final class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
  }) {
    final color = switch (type) {
      SnackType.success => AppColors.success,
      SnackType.error => AppColors.danger,
      SnackType.warning => AppColors.warning,
      SnackType.info => AppColors.primary,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.elevated,
          showCloseIcon: true,
          closeIconColor: AppColors.textSecondary,
          margin: const EdgeInsets.all(12),
          content: _Content(message: message, color: color),
        ),
      );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 22, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    );
  }
}
