#!/usr/bin/env bash
# check-permissions.sh — Verifica permissões declaradas vs utilizadas
# Uso: bash check-permissions.sh [diretório-do-projeto]
# Saída: JSON estruturado para stdout
set -uo pipefail

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

RESULTS=()
CRITICAL=0; WARNING=0; INFO=0; OK=0

add_result() {
  local id="$1" severity="$2" category="$3" title="$4" description="$5" fix="$6" reference="$7" file="$8"
  # Escapa strings para JSON usando printf
  local t d f
  t=$(printf '%s' "$title" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
  d=$(printf '%s' "$description" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
  f=$(printf '%s' "$fix" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
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

# ─── iOS: NS*UsageDescription ────────────────────────────────────────────────

# Mapeamento: chave do infoPlist → módulo que requer → descrição amigável
check_ios_permission() {
  local perm_key="$1"
  local modules="$2"
  local check_id="$3"
  local friendly_name="$4"

  # Verificar se algum módulo está no package.json
  local used=false
  for mod in $modules; do
    if grep -q "\"$mod\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
      used=true
      break
    fi
  done

  if [ "$used" = false ]; then
    # Verificar no código-fonte
    for mod in $modules; do
      if grep -r "from '$mod'\|require('$mod')\|import.*$mod" \
         "${PROJECT_DIR}/src" "${PROJECT_DIR}/app" "${PROJECT_DIR}/components" \
         "${PROJECT_DIR}/screens" "${PROJECT_DIR}/lib" 2>/dev/null | grep -q .; then
        used=true
        break
      fi
    done
  fi

  [ "$used" = false ] && return

  # Módulo detectado — verificar se a permissão está declarada
  local val
  val=$(SCAN_FILE="$APP_JSON" SCAN_KEY="$perm_key" node -e "
    try {
      const a = require(process.env.SCAN_FILE);
      const expo = a.expo || a;
      const v = expo.ios && expo.ios.infoPlist && expo.ios.infoPlist[process.env.SCAN_KEY];
      process.stdout.write(v !== undefined && v !== null ? String(v) : '__MISSING__');
    } catch(e) { process.stdout.write('__MISSING__'); }
  " 2>/dev/null || echo "__MISSING__")

  if [ "$val" = "__MISSING__" ]; then
    critical "$check_id" "apple" \
      "${perm_key} ausente (${friendly_name} detectado)" \
      "O módulo que requer ${friendly_name} foi detectado mas ${perm_key} não está declarado." \
      "Adicione ${perm_key} em expo.ios.infoPlist no app.json com uma descrição clara." \
      "https://developer.apple.com/documentation/bundleresources/information_property_list" \
      "app.json"
  elif echo "$val" | grep -iqE "^(this app needs|needs access|requires access|access needed|app needs)$"; then
    warning "${check_id}b" "apple" \
      "${perm_key} com descrição genérica" \
      "A descrição '${val}' é muito genérica. A Apple pode rejeitar o app." \
      "Reescreva a descrição explicando o propósito real do uso de ${friendly_name}." \
      "https://developer.apple.com/app-store/review/guidelines/#5.1.1" \
      "app.json"
  else
    ok "$check_id" "apple" "${perm_key} configurado" "" "app.json"
  fi
}

if [ -f "$APP_JSON" ]; then
  check_ios_permission "NSCameraUsageDescription"          "expo-camera expo-image-picker react-native-camera"      "PERM-001" "Câmera"
  check_ios_permission "NSMicrophoneUsageDescription"      "expo-av expo-audio react-native-audio"                  "PERM-002" "Microfone"
  check_ios_permission "NSLocationWhenInUseUsageDescription" "expo-location react-native-maps @react-native-community/geolocation" "PERM-003" "Localização"
  check_ios_permission "NSPhotoLibraryUsageDescription"    "expo-image-picker expo-media-library react-native-image-picker" "PERM-004" "Galeria de Fotos"
  check_ios_permission "NSPhotoLibraryAddUsageDescription" "expo-image-picker expo-media-library"                   "PERM-005" "Salvar na Galeria"
  check_ios_permission "NSContactsUsageDescription"        "expo-contacts react-native-contacts"                    "PERM-006" "Contatos"
  check_ios_permission "NSCalendarsUsageDescription"       "expo-calendar react-native-calendar-events"             "PERM-007" "Calendário"
  check_ios_permission "NSFaceIDUsageDescription"          "expo-local-authentication react-native-biometrics"      "PERM-008" "Face ID / Biometria"
  check_ios_permission "NSBluetoothAlwaysUsageDescription" "react-native-ble-plx expo-bluetooth"                    "PERM-009" "Bluetooth"
  check_ios_permission "NSMotionUsageDescription"          "expo-sensors react-native-sensors"                      "PERM-010" "Sensores de Movimento"
fi

# ─── Android: Permissões declaradas ──────────────────────────────────────────

ANDROID_MANIFEST="${PROJECT_DIR}/android/app/src/main/AndroidManifest.xml"
HAS_ANDROID_MANIFEST=false
[ -f "$ANDROID_MANIFEST" ] && HAS_ANDROID_MANIFEST=true

if [ "$HAS_ANDROID_MANIFEST" = true ]; then
  # Permissões declaradas no manifest
  DECLARED_PERMS=$(grep 'uses-permission' "$ANDROID_MANIFEST" | grep -oP 'android\.permission\.\w+' 2>/dev/null || true)

  # PERM-020: CAMERA declarada — verificar uso
  if echo "$DECLARED_PERMS" | grep -q "CAMERA"; then
    if grep -q "expo-camera\|react-native-camera\|expo-image-picker\|react-native-image-picker" \
       "${PROJECT_DIR}/package.json" 2>/dev/null; then
      ok "PERM-020" "google" "Permissão CAMERA declarada e módulo correspondente presente" "" "AndroidManifest.xml"
    else
      warning "PERM-020" "google" \
        "Permissão CAMERA declarada mas módulo de câmera não detectado em package.json" \
        "Permissões desnecessárias podem causar rejeição no Google Play e desconfiar usuários." \
        "Remova CAMERA do AndroidManifest se não for usar câmera." \
        "https://support.google.com/googleplay/android-developer/answer/9214102" \
        "AndroidManifest.xml"
    fi
  fi

  # PERM-021: ACCESS_FINE_LOCATION — justificar
  if echo "$DECLARED_PERMS" | grep -q "ACCESS_FINE_LOCATION"; then
    if grep -q "expo-location\|react-native-maps\|Geolocation" \
       "${PROJECT_DIR}/package.json" 2>/dev/null; then
      ok "PERM-021" "google" "Permissão ACCESS_FINE_LOCATION declarada e módulo presente" "" "AndroidManifest.xml"
    else
      warning "PERM-021" "google" \
        "ACCESS_FINE_LOCATION declarada mas módulo de localização não detectado" \
        "Permissão de localização precisa de justificativa clara na Data Safety Section." \
        "Remova se não usar localização ou adicione o módulo correspondente." \
        "https://support.google.com/googleplay/android-developer/answer/9214102" \
        "AndroidManifest.xml"
    fi
  fi

  # PERM-022: READ_CONTACTS — alta sensibilidade
  if echo "$DECLARED_PERMS" | grep -q "READ_CONTACTS\|WRITE_CONTACTS"; then
    warning "PERM-022" "google" \
      "Permissão de Contatos declarada — alta sensibilidade" \
      "Permissões de Contatos são altamente sensíveis e exigem justificativa clara no Data Safety e App Review." \
      "Certifique-se de que o uso é essencial e documente no Data Safety Section." \
      "https://support.google.com/googleplay/android-developer/answer/10787469" \
      "AndroidManifest.xml"
  fi

  # PERM-023: RECORD_AUDIO
  if echo "$DECLARED_PERMS" | grep -q "RECORD_AUDIO"; then
    ok "PERM-023" "google" "Permissão RECORD_AUDIO declarada" "" "AndroidManifest.xml"
  fi

  # PERM-024: INTERNET (deve estar presente)
  if ! echo "$DECLARED_PERMS" | grep -q "INTERNET"; then
    info_r "PERM-024" "google" \
      "Permissão INTERNET não declarada" \
      "A maioria dos apps React Native precisam da permissão INTERNET para funcionar." \
      "Adicione <uses-permission android:name='android.permission.INTERNET' /> ao AndroidManifest.xml" \
      "https://developer.android.com/reference/android/Manifest.permission#INTERNET" \
      "AndroidManifest.xml"
  else
    ok "PERM-024" "google" "Permissão INTERNET declarada" "" "AndroidManifest.xml"
  fi

else
  # Sem AndroidManifest — verificar via app.json
  if [ -f "$APP_JSON" ]; then
    ANDROID_PERMS=$(SCAN_FILE="$APP_JSON" node -e "
      try {
        const a = require(process.env.SCAN_FILE);
        const expo = a.expo || a;
        const perms = expo.android && expo.android.permissions;
        if (Array.isArray(perms)) {
          console.log(perms.join('\n'));
        } else {
          console.log('__MISSING__');
        }
      } catch(e) { console.log('__MISSING__'); }
    " 2>/dev/null || echo "__MISSING__")

    if [ "$ANDROID_PERMS" = "__MISSING__" ]; then
      info_r "PERM-030" "google" \
        "Permissões Android não explicitamente configuradas no app.json" \
        "Para Expo Managed, configure expo.android.permissions para controlar quais permissões são incluídas." \
        "Adicione 'permissions' em expo.android no app.json para limitar ao mínimo necessário." \
        "https://docs.expo.dev/versions/latest/config/app/#permissions" \
        "app.json"
    else
      ok "PERM-030" "google" "Permissões Android configuradas no app.json" "" "app.json"
    fi
  fi
fi

# ─── Output JSON ──────────────────────────────────────────────────────────────

RESULTS_JSON=""
for r in "${RESULTS[@]}"; do
  [ -z "$RESULTS_JSON" ] && RESULTS_JSON="$r" || RESULTS_JSON="${RESULTS_JSON},${r}"
done

# Se não houve resultados, adicionar OK genérico
if [ ${#RESULTS[@]} -eq 0 ]; then
  ok "PERM-000" "both" "Nenhuma permissão problemática detectada" "" "—"
  RESULTS_JSON="${RESULTS[0]}"
fi

echo "{\"check\":\"check-permissions\",\"results\":[${RESULTS_JSON}],\"summary\":{\"critical\":${CRITICAL},\"warning\":${WARNING},\"info\":${INFO},\"ok\":${OK}}}"
