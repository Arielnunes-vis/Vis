import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Indicador de carregamento centralizado com mensagem opcional.
///
/// Nunca usar spinner infinito sem contexto (07_DESIGN_SYSTEM.md).
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(message!, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }
}
