import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/onboarding/controllers/onboarding_controller.dart';
import 'package:vis/features/onboarding/providers/onboarding_providers.dart';

void main() {
  test('navegação e validação por passo', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(onboardingControllerProvider.notifier);

    // Passo 0 (boas-vindas) sempre pode avançar.
    expect(controller.canAdvance(), isTrue);
    controller.next();

    // Passo 1 (objetivo) exige ao menos uma escolha.
    expect(container.read(onboardingControllerProvider).step, 1);
    expect(controller.canAdvance(), isFalse);
    controller.toggleGoal('Força');
    expect(controller.canAdvance(), isTrue);
  });

  test('voltar preserva os dados preenchidos', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(onboardingControllerProvider.notifier);
    controller.toggleGoal('Saúde');
    controller.next();
    controller.back();

    final state = container.read(onboardingControllerProvider);
    expect(state.step, 0);
    expect(state.data.goals, contains('Saúde'));
  });
}
