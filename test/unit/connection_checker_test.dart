import 'package:flutter_test/flutter_test.dart';
import 'package:vis/core/exceptions/app_exception.dart';
import 'package:vis/core/network/connection_checker.dart';
import 'package:vis/core/network/network_info.dart';

/// Fake controlável de conectividade.
class FakeNetworkInfo implements INetworkInfo {
  FakeNetworkInfo(this.connected);
  bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<ConnectionStatus> get onStatusChange => Stream.value(
        connected ? ConnectionStatus.online : ConnectionStatus.noInternet,
      );
}

void main() {
  group('ConnectionChecker', () {
    test('hasConnection reflete o estado da rede', () async {
      expect(await ConnectionChecker(FakeNetworkInfo(true)).hasConnection(),
          isTrue);
      expect(await ConnectionChecker(FakeNetworkInfo(false)).hasConnection(),
          isFalse);
    });

    test('requireConnection não lança quando online', () async {
      final checker = ConnectionChecker(FakeNetworkInfo(true));
      await expectLater(checker.requireConnection(), completes);
    });

    test('requireConnection lança NetworkException quando offline', () async {
      final checker = ConnectionChecker(FakeNetworkInfo(false));
      await expectLater(
        checker.requireConnection(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
