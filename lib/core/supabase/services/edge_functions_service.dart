import 'package:supabase_flutter/supabase_flutter.dart';

import '../../logger/app_logger.dart';
import '../supabase_client.dart';
import '../supabase_exceptions.dart';

/// Serviço para consumir Supabase Edge Functions — estrutura
/// preparada (PROMPT 01), ainda sem chamadas de produção.
///
/// As funções previstas (09_SUPABASE_SQL.md): criar treino com IA,
/// responder perguntas, analisar medidas/fotos, gerar insights,
/// comparar evolução, notificações. A camada de IA da feature `ai`
/// consumirá este serviço através de suas abstrações.
abstract interface class IEdgeFunctionsService {
  Future<Map<String, dynamic>> invoke(
    String functionName, {
    Map<String, dynamic>? body,
  });
}

final class SupabaseEdgeFunctionsService implements IEdgeFunctionsService {
  const SupabaseEdgeFunctionsService();

  @override
  Future<Map<String, dynamic>> invoke(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    try {
      AppLogger.d('[EdgeFn] invoke $functionName');
      final response = await VisSupabase.client.functions.invoke(
        functionName,
        body: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {'data': data};
    } catch (e, st) {
      AppLogger.e('[EdgeFn] $functionName falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }
}
