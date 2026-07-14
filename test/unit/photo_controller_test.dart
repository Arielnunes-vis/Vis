import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/authentication/models/user_model.dart';
import 'package:vis/features/authentication/providers/authentication_providers.dart';
import 'package:vis/features/authentication/repositories/authentication_repository.dart';
import 'package:vis/features/body_progress/data/body_progress_repository_impl.dart';
import 'package:vis/features/body_progress/domain/body_enums.dart';
import 'package:vis/features/body_progress/domain/body_progress_local_store.dart';
import 'package:vis/features/body_progress/providers/body_progress_providers.dart';
import 'package:vis/features/photo_analysis/providers/photo_providers.dart';
import 'package:vis/features/photo_analysis/services/photo_capture_service.dart';

class _InMemBodyStore implements BodyProgressLocalStore {
  final Map<String, List<Map<String, dynamic>>> d = {};
  @override
  List<Map<String, dynamic>> read(String u, String c) => d['$u/$c'] ?? const [];
  @override
  Future<void> write(String u, String c, List<Map<String, dynamic>> i) async =>
      d['$u/$c'] = i;
}

class _FakeCapture implements IPhotoCaptureService {
  @override
  Future<String?> capture(PhotoSourceKind source) async => '/tmp/photo.jpg';
}

class _FakeAuth implements AuthenticationRepository {
  @override
  UserModel? get currentUser => const UserModel(id: 'u1', email: 'a@b.c');
  @override
  Stream<UserModel?> get userChanges => const Stream.empty();
  @override
  Future<UserModel> login({required String email, required String password}) =>
      throw UnimplementedError();
  @override
  Future<UserModel?> register(
          {required String email,
          required String password,
          required String name}) =>
      throw UnimplementedError();
  @override
  Future<void> logout() async {}
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  Future<void> resendConfirmation(String email) async {}
  @override
  Future<UserModel?> refreshSession() async => null;
  @override
  Future<UserModel?> updateProfile({String? name, String? photoUrl}) async =>
      null;
  @override
  Future<void> deleteAccount() async {}
}

void main() {
  test('capturar registra a foto na pose e persiste o caminho', () async {
    final container = ProviderContainer(overrides: [
      bodyProgressRepositoryProvider.overrideWithValue(
        BodyProgressRepositoryImpl(
            store: _InMemBodyStore(), currentUserId: () => 'u1'),
      ),
      photoCaptureServiceProvider.overrideWithValue(_FakeCapture()),
      authenticationRepositoryProvider.overrideWithValue(_FakeAuth()),
    ]);
    addTearDown(container.dispose);

    final ctrl = container.read(photoControllerProvider.notifier);
    final ok = await ctrl.capture(
      type: PhotoType.frontRelaxed,
      source: PhotoSourceKind.gallery,
    );

    expect(ok, isTrue);
    final state = container.read(photoControllerProvider);
    expect(state.length, 1);
    expect(state.first.localPath, '/tmp/photo.jpg');
    expect(ctrl.ofType(PhotoType.frontRelaxed).length, 1);
  });
}
