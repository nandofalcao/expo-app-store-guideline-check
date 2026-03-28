#!/usr/bin/env bash
# check-privacy-manifest.sh — Verifica iOS Privacy Manifest (PrivacyInfo.xcprivacy)
# Obrigatório desde maio de 2024 para todos os apps submetidos à App Store
# Uso: bash check-privacy-manifest.sh [diretório-do-projeto]
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
IOS_DIR="${PROJECT_DIR}/ios"
PRIVACY_INFO_FILE=""

# ─── Localizar PrivacyInfo.xcprivacy ─────────────────────────────────────────

# Em projetos bare, procurar o arquivo
if [ -d "$IOS_DIR" ]; then
  FOUND=$(find "$IOS_DIR" -name "PrivacyInfo.xcprivacy" 2>/dev/null | head -1 || true)
  [ -n "$FOUND" ] && PRIVACY_INFO_FILE="$FOUND"
fi

# ─── PRIV-001: Existência do Privacy Manifest ─────────────────────────────────

HAS_EXPO_PRIVACY_MANIFEST=false
if [ -f "$APP_JSON" ]; then
  val=$(node -e "
    try {
      const a = require('${APP_JSON}');
      const expo = a.expo || a;
      const pm = expo.ios && expo.ios.privacyManifests;
      process.stdout.write(pm ? 'yes' : 'no');
    } catch(e) { process.stdout.write('no'); }
  " 2>/dev/null || echo "no")
  [ "$val" = "yes" ] && HAS_EXPO_PRIVACY_MANIFEST=true
fi

if [ "$HAS_EXPO_PRIVACY_MANIFEST" = false ] && [ -z "$PRIVACY_INFO_FILE" ]; then
  critical "PRIV-001" "apple" \
    "Privacy Manifest (PrivacyInfo.xcprivacy) não encontrado" \
    "A Apple exige Privacy Manifest para todos os apps desde maio de 2024. Sem ele, o app será rejeitado. No Expo Managed, configure via expo.ios.privacyManifests no app.json." \
    "Adicione privacyManifests em expo.ios no app.json com as APIs utilizadas e seus motivos." \
    "https://docs.expo.dev/guides/apple-privacy/" \
    "app.json"
else
  ok "PRIV-001" "apple" "Privacy Manifest configurado" "" \
    "${PRIVACY_INFO_FILE:-app.json}"
fi

# ─── PRIV-002: NSPrivacyAccessedAPITypes ─────────────────────────────────────

# APIs que necessitam de declaração e os módulos que as usam
# Formato: "API_TYPE|reason_recomendado|modulos_que_usam"
declare -a REQUIRED_APIS=(
  "NSPrivacyAccessedAPICategoryUserDefaults|C617.1|@react-native-async-storage/async-storage expo-secure-store react-native"
  "NSPrivacyAccessedAPICategoryFileTimestamp|C617.1|react-native expo-file-system expo-media-library"
  "NSPrivacyAccessedAPICategorySystemBootTime|35F9.1|react-native expo-modules-core"
  "NSPrivacyAccessedAPICategoryDiskSpace|E174.1|react-native expo-file-system"
)

for api_entry in "${REQUIRED_APIS[@]}"; do
  IFS='|' read -r api_type reason modules <<< "$api_entry"

  # Verificar se algum módulo está no projeto
  USES_API=false
  for mod in $modules; do
    if grep -q "\"$mod\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
      USES_API=true
      break
    fi
  done

  [ "$USES_API" = false ] && continue

  # Verificar se está declarado no Privacy Manifest
  DECLARED=false

  if [ "$HAS_EXPO_PRIVACY_MANIFEST" = true ] && [ -f "$APP_JSON" ]; then
    check=$(node -e "
      try {
        const a = require('${APP_JSON}');
        const expo = a.expo || a;
        const pm = expo.ios && expo.ios.privacyManifests;
        const apis = pm && pm.NSPrivacyAccessedAPITypes || [];
        const found = apis.some(a => a.NSPrivacyAccessedAPIType === '${api_type}');
        process.stdout.write(found ? 'yes' : 'no');
      } catch(e) { process.stdout.write('no'); }
    " 2>/dev/null || echo "no")
    [ "$check" = "yes" ] && DECLARED=true
  fi

  if [ -n "$PRIVACY_INFO_FILE" ]; then
    if grep -q "$api_type" "$PRIVACY_INFO_FILE" 2>/dev/null; then
      DECLARED=true
    fi
  fi

  CHECK_ID="PRIV-$(echo "$api_type" | grep -oP '[A-Z][a-z]+$' | head -c 3 | tr '[:lower:]' '[:upper:]')$(( RANDOM % 900 + 100 ))"

  if [ "$DECLARED" = false ]; then
    critical "$CHECK_ID" "apple" \
      "${api_type} não declarado no Privacy Manifest" \
      "O módulo que usa esta API foi detectado mas não está declarado no Privacy Manifest. A Apple rejeitará o app." \
      "Adicione ${api_type} com reason ${reason} em expo.ios.privacyManifests.NSPrivacyAccessedAPITypes no app.json." \
      "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api" \
      "app.json"
  else
    ok "$CHECK_ID" "apple" "${api_type} declarado no Privacy Manifest" "" "app.json"
  fi
done

# ─── PRIV-003: NSPrivacyTracking ─────────────────────────────────────────────

# Verificar se usa tracking SDKs
USES_TRACKING=false
TRACKING_SDKS="@react-native-firebase/analytics react-native-fbsdk-next @amplitude/analytics-react-native react-native-mixpanel"
for sdk in $TRACKING_SDKS; do
  if grep -q "\"$sdk\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
    USES_TRACKING=true
    break
  fi
done

if [ "$USES_TRACKING" = true ]; then
  # Verificar ATT implementation
  HAS_ATT=false
  if grep -q "expo-tracking-transparency\|AppTrackingTransparency" "${PROJECT_DIR}/package.json" 2>/dev/null; then
    HAS_ATT=true
  fi
  if grep -r "requestTrackingPermissionsAsync\|ATTrackingManager\|AppTrackingTransparency" \
     "${PROJECT_DIR}/src" "${PROJECT_DIR}/app" "${PROJECT_DIR}/App.tsx" "${PROJECT_DIR}/App.js" 2>/dev/null | grep -q .; then
    HAS_ATT=true
  fi

  if [ "$HAS_ATT" = false ]; then
    critical "PRIV-003" "apple" \
      "App Tracking Transparency não implementado (tracking SDK detectado)" \
      "SDKs de analytics/tracking foram detectados mas App Tracking Transparency (ATT) não está implementado. Obrigatório desde iOS 14.5." \
      "Instale expo-tracking-transparency e solicite permissão antes de inicializar SDKs de tracking." \
      "https://docs.expo.dev/versions/latest/sdk/tracking-transparency/" \
      "package.json"
  else
    ok "PRIV-003" "apple" "App Tracking Transparency implementado" "" "—"
  fi

  # NSUserTrackingUsageDescription
  if [ -f "$APP_JSON" ]; then
    val=$(node -e "
      try {
        const a = require('${APP_JSON}');
        const expo = a.expo || a;
        const v = expo.ios && expo.ios.infoPlist && expo.ios.infoPlist.NSUserTrackingUsageDescription;
        process.stdout.write(v || '__MISSING__');
      } catch(e) { process.stdout.write('__MISSING__'); }
    " 2>/dev/null || echo "__MISSING__")

    if [ "$val" = "__MISSING__" ]; then
      critical "PRIV-004" "apple" \
        "NSUserTrackingUsageDescription ausente (tracking detectado)" \
        "SDKs de tracking foram detectados. NSUserTrackingUsageDescription é obrigatório para solicitar ATT." \
        "Adicione NSUserTrackingUsageDescription em expo.ios.infoPlist no app.json." \
        "https://developer.apple.com/documentation/bundleresources/information_property_list/nsusertrackingusagedescription" \
        "app.json"
    else
      ok "PRIV-004" "apple" "NSUserTrackingUsageDescription configurada" "" "app.json"
    fi
  fi
fi

# ─── PRIV-005: NSPrivacyCollectedDataTypes ────────────────────────────────────

# Se tem Privacy Manifest, verificar se NSPrivacyCollectedDataTypes está preenchido
if [ "$HAS_EXPO_PRIVACY_MANIFEST" = true ] && [ -f "$APP_JSON" ]; then
  val=$(node -e "
    try {
      const a = require('${APP_JSON}');
      const expo = a.expo || a;
      const pm = expo.ios && expo.ios.privacyManifests;
      const collected = pm && pm.NSPrivacyCollectedDataTypes;
      process.stdout.write(Array.isArray(collected) && collected.length > 0 ? 'yes' : 'no');
    } catch(e) { process.stdout.write('no'); }
  " 2>/dev/null || echo "no")

  if [ "$val" = "no" ]; then
    info_r "PRIV-005" "apple" \
      "NSPrivacyCollectedDataTypes não preenchido no Privacy Manifest" \
      "Se o app coleta dados do usuário, declare-os em NSPrivacyCollectedDataTypes no Privacy Manifest." \
      "Adicione NSPrivacyCollectedDataTypes em expo.ios.privacyManifests com os tipos de dados coletados." \
      "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests" \
      "app.json"
  else
    ok "PRIV-005" "apple" "NSPrivacyCollectedDataTypes declarado no Privacy Manifest" "" "app.json"
  fi
fi

# ─── PRIV-006: Dependências que exigem Privacy Manifest ──────────────────────

# SDKs conhecidos que têm seus próprios privacy manifest requirements
KNOWN_PRIVACY_SDKS=(
  "@sentry/react-native:Sentry coleta dados de crash e device"
  "@react-native-firebase/crashlytics:Firebase Crashlytics coleta dados de crash"
  "react-native-mmkv:MMKV usa NSUserDefaults — declarar NSPrivacyAccessedAPICategoryUserDefaults"
  "react-native-device-info:DeviceInfo usa múltiplas APIs que precisam de declaração"
)

for sdk_entry in "${KNOWN_PRIVACY_SDKS[@]}"; do
  IFS=':' read -r sdk_name sdk_note <<< "$sdk_entry"
  if grep -q "\"$sdk_name\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
    info_r "PRIV-$(echo "$sdk_name" | tr -d '@/-' | head -c 6 | tr '[:lower:]' '[:upper:]')" "apple" \
      "SDK '${sdk_name}' requer declarações no Privacy Manifest" \
      "${sdk_note}. Verifique a documentação do SDK para as declarações necessárias." \
      "Consulte a documentação de ${sdk_name} sobre Privacy Manifest e adicione as declarações necessárias." \
      "https://docs.expo.dev/guides/apple-privacy/#third-party-libraries" \
      "package.json"
  fi
done

# ─── Output JSON ──────────────────────────────────────────────────────────────

RESULTS_JSON=""
for r in "${RESULTS[@]}"; do
  [ -z "$RESULTS_JSON" ] && RESULTS_JSON="$r" || RESULTS_JSON="${RESULTS_JSON},${r}"
done

if [ ${#RESULTS[@]} -eq 0 ]; then
  ok "PRIV-000" "apple" "Nenhum problema no Privacy Manifest detectado" "" "—"
  RESULTS_JSON="${RESULTS[0]}"
fi

echo "{\"check\":\"check-privacy-manifest\",\"results\":[${RESULTS_JSON}],\"summary\":{\"critical\":${CRITICAL},\"warning\":${WARNING},\"info\":${INFO},\"ok\":${OK}}}"
