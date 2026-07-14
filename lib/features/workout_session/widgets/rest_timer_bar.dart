import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Barra de descanso exibida entre séries (PROMPT 06).
class RestTimerBar extends StatelessWidget {
  const RestTimerBar({
    required this.remaining,
    required this.total,
    required this.onAdjust,
    required this.onSkip,
    this.nextLabel,
    super.key,
  });

  final int remaining;
  final int total;
  final void Function(int delta) onAdjust;
  final VoidCallback onSkip;
  final String? nextLabel;

  String get _time {
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : remaining / total;
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.elevated,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.timer, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Descanso · $_time', style: AppTypography.subtitle),
                const Spacer(),
                if (nextLabel != null)
                  Flexible(
                    child: Text('Próximo: $nextLabel',
                        style: AppTypography.small,
                        overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: AppColors.card,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () => onAdjust(-15),
                    child: const Text('-15s')),
                TextButton(
                    onPressed: () => onAdjust(15), child: const Text('+15s')),
                TextButton(onPressed: onSkip, child: const Text('Pular')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
