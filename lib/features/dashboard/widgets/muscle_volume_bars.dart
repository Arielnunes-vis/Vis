import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/dashboard_data.dart';

/// Gráfico simples de volume por grupo muscular (PROMPT 07 — card 9).
class MuscleVolumeBars extends StatelessWidget {
  const MuscleVolumeBars({required this.data, super.key});

  final List<MuscleVolume> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Text('Sem volume registrado ainda.', style: AppTypography.caption);
    }
    final max = data.first.volume == 0 ? 1.0 : data.first.volume;
    final top = data.take(6).toList();

    return Column(
      children: [
        for (final m in top)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(m.muscle,
                      style: AppTypography.small, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (m.volume / max).clamp(0.05, 1.0),
                      minHeight: 10,
                      backgroundColor: AppColors.card,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${m.volume.toStringAsFixed(0)}',
                    style: AppTypography.small),
              ],
            ),
          ),
      ],
    );
  }
}
