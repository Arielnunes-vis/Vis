# Documentação do VIS

Estes são os documentos oficiais do projeto — a **fonte de verdade**
(`11_MASTER_PROMPT.md`). Coloque aqui os arquivos `.md` originais:

- `01_PRODUCT_VISION.md`
- `02_FUNCTIONAL_REQUIREMENTS.md`
- `03_DATABASE.md`
- `04_FLUTTER_ARCHITECTURE.md`
- `05_AI_ENGINE.md`
- `06_UI_UX_SPECIFICATION.md`
- `07_DESIGN_SYSTEM.md`
- `08_EXERCISE_LIBRARY.md`
- `09_SUPABASE_SQL.md`
- `10_DEVELOPMENT_RULES.md`
- `11_MASTER_PROMPT.md`
- `CLAUDE.md` (na raiz)

---

## Decisões e observações de implementação

### Conflito de cor de superfície (resolvido)
Os documentos divergem na cor de `Surface`:
- `04_FLUTTER_ARCHITECTURE.md`: Surface `#161616`, Card `#1C1C1E`
- `07_DESIGN_SYSTEM.md`: Surface `#111111`, Card `#1A1A1A`

**Decisão:** adotamos o `07_DESIGN_SYSTEM.md` como autoridade de design
(Surface `#111111`, Card `#1A1A1A`), mantendo `#1C1C1E` como `elevated`.
Ajuste em `lib/core/theme/app_colors.dart` se preferir os valores do doc 04.

### Nomenclatura de pastas de features
Os prompts usaram nomes ligeiramente diferentes ao longo do tempo
(`exercises` vs `exercise`, `body_progress` vs `progress`,
`workout_session` separado de `workout`). A árvore atual consolidou em:
`workout`, `exercise`, `library`, `progress`, `cardio`, etc. Ao implementar
`workout_session` e `nutrition`, criar as pastas correspondentes seguindo o
mesmo padrão interno (`data/domain/presentation/...`).

### Segurança de sessão
Tokens são gerenciados exclusivamente pelo Supabase Auth. O
`secure_storage` guarda apenas flags (ex.: onboarding concluído), nunca
tokens ou senhas.
