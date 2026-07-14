import '../exceptions/app_exception.dart';
import 'network_info.dart';

/// Utilitário de alto nível para checagens pontuais de conexão.
///
/// A observação contínua fica no provider (`connection_provider.dart`);
/// aqui expomos apenas verificações sob demanda, úteis antes de
/// operações que exigem internet (ex.: login, sincronização).
final class ConnectionChecker {
  const ConnectionChecker(this._networkInfo);

  final INetworkInfo _networkInfo;

  Future<bool> hasConnection() => _networkInfo.isConnected;

  /// Lança [NetworkException] quando não há conexão.
  Future<void> requireConnection() async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      throw NetworkException.offline();
    }
  }
}
