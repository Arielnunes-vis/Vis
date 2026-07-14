import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Avatar circular com fallback para iniciais.
class Avatar extends StatelessWidget {
  const Avatar({this.imageUrl, this.name, this.size = 64, super.key});

  final String? imageUrl;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _fallback(),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    final initials = (name ?? '?')
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
    return Container(
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTypography.subtitle.copyWith(fontSize: size * 0.34),
      ),
    );
  }
}
