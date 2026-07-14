# VIS

> Plataforma inteligente para acompanhamento de evolução física.

VIS é um aplicativo mobile (Flutter + Supabase) que registra treinos, acompanha
a evolução corporal e usa Inteligência Artificial (VIS Coach) para orientar o
usuário. Este repositório contém a **fundação de produção** do app, construída
segundo a documentação oficial (`/docs`) e as diretrizes do `CLAUDE.md`.

**Versão:** 0.1.0 · **Status:** em desenvolvimento.

---

## Stack

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter (Dart) |
| Estado | Riverpod |
| Navegação | GoRouter |
| Backend | Supabase (PostgreSQL, Auth, Storage, Realtime, Edge Functions) |
| Offline / Cache | Hive |
| Armazenamento seguro | flutter_secure_storage |
| Conectividade | connectivity_plus + internet_connection_checker_plus |
| Gráficos | fl_chart |
| Animações | flutter_animate |
| Ícones | Lucide |
| IA | OpenAI (consumida **via Supabase Edge Functions**, nunca direto do app) |

---

## Como executar

### 1. Pré-requisitos
- Flutter (stable) instalado — `flutter --version`
- Um projeto no [Supabase](https://supabase.com)

### 2. Instalar dependências
```bash
flutter pub get
```

### 3. Configurar o ambiente
Crie o arquivo `.env` a partir do exemplo e preencha com os valores do seu
projeto Supabase:
```bash
cp .env.example .env
```
```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
OPENAI_API_URL=            # usado pela Edge Function de IA
OPENAI_MODEL=gpt-4o-mini
```
> O `.env` **nunca** é versionado (já está no `.gitignore`). Nenhuma chave
> fica hardcoded no código.

### 4. Rodar
```bash
flutter run
```

### 5. Testes
```bash
flutter test
```

### Trocar de ambiente (dev/staging/prod)
Basta manter arquivos `.env` distintos e carregá-los em `Env.load(fileName: ...)`
no `main.dart`. Nenhuma URL ou chave está fixa no código.

---

## Arquitetura

Clean Architecture + **Feature First**. O fluxo de dados é sempre:

```
Screen → Controller (Riverpod) → Repository → Service → Supabase
```

A tela **nunca** acessa o Supabase diretamente (Regra 5).

```
lib/
├── app/                 # MaterialApp, GoRouter, providers globais
├── core/                # Infraestrutura compartilhada
│   ├── config/          # Env (.env / dotenv)
│   ├── constants/       # Constantes, buckets
│   ├── exceptions/      # AppException e subtipos (nunca Exception genérica)
│   ├── logger/          # AppLogger (nunca print())
│   ├── network/         # Conectividade observável
│   ├── repositories/    # Contratos base (Base/Crud/Sync)
│   ├── storage/         # Hive (local) + secure storage
│   ├── supabase/        # Cliente único + serviços (Auth/DB/Storage/Realtime/EdgeFn)
│   ├── sync/            # Fila de sincronização offline (estrutura)
│   ├── theme/           # Design System em código (Dark)
│   └── validators/      # Validadores de formulário
├── shared/widgets/      # Design System (componentes reutilizáveis)
└── features/            # Uma pasta por módulo
    └── <feature>/
        ├── data/        # implementações de repositório
        ├── domain/      # entidades / contratos
        ├── models/      # modelos
        ├── repositories/# interfaces de repositório
        ├── services/    # regras específicas
        ├── controllers/ # Riverpod Notifiers
        ├── providers/   # providers da feature
        ├── presentation/# telas
        └── widgets/     # widgets da feature
```

### Design System
Tema **Dark** próprio (nunca Material padrão), fonte **Inter**, paleta e
espaçamentos em `core/theme/`. Componentes reutilizáveis em
`shared/widgets/` (barrel: `shared/widgets/widgets.dart`) — nunca duplicar.

### IA (VIS Coach)
O app **não fala com o OpenAI diretamente**. A camada de IA (`features/ai/`)
expõe abstrações (`IAIService`, `IAIRepository`, `AIContext`) que consomem
**Supabase Edge Functions**. Antes de qualquer resposta, o `AIContext` é
montado com o histórico do usuário (Regra 026). Para trocar de provedor de IA
basta trocar a implementação de `IAIService` — nada mais muda.

---

## Status dos módulos

| Módulo | Status |
|---|---|
| Scaffold + configuração (pubspec, lint, .env) | ✅ Completo |
| Core (tema, logger, exceptions, validators, constants) | ✅ Completo |
| Infra Supabase (cliente, serviços, providers) | ✅ Completo |
| Rede / conectividade | ✅ Completo |
| Storage local (Hive) + secure storage | ✅ Completo |
| Sincronização offline | 🟡 Estrutura pronta |
| Design System (shared widgets) | ✅ Completo |
| Roteamento (GoRouter + guardas) | ✅ Completo |
| **Authentication** | ✅ Completo (login, cadastro, recuperação, verificação, sessão) |
| **Onboarding** (12 passos) | ✅ Completo |
| Camada de IA (abstrações) | ✅ Estrutura pronta |
| **AI Workout Generator** | ✅ Completo (gerar, editar, salvar, feedback, cache offline) |
| **Notifications** | ✅ Completo (locais: agendar/repetir/cancelar; Push: estrutura FCM/APNS) |
| Workout / Workout Session | ⬜ Estrutura de pastas criada |
| Exercise Library | ⬜ Estrutura de pastas criada |
| Dashboard | ⬜ Placeholder |
| Body Progress / Cardio / Nutrition | ⬜ Estrutura de pastas criada |
| AI Photo Analysis / AI Insights / Analytics / Settings | ⬜ Estrutura de pastas criada |

### Notificações — configuração nativa
As notificações locais exigem configuração de plataforma:
**Android** — permissão `POST_NOTIFICATIONS` (API 33+) e receiver de agendamento
exato no `AndroidManifest.xml`; **iOS** — permissões no `Info.plist` e capability
de notificações. O envio remoto (Push) é apenas estrutura: para ativá-lo, adicione
`firebase_messaging` e substitua o `NoopPushNotificationService`.

Os módulos marcados como ⬜/🟡 possuem pasta e telas placeholder para o
roteamento funcionar, e serão implementados **um a um** nos próximos passos
(cada um com telas, models, repositórios, controllers e testes).

---

## Backend Supabase (a criar)

O schema (tabelas, RLS, views, funções, buckets) está especificado em
`docs/03_DATABASE.md` e `docs/09_SUPABASE_SQL.md`. Buckets privados esperados:
`avatars`, `progress_photos`, `meal_photos`, `exercise_images`,
`exercise_gifs`, `exercise_videos`. Todas as tabelas com **Row Level Security**.

---

## Convenções
- Código em **inglês**; textos de UI em **português**.
- Classes `PascalCase`, arquivos/pastas `snake_case`, constantes `UPPER_CASE`.
- Nunca `print()` → usar `AppLogger`.
- Nunca `Exception` genérica → usar `AppException`.
- Toda exclusão é **soft delete**; histórico nunca é apagado.

_Criado a partir da documentação de Ariel Nunes._
