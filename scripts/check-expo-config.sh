#!/usr/bin/env bash
# check-expo-config.sh — Verifica configuração do app.json / app.config.js
# Uso: bash check-expo-config.sh [diretório-do-projeto]
# Saída: JSON estruturado para stdout
set -uo pipefail

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

RESULTS=()
CRITICAL=0
WARNING=0
INFO=0
OK=0

# ─── Helpers ──────────────────────────────────────────────────────────────────

add_result() {
  local id="$1" severity="$2" category="$3" title="$4" description="$5" fix="$6" reference="$7" file="$8"
  RESULTS+=("{\"id\":\"${id}\",\"severity\":\"${severity}\",\"category\":\"${category}\",\"title\":$(echo "$title" | node -e 'process.stdout.write(JSON.stringify(require("fs").readFileSync("/dev/stdin","utf8").trim()))' 2>/dev/null || echo "\"${title}\""),\"description\":$(echo "$description" | node -e 'process.stdout.write(JSON.stringify(require("fs").readFileSync("/dev/stdin","utf8").trim()))' 2>/dev/null || echo "\"${description}\""),\"fix\":$(echo "$fix" | node -e 'process.stdout.write(JSON.stringify(require("fs").readFileSync("/dev/stdin","utf8").trim()))' 2>/dev/null || echo "\"${fix}\""),\"reference\":\"${reference}\",\"file\":\"${file}\"}")
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
info()     { add_result "$1" "INFO"     "$2" "$3" "$4" "$5" "$6" "$7"; }

# ─── Parsing do app.json ──────────────────────────────────────────────────────

APP_JSON="${PROJECT_DIR}/app.json"

if [ ! -f "$APP_JSON" ]; then
  critical "EXPO-000" "config" \
    "app.json não encontrado" \
    "O arquivo app.json é obrigatório para projetos Expo." \
    "Crie um app.json na raiz do projeto com as configurações básicas do Expo." \
    "https://docs.expo.dev/versions/latest/config/app/" \
    "app.json"
  # Tentar verificar app.config.js
  if [ ! -f "${PROJECT_DIR}/app.config.js" ] && [ ! -f "${PROJECT_DIR}/app.config.ts" ]; then
    # Nem app.json nem app.config.js — emitir resultados e sair
    echo "{\"check\":\"check-expo-config\",\"results\":[$(IFS=,; echo "${RESULTS[*]}")],\"summary\":{\"critical\":${CRITICAL},\"warning\":${WARNING},\"info\":${INFO},\"ok\":${OK}}}"
    exit 0
  fi
fi

# Extrair valores do app.json via node
get_val() {
  SCAN_FILE="$APP_JSON" SCAN_KEY="${1}" node -e "
    try {
      const a = require(process.env.SCAN_FILE);
      const expo = a.expo || a;
      const path = process.env.SCAN_KEY.split('.');
      let val = expo;
      for (const k of path) { val = val && val[k]; }
      if (val === undefined || val === null) {
        process.stdout.write('__MISSING__');
      } else {
        process.stdout.write(String(val));
      }
    } catch(e) {
      process.stdout.write('__ERROR__');
    }
  " 2>/dev/null || echo "__ERROR__"
}

get_array() {
  SCAN_FILE="$APP_JSON" SCAN_KEY="${1}" node -e "
    try {
      const a = require(process.env.SCAN_FILE);
      const expo = a.expo || a;
      const path = process.env.SCAN_KEY.split('.');
      let val = expo;
      for (const k of path) { val = val && val[k]; }
      if (Array.isArray(val)) {
        process.stdout.write(val.join('\n'));
      } else {
        process.stdout.write('__MISSING__');
      }
    } catch(e) {
      process.stdout.write('__MISSING__');
    }
  " 2>/dev/null || echo "__MISSING__"
}

# ─── Verificações ─────────────────────────────────────────────────────────────

# EXPO-001: Bundle Identifier iOS
val=$(get_val "ios.bundleIdentifier")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  critical "EXPO-001" "apple" \
    "Bundle Identifier iOS não definido" \
    "expo.ios.bundleIdentifier é obrigatório para submeter ao App Store." \
    "Adicione 'bundleIdentifier' em expo.ios no app.json. Ex: 'com.empresa.app'" \
    "https://docs.expo.dev/versions/latest/config/app/#bundleidentifier" \
    "app.json"
else
  ok "EXPO-001" "apple" "Bundle Identifier iOS definido: $val" "" "app.json"
fi

# EXPO-002: Package Android
val=$(get_val "android.package")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  critical "EXPO-002" "google" \
    "Package Android não definido" \
    "expo.android.package é obrigatório para submeter ao Google Play." \
    "Adicione 'package' em expo.android no app.json. Ex: 'com.empresa.app'" \
    "https://docs.expo.dev/versions/latest/config/app/#package" \
    "app.json"
else
  ok "EXPO-002" "google" "Package Android definido: $val" "" "app.json"
fi

# EXPO-003: Build Number iOS
val=$(get_val "ios.buildNumber")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  warning "EXPO-003" "apple" \
    "Build Number iOS não definido" \
    "expo.ios.buildNumber deve ser incrementado a cada submissão ao App Store." \
    "Adicione 'buildNumber' em expo.ios no app.json. Ex: '1'" \
    "https://docs.expo.dev/versions/latest/config/app/#buildnumber" \
    "app.json"
else
  ok "EXPO-003" "apple" "Build Number iOS definido: $val" "" "app.json"
fi

# EXPO-004: Version Code Android
val=$(get_val "android.versionCode")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  warning "EXPO-004" "google" \
    "Version Code Android não definido" \
    "expo.android.versionCode deve ser um inteiro incrementado a cada submissão ao Google Play." \
    "Adicione 'versionCode' em expo.android no app.json. Ex: 1" \
    "https://docs.expo.dev/versions/latest/config/app/#versioncode" \
    "app.json"
else
  ok "EXPO-004" "google" "Version Code Android definido: $val" "" "app.json"
fi

# EXPO-005: Privacy Manifest iOS
val=$(get_val "ios.privacyManifests")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  critical "EXPO-005" "apple" \
    "Privacy Manifest iOS não configurado" \
    "A Apple exige PrivacyInfo.xcprivacy desde maio de 2024. No Expo, configure via expo.ios.privacyManifests no app.json." \
    "Adicione 'privacyManifests' em expo.ios com NSPrivacyAccessedAPITypes e as APIs utilizadas pelo app." \
    "https://docs.expo.dev/guides/apple-privacy/" \
    "app.json"
else
  ok "EXPO-005" "apple" "Privacy Manifest iOS configurado" "" "app.json"
fi

# EXPO-006: Privacy Policy URL
val_ios=$(get_val "ios.privacyPolicyUrl")
val_privacy=$(get_val "privacyPolicyUrl")
if [ "$val_ios" = "__MISSING__" ] && [ "$val_privacy" = "__MISSING__" ]; then
  critical "EXPO-006" "both" \
    "URL da Política de Privacidade não encontrada" \
    "Apple e Google exigem uma Política de Privacidade. A URL deve estar configurada no app.json e informada nas lojas." \
    "Adicione 'privacyPolicyUrl' no app.json com a URL da sua política de privacidade." \
    "https://developer.apple.com/app-store/review/guidelines/#privacy" \
    "app.json"
else
  ok "EXPO-006" "both" "URL de Política de Privacidade configurada" "" "app.json"
fi

# EXPO-007: Ícone do app
val=$(get_val "icon")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  warning "EXPO-007" "both" \
    "Ícone do app não configurado" \
    "expo.icon é necessário para submissão em ambas as lojas." \
    "Adicione 'icon' no app.json apontando para um arquivo PNG 1024x1024." \
    "https://docs.expo.dev/versions/latest/config/app/#icon" \
    "app.json"
else
  ok "EXPO-007" "both" "Ícone do app configurado: $val" "" "app.json"
fi

# EXPO-008: Splash Screen
val=$(get_val "splash")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  warning "EXPO-008" "both" \
    "Splash Screen não configurada" \
    "expo.splash é necessário para uma boa experiência de usuário e é avaliado durante o review." \
    "Adicione configuração de 'splash' no app.json com imagem e backgroundColor." \
    "https://docs.expo.dev/versions/latest/config/app/#splash" \
    "app.json"
else
  ok "EXPO-008" "both" "Splash Screen configurada" "" "app.json"
fi

# EXPO-009: Suporte a Tablet iOS
val=$(get_val "ios.supportsTablet")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  info "EXPO-009" "apple" \
    "supportsTablet não explicitamente definido" \
    "Defina explicitamente se o app suporta iPad para evitar ambiguidade durante o review." \
    "Adicione 'supportsTablet: true' ou 'false' em expo.ios no app.json." \
    "https://developer.apple.com/app-store/review/guidelines/#2.4.1" \
    "app.json"
else
  ok "EXPO-009" "apple" "supportsTablet definido: $val" "" "app.json"
fi

# EXPO-010: App Scheme (Deep Linking)
val=$(get_val "scheme")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  info "EXPO-010" "both" \
    "Scheme (deep linking) não configurado" \
    "Configurar um scheme é necessário para deep linking e Universal Links." \
    "Adicione 'scheme' no app.json. Ex: 'meuapp'" \
    "https://docs.expo.dev/versions/latest/config/app/#scheme" \
    "app.json"
else
  ok "EXPO-010" "both" "Scheme configurado: $val" "" "app.json"
fi

# EXPO-011: Versão do App
val=$(get_val "version")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  critical "EXPO-011" "both" \
    "Versão do app não definida" \
    "expo.version é obrigatório. Deve seguir o formato semver (ex: 1.0.0)." \
    "Adicione 'version' no app.json seguindo semver." \
    "https://docs.expo.dev/versions/latest/config/app/#version" \
    "app.json"
else
  ok "EXPO-011" "both" "Versão do app definida: $val" "" "app.json"
fi

# EXPO-012: Nome do App
val=$(get_val "name")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  critical "EXPO-012" "both" \
    "Nome do app não definido" \
    "expo.name é obrigatório — é o nome exibido embaixo do ícone no dispositivo." \
    "Adicione 'name' no app.json com o nome do seu aplicativo." \
    "https://docs.expo.dev/versions/latest/config/app/#name" \
    "app.json"
else
  ok "EXPO-012" "both" "Nome do app definido: $val" "" "app.json"
fi

# EXPO-013: Orientação
val=$(get_val "orientation")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  info "EXPO-013" "both" \
    "Orientação do app não configurada" \
    "Definir 'orientation' evita rotações inesperadas que podem ser avaliadas negativamente." \
    "Adicione 'orientation' no app.json: 'portrait', 'landscape' ou 'default'." \
    "https://docs.expo.dev/versions/latest/config/app/#orientation" \
    "app.json"
else
  ok "EXPO-013" "both" "Orientação configurada: $val" "" "app.json"
fi

# EXPO-014: NSCameraUsageDescription (se usa câmera)
USES_CAMERA=false
if grep -r "expo-camera\|react-native-camera\|ImagePicker\|expo-image-picker" "${PROJECT_DIR}/package.json" > /dev/null 2>&1; then
  USES_CAMERA=true
fi

if [ "$USES_CAMERA" = true ]; then
  val=$(get_val "ios.infoPlist.NSCameraUsageDescription")
  if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
    critical "EXPO-014" "apple" \
      "NSCameraUsageDescription ausente (câmera detectada)" \
      "O app usa câmera mas não declara NSCameraUsageDescription. A Apple rejeitará o app." \
      "Adicione 'NSCameraUsageDescription' em expo.ios.infoPlist com uma descrição clara do uso." \
      "https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription" \
      "app.json"
  else
    # Verificar se a descrição não é genérica
    if echo "$val" | grep -iqE "^(this app needs|needs access|requires access|camera access)$"; then
      warning "EXPO-014b" "apple" \
        "NSCameraUsageDescription muito genérica" \
        "A Apple pode rejeitar descrições de permissão genéricas. Descreva o propósito real." \
        "Reescreva a descrição explicando especificamente para que o app usa a câmera." \
        "https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription" \
        "app.json"
    else
      ok "EXPO-014" "apple" "NSCameraUsageDescription configurada" "" "app.json"
    fi
  fi
fi

# EXPO-015: NSLocationWhenInUseUsageDescription (se usa localização)
USES_LOCATION=false
if grep -r "expo-location\|react-native-maps\|Geolocation" "${PROJECT_DIR}/package.json" > /dev/null 2>&1; then
  USES_LOCATION=true
fi

if [ "$USES_LOCATION" = true ]; then
  val=$(get_val "ios.infoPlist.NSLocationWhenInUseUsageDescription")
  if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
    critical "EXPO-015" "apple" \
      "NSLocationWhenInUseUsageDescription ausente (localização detectada)" \
      "O app usa localização mas não declara NSLocationWhenInUseUsageDescription." \
      "Adicione 'NSLocationWhenInUseUsageDescription' em expo.ios.infoPlist." \
      "https://docs.expo.dev/versions/latest/sdk/location/#configuration-in-appjsonappconfigjs" \
      "app.json"
  else
    ok "EXPO-015" "apple" "NSLocationWhenInUseUsageDescription configurada" "" "app.json"
  fi

  # Background location
  val_bg=$(get_val "ios.infoPlist.NSLocationAlwaysAndWhenInUseUsageDescription")
  if [ "$val_bg" != "__MISSING__" ] && [ "$val_bg" != "__ERROR__" ]; then
    warning "EXPO-015b" "apple" \
      "Localização em background declarada — justificativa adicional obrigatória" \
      "Background location requer aprovação especial da Apple. Certifique-se de que o uso é essencial." \
      "Documente o caso de uso no App Review Notes e em expo.ios.infoPlist.UIBackgroundModes." \
      "https://developer.apple.com/app-store/review/guidelines/#5.1.1" \
      "app.json"
  fi
fi

# EXPO-016: NSMicrophoneUsageDescription (se usa microfone)
USES_MIC=false
if grep -r "expo-av\|react-native-audio\|Audio\." "${PROJECT_DIR}/package.json" > /dev/null 2>&1; then
  USES_MIC=true
fi

if [ "$USES_MIC" = true ]; then
  val=$(get_val "ios.infoPlist.NSMicrophoneUsageDescription")
  if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
    critical "EXPO-016" "apple" \
      "NSMicrophoneUsageDescription ausente (áudio detectado)" \
      "O app usa áudio/microfone mas não declara NSMicrophoneUsageDescription." \
      "Adicione 'NSMicrophoneUsageDescription' em expo.ios.infoPlist." \
      "https://developer.apple.com/documentation/bundleresources/information_property_list/nsmicrophoneusagedescription" \
      "app.json"
  else
    ok "EXPO-016" "apple" "NSMicrophoneUsageDescription configurada" "" "app.json"
  fi
fi

# EXPO-017: Android adaptiveIcon
val=$(get_val "android.adaptiveIcon")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  warning "EXPO-017" "google" \
    "Adaptive Icon Android não configurado" \
    "Android 8.0+ usa Adaptive Icons. Sem ele, o ícone pode aparecer mal formatado em alguns launchers." \
    "Adicione 'adaptiveIcon' em expo.android com 'foregroundImage' e 'backgroundColor'." \
    "https://docs.expo.dev/versions/latest/config/app/#adaptiveicon" \
    "app.json"
else
  ok "EXPO-017" "google" "Adaptive Icon Android configurado" "" "app.json"
fi

# EXPO-018: Slug do app
val=$(get_val "slug")
if [ "$val" = "__MISSING__" ] || [ "$val" = "__ERROR__" ]; then
  warning "EXPO-018" "both" \
    "Slug do app não definido" \
    "expo.slug é necessário para publicação no Expo e EAS Build." \
    "Adicione 'slug' no app.json. Deve ser único e em kebab-case." \
    "https://docs.expo.dev/versions/latest/config/app/#slug" \
    "app.json"
else
  ok "EXPO-018" "both" "Slug definido: $val" "" "app.json"
fi

# ─── Output JSON ──────────────────────────────────────────────────────────────

RESULTS_JSON=""
for r in "${RESULTS[@]}"; do
  [ -z "$RESULTS_JSON" ] && RESULTS_JSON="$r" || RESULTS_JSON="${RESULTS_JSON},${r}"
done

echo "{\"check\":\"check-expo-config\",\"results\":[${RESULTS_JSON}],\"summary\":{\"critical\":${CRITICAL},\"warning\":${WARNING},\"info\":${INFO},\"ok\":${OK}}}"
