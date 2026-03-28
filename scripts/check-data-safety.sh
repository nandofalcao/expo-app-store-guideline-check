#!/usr/bin/env bash
# check-data-safety.sh — Verifica preparação para Google Play Data Safety Section
# Uso: bash check-data-safety.sh [diretório-do-projeto]
# Saída: JSON estruturado para stdout
set -uo pipefail

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

RESULTS=()
CRITICAL=0; WARNING=0; INFO=0; OK=0

add_result() {
  local id="$1" severity="$2" category="$3" title="$4" description="$5" fix="$6" reference="$7" file="$8"
  local t d f
  t=$(printf '%s' "$title" | sed 's/\\/\\\\/g; s/"/\\"/g')
  d=$(printf '%s' "$description" | sed 's/\\/\\\\/g; s/"/\\"/g')
  f=$(printf '%s' "$fix" | sed 's/\\/\\\\/g; s/"/\\"/g')
  RESULTS+=("{\"id\":\"${id}\",\"severity\":\"${severity}\",\"category\":\"${category}\",\"title\":\"${t}\",\"description\":\"${d}\",\"fix\":\"${f}\",\"reference\":\"${reference}\",\"file\":\"${file}\"}")
  case "$severity" in
    CRITICAL) CRITICAL=$((CRITICAL+1)) ;;
    WARNING)  WARNING=$((WARNING+1)) ;;
    INFO)     INFO=$((INFO+1)) ;;
    OK)       OK=$((OK+1)) ;;
  esac
}

ok()       { add_result "$1" "OK"       "$2" "$3" "$4" "" "" "$5"; }
critical() { add_result "$1" "CRITICAL" "$2" "$3" "$4" "$5" "$6" "$7"; }
warning()  { add_result "$1" "WARNING"  "$2" "$3" "$4" "$5" "$6" "$7"; }
info_r()   { add_result "$1" "INFO"     "$2" "$3" "$4" "$5" "$6" "$7"; }

APP_JSON="${PROJECT_DIR}/app.json"
PKG_JSON="${PROJECT_DIR}/package.json"

# ─── DS-001: Target API Level ────────────────────────────────────────────────

# Verificar targetSdkVersion no app.json (Expo) ou build.gradle (bare)
TARGET_SDK="unknown"

if [ -f "$APP_JSON" ]; then
  TARGET_SDK=$(node -e "
    try {
      const a = require('${APP_JSON}');
      const expo = a.expo || a;
      const sdk = expo.android && expo.android.targetSdkVersion;
      process.stdout.write(sdk ? String(sdk) : '__MISSING__');
    } catch(e) { process.stdout.write('__MISSING__'); }
  " 2>/dev/null || echo "__MISSING__")
fi

if [ "$TARGET_SDK" = "__MISSING__" ]; then
  # Tentar build.gradle
  BUILD_GRADLE="${PROJECT_DIR}/android/app/build.gradle"
  if [ -f "$BUILD_GRADLE" ]; then
    TARGET_SDK=$(grep 'targetSdkVersion' "$BUILD_GRADLE" | grep -oP '\d+' | head -1 || echo "unknown")
  fi
fi

if [ "$TARGET_SDK" = "unknown" ] || [ "$TARGET_SDK" = "__MISSING__" ]; then
  warning "DS-001" "google" \
    "Target SDK Version não detectado" \
    "Não foi possível detectar o targetSdkVersion. Novos apps em 2025+ precisam mirar API 35 (Android 15)." \
    "Configure targetSdkVersion em expo.android.targetSdkVersion ou no android/app/build.gradle." \
    "https://support.google.com/googleplay/android-developer/answer/11926878" \
    "app.json"
elif [ "$TARGET_SDK" -lt 34 ] 2>/dev/null; then
  critical "DS-001" "google" \
    "Target SDK Version muito baixo: $TARGET_SDK (mínimo: 34 / Android 14)" \
    "O Google Play exige targetSdkVersion >= 34 para novos apps e atualizações desde agosto de 2024." \
    "Atualize targetSdkVersion para 35 (Android 15) no app.json ou build.gradle." \
    "https://support.google.com/googleplay/android-developer/answer/11926878" \
    "app.json"
elif [ "$TARGET_SDK" -eq 34 ] 2>/dev/null; then
  warning "DS-001" "google" \
    "Target SDK Version: $TARGET_SDK (recomendado: 35 / Android 15)" \
    "API 35 (Android 15) é o target recomendado para novos apps em 2025/2026." \
    "Considere atualizar para targetSdkVersion 35 para melhor compatibilidade futura." \
    "https://support.google.com/googleplay/android-developer/answer/11926878" \
    "app.json"
else
  ok "DS-001" "google" "Target SDK Version adequado: $TARGET_SDK" "" "app.json"
fi

# ─── DS-002: Analytics SDKs ──────────────────────────────────────────────────

declare -a ANALYTICS_SDKS=(
  "@react-native-firebase/analytics:Firebase Analytics coleta dados de uso e comportamento"
  "@amplitude/analytics-react-native:Amplitude coleta eventos de uso e dados do usuário"
  "react-native-mixpanel:Mixpanel coleta eventos e propriedades do usuário"
  "@segment/analytics-react-native:Segment coleta e encaminha dados de analytics"
  "react-native-rudderstack:RudderStack coleta e encaminha eventos de analytics"
  "@datadog/mobile-react-native:Datadog coleta dados de performance e erros"
  "react-native-posthog:PostHog coleta eventos de produto e dados de usuário"
)

ANALYTICS_FOUND=()
for sdk_entry in "${ANALYTICS_SDKS[@]}"; do
  IFS=':' read -r sdk_name sdk_desc <<< "$sdk_entry"
  if grep -q "\"$sdk_name\"" "$PKG_JSON" 2>/dev/null; then
    ANALYTICS_FOUND+=("$sdk_name")
    warning "DS-002-$(echo "$sdk_name" | tr -d '@/' | head -c 8)" "google" \
      "SDK de Analytics detectado: $sdk_name" \
      "${sdk_desc}. Declare esses dados na Data Safety Section do Google Play." \
      "Vá para Google Play Console > App content > Data safety e declare os dados coletados por ${sdk_name}." \
      "https://support.google.com/googleplay/android-developer/answer/10787469" \
      "package.json"
  fi
done

if [ ${#ANALYTICS_FOUND[@]} -eq 0 ]; then
  ok "DS-002" "google" "Nenhum SDK de analytics de terceiros detectado" "" "package.json"
fi

# ─── DS-003: Crash Reporting ─────────────────────────────────────────────────

declare -a CRASH_SDKS=(
  "@sentry/react-native:Sentry"
  "@react-native-firebase/crashlytics:Firebase Crashlytics"
  "react-native-bugsnag:Bugsnag"
)

CRASH_FOUND=false
for sdk_entry in "${CRASH_SDKS[@]}"; do
  IFS=':' read -r sdk_name sdk_display <<< "$sdk_entry"
  if grep -q "\"$sdk_name\"" "$PKG_JSON" 2>/dev/null; then
    CRASH_FOUND=true
    info_r "DS-003" "google" \
      "SDK de crash reporting detectado: $sdk_display" \
      "${sdk_display} coleta dados de diagnóstico (crash logs, device info). Declare na Data Safety Section." \
      "Na Data Safety Section, declare 'Crash logs' e 'Diagnostics' como dados coletados automaticamente." \
      "https://support.google.com/googleplay/android-developer/answer/10787469#zippy=%2Cdiagnostics" \
      "package.json"
    break
  fi
done

# ─── DS-004: Advertising ID ──────────────────────────────────────────────────

USES_AD_ID=false
AD_ID_TRIGGERS="react-native-google-mobile-ads expo-ads-admob @react-native-firebase/in-app-messaging"
for sdk in $AD_ID_TRIGGERS; do
  if grep -q "\"$sdk\"" "$PKG_JSON" 2>/dev/null; then
    USES_AD_ID=true
    break
  fi
done

if [ "$USES_AD_ID" = true ]; then
  critical "DS-004" "google" \
    "SDK de publicidade detectado — Advertising ID requer disclosure" \
    "SDKs de publicidade usam o Android Advertising ID. Isso requer declaração na Data Safety Section e permissão AD_ID no manifest." \
    "Declare uso de 'Device or other IDs > Advertising ID' na Data Safety Section. Verifique se AD_ID está no AndroidManifest." \
    "https://support.google.com/googleplay/android-developer/answer/6048248" \
    "package.json"
else
  ok "DS-004" "google" "Nenhum SDK de publicidade/Advertising ID detectado" "" "package.json"
fi

# ─── DS-005: Autenticação e dados de conta ───────────────────────────────────

USES_AUTH=false
AUTH_SDKS="@react-native-google-signin/google-signin react-native-fbsdk-next @invertase/react-native-apple-authentication expo-auth-session"
for sdk in $AUTH_SDKS; do
  if grep -q "\"$sdk\"" "$PKG_JSON" 2>/dev/null; then
    USES_AUTH=true
    break
  fi
done

if [ "$USES_AUTH" = true ]; then
  info_r "DS-005" "google" \
    "SDK de autenticação social detectado" \
    "Autenticação via Google/Facebook/Apple coleta dados de conta do usuário. Declare na Data Safety Section." \
    "Na Data Safety Section, declare 'Account info' se usar autenticação social ou criar contas." \
    "https://support.google.com/googleplay/android-developer/answer/10787469" \
    "package.json"
fi

# ─── DS-006: Localização ─────────────────────────────────────────────────────

USES_LOCATION=false
LOCATION_SDKS="expo-location react-native-maps @react-native-community/geolocation"
for sdk in $LOCATION_SDKS; do
  if grep -q "\"$sdk\"" "$PKG_JSON" 2>/dev/null; then
    USES_LOCATION=true
    break
  fi
done

if [ "$USES_LOCATION" = true ]; then
  warning "DS-006" "google" \
    "SDK de localização detectado — declarar no Data Safety" \
    "O app usa localização. Na Data Safety Section, declare se coleta localização aproximada ou precisa, e se em background." \
    "Na Data Safety Section, declare 'Location > Approximate location' e/ou 'Precise location' conforme o caso." \
    "https://support.google.com/googleplay/android-developer/answer/10787469" \
    "package.json"
else
  ok "DS-006" "google" "Nenhum SDK de localização detectado" "" "package.json"
fi

# ─── DS-007: Armazenamento de arquivos ───────────────────────────────────────

USES_STORAGE=false
STORAGE_SDKS="expo-file-system expo-document-picker expo-media-library react-native-fs"
for sdk in $STORAGE_SDKS; do
  if grep -q "\"$sdk\"" "$PKG_JSON" 2>/dev/null; then
    USES_STORAGE=true
    break
  fi
done

if [ "$USES_STORAGE" = true ]; then
  info_r "DS-007" "google" \
    "SDK de armazenamento de arquivos detectado" \
    "O app acessa o armazenamento do dispositivo. Declare na Data Safety Section se coleta ou lê arquivos do usuário." \
    "Na Data Safety Section, declare 'Photos and videos' ou 'Files and docs' conforme o conteúdo acessado." \
    "https://support.google.com/googleplay/android-developer/answer/10787469" \
    "package.json"
fi

# ─── DS-008: Push Notifications ──────────────────────────────────────────────

USES_PUSH=false
PUSH_SDKS="expo-notifications react-native-push-notification @react-native-firebase/messaging"
for sdk in $PUSH_SDKS; do
  if grep -q "\"$sdk\"" "$PKG_JSON" 2>/dev/null; then
    USES_PUSH=true
    break
  fi
done

if [ "$USES_PUSH" = true ]; then
  info_r "DS-008" "google" \
    "SDK de push notifications detectado" \
    "Push notifications podem envolver coleta de tokens de dispositivo. Declare na Data Safety se aplicável." \
    "Se armazenar push tokens no servidor, declare 'Device or other IDs' na Data Safety Section." \
    "https://support.google.com/googleplay/android-developer/answer/10787469" \
    "package.json"
fi

# ─── DS-009: Verificação do formulário Data Safety ───────────────────────────

# Verificar se há evidência de que o formulário foi preenchido
# (não temos como verificar diretamente, mas podemos checar se há documentação)
DATA_SAFETY_DOC="${PROJECT_DIR}/docs/data-safety.md"
DATA_SAFETY_DOC2="${PROJECT_DIR}/DATA_SAFETY.md"

if [ -f "$DATA_SAFETY_DOC" ] || [ -f "$DATA_SAFETY_DOC2" ]; then
  ok "DS-009" "google" "Documentação de Data Safety encontrada no projeto" "" "docs/data-safety.md"
else
  info_r "DS-009" "google" \
    "Nenhuma documentação de Data Safety no repositório" \
    "É boa prática manter documentação interna do que foi declarado na Data Safety Section do Google Play." \
    "Crie docs/data-safety.md documentando os dados coletados. Use o template em templates/data-safety-form.md." \
    "https://support.google.com/googleplay/android-developer/answer/10787469" \
    "—"
fi

# ─── Output JSON ──────────────────────────────────────────────────────────────

RESULTS_JSON=""
for r in "${RESULTS[@]}"; do
  [ -z "$RESULTS_JSON" ] && RESULTS_JSON="$r" || RESULTS_JSON="${RESULTS_JSON},${r}"
done

if [ ${#RESULTS[@]} -eq 0 ]; then
  ok "DS-000" "google" "Nenhum problema de Data Safety detectado" "" "—"
  RESULTS_JSON="${RESULTS[0]}"
fi

echo "{\"check\":\"check-data-safety\",\"results\":[${RESULTS_JSON}],\"summary\":{\"critical\":${CRITICAL},\"warning\":${WARNING},\"info\":${INFO},\"ok\":${OK}}}"
