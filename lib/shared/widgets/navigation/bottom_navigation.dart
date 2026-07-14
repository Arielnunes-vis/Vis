import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';

/// Item da barra de navegação inferior.
class VisNavItem {
  const VisNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Bottom Navigation fixa de 5 abas (06_UI_UX_SPECIFICATION.md).
///
/// Dashboard · Treinos · Biblioteca · Evolução · Perfil.
/// Nunca usar menu lateral.
class VisBottomNavigation extends StatelessWidget {
  const VisBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<VisNavItem> items = [
    VisNavItem(icon: LucideIcons.home, label: 'Dashboard'),
    VisNavItem(icon: LucideIcons.dumbbell, label: 'Treinos'),
    VisNavItem(icon: LucideIcons.library, label: 'Biblioteca'),
    VisNavItem(icon: LucideIcons.trendingUp, label: 'Evolução'),
    VisNavItem(icon: LucideIcons.user, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon, color: AppColors.textSecondary),
              selectedIcon: Icon(item.icon, color: AppColors.primary),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
