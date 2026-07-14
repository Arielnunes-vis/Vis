/// Insight de análise de uma região corporal (PROMPT 13).
class PhotoInsight {
  const PhotoInsight({required this.region, required this.message});
  final String region;
  final String message;

  factory PhotoInsight.fromMap(Map<String, dynamic> m) => PhotoInsight(
        region: (m['region'] ?? '') as String,
        message: (m['message'] ?? '') as String,
      );
}

/// Resultado da análise de evolução por fotos (PROMPT 13).
///
/// Estrutura preparada — preenchida pela Edge Function de IA. Linguagem
/// objetiva, sem exageros (Regra do prompt).
class PhotoAnalysisResult {
  const PhotoAnalysisResult({
    this.summary = '',
    this.insights = const [],
    this.isEstimate = true,
  });

  final String summary;
  final List<PhotoInsight> insights;
  final bool isEstimate;

  factory PhotoAnalysisResult.fromMap(Map<String, dynamic> m) =>
      PhotoAnalysisResult(
        summary: (m['summary'] ?? '') as String,
        isEstimate: (m['is_estimate'] as bool?) ?? true,
        insights: (m['insights'] as List? ?? [])
            .map((e) => PhotoInsight.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
