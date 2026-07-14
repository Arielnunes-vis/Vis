import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/core/theme/app_theme.dart';
import 'package:vis/shared/widgets/buttons/primary_button.dart';

void main() {
  testWidgets('PrimaryButton dispara onPressed e mostra loading', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: PrimaryButton(
            label: 'Entrar',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
    await tester.tap(find.byType(PrimaryButton));
    expect(pressed, isTrue);

    // Em loading, o rótulo é substituído pelo indicador.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: PrimaryButton(label: 'Entrar', onPressed: null, isLoading: true),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
