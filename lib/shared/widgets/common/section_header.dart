import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Cabeçalho de seção reutilizável (título + ação opcional).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.subtitle),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
