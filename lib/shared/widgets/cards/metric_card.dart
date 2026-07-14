import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../common/card_container.dart';

/// Card de métrica: título, valor e variação opcional.
///
/// Usado no Dashboard e na Evolução para KPIs (peso, volume, tempo).
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.title,
    required this.value,
    this.delta,
    this.deltaPositive,
    this.icon,
    super.key,
  });

  final String title;
  final String value;
  final String? delta;
  final bool? deltaPositive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final deltaColor = deltaPositive == null
        ? AppColors.textSecondary
        : (deltaPositive! ? AppColors.success : AppColors.danger);

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
              ],
              Expanded(child: Text(title, style: AppTypography.caption)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTypography.title),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(delta!,
                style: AppTypography.small.copyWith(color: deltaColor)),
          ],
        ],
      ),
    );
  }
}
