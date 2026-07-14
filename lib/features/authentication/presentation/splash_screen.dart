import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Tela inicial exibida enquanto o app decide o destino do usuário.
///
/// A lógica de redirecionamento (sessão? onboarding?) fica no
/// `redirect` do GoRouter — esta tela é apenas a apresentação.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('VIS', style: AppTypography.display.copyWith(fontSize: 56))
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 8),
            Text(
              'Evolua com inteligência.',
              style: AppTypography.caption,
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 40),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ],
        ),
      ),
    );
  }
}
