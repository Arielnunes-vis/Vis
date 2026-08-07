/// Situação de uma métrica nutricional frente à meta configurada
/// (PROMPT 10 — Relatórios).
///
/// Comparação puramente aritmética sobre os dados já registrados pelo
/// usuário — sem IA e sem recomendação médica/nutricional.
enum NutritionGoalStatus {
  below('abaixo da meta'),
  onTarget('dentro da meta'),
  above('acima da meta');

  const NutritionGoalStatus(this.label);

  final String label;
}
