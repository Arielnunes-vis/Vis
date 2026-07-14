import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/onboarding_controller.dart';
import '../domain/onboarding_options.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/choice_tile.dart';
import '../widgets/onboarding_scaffold.dart';

/// Fluxo de onboarding em 12 passos (PROMPT 03).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _restrictions = TextEditingController();
  final _preferences = TextEditingController();

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _restrictions.dispose();
    _preferences.dispose();
    super.dispose();
  }

  OnboardingController get _c =>
      ref.read(onboardingControllerProvider.notifier);

  void _handleNext(OnboardingState state) {
    if (state.isLast) {
      _c.finish();
    } else {
      _c.next();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OnboardingState>(onboardingControllerProvider, (prev, next) {
      if (next.completed) {
        ref.read(routerNotifierProvider).markOnboardingCompleted();
        context.goNamed('dashboard');
      } else if (next.error != null) {
        AppSnackBar.show(context, next.error!, type: SnackType.error);
      }
    });

    final state = ref.watch(onboardingControllerProvider);

    return OnboardingScaffold(
      step: state.step,
      totalSteps: state.totalSteps,
      title: _titleFor(state.step),
      subtitle: _subtitleFor(state.step),
      canAdvance: _c.canAdvance(),
      isSaving: state.isSaving,
      nextLabel: state.isLast ? 'Concluir' : 'Continuar',
      onBack: _c.back,
      onNext: () => _handleNext(state),
      child: _StepContent(
        state: state,
        controller: _c,
        age: _age,
        height: _height,
        weight: _weight,
        restrictions: _restrictions,
        preferences: _preferences,
      ),
    );
  }

  String _titleFor(int step) => switch (step) {
        0 => 'Vamos te conhecer',
        1 => 'Qual seu objetivo?',
        2 => 'Sexo',
        3 => 'Suas medidas',
        4 => 'Sua experiência',
        5 => 'Dias disponíveis',
        6 => 'Tempo por treino',
        7 => 'Onde você treina?',
        8 => 'Equipamentos',
        9 => 'Limitações',
        10 => 'Preferências',
        11 => 'Tudo certo!',
        _ => '',
      };

  String? _subtitleFor(int step) => switch (step) {
        0 => 'Vamos criar uma experiência personalizada para você.',
        1 => 'Você pode escolher mais de um.',
        3 => 'Usaremos para acompanhar sua evolução.',
        8 => 'Selecione tudo o que você tem disponível.',
        9 => 'Opcional — lesões, dores ou restrições médicas.',
        10 => 'Opcional — o que você gosta ou evita nos treinos.',
        11 => 'Revise suas respostas e conclua.',
        _ => null,
      };
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.state,
    required this.controller,
    required this.age,
    required this.height,
    required this.weight,
    required this.restrictions,
    required this.preferences,
  });

  final OnboardingState state;
  final OnboardingController controller;
  final TextEditingController age;
  final TextEditingController height;
  final TextEditingController weight;
  final TextEditingController restrictions;
  final TextEditingController preferences;

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    switch (state.step) {
      case 0:
        return const Text(
          'Responda algumas perguntas rápidas. Com isso o VIS Coach '
          'monta treinos, insights e recomendações sob medida para você.',
        );
      case 1:
        return Column(
          children: [
            for (final g in OnboardingOptions.goals)
              ChoiceTile(
                label: g,
                selected: d.goals.contains(g),
                onTap: () => controller.toggleGoal(g),
              ),
          ],
        );
      case 2:
        return Column(
          children: [
            for (final s in OnboardingOptions.sex)
              ChoiceTile(
                label: s,
                selected: d.sex == s,
                onTap: () => controller.setSex(s),
              ),
          ],
        );
      case 3:
        return Column(
          children: [
            _NumberField(
              label: 'Idade',
              suffix: 'anos',
              controller: age,
              onChanged: (v) => controller.setAge(int.tryParse(v)),
            ),
            const SizedBox(height: AppSpacing.m),
            _NumberField(
              label: 'Altura',
              suffix: 'cm',
              controller: height,
              onChanged: (v) => controller.setHeight(double.tryParse(v)),
            ),
            const SizedBox(height: AppSpacing.m),
            _NumberField(
              label: 'Peso',
              suffix: 'kg',
              controller: weight,
              onChanged: (v) => controller.setWeight(double.tryParse(v)),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            for (final e in OnboardingOptions.experience)
              ChoiceTile(
                label: e,
                selected: d.experience == e,
                onTap: () => controller.setExperience(e),
              ),
          ],
        );
      case 5:
        return Column(
          children: [
            for (final day in OnboardingOptions.days)
              ChoiceTile(
                label: '$day ${day == 1 ? 'dia' : 'dias'} por semana',
                selected: d.trainingDays == day,
                onTap: () => controller.setDays(day),
              ),
          ],
        );
      case 6:
        return Column(
          children: [
            for (final t in OnboardingOptions.timePerWorkout)
              ChoiceTile(
                label: '$t minutos',
                selected: d.timePerWorkout == t,
                onTap: () => controller.setTime(t),
              ),
          ],
        );
      case 7:
        return Column(
          children: [
            for (final l in OnboardingOptions.location)
              ChoiceTile(
                label: l,
                selected: d.location == l,
                onTap: () => controller.setLocation(l),
              ),
          ],
        );
      case 8:
        return Column(
          children: [
            for (final eq in OnboardingOptions.equipment)
              ChoiceTile(
                label: eq,
                selected: d.equipment.contains(eq),
                onTap: () => controller.toggleEquipment(eq),
              ),
          ],
        );
      case 9:
        return VisTextField(
          label: 'Limitações (opcional)',
          controller: restrictions,
          hint: 'Ex.: dor no ombro, cirurgia no joelho...',
          onChanged: controller.setRestrictions,
        );
      case 10:
        return VisTextField(
          label: 'Preferências (opcional)',
          controller: preferences,
          hint: 'Ex.: prefiro halteres, treino curto, de manhã...',
          onChanged: controller.setPreferences,
        );
      case 11:
        return _Summary(state: state);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.suffix,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String suffix;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return VisTextField(
      label: '$label ($suffix)',
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});
  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    final rows = <(String, String)>[
      ('Objetivo', d.goals.join(', ')),
      ('Sexo', d.sex ?? '-'),
      ('Idade', d.age?.toString() ?? '-'),
      ('Altura', d.height != null ? '${d.height} cm' : '-'),
      ('Peso', d.weight != null ? '${d.weight} kg' : '-'),
      ('Experiência', d.experience ?? '-'),
      ('Dias', d.trainingDays?.toString() ?? '-'),
      ('Tempo', d.timePerWorkout != null ? '${d.timePerWorkout} min' : '-'),
      ('Local', d.location ?? '-'),
      ('Equipamentos', d.equipment.join(', ')),
      if (d.restrictions.isNotEmpty) ('Limitações', d.restrictions),
      if (d.preferences.isNotEmpty) ('Preferências', d.preferences),
    ];
    return CardContainer(
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(r.$1,
                        style: const TextStyle(color: Color(0xFFB3B3B3))),
                  ),
                  Expanded(
                    child: Text(r.$2.isEmpty ? '-' : r.$2),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
