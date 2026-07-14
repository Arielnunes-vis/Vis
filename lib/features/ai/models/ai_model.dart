/// Modelos de domínio da camada de IA (VIS Coach).
///
/// Estrutura preparada (nunca conecta diretamente ao OpenAI — o acesso
/// ocorre via Supabase Edge Functions, 05_AI_ENGINE.md).

enum AIRole { user, coach, system }

/// Uma mensagem trocada com o VIS Coach.
class AIMessage {
  const AIMessage({
    required this.role,
    required this.content,
    this.createdAt,
  });

  final AIRole role;
  final String content;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'content': content,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  factory AIMessage.fromMap(Map<String, dynamic> m) => AIMessage(
        role: AIRole.values.firstWhere(
          (r) => r.name == m['role'],
          orElse: () => AIRole.coach,
        ),
        content: (m['content'] ?? '') as String,
        createdAt: m['created_at'] != null
            ? DateTime.tryParse(m['created_at'] as String)
            : null,
      );
}

/// Resposta estruturada do VIS Coach.
///
/// Toda recomendação deve explicar o motivo (Regra 008/028): por isso
/// [reason] acompanha a resposta principal.
class AIResponse {
  const AIResponse({
    required this.message,
    this.reason,
    this.isEstimate = false,
    this.raw,
  });

  final String message;
  final String? reason;
  final bool isEstimate;
  final Map<String, dynamic>? raw;

  factory AIResponse.fromMap(Map<String, dynamic> map) => AIResponse(
        message: (map['message'] ?? map['answer'] ?? '') as String,
        reason: map['reason'] as String?,
        isEstimate: (map['is_estimate'] as bool?) ?? false,
        raw: map,
      );
}
