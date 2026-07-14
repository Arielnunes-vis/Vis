import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/notification_enums.dart';
import '../models/notification_model.dart';

/// Item do histórico de notificações (PROMPT 15).
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    this.onTap,
    super.key,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      color: notification.isRead ? AppColors.card : AppColors.elevated,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(notification.category),
              size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (!notification.isRead)
                      const _Dot(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(notification.body, style: AppTypography.caption),
                const SizedBox(height: 6),
                VisBadge(label: notification.category.label),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(NotificationCategory c) => switch (c) {
        NotificationCategory.workout => LucideIcons.dumbbell,
        NotificationCategory.cardio => LucideIcons.heartPulse,
        NotificationCategory.nutrition => LucideIcons.utensils,
        NotificationCategory.water => LucideIcons.droplet,
        NotificationCategory.weight => LucideIcons.scale,
        NotificationCategory.measurements => LucideIcons.ruler,
        NotificationCategory.photos => LucideIcons.camera,
        NotificationCategory.goals => LucideIcons.target,
        NotificationCategory.ai => LucideIcons.sparkles,
        NotificationCategory.system => LucideIcons.bell,
      };
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      );
}
