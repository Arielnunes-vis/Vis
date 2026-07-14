import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Barra de progresso arredondada padrão do VIS.
///
/// Centraliza o padrão `ClipRRect + LinearProgressIndicator` repetido em
/// Dashboard, Nutrição e Analytics (Regra 002 — não duplicar). O valor é
/// limitado a 0..1 defensivamente.
class VisProgressBar extends StatelessWidget {
  const VisProgressBar({
    required this.value,
    this.color = AppColors.primary,
    this.background = AppColors.card,
    this.height = 8,
    super.key,
  });

  final double value;
  final Color color;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: background,
        color: color,
      ),
    );
  }
}
