import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/logger/app_logger.dart';
import 'core/storage/local_storage_service.dart';
import 'core/supabase/supabase_client.dart';
import 'core/theme/app_theme.dart';

/// Ponto de entrada do VIS.
///
/// Ordem do bootstrap:
/// 1. Bindings do Flutter
/// 2. Variáveis de ambiente (.env)
/// 3. Supabase (cliente único)
/// 4. Hive (armazenamento local / offline)
/// 5. runApp dentro do ProviderScope
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);

  try {
    await Env.load();
    await VisSupabase.initialize();
    await LocalStorageService.initialize();
  } catch (e, st) {
    // Falha de bootstrap não deve travar o binário silenciosamente.
    AppLogger.f('[Bootstrap] falhou', error: e, stackTrace: st);
  }

  runApp(const ProviderScope(child: VisApp()));
}
