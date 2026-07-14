import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

/// Cabeçalho + cartão agrupando um conjunto de opções de configuração.
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.xs, bottom: AppSpacing.s),
          child: Text(title,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary)),
        ),
        CardContainer(
          padding: EdgeInsets.zero,
          child: Column(children: _withDividers(children)),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(const Divider(height: 1, color: AppColors.divider));
      }
    }
    return out;
  }
}

/// Linha de configuração: ícone, título, subtítulo e trailing/ação.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m, vertical: AppSpacing.m),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: AppTypography.small
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.s),
              trailing!,
            ] else if (onTap != null)
              const Icon(LucideIcons.chevronRight,
                  size: 18, color: AppColors.disabled),
          ],
        ),
      ),
    );
  }
}
