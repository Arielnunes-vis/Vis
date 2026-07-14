import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Vista genérica usada pelas telas ainda não implementadas.
///
/// Serve apenas para validar o roteamento durante o scaffold. Cada
/// feature substituirá isto pela sua interface real em etapas futuras.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.construction,
                  size: 40, color: AppColors.primary),
              const SizedBox(height: AppSpacing.m),
              Text(title, style: AppTypography.title),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Módulo em construção.',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
