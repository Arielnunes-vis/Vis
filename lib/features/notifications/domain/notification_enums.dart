/// Enums do módulo de notificações (PROMPT 15).

/// Categoria (origem) da notificação.
enum NotificationCategory {
  workout('Treino'),
  cardio('Cardio'),
  nutrition('Nutrição'),
  water('Água'),
  weight('Peso'),
  measurements('Medidas'),
  photos('Fotos'),
  goals('Metas'),
  ai('IA'),
  system('Sistema');

  const NotificationCategory(this.label);
  final String label;
}

/// Tipo da notificação.
enum NotificationType {
  reminder('Lembrete'),
  alert('Alerta'),
  summary('Resumo'),
  achievement('Conquista'),
  goal('Meta'),
  info('Informação'),
  warning('Aviso');

  const NotificationType(this.label);
  final String label;
}

/// Prioridade.
enum NotificationPriority { low, medium, high, critical }

/// Ação vinculada a uma notificação (deep link interno).
enum NotificationAction {
  openDashboard,
  startWorkout,
  logWater,
  logWeight,
  openCardio,
  openNutrition,
  none;

  static NotificationAction fromName(String? name) =>
      NotificationAction.values.firstWhere(
        (a) => a.name == name,
        orElse: () => NotificationAction.none,
      );
}
