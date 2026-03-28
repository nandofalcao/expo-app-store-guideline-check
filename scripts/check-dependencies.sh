#!/usr/bin/env bash
# check-dependencies.sh — Analisa dependências por riscos conhecidos
# Uso: bash check-dependencies.sh [diretório-do-projeto]
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

PKG_JSON="${PROJECT_DIR}/package.json"

if [ ! -f "$PKG_JSON" ]; then
  critical "DEP-000" "both" \
    "package.json não encontrado" \
    "Não foi possível analisar dependências: package.json ausente." \
    "Execute este script na raiz do projeto React Native/Expo." \
    "" "—"
  echo "{\"check\":\"check-dependencies\",\"results\":[${RESULTS[0]}],\"summary\":{\"critical\":1,\"warning\":0,\"info\":0,\"ok\":0}}"
  exit 0
fi

# ─── DEP-001: Versão do React Native ─────────────────────────────────────────

RN_VERSION=$(node -e "
  try {
    const p = require('${PKG_JSON}');
    const v = (p.dependencies && p.dependencies['react-native']) ||
              (p.devDependencies && p.devDependencies['react-native']) || '__MISSING__';
    process.stdout.write(v.replace(/[\^~>=<]/g, '').split('.').slice(0,2).join('.') || '__MISSING__');
  } catch(e) { process.stdout.write('__MISSING__'); }
" 2>/dev/null || echo "__MISSING__")

if [ "$RN_VERSION" != "__MISSING__" ]; then
  RN_MAJOR=$(echo "$RN_VERSION" | cut -d. -f1)
  RN_MINOR=$(echo "$RN_VERSION" | cut -d. -f2)

  if [ "$RN_MAJOR" -eq 0 ] && [ "$RN_MINOR" -lt 73 ] 2>/dev/null; then
    warning "DEP-001" "both" \
      "React Native desatualizado: 0.${RN_MINOR} (recomendado: 0.76+)" \
      "Versões antigas de React Native podem não suportar APIs mínimas exigidas pelas lojas ou ter vulnerabilidades conhecidas." \
      "Atualize para React Native 0.76+ ou use a versão LTS mais recente." \
      "https://reactnative.dev/blog" \
      "package.json"
  else
    ok "DEP-001" "both" "React Native atualizado: 0.${RN_MINOR}" "" "package.json"
  fi
fi

# ─── DEP-002: Expo SDK Version ────────────────────────────────────────────────

EXPO_VERSION=$(node -e "
  try {
    const p = require('${PKG_JSON}');
    const v = (p.dependencies && p.dependencies['expo']) ||
              (p.devDependencies && p.devDependencies['expo']) || '__MISSING__';
    const clean = v.replace(/[\^~>=<]/g, '');
    const major = parseInt(clean.split('.')[0]) || 0;
    process.stdout.write(major > 0 ? String(major) : '__MISSING__');
  } catch(e) { process.stdout.write('__MISSING__'); }
" 2>/dev/null || echo "__MISSING__")

if [ "$EXPO_VERSION" != "__MISSING__" ]; then
  if [ "$EXPO_VERSION" -lt 51 ] 2>/dev/null; then
    critical "DEP-002" "both" \
      "Expo SDK desatualizado: SDK ${EXPO_VERSION} (mínimo recomendado: SDK 51+)" \
      "Versões antigas do Expo SDK podem não incluir o Privacy Manifest obrigatório para iOS e ter vulnerabilidades." \
      "Atualize para Expo SDK 52 ou superior: npx expo upgrade" \
      "https://docs.expo.dev/workflow/upgrading-expo-sdk-walkthrough/" \
      "package.json"
  elif [ "$EXPO_VERSION" -lt 52 ] 2>/dev/null; then
    warning "DEP-002" "both" \
      "Expo SDK ${EXPO_VERSION} — versão nova disponível (SDK 52+)" \
      "Manter o SDK Expo atualizado garante suporte às APIs mais recentes das lojas." \
      "Considere atualizar: npx expo upgrade" \
      "https://docs.expo.dev/workflow/upgrading-expo-sdk-walkthrough/" \
      "package.json"
  else
    ok "DEP-002" "both" "Expo SDK atualizado: SDK ${EXPO_VERSION}" "" "package.json"
  fi
fi

# ─── DEP-003: SDKs com coleta de dados — disclosure obrigatório ───────────────

declare -a DATA_COLLECTING_SDKS=(
  "@react-native-firebase/analytics:Coleta eventos, propriedades de usuário e dados de dispositivo"
  "@react-native-firebase/crashlytics:Coleta crash logs, stack traces e dados de dispositivo"
  "@amplitude/analytics-react-native:Coleta eventos, sessões e propriedades de usuário"
  "react-native-mixpanel:Coleta eventos, propriedades e dados de perfil"
  "react-native-fbsdk-next:Coleta dados do Facebook para analytics e publicidade"
  "react-native-google-mobile-ads:Coleta Advertising ID e dados de comportamento"
  "@segment/analytics-react-native:Coleta e encaminha eventos para múltiplos destinos"
  "react-native-branch:Coleta dados de atribuição e deep linking"
  "react-native-appsflyer:Coleta dados de atribuição de instalação e eventos"
  "react-native-adjust:Coleta dados de atribuição mobile"
)

DATA_SDK_COUNT=0
for sdk_entry in "${DATA_COLLECTING_SDKS[@]}"; do
  IFS=':' read -r sdk_name sdk_desc <<< "$sdk_entry"
  if grep -q "\"$sdk_name\"" "$PKG_JSON" 2>/dev/null; then
    DATA_SDK_COUNT=$((DATA_SDK_COUNT+1))
    info_r "DEP-003-${DATA_SDK_COUNT}" "both" \
      "SDK coleta dados: $sdk_name" \
      "${sdk_desc}. Deve ser declarado na Data Safety (Google) e Privacy Labels (Apple)." \
      "Certifique-se de declarar os dados coletados por ${sdk_name} nas seções de privacidade de ambas as lojas." \
      "https://support.google.com/googleplay/android-developer/answer/10787469" \
      "package.json"
  fi
done

if [ "$DATA_SDK_COUNT" -eq 0 ]; then
  ok "DEP-003" "both" "Nenhum SDK de coleta de dados de terceiros detectado" "" "package.json"
fi

# ─── DEP-004: Pacotes deprecated ou com problemas conhecidos ─────────────────

declare -a DEPRECATED_PKGS=(
  "@react-native-community/async-storage:Migrado para @react-native-async-storage/async-storage"
  "react-native-camera:Substituído por react-native-vision-camera (mais ativo e mantido)"
  "react-native-fcm:Firebase Cloud Messaging agora via @react-native-firebase/messaging"
  "react-native-code-push:CodePush está sendo descontinuado pelo Visual Studio App Center"
  "react-native-linear-gradient:Use expo-linear-gradient se usar Expo"
  "@react-native-community/netinfo:Verificar compatibilidade com novas versões do RN"
)

for pkg_entry in "${DEPRECATED_PKGS[@]}"; do
  IFS=':' read -r pkg_name pkg_note <<< "$pkg_entry"
  if grep -q "\"$pkg_name\"" "$PKG_JSON" 2>/dev/null; then
    warning "DEP-004-$(echo "$pkg_name" | tr -d '@/-' | head -c 8)" "both" \
      "Pacote possivelmente deprecated: $pkg_name" \
      "${pkg_note}." \
      "Avalie se é necessário migrar para a alternativa recomendada." \
      "https://www.npmjs.com/package/${pkg_name}" \
      "package.json"
  fi
done

# ─── DEP-005: npm audit (se disponível) ──────────────────────────────────────

if command -v npm &>/dev/null && [ -f "${PROJECT_DIR}/package-lock.json" ]; then
  AUDIT_OUTPUT=$(cd "$PROJECT_DIR" && npm audit --json 2>/dev/null || true)
  if [ -n "$AUDIT_OUTPUT" ]; then
    CRITICAL_VULNS=$(echo "$AUDIT_OUTPUT" | node -e "
      let data = '';
      process.stdin.on('data', d => data += d);
      process.stdin.on('end', () => {
        try {
          const r = JSON.parse(data);
          const meta = r.metadata && r.metadata.vulnerabilities;
          process.stdout.write(meta ? String(meta.critical || 0) : '0');
        } catch(e) { process.stdout.write('0'); }
      });
    " 2>/dev/null || echo "0")

    HIGH_VULNS=$(echo "$AUDIT_OUTPUT" | node -e "
      let data = '';
      process.stdin.on('data', d => data += d);
      process.stdin.on('end', () => {
        try {
          const r = JSON.parse(data);
          const meta = r.metadata && r.metadata.vulnerabilities;
          process.stdout.write(meta ? String(meta.high || 0) : '0');
        } catch(e) { process.stdout.write('0'); }
      });
    " 2>/dev/null || echo "0")

    if [ "$CRITICAL_VULNS" -gt 0 ] 2>/dev/null; then
      critical "DEP-005" "security" \
        "npm audit: ${CRITICAL_VULNS} vulnerabilidade(s) CRÍTICA(S) encontrada(s)" \
        "Dependências com vulnerabilidades críticas representam risco de segurança e podem causar rejeição nas lojas." \
        "Execute 'npm audit fix' para corrigir automaticamente. Revise manualmente as que precisam de intervenção." \
        "https://docs.npmjs.com/cli/v10/commands/npm-audit" \
        "package-lock.json"
    elif [ "$HIGH_VULNS" -gt 0 ] 2>/dev/null; then
      warning "DEP-005" "security" \
        "npm audit: ${HIGH_VULNS} vulnerabilidade(s) de alta severidade encontrada(s)" \
        "Dependências com vulnerabilidades altas representam risco de segurança." \
        "Execute 'npm audit' para ver detalhes e 'npm audit fix' para corrigir o que for possível." \
        "https://docs.npmjs.com/cli/v10/commands/npm-audit" \
        "package-lock.json"
    else
      ok "DEP-005" "security" "npm audit: nenhuma vulnerabilidade crítica ou alta encontrada" "" "package-lock.json"
    fi
  fi
elif command -v yarn &>/dev/null && [ -f "${PROJECT_DIR}/yarn.lock" ]; then
  info_r "DEP-005" "security" \
    "Verifique vulnerabilidades com yarn audit" \
    "Não foi possível executar yarn audit automaticamente. Execute manualmente para verificar vulnerabilidades." \
    "Execute 'yarn audit' na raiz do projeto e corrija as vulnerabilidades encontradas." \
    "https://yarnpkg.com/cli/npm/audit" \
    "yarn.lock"
fi

# ─── DEP-006: Licenças de dependências ───────────────────────────────────────

# Verificar presença de pacotes com licenças GPL (incompatíveis com App Store)
GPL_PACKAGES=$(node -e "
  try {
    const p = require('${PKG_JSON}');
    const deps = {...(p.dependencies||{}), ...(p.devDependencies||{})};
    const gplPkgs = Object.keys(deps).filter(d => d.includes('gpl') || d.includes('GPL'));
    process.stdout.write(gplPkgs.join(', ') || '__NONE__');
  } catch(e) { process.stdout.write('__NONE__'); }
" 2>/dev/null || echo "__NONE__")

if [ "$GPL_PACKAGES" != "__NONE__" ] && [ -n "$GPL_PACKAGES" ]; then
  warning "DEP-006" "apple" \
    "Possíveis pacotes GPL detectados: $GPL_PACKAGES" \
    "Licenças GPL podem ser incompatíveis com a distribuição via App Store (Apple). Verifique cada dependência." \
    "Revise as licenças dos pacotes e substitua por alternativas com licenças permissivas (MIT, Apache 2.0, BSD)." \
    "https://developer.apple.com/app-store/review/guidelines/#5.2.1" \
    "package.json"
else
  ok "DEP-006" "both" "Nenhum pacote com licença GPL óbvia detectado" "" "package.json"
fi

# ─── Output JSON ──────────────────────────────────────────────────────────────

RESULTS_JSON=""
for r in "${RESULTS[@]}"; do
  [ -z "$RESULTS_JSON" ] && RESULTS_JSON="$r" || RESULTS_JSON="${RESULTS_JSON},${r}"
done

if [ ${#RESULTS[@]} -eq 0 ]; then
  ok "DEP-000" "both" "Nenhum problema de dependências detectado" "" "—"
  RESULTS_JSON="${RESULTS[0]}"
fi

echo "{\"check\":\"check-dependencies\",\"results\":[${RESULTS_JSON}],\"summary\":{\"critical\":${CRITICAL},\"warning\":${WARNING},\"info\":${INFO},\"ok\":${OK}}}"
