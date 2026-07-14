import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/secondary_button.dart';

/// Estado de erro amigável com opção de tentar novamente (Regra 15).
class ErrorState extends StatelessWidget {
  const ErrorState({
    this.message = 'Algo deu errado. Tente novamente.',
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertTriangle,
                size: 40, color: AppColors.danger),
            const SizedBox(height: AppSpacing.m),
            Text(message,
                style: AppTypography.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.l),
              SecondaryButton(
                label: 'Tentar novamente',
                onPressed: onRetry,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
