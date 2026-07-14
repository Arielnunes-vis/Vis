import 'package:supabase_flutter/supabase_flutter.dart';

import '../../logger/app_logger.dart';
import '../supabase_client.dart';
import '../supabase_exceptions.dart';

/// Interface do serviço de banco de dados (acesso PostgREST).
///
/// Fornece operações genéricas de CRUD que os repositórios de cada
/// feature reutilizam. Regra 001/003: nunca sobrescrever histórico —
/// os repositórios devem preferir INSERT a UPDATE quando aplicável.
abstract interface class IDatabaseService {
  SupabaseQueryBuilder from(String table);

  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
  });

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> values,
  );

  Future<Map<String, dynamic>> update(
    String table,
    Map<String, dynamic> values, {
    required String id,
  });

  /// Soft delete (23_DEVELOPMENT_RULES / 09_SUPABASE) — nunca DELETE físico.
  Future<void> softDelete(String table, {required String id});
}

final class SupabaseDatabaseService implements IDatabaseService {
  const SupabaseDatabaseService();

  SupabaseClient get _client => VisSupabase.client;

  @override
  SupabaseQueryBuilder from(String table) => _client.from(table);

  @override
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
  }) async {
    try {
      final data = await _client.from(table).select(columns);
      return List<Map<String, dynamic>>.from(data);
    } catch (e, st) {
      AppLogger.e('[DB] select $table falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> values,
  ) async {
    try {
      final data = await _client.from(table).insert(values).select().single();
      return data;
    } catch (e, st) {
      AppLogger.e('[DB] insert $table falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<Map<String, dynamic>> update(
    String table,
    Map<String, dynamic> values, {
    required String id,
  }) async {
    try {
      final data =
          await _client.from(table).update(values).eq('id', id).select().single();
      return data;
    } catch (e, st) {
      AppLogger.e('[DB] update $table falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<void> softDelete(String table, {required String id}) async {
    try {
      await _client
          .from(table)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e, st) {
      AppLogger.e('[DB] softDelete $table falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }
}
