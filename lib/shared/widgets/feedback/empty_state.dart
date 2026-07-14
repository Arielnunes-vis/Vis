import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/primary_button.dart';

/// Estado vazio padrão: ícone, título, descrição e ação opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.description,
    this.icon = LucideIcons.inbox,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.m),
            Text(title, style: AppTypography.subtitle, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(description!,
                  style: AppTypography.caption, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.l),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
