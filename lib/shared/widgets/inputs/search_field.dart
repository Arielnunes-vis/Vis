import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';

/// Barra de busca reutilizável (biblioteca, exercícios).
class SearchField extends StatelessWidget {
  const SearchField({
    this.controller,
    this.hint = 'Pesquisar...',
    this.onChanged,
    this.onClear,
    super.key,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(LucideIcons.search,
            size: 20, color: AppColors.textSecondary),
        suffixIcon: onClear != null
            ? IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
