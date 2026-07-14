import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/logger/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../body_progress/domain/body_enums.dart';
import '../../body_progress/models/body_photo.dart';
import '../providers/photo_providers.dart';
import '../services/photo_capture_service.dart';

/// Galeria de fotos de progresso por pose (PROMPT 13).
class PhotosGalleryScreen extends ConsumerWidget {
  const PhotosGalleryScreen({super.key});

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
    final photos = ref.watch(photoControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fotos de progresso')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSheet(context, ref),
        icon: const Icon(LucideIcons.camera),
        label: const Text('Adicionar foto'),
      ),
      body: photos.isEmpty
          ? const EmptyState(
              icon: LucideIcons.camera,
              title: 'Nenhuma foto ainda',
              description:
                  'Adicione fotos das poses para acompanhar a evolução.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                for (final pose in _poses)
                  _PoseSection(
                    pose: pose,
                    photos:
                        photos.where((p) => p.type == pose).toList(),
                  ),
              ],
            ),
    );
  }

  Future<void> _addSheet(BuildContext context, WidgetRef ref) async {
    PhotoType selected = PhotoType.frontRelaxed;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adicionar foto', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.m),
              Text('Pose', style: AppTypography.caption),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _poses)
                    VisChip(
                      label: p.label,
                      selected: selected == p,
                      onTap: () => setModal(() => selected = p),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Galeria',
                      icon: LucideIcons.image,
                      onPressed: () => _capture(
                          ctx, ref, selected, PhotoSourceKind.gallery),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Câmera',
                      icon: LucideIcons.camera,
                      onPressed: () => _capture(
                          ctx, ref, selected, PhotoSourceKind.camera),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capture(
    BuildContext ctx,
    WidgetRef ref,
    PhotoType type,
    PhotoSourceKind source,
  ) async {
    Navigator.pop(ctx);
    try {
      await ref
          .read(photoControllerProvider.notifier)
          .capture(type: type, source: source);
    } catch (e, st) {
      AppLogger.e('[Photos] falha ao capturar imagem',
          error: e, stackTrace: st);
      if (ctx.mounted) {
        AppSnackBar.show(ctx, 'Não foi possível acessar a imagem.',
            type: SnackType.error);
      }
    }
  }
}

class _PoseSection extends StatelessWidget {
  const _PoseSection({required this.pose, required this.photos});
  final PhotoType pose;
  final List<BodyPhoto> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(pose.label, style: AppTypography.subtitle)),
              if (photos.length >= 2)
                TextButton.icon(
                  icon: const Icon(LucideIcons.arrowLeftRight, size: 16),
                  label: const Text('Comparar'),
                  onPressed: () =>
                      context.pushNamed('photos-compare', extra: pose),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (_, i) {
                final p = photos[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: p.displayPath != null
                      ? Image.file(File(p.displayPath!),
                          width: 110, height: 140, fit: BoxFit.cover)
                      : Container(
                          width: 110,
                          height: 140,
                          color: AppColors.card,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
