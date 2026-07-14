# VIS — Backend Supabase

Este diretório reúne o backend que a especificação (`docs` 03/09) exige e
que ainda não existia versionado no projeto.

## Ordem de execução (SQL Editor do Supabase)

1. `migrations/0000_schema.sql` — cria todas as tabelas + o gatilho que
   popula `public.users` no cadastro.
2. `migrations/0001_baseline_security_performance.sql` — RLS, índices,
   trigger de `updated_at` e políticas de Storage.
3. `migrations/0002_views_and_functions.sql` — views e funções SQL.

Rode sempre nessa ordem (0000 → 0001 → 0002).

## migrations/0001_baseline_security_performance.sql

Baseline idempotente que implementa:

- **RLS** habilitado em todas as tabelas de usuário, com políticas
  `select/insert/update` por `auth.uid()`. Tabelas-filhas
  (`workout_days`, `workout_exercises`, `exercise_sets`) herdam a posse via
  `EXISTS` no pai. Catálogos globais (`exercise_library`, `achievements`)
  têm leitura para autenticados e escrita bloqueada ao cliente.
- **Sem DELETE**: nenhuma política de delete é criada — o app usa apenas
  soft delete (`deleted_at`). Os `SELECT` ocultam registros soft-deletados.
- **Índices** das consultas frequentes, incluindo compostos
  `(user_id, created_at desc)` / `(user_id, performed_at desc)` para
  paginação eficiente.
- **Trigger** `set_updated_at` nas tabelas com `updated_at`.
- **Storage**: buckets privados (`avatars`, `progress_photos`, `meal_photos`
  e catálogos) com políticas por dono, usando a convenção de path
  `<bucket>/<auth.uid()>/<arquivo>`.

Antes de aplicar em produção, reconcilie os nomes de colunas com o schema
efetivamente criado (o baseline segue os nomes do `03_DATABASE.md`).

## Convenções que o cliente deve seguir

- **Uploads** para buckets de usuário devem prefixar o path com o `uid`
  (`progress_photos/<uid>/<arquivo>.jpg`) para casar com as políticas de
  Storage. O `SupabaseStorageService.uploadBinary` já recebe o `path`;
  garanta esse prefixo na feature de fotos quando o upload for ativado.
- **Downloads** sempre por URL assinada (`createSignedUrl`) — buckets são
  privados. O cliente já expõe esse método.
- **Leituras paginadas**: quando a sincronização servidor↔cliente for
  implementada, os `SELECT` de listas devem usar `range()/limit()` e
  ordenar por `created_at desc` (os índices compostos já suportam isso).
- **Chaves**: o app usa apenas a `anonKey` (correto). Segredos (OpenAI)
  ficam nas Edge Functions, nunca no cliente.

## Pendente (próximo passo de backend)

Views (`dashboard_summary`, `weekly_volume`, `muscle_balance`,
`exercise_prs`, `body_progress`) e funções SQL
(`calculate_training_volume`, `calculate_estimated_1rm`, `streak_days`,
`weekly_sets`, `monthly_progress`, `ai_context`) descritas em
`09_SUPABASE_SQL.md` — hoje esses cálculos são feitos no cliente
(offline-first). As Edge Functions de IA (`ai-answer`, `ai-create-workout`,
`ai-analyze-photos`) precisam ser publicadas com o segredo da OpenAI.
