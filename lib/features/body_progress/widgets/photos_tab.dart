import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/body_enums.dart';
import '../providers/body_progress_providers.dart';

/// Aba de fotos de progresso (PROMPT 08).
///
/// A captura/compressão/upload real (câmera + Supabase Storage) entra na
/// integração de mídia. Esta aba já organiza as poses e o histórico.
class PhotosTab extends ConsumerWidget {
  const PhotosTab({super.key});

  static const _poses = [
    PhotoType.frontRelaxed,
    PhotoType.frontFlexed,
    PhotoType.sideRight,
    PhotoType.sideLeft,
    PhotoType.backRelaxed,
    PhotoType.backFlexed,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(bodyProgressRepositoryProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        PrimaryButton(
          label: 'Abrir galeria de fotos',
          icon: LucideIcons.camera,
          onPressed: () => context.pushNamed('photos'),
        ),
        const SizedBox(height: AppSpacing.m),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.m,
          childAspectRatio: 4 / 5,
          children: [
            for (final pose in _poses)
              _PoseSlot(
                label: pose.label,
                count: repo.photos(type: pose).length,
              ),
          ],
        ),
      ],
    );
  }
}

class _PoseSlot extends StatelessWidget {
  const _PoseSlot({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.imagePlus, color: AppColors.disabled),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.small, textAlign: TextAlign.center),
          Text('$count foto(s)', style: AppTypography.small),
        ],
      ),
    );
  }
}
