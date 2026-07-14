import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

/// Estrutura comum de cada passo do onboarding: barra de progresso,
/// título, subtítulo, conteúdo e navegação (voltar / avançar).
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.child,
    required this.onNext,
    required this.onBack,
    this.subtitle,
    this.nextLabel = 'Continuar',
    this.canAdvance = true,
    this.isSaving = false,
    super.key,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String nextLabel;
  final bool canAdvance;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / totalSteps;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (step > 0)
                    VisIconButton(
                      icon: Icons.arrow_back,
                      onPressed: onBack,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.card,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text('Passo ${step + 1} de $totalSteps',
                  style: AppTypography.small),
              const SizedBox(height: AppSpacing.l),
              Text(title, style: AppTypography.headline.copyWith(fontSize: 26)),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.s),
                Text(subtitle!, style: AppTypography.caption),
              ],
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  child: SingleChildScrollView(
                    key: ValueKey(step),
                    child: child,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              PrimaryButton(
                label: nextLabel,
                isLoading: isSaving,
                onPressed: canAdvance ? onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
