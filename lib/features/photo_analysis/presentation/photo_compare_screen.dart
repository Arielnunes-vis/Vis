import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../body_progress/domain/body_enums.dart';
import '../providers/photo_providers.dart';
import '../widgets/before_after_slider.dart';

/// Comparação antes/depois de uma pose (PROMPT 13).
class PhotoCompareScreen extends ConsumerWidget {
  const PhotoCompareScreen({required this.pose, super.key});

  final PhotoType pose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Considera apenas fotos com imagem disponível localmente, para que
    // `first`/`last` sejam sempre válidas no slider (evita null-check crash).
    final photos = ref
        .watch(photoControllerProvider)
        .where((p) => p.type == pose && p.displayPath != null)
        .toList()
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    return Scaffold(
      appBar: AppBar(title: Text('Comparar · ${pose.label}')),
      body: photos.length < 2
          ? const EmptyState(
              icon: LucideIcons.arrowLeftRight,
              title: 'Fotos insuficientes',
              description: 'Adicione ao menos duas fotos desta pose.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                BeforeAfterSlider(
                  beforePath: photos.first.displayPath!,
                  afterPath: photos.last.displayPath!,
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_date(photos.first.takenAt),
                        style: AppTypography.small),
                    Text(_date(photos.last.takenAt),
                        style: AppTypography.small),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                CardContainer(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: null, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A análise por IA (definição, simetria, evolução por '
                          'região) será gerada aqui após o upload das fotos.',
                          style: AppTypography.small,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
