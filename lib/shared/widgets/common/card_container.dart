import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Container base para todos os cards do VIS.
///
/// Centraliza cor, raio e padding para garantir consistência visual
/// (07_DESIGN_SYSTEM.md). Demais cards compõem sobre este.
class CardContainer extends StatelessWidget {
  const CardContainer({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.m),
    this.color = AppColors.card,
    this.onTap,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
