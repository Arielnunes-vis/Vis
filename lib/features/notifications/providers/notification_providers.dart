import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../controllers/notification_controller.dart';
import '../data/notification_repository_impl.dart';
import '../repositories/notification_repository.dart';
import '../services/local_notification_service.dart';
import '../services/push_notification_service.dart';

/// Re-exporta o contrato para consumidores do controller.
export '../repositories/notification_repository.dart'
    show NotificationRepository;

/// Providers do módulo de notificações (PROMPT 15).

final localNotificationServiceProvider = Provider<ILocalNotificationService>(
  (ref) => LocalNotificationService(),
);

/// Push preparado para FCM/APNS — stub por enquanto.
final pushNotificationServiceProvider = Provider<IPushNotificationService>(
  (ref) => const NoopPushNotificationService(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    local: ref.watch(localNotificationServiceProvider),
    storage: const LocalStorageService(),
  ),
);

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);
