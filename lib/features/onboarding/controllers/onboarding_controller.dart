import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/logger/app_logger.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../domain/onboarding_options.dart';
import '../models/onboarding_model.dart';
import '../providers/onboarding_providers.dart';

/// Estado do fluxo de onboarding.
class OnboardingState {
  const OnboardingState({
    this.step = 0,
    this.data = const OnboardingData(),
    this.isSaving = false,
    this.completed = false,
    this.error,
  });

  final int step;
  final OnboardingData data;
  final bool isSaving;
  final bool completed;
  final String? error;

  int get totalSteps => OnboardingOptions.totalSteps;
  bool get isFirst => step == 0;
  bool get isLast => step == totalSteps - 1;

  OnboardingState copyWith({
    int? step,
    OnboardingData? data,
    bool? isSaving,
    bool? completed,
    String? error,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      data: data ?? this.data,
      isSaving: isSaving ?? this.isSaving,
      completed: completed ?? this.completed,
      error: error,
    );
  }
}

/// Controller do onboarding (PROMPT 03). Nunca perde dados ao voltar.
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void next() {
    if (!state.isLast) state = state.copyWith(step: state.step + 1);
  }

  void back() {
    if (!state.isFirst) state = state.copyWith(step: state.step - 1);
  }

  void goTo(int step) => state = state.copyWith(step: step);

  void _update(OnboardingData data) => state = state.copyWith(data: data);

  void toggleGoal(String goal) {
    final goals = [...state.data.goals];
    goals.contains(goal) ? goals.remove(goal) : goals.add(goal);
    _update(state.data.copyWith(goals: goals));
  }

  void setSex(String value) => _update(state.data.copyWith(sex: value));
  void setAge(int? value) => _update(state.data.copyWith(age: value));
  void setHeight(double? value) => _update(state.data.copyWith(height: value));
  void setWeight(double? value) => _update(state.data.copyWith(weight: value));
  void setExperience(String v) => _update(state.data.copyWith(experience: v));
  void setDays(int v) => _update(state.data.copyWith(trainingDays: v));
  void setTime(int v) => _update(state.data.copyWith(timePerWorkout: v));
  void setLocation(String v) => _update(state.data.copyWith(location: v));

  void toggleEquipment(String item) {
    final list = [...state.data.equipment];
    list.contains(item) ? list.remove(item) : list.add(item);
    _update(state.data.copyWith(equipment: list));
  }

  void setRestrictions(String v) =>
      _update(state.data.copyWith(restrictions: v));
  void setPreferences(String v) =>
      _update(state.data.copyWith(preferences: v));

  /// Validação por passo (nenhum passo obrigatório vazio — PROMPT 03).
  bool canAdvance() {
    final d = state.data;
    return switch (state.step) {
      0 => true, // boas-vindas
      1 => d.goals.isNotEmpty,
      2 => d.sex != null,
      3 => d.age != null && d.height != null && d.weight != null,
      4 => d.experience != null,
      5 => d.trainingDays != null,
      6 => d.timePerWorkout != null,
      7 => d.location != null,
      8 => d.equipment.isNotEmpty,
      9 => true, // limitações (opcional)
      10 => true, // preferências (opcional)
      11 => true, // resumo
      _ => true,
    };
  }

  Future<void> finish() async {
    final user = ref.read(authenticationRepositoryProvider).currentUser;
    if (user == null) {
      state = state.copyWith(error: 'Sessão expirada. Entre novamente.');
      return;
    }
    state = state.copyWith(isSaving: true, error: null);
    try {
      await ref
          .read(onboardingRepositoryProvider)
          .save(userId: user.id, data: state.data);
      state = state.copyWith(isSaving: false, completed: true);
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, error: e.message);
    } catch (e, st) {
      AppLogger.e('[Onboarding] falha inesperada ao salvar',
          error: e, stackTrace: st);
      state = state.copyWith(
        isSaving: false,
        error: 'Não foi possível salvar. Tente novamente.',
      );
    }
  }
}
