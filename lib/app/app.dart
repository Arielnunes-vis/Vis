import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/supabase/supabase_provider.dart';
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
  ProviderSubscription<AsyncValue<AuthState>>? _authSub;

  @override
  void initState() {
    super.initState();
    // O bootstrap (Supabase/Hive/env) já ocorreu em main(); liberamos
    // o roteamento após o primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routerNotifierProvider).setReady();
      // Inicia a sincronização offline -> nuvem (PROMPT 01).
      ref.read(syncManagerProvider).start();
    });
    // Dispara a sincronização do peso sempre que houver uma sessão
    // autenticada: `fireImmediately` cobre quem já abre o app logado
    // (ex.: Safari com sessão salva); o listener em si cobre quem loga
    // DEPOIS de abrir o app (ex.: atalho novo, sem sessão anterior) —
    // sem isso, um atalho recém-criado nunca chegava a sincronizar,
    // porque o login acontece depois do primeiro frame do app.
    _authSub = ref.listenManual(
      supabaseAuthStateProvider,
      (previous, next) {
        if (next.value?.session != null) {
          // ignore: discarded_futures
          _bootstrapWeightSync();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _authSub?.close();
    super.dispose();
  }

  /// Alinha o histórico de peso com a nuvem nos dois sentidos: primeiro
  /// baixa o que já existe no Supabase (para um aparelho/atalho novo que
  /// ainda não tem nada salvo localmente), depois envia o que só existe
  /// neste aparelho (para o caso de ter sido criado antes da sincronização
  /// existir, ou enquanto estava offline).
  Future<void> _bootstrapWeightSync() async {
    final repo = ref.read(bodyProgressRepositoryProvider);
    await repo.restoreWeightHistory();
    await repo.syncWeightHistory();
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
