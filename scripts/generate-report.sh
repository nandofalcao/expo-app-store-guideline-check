#!/usr/bin/env bash
# generate-report.sh — Consolida resultados dos checks em relatório markdown
# Uso: bash generate-report.sh <project_dir> <results_dir> <report_file> <app_name> <app_version> <project_type> <platforms>
set -uo pipefail

PROJECT_DIR="${1:-.}"
RESULTS_DIR="${2:-${PROJECT_DIR}/.compliance-report/results}"
REPORT_FILE="${3:-${PROJECT_DIR}/.compliance-report/report.md}"
APP_NAME="${4:-Unknown}"
APP_VERSION="${5:-Unknown}"
PROJECT_TYPE="${6:-unknown}"
PLATFORMS="${7:-ios android}"

REPORT_DATE=$(date '+%d/%m/%Y %H:%M')

# ─── Agregar todos os resultados ──────────────────────────────────────────────

TOTAL_CRITICAL=0
TOTAL_WARNING=0
TOTAL_INFO=0
TOTAL_OK=0

# Coletar todos os itens por categoria
collect_by_severity() {
  local severity="$1"
  local category_filter="$2"  # "apple", "google", "security", "both", ou "" para todos

  for json_file in "${RESULTS_DIR}"/*.json; do
    [ -f "$json_file" ] || continue
    SCAN_FILE="$json_file" SCAN_SEVERITY="$severity" SCAN_CATEGORY="$category_filter" node -e "
      try {
        const data = require(process.env.SCAN_FILE);
        const sev = process.env.SCAN_SEVERITY;
        const cat = process.env.SCAN_CATEGORY;
        const results = data.results || [];
        results.forEach(r => {
          const matchSeverity = r.severity === sev;
          const matchCategory = cat === '' || r.category === cat || r.category === 'both';
          if (matchSeverity && matchCategory) {
            const icon = {CRITICAL:'🔴',WARNING:'⚠️',INFO:'ℹ️',OK:'✅'}[r.severity] || '';
            console.log('- ' + icon + ' **' + r.title + '**');
            if (r.description) console.log('  ' + r.description);
            if (r.fix) console.log('  > **Correção:** ' + r.fix);
            if (r.reference) console.log('  > **Referência:** ' + r.reference);
            if (r.file && r.file !== '—') console.log('  > **Arquivo:** \`' + r.file + '\`');
            console.log('');
          }
        });
      } catch(e) {}
    " 2>/dev/null || true
  done
}

collect_ok_items() {
  local category_filter="$1"

  for json_file in "${RESULTS_DIR}"/*.json; do
    [ -f "$json_file" ] || continue
    SCAN_FILE="$json_file" SCAN_CATEGORY="$category_filter" node -e "
      try {
        const data = require(process.env.SCAN_FILE);
        const cat = process.env.SCAN_CATEGORY;
        const results = data.results || [];
        results.forEach(r => {
          const matchCategory = cat === '' || r.category === cat || r.category === 'both';
          if (r.severity === 'OK' && matchCategory) {
            console.log('- ✅ ' + r.title);
          }
        });
      } catch(e) {}
    " 2>/dev/null || true
  done
}

# Contar totais
for json_file in "${RESULTS_DIR}"/*.json; do
  [ -f "$json_file" ] || continue
  c=$(SCAN_FILE="$json_file" node -e "try{const r=require(process.env.SCAN_FILE);console.log(r.summary.critical||0);}catch(e){console.log(0);}" 2>/dev/null || echo 0)
  w=$(SCAN_FILE="$json_file" node -e "try{const r=require(process.env.SCAN_FILE);console.log(r.summary.warning||0);}catch(e){console.log(0);}" 2>/dev/null || echo 0)
  i=$(SCAN_FILE="$json_file" node -e "try{const r=require(process.env.SCAN_FILE);console.log(r.summary.info||0);}catch(e){console.log(0);}" 2>/dev/null || echo 0)
  o=$(SCAN_FILE="$json_file" node -e "try{const r=require(process.env.SCAN_FILE);console.log(r.summary.ok||0);}catch(e){console.log(0);}" 2>/dev/null || echo 0)
  TOTAL_CRITICAL=$((TOTAL_CRITICAL + ${c:-0}))
  TOTAL_WARNING=$((TOTAL_WARNING + ${w:-0}))
  TOTAL_INFO=$((TOTAL_INFO + ${i:-0}))
  TOTAL_OK=$((TOTAL_OK + ${o:-0}))
done

# ─── Gerar Relatório ──────────────────────────────────────────────────────────

{
cat << HEADER
# 📊 Relatório de Compliance — ${APP_NAME}

> **Data:** ${REPORT_DATE}
> **Versão do App:** ${APP_VERSION}
> **Tipo de Projeto:** ${PROJECT_TYPE}
> **Plataformas:** ${PLATFORMS}

---

## Resumo Executivo

| Nível | Quantidade | Ação |
|-------|-----------|------|
| 🔴 Crítico | ${TOTAL_CRITICAL} | Corrigir antes de submeter |
| ⚠️ Alerta | ${TOTAL_WARNING} | Revisar — pode causar problemas |
| ℹ️ Info | ${TOTAL_INFO} | Considerar para melhor compliance |
| ✅ OK | ${TOTAL_OK} | Conformidade verificada |

HEADER

# Status geral
if [ "$TOTAL_CRITICAL" -gt 0 ]; then
  echo "**Status: 🔴 NÃO PRONTO PARA SUBMISSÃO** — corrija os problemas críticos antes de enviar às lojas."
elif [ "$TOTAL_WARNING" -gt 0 ]; then
  echo "**Status: ⚠️ ATENÇÃO NECESSÁRIA** — sem problemas críticos, mas há alertas para revisar."
else
  echo "**Status: ✅ PRONTO PARA REVISÃO** — nenhum problema crítico detectado. Revise os itens de atenção."
fi

echo ""
echo "---"
echo ""

# ─── Seção Apple App Store ───────────────────────────────────────────────────
if echo "$PLATFORMS" | grep -q "ios"; then
  echo "## 🍎 Apple App Store"
  echo ""

  APPLE_CRITICAL=$(collect_by_severity "CRITICAL" "apple")
  if [ -n "$APPLE_CRITICAL" ]; then
    echo "### 🔴 Críticos"
    echo ""
    echo "$APPLE_CRITICAL"
  fi

  APPLE_WARNING=$(collect_by_severity "WARNING" "apple")
  if [ -n "$APPLE_WARNING" ]; then
    echo "### ⚠️ Alertas"
    echo ""
    echo "$APPLE_WARNING"
  fi

  APPLE_INFO=$(collect_by_severity "INFO" "apple")
  if [ -n "$APPLE_INFO" ]; then
    echo "### ℹ️ Informações"
    echo ""
    echo "$APPLE_INFO"
  fi

  APPLE_OK=$(collect_ok_items "apple")
  if [ -n "$APPLE_OK" ]; then
    echo "### ✅ OK"
    echo ""
    echo "$APPLE_OK"
    echo ""
  fi

  echo "---"
  echo ""
fi

# ─── Seção Google Play Store ─────────────────────────────────────────────────
if echo "$PLATFORMS" | grep -q "android"; then
  echo "## 🤖 Google Play Store"
  echo ""

  GOOGLE_CRITICAL=$(collect_by_severity "CRITICAL" "google")
  if [ -n "$GOOGLE_CRITICAL" ]; then
    echo "### 🔴 Críticos"
    echo ""
    echo "$GOOGLE_CRITICAL"
  fi

  GOOGLE_WARNING=$(collect_by_severity "WARNING" "google")
  if [ -n "$GOOGLE_WARNING" ]; then
    echo "### ⚠️ Alertas"
    echo ""
    echo "$GOOGLE_WARNING"
  fi

  GOOGLE_INFO=$(collect_by_severity "INFO" "google")
  if [ -n "$GOOGLE_INFO" ]; then
    echo "### ℹ️ Informações"
    echo ""
    echo "$GOOGLE_INFO"
  fi

  GOOGLE_OK=$(collect_ok_items "google")
  if [ -n "$GOOGLE_OK" ]; then
    echo "### ✅ OK"
    echo ""
    echo "$GOOGLE_OK"
    echo ""
  fi

  echo "---"
  echo ""
fi

# ─── Seção Segurança ─────────────────────────────────────────────────────────
echo "## 🔐 Segurança de Dados"
echo ""

SEC_CRITICAL=$(collect_by_severity "CRITICAL" "security")
if [ -n "$SEC_CRITICAL" ]; then
  echo "### 🔴 Críticos"
  echo ""
  echo "$SEC_CRITICAL"
fi

SEC_WARNING=$(collect_by_severity "WARNING" "security")
if [ -n "$SEC_WARNING" ]; then
  echo "### ⚠️ Alertas"
  echo ""
  echo "$SEC_WARNING"
fi

SEC_INFO=$(collect_by_severity "INFO" "security")
if [ -n "$SEC_INFO" ]; then
  echo "### ℹ️ Informações"
  echo ""
  echo "$SEC_INFO"
fi

SEC_OK=$(collect_ok_items "security")
if [ -n "$SEC_OK" ]; then
  echo "### ✅ OK"
  echo ""
  echo "$SEC_OK"
  echo ""
fi

echo "---"
echo ""

# ─── Seção Both (aplica a ambas) ─────────────────────────────────────────────
BOTH_CRITICAL=$(collect_by_severity "CRITICAL" "both")
BOTH_WARNING=$(collect_by_severity "WARNING" "both")
BOTH_INFO=$(collect_by_severity "INFO" "both")

if [ -n "$BOTH_CRITICAL" ] || [ -n "$BOTH_WARNING" ] || [ -n "$BOTH_INFO" ]; then
  echo "## 📋 Ambas as Plataformas"
  echo ""

  if [ -n "$BOTH_CRITICAL" ]; then
    echo "### 🔴 Críticos"
    echo ""
    echo "$BOTH_CRITICAL"
  fi

  if [ -n "$BOTH_WARNING" ]; then
    echo "### ⚠️ Alertas"
    echo ""
    echo "$BOTH_WARNING"
  fi

  if [ -n "$BOTH_INFO" ]; then
    echo "### ℹ️ Informações"
    echo ""
    echo "$BOTH_INFO"
  fi

  echo "---"
  echo ""
fi

# ─── Próximos Passos ─────────────────────────────────────────────────────────
cat << NEXTSTEPS
## 🚀 Próximos Passos

### Antes de Submeter

NEXTSTEPS

if [ "$TOTAL_CRITICAL" -gt 0 ]; then
  echo "1. **🔴 Corrigir todos os problemas CRÍTICOS** — não submeta sem resolver estes"
  echo "2. **⚠️ Revisar todos os ALERTAS** — decida se se aplicam ao seu contexto"
  echo "3. **ℹ️ Considerar itens INFO** — melhoram compliance mas não são obrigatórios"
  echo "4. **📋 Executar checklists manuais** — \`checklists/pre-submission-ios.md\` e/ou \`checklists/pre-submission-android.md\`"
  echo "5. **🧪 Testar em device real** — não apenas em simulador"
else
  echo "1. **⚠️ Revisar os ALERTAS** — decida quais se aplicam ao seu contexto"
  echo "2. **ℹ️ Considerar itens INFO** — melhoram compliance mas não são obrigatórios"
  echo "3. **📋 Executar checklists manuais** — \`checklists/pre-submission-ios.md\` e/ou \`checklists/pre-submission-android.md\`"
  echo "4. **🧪 Testar em device real** — não apenas em simulador"
  echo "5. **📝 Preencher formulários nas lojas** — Data Safety (Google) e Privacy Labels (Apple)"
fi

cat << FOOTER

### Recursos da Skill

| Recurso | Arquivo |
|---------|---------|
| Checklist iOS | \`checklists/pre-submission-ios.md\` |
| Checklist Android | \`checklists/pre-submission-android.md\` |
| Checklist Privacidade | \`checklists/privacy-compliance.md\` |
| Template Política de Privacidade | \`templates/privacy-policy-pt-br.md\` |
| Guia Data Safety Google | \`templates/data-safety-form.md\` |
| Guia Privacy Labels Apple | \`templates/app-privacy-labels.md\` |
| Diretrizes Apple | \`references/apple-app-store.md\` |
| Diretrizes Google Play | \`references/google-play-store.md\` |
| Requisitos LGPD | \`references/lgpd-privacy.md\` |

---

*Relatório gerado por [mobile-app-compliance-checker](https://github.com/nandofalcao/mobile-app-compliance-checker)*
*Este relatório verifica conformidade técnica. Consulte um advogado para conformidade legal completa com LGPD e outras regulamentações.*
FOOTER

} > "$REPORT_FILE"

echo "Relatório salvo em: $REPORT_FILE"
