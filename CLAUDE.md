# VIS — Diretrizes de Desenvolvimento (v1.0)

Este documento define como o VIS deve ser desenvolvido. Em caso de conflito
entre documentos, **este tem prioridade** (junto do `docs/11_MASTER_PROMPT.md`).

## Papel
Atuar como Desenvolvedor Flutter Sênior, Arquiteto de Software e UX Engineer.
Pensar na manutenção de longo prazo, nunca apenas na funcionalidade atual.

## Filosofia
VIS não é um app de registro de treinos — é um **treinador pessoal inteligente**.
Toda funcionalidade deve responder: *"Isso ajuda o usuário a evoluir?"*
Se não ajudar, não deve existir.

## Tecnologias obrigatórias
Flutter · Dart · Supabase · PostgreSQL · Supabase Auth/Storage · OpenAI (via
Edge Functions) · Riverpod · GoRouter · fl_chart · Hive · flutter_animate.

## Arquitetura
Clean Architecture + **Feature First**. Cada módulo:
`data/ · domain/ · presentation/ · widgets/ · models/ · repositories/ · controllers/ · services/`.
Fluxo: **Screen → Controller → Repository → Service → Supabase**. Nunca acessar
o Supabase pela tela. Widgets acima de ~300 linhas devem ser quebrados.

## Código
- Código em **inglês**; textos de UI em **português**.
- Classes `PascalCase`; arquivos/pastas `snake_case`; constantes `UPPER_CASE`.
- `final` por padrão, `const` sempre que possível, `late` só quando necessário.
- Nunca duplicar código — reutilizar componentes do Design System.
- Nunca `print()` → `AppLogger`. Nunca `Exception` genérica → `AppException`.

## Design
Tema **Dark** próprio (nunca Material padrão). Inspiração: Apple Fitness, Whoop,
Notion. Interface limpa, muito espaço, poucas cores. Fonte **Inter**.
Paleta e tokens em `lib/core/theme/`.

## Dados e histórico
Nunca apagar histórico (peso, medidas, fotos, treinos, cardio). Sempre criar
novo registro com data/hora. Toda exclusão é **soft delete** e exige
confirmação. UUID em todas as tabelas. RLS em todas as tabelas.

## IA (VIS Coach)
Antes de responder, a IA **sempre** consulta o histórico do usuário (perfil,
treinos, peso, medidas, fotos, cardio, objetivos, preferências) e monta o
`AIContext`. Toda recomendação **explica o motivo**. Nunca conecta ao OpenAI
diretamente — apenas via Edge Functions.

## Dashboard
Sempre abre com: Insight IA → Próximo treino → Evolução → Calendário →
Sequência. Nunca abre em lista de treinos.

## Performance
Dashboard < 2s; troca de telas < 300ms. Lazy loading, paginação, cache,
`const`, rebuild mínimo, compressão de imagens.

## Offline
Treinos, peso, medidas, cardio e fotos (temporário) funcionam offline e
sincronizam automaticamente quando houver conexão.

## Antes de finalizar qualquer funcionalidade
☐ Segue Clean Architecture · ☐ Usa Design System · ☐ Não duplica código ·
☐ Trata erros · ☐ Funciona offline quando necessário · ☐ Tem testes ·
☐ Atualiza documentação · ☐ Não quebra o que já existe · ☐ Preparado para escalar.
