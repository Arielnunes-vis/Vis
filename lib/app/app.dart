import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
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
