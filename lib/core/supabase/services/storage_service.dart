import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../logger/app_logger.dart';
import '../supabase_client.dart';
import '../supabase_exceptions.dart';

/// Interface do serviço de Storage (buckets privados + URLs assinadas).
///
/// PROMPT 01: estrutura preparada, ainda sem upload de produção.
abstract interface class IStorageService {
  Future<String> uploadBinary(
    String bucket,
    String path,
    Uint8List bytes, {
    String? contentType,
    bool upsert,
  });

  Future<String> createSignedUrl(
    String bucket,
    String path, {
    int expiresInSeconds,
  });

  Future<void> remove(String bucket, List<String> paths);
}

final class SupabaseStorageService implements IStorageService {
  const SupabaseStorageService();

  SupabaseStorageClient get _storage => VisSupabase.storage;

  @override
  Future<String> uploadBinary(
    String bucket,
    String path,
    Uint8List bytes, {
    String? contentType,
    bool upsert = false,
  }) async {
    try {
      final result = await _storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: upsert),
          );
      AppLogger.d('[Storage] upload $bucket/$path');
      return result;
    } catch (e, st) {
      AppLogger.e('[Storage] upload falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<String> createSignedUrl(
    String bucket,
    String path, {
    int expiresInSeconds = 3600,
  }) async {
    try {
      return await _storage.from(bucket).createSignedUrl(path, expiresInSeconds);
    } catch (e, st) {
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<void> remove(String bucket, List<String> paths) async {
    try {
      await _storage.from(bucket).remove(paths);
    } catch (e, st) {
      throw SupabaseErrorMapper.map(e, st);
    }
  }
}
