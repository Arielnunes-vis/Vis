#!/usr/bin/env bash
# Build do VIS (Flutter web) no ambiente da Netlify.
# Requer, no painel da Netlify (Site settings -> Environment variables):
#   SUPABASE_URL        = a Project URL do seu projeto Supabase
#   SUPABASE_ANON_KEY   = a chave anon (public) do Supabase
set -euo pipefail

echo "==> Instalando Flutter (stable)…"
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
git config --global --add safe.directory "$HOME/flutter" || true

flutter --version
flutter config --enable-web

echo "==> Gerando a plataforma web (se ainda não existir)…"
flutter create --platforms web --project-name vis --org com.vis .

echo "==> Criando .env a partir das variáveis de ambiente…"
printf 'SUPABASE_URL=%s\nSUPABASE_ANON_KEY=%s\n' \
  "${SUPABASE_URL:-}" "${SUPABASE_ANON_KEY:-}" > .env

echo "==> Baixando dependências e compilando…"
flutter pub get
flutter build web --release

echo "==> Build concluído: build/web"
