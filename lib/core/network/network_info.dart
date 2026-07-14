import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Estado de conectividade observável pelo app (PROMPT 01).
enum ConnectionStatus { online, offline, connecting, noInternet }

/// Abstração de checagem de conectividade real (não apenas interface
/// de rede, mas acesso efetivo à internet).
abstract interface class INetworkInfo {
  Future<bool> get isConnected;
  Stream<ConnectionStatus> get onStatusChange;
}

final class NetworkInfo implements INetworkInfo {
  NetworkInfo({InternetConnection? checker})
      : _checker = checker ?? InternetConnection();

  final InternetConnection _checker;

  @override
  Future<bool> get isConnected => _checker.hasInternetAccess;

  @override
  Stream<ConnectionStatus> get onStatusChange =>
      _checker.onStatusChange.map(_map);

  ConnectionStatus _map(InternetStatus status) => switch (status) {
        InternetStatus.connected => ConnectionStatus.online,
        InternetStatus.disconnected => ConnectionStatus.noInternet,
      };
}
