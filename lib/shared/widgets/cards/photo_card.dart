import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Card de foto de progresso (proporção 4:5 — 07_DESIGN_SYSTEM.md).
class PhotoCard extends StatelessWidget {
  const PhotoCard({
    required this.imageUrl,
    this.label,
    this.onTap,
    super.key,
  });

  final String imageUrl;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                  : Container(color: AppColors.elevated),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(label!, style: AppTypography.small),
          ],
        ],
      ),
    );
  }
}
