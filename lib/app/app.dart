import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/sync/sync_manager.dart';
import '../core/theme/app_theme.dart';
import '../features/body_progress/providers/body_progress_providers.dart';
import 'router.dart';

/// Widget raiz do VIS.
///
/// Configura o MaterialApp.router com o tema Dark próprio e o GoRouter.
/// Sinaliza ao [RouterNotifier] que o bootstrap terminou (sai do splash).
class VisApp extends ConsumerStatefulWidget {
  const VisApp({super.key});

  @override
  ConsumerState<VisApp> createState() => _VisAppState();
}

class _VisAppState extends ConsumerState<VisApp> {
  @override
  void initState() {
    super.initState();
    // O bootstrap (Supabase/Hive/env) já ocorreu em main(); liberamos
    // o roteamento após o primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routerNotifierProvider).setReady();
      // Inicia a sincronização offline -> nuvem (PROMPT 01) e garante que
      // o histórico de peso já salvo neste aparelho suba para o Supabase
      // (para aparecer também em outros lugares, como o atalho na tela
      // inicial do iPhone).
      ref.read(syncManagerProvider).start();
      // ignore: discarded_futures
      ref.read(bodyProgressRepositoryProvider).syncWeightHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
