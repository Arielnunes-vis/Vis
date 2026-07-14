import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../common/card_container.dart';

/// Card de exercício: miniatura, nome, equipamento e grupo muscular.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.name,
    required this.muscle,
    required this.equipment,
    this.imageUrl,
    this.onTap,
    this.trailing,
    super.key,
  });

  final String name;
  final String muscle;
  final String equipment;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
                  : Container(color: AppColors.elevated),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$muscle · $equipment', style: AppTypography.small),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
