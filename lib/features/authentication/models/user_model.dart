import 'package:equatable/equatable.dart';

/// Usuário autenticado (dados básicos vindos do Supabase Auth).
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.emailConfirmed = false,
  });

  final String id;
  final String email;
  final String? name;
  final bool emailConfirmed;

  factory UserModel.fromAuth({
    required String id,
    required String email,
    Map<String, dynamic>? metadata,
    bool emailConfirmed = false,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: metadata?['name'] as String?,
      emailConfirmed: emailConfirmed,
    );
  }

  @override
  List<Object?> get props => [id, email, name, emailConfirmed];
}

/// Perfil estendido do usuário (tabela `users` — 03_DATABASE.md).
///
/// Preenchido no onboarding e no perfil. Aqui fica apenas o modelo;
/// a persistência é responsabilidade dos respectivos módulos.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    this.photoUrl,
    this.birthDate,
    this.height,
    this.currentWeight,
    this.goal,
    this.experienceLevel,
    this.trainingLocation,
    this.onboardingCompleted = false,
  });

  final String id;
  final String? photoUrl;
  final DateTime? birthDate;
  final double? height;
  final double? currentWeight;
  final String? goal;
  final String? experienceLevel;
  final String? trainingLocation;
  final bool onboardingCompleted;

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] as String,
        photoUrl: map['photo_url'] as String?,
        birthDate: map['birth_date'] != null
            ? DateTime.tryParse(map['birth_date'] as String)
            : null,
        height: (map['height'] as num?)?.toDouble(),
        currentWeight: (map['current_weight'] as num?)?.toDouble(),
        goal: map['goal'] as String?,
        experienceLevel: map['experience_level'] as String?,
        trainingLocation: map['training_location'] as String?,
        onboardingCompleted: (map['onboarding_completed'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [id, onboardingCompleted, goal, experienceLevel];
}
