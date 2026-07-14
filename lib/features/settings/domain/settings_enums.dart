/// Enums do módulo de Configurações (PROMPT 17).

/// Sistema de unidades para peso e medidas.
enum UnitSystem {
  metric('Métrico', 'kg · cm', 'kg', 'cm'),
  imperial('Imperial', 'lb · in', 'lb', 'in');

  const UnitSystem(this.label, this.hint, this.weightUnit, this.lengthUnit);

  final String label;
  final String hint;
  final String weightUnit;
  final String lengthUnit;

  static UnitSystem fromName(String? name) => values.firstWhere(
        (u) => u.name == name,
        orElse: () => UnitSystem.metric,
      );
}
