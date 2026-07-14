import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Faixa discreta indicando modo offline. Não bloqueia o usuário
/// (07_DESIGN_SYSTEM.md — Modo Offline).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warning.withValues(alpha: 0.16),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.wifiOff, size: 14, color: AppColors.warning),
          const SizedBox(width: 8),
          Text(
            'Você está offline',
            style: AppTypography.small.copyWith(color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}
