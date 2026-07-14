/// Dados coletados no onboarding (PROMPT 03).
///
/// Imutável, com [copyWith]. Alimenta perfil, Dashboard, gerador de
/// treino e a IA. Os grupos [UserGoals], [TrainingProfile],
/// [EquipmentProfile] e [RestrictionsProfile] são recortes usados na
/// persistência e na montagem do contexto da IA.
class OnboardingData {
  const OnboardingData({
    this.goals = const [],
    this.sex,
    this.age,
    this.height,
    this.weight,
    this.experience,
    this.trainingDays,
    this.timePerWorkout,
    this.location,
    this.equipment = const [],
    this.restrictions = '',
    this.preferences = '',
  });

  final List<String> goals;
  final String? sex;
  final int? age;
  final double? height;
  final double? weight;
  final String? experience;
  final int? trainingDays;
  final int? timePerWorkout;
  final String? location;
  final List<String> equipment;
  final String restrictions;
  final String preferences;

  OnboardingData copyWith({
    List<String>? goals,
    String? sex,
    int? age,
    double? height,
    double? weight,
    String? experience,
    int? trainingDays,
    int? timePerWorkout,
    String? location,
    List<String>? equipment,
    String? restrictions,
    String? preferences,
  }) {
    return OnboardingData(
      goals: goals ?? this.goals,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      experience: experience ?? this.experience,
      trainingDays: trainingDays ?? this.trainingDays,
      timePerWorkout: timePerWorkout ?? this.timePerWorkout,
      location: location ?? this.location,
      equipment: equipment ?? this.equipment,
      restrictions: restrictions ?? this.restrictions,
      preferences: preferences ?? this.preferences,
    );
  }

  UserGoals get userGoals => UserGoals(goals);
  TrainingProfile get trainingProfile => TrainingProfile(
        experience: experience,
        trainingDays: trainingDays,
        timePerWorkout: timePerWorkout,
        location: location,
      );
  EquipmentProfile get equipmentProfile => EquipmentProfile(equipment);
  RestrictionsProfile get restrictionsProfile =>
      RestrictionsProfile(restrictions: restrictions, preferences: preferences);

  /// Serializa para persistência / contexto da IA.
  Map<String, dynamic> toMap() => {
        'goals': goals,
        'sex': sex,
        'age': age,
        'height': height,
        'weight': weight,
        'experience_level': experience,
        'training_days': trainingDays,
        'time_per_workout': timePerWorkout,
        'training_location': location,
        'equipment': equipment,
        'restrictions': restrictions,
        'preferences': preferences,
      };
}

class UserGoals {
  const UserGoals(this.goals);
  final List<String> goals;
}

class TrainingProfile {
  const TrainingProfile({
    this.experience,
    this.trainingDays,
    this.timePerWorkout,
    this.location,
  });
  final String? experience;
  final int? trainingDays;
  final int? timePerWorkout;
  final String? location;
}

class EquipmentProfile {
  const EquipmentProfile(this.equipment);
  final List<String> equipment;
}

class RestrictionsProfile {
  const RestrictionsProfile({this.restrictions = '', this.preferences = ''});
  final String restrictions;
  final String preferences;
}

/// Alias de compatibilidade com a nomenclatura da documentação
/// (03_PROMPT / `OnboardingModel`). O modelo canônico é [OnboardingData].
typedef OnboardingModel = OnboardingData;
