import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Diálogo de confirmação para ações críticas (Regra 004).
///
/// Ex.: excluir treino, foto, medidas. Retorna `true` se confirmado.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.danger = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool danger;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        danger: danger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.s),
            Text(message, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
                const SizedBox(width: AppSpacing.s),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    confirmLabel,
                    style: TextStyle(
                      color: danger ? AppColors.danger : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
