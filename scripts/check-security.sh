#!/usr/bin/env bash
# check-security.sh — Verifica práticas de segurança de dados no código
# Uso: bash check-security.sh [diretório-do-projeto]
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

# Diretórios de código-fonte para busca
SRC_DIRS=()
for dir in src app components screens lib hooks services utils store; do
  [ -d "${PROJECT_DIR}/${dir}" ] && SRC_DIRS+=("${PROJECT_DIR}/${dir}")
done
# Adicionar arquivos raiz comuns
for f in App.tsx App.js App.ts index.tsx index.js; do
  [ -f "${PROJECT_DIR}/${f}" ] && SRC_DIRS+=("${PROJECT_DIR}/${f}")
done

# ─── SEC-001: AsyncStorage com dados sensíveis ────────────────────────────────

USES_ASYNC_STORAGE=false
if grep -q "async-storage\|AsyncStorage" "$PKG_JSON" 2>/dev/null; then
  USES_ASYNC_STORAGE=true
fi

if [ "$USES_ASYNC_STORAGE" = true ] && [ ${#SRC_DIRS[@]} -gt 0 ]; then
  SENSITIVE_PATTERNS="token\|password\|senha\|secret\|api_key\|apikey\|auth\|credential\|jwt\|bearer\|session"
  MATCHES=$(grep -r "AsyncStorage.setItem\|AsyncStorage.set" "${SRC_DIRS[@]}" 2>/dev/null | \
    grep -iE "$SENSITIVE_PATTERNS" | head -5 || true)

  if [ -n "$MATCHES" ]; then
    FIRST_MATCH=$(echo "$MATCHES" | head -1 | sed 's/\\/\\\\/g; s/"/\\"/g')
    critical "SEC-001" "security" \
      "AsyncStorage potencialmente usado para dados sensíveis" \
      "AsyncStorage é não-encriptado. Detectado uso com chaves que sugerem dados sensíveis. Exemplo: ${FIRST_MATCH}" \
      "Use expo-secure-store ou react-native-keychain para armazenar tokens, senhas e dados sensíveis." \
      "https://docs.expo.dev/versions/latest/sdk/securestore/" \
      "src/"
  else
    ok "SEC-001" "security" "Nenhum uso suspeito de AsyncStorage com dados sensíveis detectado" "" "—"
  fi
elif [ "$USES_ASYNC_STORAGE" = false ]; then
  ok "SEC-001" "security" "AsyncStorage não utilizado" "" "—"
fi

# ─── SEC-002: Armazenamento Seguro disponível ─────────────────────────────────

HAS_SECURE_STORAGE=false
for pkg in "expo-secure-store" "react-native-keychain" "react-native-sensitive-info"; do
  if grep -q "\"$pkg\"" "$PKG_JSON" 2>/dev/null; then
    HAS_SECURE_STORAGE=true
    ok "SEC-002" "security" "Biblioteca de armazenamento seguro presente: $pkg" "" "package.json"
    break
  fi
done

if [ "$HAS_SECURE_STORAGE" = false ]; then
  info_r "SEC-002" "security" \
    "Nenhuma biblioteca de armazenamento seguro encontrada" \
    "Se o app armazena tokens de autenticação ou dados sensíveis, use uma biblioteca de armazenamento encriptado." \
    "Instale expo-secure-store: npx expo install expo-secure-store" \
    "https://docs.expo.dev/versions/latest/sdk/securestore/" \
    "package.json"
fi

# ─── SEC-003: API Keys hardcoded no código-fonte ──────────────────────────────

if [ ${#SRC_DIRS[@]} -gt 0 ]; then
  # Padrões comuns de API keys hardcoded
  HARDCODED_PATTERNS='(api_key|apikey|api-key|secret_key|secretkey|private_key)\s*[=:]\s*["\x27][A-Za-z0-9_\-]{20,}'
  MATCHES=$(grep -rEi "$HARDCODED_PATTERNS" "${SRC_DIRS[@]}" 2>/dev/null | \
    grep -v "\.test\.\|\.spec\.\|__mocks__\|placeholder\|your_api_key\|YOUR_KEY" | \
    head -3 || true)

  if [ -n "$MATCHES" ]; then
    critical "SEC-003" "security" \
      "Possíveis API keys hardcoded no código-fonte" \
      "Credenciais hardcoded no código são um risco de segurança grave e podem ser expostas em repositórios." \
      "Mova segredos para variáveis de ambiente (.env) e acesse via expo-constants ou react-native-config. Nunca commite .env com valores reais." \
      "https://docs.expo.dev/guides/environment-variables/" \
      "src/"
  else
    ok "SEC-003" "security" "Nenhuma API key hardcoded óbvia detectada no código-fonte" "" "—"
  fi
fi

# ─── SEC-004: Arquivos .env com segredos commitados ───────────────────────────

ENV_FILES_FOUND=false
COMMITTED_ENV=""
for env_file in .env .env.local .env.production .env.staging; do
  if [ -f "${PROJECT_DIR}/${env_file}" ]; then
    ENV_FILES_FOUND=true
    # Verificar se está no .gitignore
    if ! grep -q "^${env_file}$\|^${env_file}\s" "${PROJECT_DIR}/.gitignore" 2>/dev/null; then
      COMMITTED_ENV="${COMMITTED_ENV} ${env_file}"
    fi
  fi
done

if [ -n "$COMMITTED_ENV" ]; then
  critical "SEC-004" "security" \
    "Arquivo .env não está no .gitignore:${COMMITTED_ENV}" \
    "Arquivos .env com segredos que não estão no .gitignore podem ser acidentalmente commitados e expostos." \
    "Adicione '${COMMITTED_ENV}' ao .gitignore. Crie um .env.example com valores de exemplo (sem segredos reais)." \
    "https://docs.expo.dev/guides/environment-variables/" \
    ".gitignore"
elif [ "$ENV_FILES_FOUND" = true ]; then
  ok "SEC-004" "security" "Arquivos .env encontrados e protegidos pelo .gitignore" "" ".gitignore"
else
  ok "SEC-004" "security" "Nenhum arquivo .env encontrado (verificar se variáveis de ambiente estão configuradas)" "" "—"
fi

# ─── SEC-005: URLs HTTP (não HTTPS) em código-fonte ──────────────────────────

if [ ${#SRC_DIRS[@]} -gt 0 ]; then
  HTTP_MATCHES=$(grep -rE "http://[a-zA-Z0-9]" "${SRC_DIRS[@]}" 2>/dev/null | \
    grep -v "localhost\|127\.0\.0\.1\|0\.0\.0\.0\|http://schemas\|http://www\.w3\.org\|\.test\.\|\.spec\." | \
    head -5 || true)

  if [ -n "$HTTP_MATCHES" ]; then
    FIRST_HTTP=$(echo "$HTTP_MATCHES" | head -1 | sed 's/.*http/http/' | cut -c1-80 | sed 's/"/\\"/g')
    critical "SEC-005" "security" \
      "URLs HTTP (não HTTPS) detectadas no código" \
      "URLs HTTP transmitem dados em texto claro. Pode causar rejeição nas lojas e viola boas práticas. Exemplo: ${FIRST_HTTP}" \
      "Substitua todas as URLs http:// por https://. Para Android, adicione network security config se necessário." \
      "https://developer.android.com/training/articles/security-config" \
      "src/"
  else
    ok "SEC-005" "security" "Nenhuma URL HTTP não-segura detectada no código" "" "—"
  fi
fi

# ─── SEC-006: console.log com dados sensíveis ────────────────────────────────

if [ ${#SRC_DIRS[@]} -gt 0 ]; then
  SENSITIVE_LOG_PATTERNS="console\.log.*\(.*token\|console\.log.*password\|console\.log.*senha\|console\.log.*secret\|console\.log.*auth\|console\.log.*credential"
  LOG_MATCHES=$(grep -rEi "$SENSITIVE_LOG_PATTERNS" "${SRC_DIRS[@]}" 2>/dev/null | \
    grep -v "\.test\.\|\.spec\." | head -3 || true)

  if [ -n "$LOG_MATCHES" ]; then
    warning "SEC-006" "security" \
      "console.log com possíveis dados sensíveis detectado" \
      "Logs com tokens, senhas ou credenciais podem vazar dados em produção e em logs do dispositivo." \
      "Remova ou substitua console.log sensíveis. Use uma biblioteca de logging que desativa logs em produção (ex: react-native-logs)." \
      "https://reactnative.dev/docs/debugging#examining-console-logs" \
      "src/"
  else
    ok "SEC-006" "security" "Nenhum console.log suspeito com dados sensíveis detectado" "" "—"
  fi
fi

# ─── SEC-007: eval() e Function() ────────────────────────────────────────────

if [ ${#SRC_DIRS[@]} -gt 0 ]; then
  EVAL_MATCHES=$(grep -rE "\beval\s*\(|\bnew Function\s*\(" "${SRC_DIRS[@]}" 2>/dev/null | \
    grep -v "\.test\.\|\.spec\.\|node_modules" | head -3 || true)

  if [ -n "$EVAL_MATCHES" ]; then
    warning "SEC-007" "security" \
      "Uso de eval() ou new Function() detectado" \
      "eval() e new Function() são vetores de injeção de código e violam a Content Security Policy. Podem causar rejeição nas lojas." \
      "Refatore o código para evitar eval(). Use alternativas como JSON.parse() para parsing de dados." \
      "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval#never_use_eval!" \
      "src/"
  else
    ok "SEC-007" "security" "Nenhum uso de eval() ou new Function() detectado" "" "—"
  fi
fi

# ─── SEC-008: SSL Pinning ────────────────────────────────────────────────────

HAS_SSL_PINNING=false
SSL_PKGS="react-native-ssl-pinning react-native-pinch"
for pkg in $SSL_PKGS; do
  if grep -q "\"$pkg\"" "$PKG_JSON" 2>/dev/null; then
    HAS_SSL_PINNING=true
    break
  fi
done

if [ "$HAS_SSL_PINNING" = true ]; then
  ok "SEC-008" "security" "SSL Pinning implementado" "" "package.json"
else
  info_r "SEC-008" "security" \
    "SSL Pinning não implementado" \
    "SSL Pinning previne ataques man-in-the-middle mesmo com certificados válidos. Recomendado para apps financeiros e de saúde." \
    "Considere implementar SSL Pinning com react-native-ssl-pinning para endpoints críticos." \
    "https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning" \
    "package.json"
fi

# ─── SEC-009: Expo Constants expondo segredos ─────────────────────────────────

if [ ${#SRC_DIRS[@]} -gt 0 ]; then
  CONSTANTS_SENSITIVE=$(grep -rE "Constants\.(expoConfig|manifest)\.(extra|env)" "${SRC_DIRS[@]}" 2>/dev/null | \
    grep -iE "secret|key|token|password" | head -3 || true)

  if [ -n "$CONSTANTS_SENSITIVE" ]; then
    warning "SEC-009" "security" \
      "Expo Constants acessando possíveis segredos do extra/env" \
      "Valores em expo.extra no app.json são expostos no bundle do app. Não coloque segredos lá." \
      "Segredos não devem estar em expo.extra. Use variáveis de ambiente no servidor ou EAS Secrets para builds." \
      "https://docs.expo.dev/build-reference/variables/" \
      "src/"
  else
    ok "SEC-009" "security" "Nenhum acesso suspeito a Expo Constants com segredos detectado" "" "—"
  fi
fi

# ─── SEC-010: Network Security Config Android ────────────────────────────────

ANDROID_NET_CONFIG="${PROJECT_DIR}/android/app/src/main/res/xml/network_security_config.xml"
if [ -d "${PROJECT_DIR}/android" ]; then
  if [ -f "$ANDROID_NET_CONFIG" ]; then
    # Verificar se permite cleartext
    if grep -q "cleartextTrafficPermitted=\"true\"" "$ANDROID_NET_CONFIG" 2>/dev/null; then
      warning "SEC-010" "security" \
        "Network Security Config permite tráfego cleartext (HTTP)" \
        "cleartextTrafficPermitted='true' permite conexões HTTP inseguras. Use apenas em desenvolvimento." \
        "Restrinja cleartextTrafficPermitted apenas para domínios específicos de desenvolvimento, não globalmente." \
        "https://developer.android.com/training/articles/security-config" \
        "android/app/src/main/res/xml/network_security_config.xml"
    else
      ok "SEC-010" "security" "Network Security Config não permite cleartext HTTP globalmente" "" "android/"
    fi
  else
    ok "SEC-010" "security" "Sem Network Security Config customizado (padrão seguro do Android)" "" "android/"
  fi
fi

# ─── Output JSON ──────────────────────────────────────────────────────────────

RESULTS_JSON=""
for r in "${RESULTS[@]}"; do
  [ -z "$RESULTS_JSON" ] && RESULTS_JSON="$r" || RESULTS_JSON="${RESULTS_JSON},${r}"
done

if [ ${#RESULTS[@]} -eq 0 ]; then
  ok "SEC-000" "security" "Nenhum problema de segurança detectado" "" "—"
  RESULTS_JSON="${RESULTS[0]}"
fi

echo "{\"check\":\"check-security\",\"results\":[${RESULTS_JSON}],\"summary\":{\"critical\":${CRITICAL},\"warning\":${WARNING},\"info\":${INFO},\"ok\":${OK}}}"
