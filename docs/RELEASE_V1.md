# VIS — Validação de Release V1 (PROMPT 18)

_Auditoria estática do código em 14/07/2026. Este documento reporta o
estado real do projeto — não “confirma” prontidão que não exista._

## 1. Veredito

Todos os módulos de funcionalidade previstos foram **implementados** e o
aplicativo está **livre de telas placeholder**. O código está pronto para a
fase de validação em ambiente real (rodar testes, aplicar o schema do
Supabase, publicar as Edge Functions e fazer a configuração nativa). A V1
**ainda não pode ser declarada publicável** antes desses passos, que
dependem do seu ambiente (Supabase, chaves, build Android/iOS) e não podem
ser executados a partir daqui.

Resumo: **código-fonte completo ✅ · validação de ambiente/publicação pendente ⏳**.

## 2. Inventário de módulos

| # | Módulo | Estado | Teste unitário |
|---|--------|--------|----------------|
| 00 | Estrutura, tema, DI | ✅ | infra |
| 01 | Supabase (cliente, env, Edge Functions) | ✅ código | `supabase_infra_test` |
| 02 | Autenticação | ✅ | `authentication_controller_test` |
| 03 | Onboarding | ✅ | `onboarding_controller_test` |
| 04 | Arquitetura Flutter (GoRouter, Riverpod) | ✅ | — |
| 05 | AI Engine (abstrações + Edge Functions) | ✅ código | `ai_context_builder_test` |
| 06 | Workout Engine | ✅ | `workout_repository_test`, `workout_editor_controller_test` |
| 06 | Workout Session | ✅ | `workout_session_repository_test`, `workout_session_controller_test` |
| 07 | Dashboard + Design System | ✅ | `dashboard_repository_test` |
| 08 | Biblioteca de Exercícios | ✅ | `exercise_repository_test`, `exercise_library_controller_test` |
| 08 | Evolução Corporal (peso/medidas/fotos) | ✅ | `body_progress_repository_test` |
| 09 | Cardio | ✅ | `cardio_repository_test` |
| 10 | Nutrição | ✅ | `nutrition_repository_test` |
| 11 | AI Context Builder | ✅ | `ai_context_builder_test` |
| 12 | AI Photo Analysis | ✅ código | `photo_controller_test` |
| 13 | AI Personal Trainer (chat) | ✅ código | `ai_chat_controller_test` |
| 14 | AI Insights | ✅ | `insight_engine_test` |
| 15 | Notificações locais | ✅ | `notification_controller_test` |
| 16 | Analytics | ✅ | `analytics_service_test` |
| 17 | Configurações + Perfil | ✅ | `settings_repository_test` |
| — | Gerador de Treino IA | ✅ código | `ai_workout_controller_test` |

“✅ código” = lógica do cliente pronta, mas o resultado final depende de
serviço externo (Edge Function/OpenAI) que precisa estar publicado.

Métricas: **258 arquivos** em `lib/`, **26 arquivos de teste**.

## 3. Mapa de rotas

Guardas de rota (splash → auth → onboarding → app) ativas via `RouterNotifier`.
Abas fixas (`StatefulShellRoute`): Dashboard, Treinos, Biblioteca, Evolução,
Perfil. Todas as navegações por nome (`pushNamed`/`goNamed`) foram
conferidas e **resolvem para rotas definidas** — sem rota quebrada.
Telas full-screen: editor/detalhe/sessão/resumo de treino, detalhe de
exercício, fotos e comparação, cardio, nutrição, configurações, coach IA,
treino IA, insights, analytics e notificações.

## 4. O que foi ajustado nesta etapa (18)

Removida a última tela placeholder (`MeasurementsScreen`) e sua rota
`/measurements`, que estava órfã — o registro de medidas já é feito na aba
“Medidas” da Evolução. Removidas também as pastas de scaffold vazias
(`library`, `photos`, `progress`, `measurements`). Resultado: **nenhuma
`PlaceholderView` restante** em `lib/features`.

## 5. Checklist de validação antes de publicar

### 5.1 No projeto (você roda localmente)

- [ ] `flutter pub get`
- [ ] `flutter analyze` (sem erros) — ver nota sobre ícones em Pendências
- [ ] `flutter test` (26 arquivos de teste devem passar)
- [ ] `flutter run` — percorrer o fluxo: cadastro → onboarding → criar/gerar
      treino → executar sessão → registrar cardio/refeição/peso → ver
      Dashboard/Insights/Analytics → Configurações/Perfil → sair

### 5.2 Supabase

- [ ] Aplicar o schema e as políticas **RLS** de `09_SUPABASE_SQL.md` /
      `03_DATABASE.md` (UUID + RLS em todas as tabelas)
- [ ] Criar os buckets de Storage (ex.: `progress_photos`)
- [ ] Publicar as **Edge Functions**: `ai-answer`, `ai-create-workout`,
      `ai-analyze-photos`, com o segredo da OpenAI configurado na função
      (nunca no app)
- [ ] Criar o `.env` a partir de `.env.example` com `SUPABASE_URL` e
      `SUPABASE_ANON_KEY`

### 5.3 Configuração nativa

- [ ] **Notificações** (`flutter_local_notifications` + `timezone`):
      Android 13+ `POST_NOTIFICATIONS`, canais e (se usar agendamento exato)
      permissão de alarme exato; iOS — solicitação de permissão no
      `AppDelegate`
- [ ] **Câmera/galeria** (`image_picker`): iOS `NSCameraUsageDescription` e
      `NSPhotoLibraryUsageDescription` no `Info.plist`
- [ ] Ícones do app, splash nativo e número de versão (`AppConstants.appVersion` = 0.1.0)

## 6. Pendências conhecidas (agregadas dos módulos)

- **IA depende de backend:** chat, análise de fotos e geração de treino têm o
  cliente pronto, mas só respondem com as Edge Functions publicadas e a
  chave da OpenAI ativa.
- **Sincronização com o servidor:** o app é offline-first (Hive) e tudo
  funciona localmente; o envio/merge para o Supabase (SyncManager) e o
  upload/compressão de fotos para o Storage ficam para a etapa de sync.
- **Preferências ainda não consumidas:** unidades e tempo de descanso padrão
  (módulo 17) são persistidos e expostos por providers, mas as telas de
  treino/sessão ainda não os leem — fiação de integração pendente.
- **Perfil/Backup:** edição de perfil (nome, objetivo, foto) e
  backup/exportação real são evolução; hoje o Perfil mostra conta e navega.
- **Push (FCM/APNS):** apenas estrutura preparada; envio remoto não implementado.
- **Ícones Lucide novos:** confirme via `flutter analyze` os identificadores
  introduzidos recentemente (`globe`, `info`, `logOut`, `moon`, `vibrate`,
  `volume2`) — são ícones estáveis do Lucide; caso algum divirja nesta
  versão do pacote, é um rename trivial.
- **Wearables** (Google Fit/Apple Health/Garmin): estrutura futura.

## 7. Limite desta auditoria

Esta validação é **estática** (o SDK Flutter não está disponível no ambiente
que gerou este relatório): confirmei estrutura, resolução de imports,
integridade de rotas, presença de testes e ausência de placeholders. **Não**
foi possível executar `flutter analyze`/`test`/`build` nem validar schema,
RLS, performance ou builds nativos — esses passos ficam com você, no seu
ambiente, seguindo o checklist acima.
