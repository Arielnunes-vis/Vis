/// Opções fixas de cada passo do onboarding (PROMPT 03).
///
/// Centralizadas para reutilização e para manter os textos (em
/// português) separados da lógica.
abstract final class OnboardingOptions {
  const OnboardingOptions._();

  static const List<String> goals = [
    'Ganhar massa muscular',
    'Perder gordura',
    'Recomposição corporal',
    'Melhorar condicionamento',
    'Força',
    'Saúde',
    'Outro',
  ];

  static const List<String> sex = [
    'Masculino',
    'Feminino',
    'Homem Trans',
    'Mulher Trans',
    'Prefiro não informar',
    'Outro',
  ];

  static const List<String> experience = [
    'Nunca treinei',
    'Iniciante',
    'Intermediário',
    'Avançado',
  ];

  static const List<int> days = [1, 2, 3, 4, 5, 6, 7];

  static const List<int> timePerWorkout = [30, 45, 60, 75, 90];

  static const List<String> location = ['Academia', 'Casa', 'Ambos'];

  static const List<String> equipment = [
    'Máquinas',
    'Halteres',
    'Barra',
    'Smith',
    'Cabos',
    'Banco',
    'Peso corporal',
    'Elásticos',
    'Kettlebell',
    'TRX',
    'Outros',
  ];

  static const int totalSteps = 12;
}
