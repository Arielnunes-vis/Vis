import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/graphs_tab.dart';
import '../widgets/measurements_tab.dart';
import '../widgets/photos_tab.dart';
import '../widgets/weight_tab.dart';

/// Evolução corporal — peso, medidas, fotos e gráficos (PROMPT 08).
class BodyProgressScreen extends StatelessWidget {
  const BodyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Evolução'),
          actions: [
            IconButton(
              tooltip: 'Estatísticas',
              icon: const Icon(LucideIcons.barChart3),
              onPressed: () => context.pushNamed('analytics'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Peso'),
              Tab(text: 'Medidas'),
              Tab(text: 'Fotos'),
              Tab(text: 'Gráficos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WeightTab(),
            MeasurementsTab(),
            PhotosTab(),
            GraphsTab(),
          ],
        ),
      ),
    );
  }
}
