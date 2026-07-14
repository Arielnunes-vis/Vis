import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../controllers/authentication_controller.dart';
import '../data/authentication_repository_impl.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../repositories/authentication_repository.dart';
import '../services/authentication_service.dart';

/// Providers do módulo de autenticação (PROMPT 02).

final authenticationServiceProvider = Provider<AuthenticationService>(
  (ref) => SupabaseAuthenticationService(ref.watch(authServiceProvider)),
);

final authenticationRepositoryProvider = Provider<AuthenticationRepository>(
  (ref) =>
      AuthenticationRepositoryImpl(ref.watch(authenticationServiceProvider)),
);

final authenticationControllerProvider =
    NotifierProvider<AuthenticationController, AuthState>(
  AuthenticationController.new,
);

/// Emite o usuário atual conforme mudanças de sessão do Supabase.
final currentUserProvider = StreamProvider<UserModel?>(
  (ref) => ref.watch(authenticationRepositoryProvider).userChanges,
);
