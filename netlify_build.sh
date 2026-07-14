#!/usr/bin/env bash
set -euo pipefail

echo "==> Instalando Flutter 3.29.3…"
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.29.3 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
git config --global --add safe.directory "$HOME/flutter" || true
flutter --version
flutter config --enable-web

echo "==> Gerando a plataforma web…"
flutter create --platforms web --project-name vis --org com.vis .

echo "==> Correcoes de compilacao…"
EDITOR_FILE=lib/features/workout/presentation/workout_editor_screen.dart
if ! grep -q "controllers/workout_editor_controller.dart" "$EDITOR_FILE"; then
  sed -i "s|import '../domain/workout_enums.dart';|import '../controllers/workout_editor_controller.dart';\nimport '../domain/workout_enums.dart';|" "$EDITOR_FILE"
fi
NOTIF_FILE=lib/features/notifications/services/local_notification_service.dart
if ! grep -q "uiLocalNotificationDateInterpretation" "$NOTIF_FILE"; then
  sed -i "s|androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,|androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,\n          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,|g" "$NOTIF_FILE"
fi

echo "==> Embutindo chaves do Supabase no app…"
ENV_FILE=lib/core/config/env.dart
if ! grep -q "String.fromEnvironment('SUPABASE_URL')" "$ENV_FILE"; then
  sed -i "s|await dotenv.load(fileName: fileName);|try { await dotenv.load(fileName: fileName); } catch (_) {}|" "$ENV_FILE"
  sed -i "s|static String get supabaseUrl => _require('SUPABASE_URL');|static String get supabaseUrl { const v = String.fromEnvironment('SUPABASE_URL'); return v.isNotEmpty ? v : _require('SUPABASE_URL'); }|" "$ENV_FILE"
  sed -i "s|static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');|static String get supabaseAnonKey { const v = String.fromEnvironment('SUPABASE_ANON_KEY'); return v.isNotEmpty ? v : _require('SUPABASE_ANON_KEY'); }|" "$ENV_FILE"
fi

printf 'SUPABASE_URL=%s\nSUPABASE_ANON_KEY=%s\n' "${SUPABASE_URL:-}" "${SUPABASE_ANON_KEY:-}" > .env
mkdir -p assets/images assets/icons assets/gifs assets/fonts

echo "==> Compilando…"
flutter pub get
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
