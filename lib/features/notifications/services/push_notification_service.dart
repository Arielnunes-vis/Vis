import '../../../core/logger/app_logger.dart';

/// Serviço de Push Notifications (PROMPT 15).
///
/// ESTRUTURA PREPARADA para Firebase Cloud Messaging (Android) e
/// Apple Push Notification Service (iOS). O envio remoto NÃO é
/// implementado nesta etapa — apenas o contrato e um stub, para que o
/// app compile e a integração futura seja plugável.
abstract interface class IPushNotificationService {
  /// Inicializa o provedor de push e retorna o token do dispositivo.
  Future<String?> initialize();

  /// Registra o token no backend (tabela de dispositivos do usuário).
  Future<void> registerToken(String userId, String token);

  /// Remove o registro (logout).
  Future<void> unregister(String userId);

  Stream<Map<String, dynamic>> get onMessage;
}

/// Stub sem envio remoto. Substituível por uma implementação FCM/APNS
/// quando o Firebase for configurado no projeto.
final class NoopPushNotificationService implements IPushNotificationService {
  const NoopPushNotificationService();

  @override
  Future<String?> initialize() async {
    AppLogger.d('[Push] stub — FCM/APNS não configurado nesta versão.');
    return null;
  }

  @override
  Future<void> registerToken(String userId, String token) async {}

  @override
  Future<void> unregister(String userId) async {}

  @override
  Stream<Map<String, dynamic>> get onMessage => const Stream.empty();
}
