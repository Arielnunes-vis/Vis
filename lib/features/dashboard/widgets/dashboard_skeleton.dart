import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Skeleton do Dashboard — nunca tela branca (07_DESIGN_SYSTEM.md).
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: const [
        _Box(height: 88),
        SizedBox(height: AppSpacing.m),
        _Box(height: 120),
        SizedBox(height: AppSpacing.m),
        _Box(height: 80),
        SizedBox(height: AppSpacing.m),
        _Box(height: 140),
        SizedBox(height: AppSpacing.m),
        _Box(height: 160),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
