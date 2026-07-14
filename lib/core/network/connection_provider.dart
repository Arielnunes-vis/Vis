import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_checker.dart';
import 'network_info.dart';

/// Providers de conectividade (PROMPT 01).

final networkInfoProvider = Provider<INetworkInfo>((ref) => NetworkInfo());

final connectionCheckerProvider = Provider<ConnectionChecker>(
  (ref) => ConnectionChecker(ref.watch(networkInfoProvider)),
);

/// Estado observável da conexão. Começa em [ConnectionStatus.connecting]
/// e emite atualizações em tempo real.
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final info = ref.watch(networkInfoProvider);
  return info.onStatusChange;
});

/// Conveniência: `true` quando há internet efetiva.
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectionStatusProvider).value;
  return status == ConnectionStatus.online;
});
