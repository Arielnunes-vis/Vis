import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../common/card_container.dart';

/// Card de insight da IA — sempre no topo do Dashboard (Regra 006/008).
///
/// Todo insight deve explicar o motivo; por isso o corpo é destacado.
class InsightCard extends StatelessWidget {
  const InsightCard({
    required this.message,
    this.title = 'VIS Coach',
    this.onDetails,
    super.key,
  });

  final String message;
  final String title;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderColor: AppColors.primary.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(message, style: AppTypography.body),
          if (onDetails != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onDetails, child: const Text('Saiba mais')),
            ),
          ],
        ],
      ),
    );
  }
}
