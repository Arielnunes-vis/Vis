import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../workout/domain/workout_enums.dart';
import '../models/workout_set_session.dart';

/// Linha de uma série durante a execução (PROMPT 06).
///
/// StatefulWidget com controllers próprios para que o rebuild da lista
/// (a cada tick do cronômetro) não reinicie os campos em edição.
class SessionSetRow extends StatefulWidget {
  const SessionSetRow({
    required this.set,
    required this.onChanged,
    required this.onToggleDone,
    super.key,
  });

  final WorkoutSetSession set;
  final void Function({double? weight, int? reps}) onChanged;
  final VoidCallback onToggleDone;

  @override
  State<SessionSetRow> createState() => _SessionSetRowState();
}

class _SessionSetRowState extends State<SessionSetRow> {
  late final TextEditingController _weight =
      TextEditingController(text: widget.set.weight?.toString() ?? '');
  late final TextEditingController _reps =
      TextEditingController(text: widget.set.reps?.toString() ?? '');

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _push() => widget.onChanged(
        weight: double.tryParse(_weight.text.replaceAll(',', '.')),
        reps: int.tryParse(_reps.text),
      );

  @override
  Widget build(BuildContext context) {
    final done = widget.set.completed;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${widget.set.setNumber}',
                style: AppTypography.body, textAlign: TextAlign.center),
          ),
          if (widget.set.type != SetType.normal)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(widget.set.type.label,
                  style: AppTypography.small.copyWith(color: AppColors.primary)),
            ),
          Expanded(
            child: _numField(_weight, 'kg'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(_reps, 'reps'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? AppColors.success : AppColors.disabled,
            ),
            onPressed: widget.onToggleDone,
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      onChanged: (_) => _push(),
    );
  }
}
