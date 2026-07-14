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

echo "==> Aplicando correcoes de compilacao…"
EDITOR_FILE=lib/features/workout/presentation/workout_editor_screen.dart
if ! grep -q "controllers/workout_editor_controller.dart" "$EDITOR_FILE"; then
  sed -i "s|import '../domain/workout_enums.dart';|import '../controllers/workout_editor_controller.dart';\nimport '../domain/workout_enums.dart';|" "$EDITOR_FILE"
fi

NOTIF_FILE=lib/features/notifications/services/local_notification_service.dart
if ! grep -q "uiLocalNotificationDateInterpretation" "$NOTIF_FILE"; then
  sed -i "s|androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,|androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,\n          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,|g" "$NOTIF_FILE"
fi

echo "==> Criando .env…"
printf 'SUPABASE_URL=%s\nSUPABASE_ANON_KEY=%s\n' "${SUPABASE_URL:-}" "${SUPABASE_ANON_KEY:-}" > .env

echo "==> Garantindo pastas de assets…"
mkdir -p assets/images assets/icons assets/gifs assets/fonts

echo "==> Baixando dependencias e compilando…"
flutter pub get
flutter build web --release
