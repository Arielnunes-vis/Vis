import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/navigation/bottom_navigation.dart';

/// Casca das abas principais com a Bottom Navigation fixa
/// (06_UI_UX_SPECIFICATION.md — 5 abas, sempre visível).
///
/// Usada pela [StatefulShellRoute]; preserva o estado de cada aba
/// (IndexedStack) ao alternar.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: VisBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Toca de novo na aba atual → volta à raiz daquela aba.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
