import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acesso centralizado e tipado às variáveis de ambiente.
///
/// Todas as chaves são carregadas do arquivo `.env` via [dotenv]
/// (ver [Env.load]). Nenhum valor sensível deve ser hardcoded no
/// código (10_DEVELOPMENT_RULES.md — Regra 12).
///
/// Uso:
/// ```dart
/// await Env.load();
/// final url = Env.supabaseUrl;
/// ```
abstract final class Env {
  const Env._();

  /// Carrega o arquivo `.env`. Deve ser chamado uma única vez no
  /// bootstrap do app, antes de inicializar o Supabase.
  static Future<void> load({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  static String _require(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        'Variável de ambiente ausente: "$key". '
        'Verifique se o arquivo .env foi criado a partir de .env.example.',
      );
    }
    return value;
  }

  static String _optional(String key, {String fallback = ''}) {
    return dotenv.maybeGet(key) ?? fallback;
  }

  // ----- Supabase -----
  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  // ----- OpenAI (via Edge Functions) -----
  static String get openAiApiUrl => _optional('OPENAI_API_URL');
  static String get openAiModel => _optional('OPENAI_MODEL', fallback: 'gpt-4o-mini');

  /// Indica se as variáveis mínimas necessárias estão presentes.
  static bool get isConfigured {
    final url = dotenv.maybeGet('SUPABASE_URL');
    final key = dotenv.maybeGet('SUPABASE_ANON_KEY');
    return url != null && url.isNotEmpty && key != null && key.isNotEmpty;
  }
}
