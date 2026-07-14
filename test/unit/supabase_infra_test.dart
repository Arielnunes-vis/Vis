import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:vis/core/exceptions/app_exception.dart';
import 'package:vis/core/supabase/services/auth_service.dart';
import 'package:vis/core/supabase/services/database_service.dart';
import 'package:vis/core/supabase/services/edge_functions_service.dart';
import 'package:vis/core/supabase/services/realtime_service.dart';
import 'package:vis/core/supabase/services/storage_service.dart';
import 'package:vis/core/supabase/supabase_exceptions.dart';
import 'package:vis/core/supabase/supabase_service.dart';

void main() {
  group('SupabaseService.production', () {
    test('conecta implementações concretas de cada serviço', () {
      final service = SupabaseService.production();
      expect(service.auth, isA<SupabaseAuthService>());
      expect(service.database, isA<SupabaseDatabaseService>());
      expect(service.storage, isA<SupabaseStorageService>());
      expect(service.realtime, isA<SupabaseRealtimeService>());
      expect(service.functions, isA<SupabaseEdgeFunctionsService>());
    });
  });

  group('SupabaseErrorMapper', () {
    test('AuthException do SDK vira AuthException do VIS', () {
      final mapped = SupabaseErrorMapper.map(
        sb.AuthException('Invalid login credentials'),
      );
      expect(mapped, isA<AuthException>());
      expect(mapped.message, 'E-mail ou senha incorretos.');
    });

    test('erro desconhecido vira UnknownException', () {
      final mapped = SupabaseErrorMapper.map(Exception('boom'));
      expect(mapped, isA<UnknownException>());
    });
  });

  group('RealtimeEvents', () {
    test('mapeia para PostgresChangeEvent', () {
      expect(RealtimeEvents.insert.change, sb.PostgresChangeEvent.insert);
      expect(RealtimeEvents.all.change, sb.PostgresChangeEvent.all);
    });
  });
}
