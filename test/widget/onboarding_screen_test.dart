import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/core/theme/app_theme.dart';
import 'package:vis/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding renderiza o passo 1 e avança para o passo 2',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const OnboardingScreen(),
        ),
      ),
    );

    // Passo 1 — boas-vindas.
    expect(find.text('Vamos te conhecer'), findsOneWidget);
    expect(find.text('Passo 1 de 12'), findsOneWidget);

    // Avança (boas-vindas sempre pode avançar).
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();

    // Passo 2 — objetivo.
    expect(find.text('Qual seu objetivo?'), findsOneWidget);
    expect(find.text('Passo 2 de 12'), findsOneWidget);
  });
}
