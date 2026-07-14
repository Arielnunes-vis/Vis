/// Contexto do usuário enviado à IA antes de qualquer resposta.
///
/// Regra 026 / 05_AI_ENGINE.md: a IA NUNCA responde só com a pergunta —
/// primeiro consulta perfil, treinos, histórico, peso, medidas, fotos,
/// cardio, objetivos e preferências. Este objeto agrega esse contexto.
///
/// A montagem efetiva (a partir dos repositórios e da view SQL
/// `ai_context`) será implementada quando os módulos de dados
/// existirem. Aqui fica o contrato.
class AIContext {
  const AIContext({
    this.profile = const {},
    this.goals = const {},
    this.workouts = const [],
    this.weightHistory = const [],
    this.measurements = const [],
    this.cardio = const [],
    this.personalRecords = const [],
    this.equipment = const [],
    this.preferences = const {},
  });

  final Map<String, dynamic> profile;
  final Map<String, dynamic> goals;
  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> weightHistory;
  final List<Map<String, dynamic>> measurements;
  final List<Map<String, dynamic>> cardio;
  final List<Map<String, dynamic>> personalRecords;
  final List<String> equipment;
  final Map<String, dynamic> preferences;

  /// Serializa no formato consumido pela Edge Function de IA.
  Map<String, dynamic> toJson() => {
        'profile': profile,
        'goals': goals,
        'workouts': workouts,
        'weight_history': weightHistory,
        'measurements': measurements,
        'cardio': cardio,
        'personal_records': personalRecords,
        'equipment': equipment,
        'preferences': preferences,
      };

  bool get isEmpty =>
      profile.isEmpty && workouts.isEmpty && measurements.isEmpty;
}
