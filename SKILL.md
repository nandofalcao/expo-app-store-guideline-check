---
name: mobile-app-compliance-checker
description: >
  Verifica se uma aplicação React Native/Expo está em conformidade com as
  diretrizes da Apple App Store, Google Play Store, LGPD e políticas de
  privacidade. Use esta skill sempre que o usuário mencionar: compliance,
  conformidade, submissão app store, rejeição app store, privacy policy,
  política de privacidade, LGPD, proteção de dados, data safety, privacy
  manifest, app review, pre-submission checklist, verificação de segurança
  de app mobile, ou qualquer menção a preparar um app para publicação nas
  lojas. Também acione quando o usuário perguntar sobre permissões de app,
  coleta de dados, ou requisitos de privacidade para apps mobile.
version: "1.0.0"
updated: "2026-03-28"
platforms: [ios, android]
frameworks: [react-native, expo]
---

# Mobile App Compliance Checker

Skill para verificar conformidade de apps React Native/Expo com diretrizes da
Apple App Store, Google Play Store, LGPD e boas práticas de privacidade/segurança.

---

## O Que Esta Skill Faz

1. **Analisa o projeto automaticamente** via scripts bash
2. **Classifica problemas** em: CRÍTICO / ALERTA / INFO / OK
3. **Gera relatório acionável** com correções sugeridas para cada problema
4. **Cobre quatro domínios:** Apple App Store, Google Play, LGPD/Privacidade, Segurança

---

## Fluxo de Execução

### Análise Automatizada (recomendado)

```bash
# Na raiz do projeto React Native/Expo:
bash /caminho/para/skill/scripts/scan-project.sh .

# O relatório será gerado em:
# ./.compliance-report/report_YYYYMMDD_HHMMSS.md
```

### Análise por Domínio (quando necessário verificar só uma área)

```bash
# Somente configuração Expo
bash scripts/check-expo-config.sh /caminho/projeto

# Somente permissões
bash scripts/check-permissions.sh /caminho/projeto

# Somente iOS Privacy Manifest
bash scripts/check-privacy-manifest.sh /caminho/projeto

# Somente Google Data Safety
bash scripts/check-data-safety.sh /caminho/projeto

# Somente segurança
bash scripts/check-security.sh /caminho/projeto

# Somente dependências
bash scripts/check-dependencies.sh /caminho/projeto
```

---

## Quando Usar Cada Recurso

| Situação | Recurso |
|----------|---------|
| Preparar app para submissão | `scripts/scan-project.sh` + checklists relevantes |
| Rejeição Apple | `references/apple-app-store.md` + `references/common-rejections.md` |
| Rejeição Google Play | `references/google-play-store.md` + `references/common-rejections.md` |
| Configurar Privacy Manifest iOS | `references/react-native-expo.md` + `scripts/check-privacy-manifest.sh` |
| Preencher Data Safety Google | `templates/data-safety-form.md` + `scripts/check-data-safety.sh` |
| Preencher Privacy Labels Apple | `templates/app-privacy-labels.md` |
| Criar Política de Privacidade | `templates/privacy-policy-pt-br.md` |
| Criar Termos de Uso | `templates/terms-of-use-pt-br.md` |
| Verificar conformidade LGPD | `references/lgpd-privacy.md` + `checklists/privacy-compliance.md` |
| Checklist completo iOS | `checklists/pre-submission-ios.md` |
| Checklist completo Android | `checklists/pre-submission-android.md` |
| Verificar segurança de dados | `checklists/security-checklist.md` + `scripts/check-security.sh` |

---

## Estrutura dos Resultados

Cada verificação produz resultados com a seguinte estrutura:

```json
{
  "id": "EXPO-001",
  "severity": "CRITICAL",
  "category": "apple",
  "title": "Descrição curta do problema",
  "description": "Explicação detalhada",
  "fix": "Como corrigir",
  "reference": "URL ou doc de referência",
  "file": "arquivo relevante"
}
```

### Níveis de Severidade

| Nível | Símbolo | Ação Necessária |
|-------|---------|-----------------|
| CRITICAL | 🔴 | Corrigir antes de submeter — causará rejeição |
| WARNING | ⚠️ | Revisar — pode causar rejeição ou problema futuro |
| INFO | ℹ️ | Considerar — boa prática mas não obrigatório |
| OK | ✅ | Conformidade verificada |

---

## Domínios de Verificação

### Apple App Store
- **Configuração básica:** bundle identifier, version, build number
- **Permissões iOS:** NS*UsageDescription strings
- **Privacy Manifest:** PrivacyInfo.xcprivacy / expo.ios.privacyManifests
- **App Tracking Transparency:** implementação para tracking
- **Account Deletion:** obrigatório se há criação de conta
- **IAP/Subscriptions:** restore purchases, preços visíveis

Referências: `references/apple-app-store.md`

### Google Play Store
- **Configuração básica:** package name, versionCode
- **Target API Level:** Android 15 (API 35) para novos apps 2025+
- **Data Safety Section:** preparação e preenchimento
- **Permissões Android:** `<uses-permission>` justificadas
- **Content Rating:** questionário preenchido

Referências: `references/google-play-store.md`

### LGPD / Privacidade
- **Política de Privacidade:** presença, acessibilidade, idioma
- **Consentimento:** mecanismo explícito antes de coletar dados
- **Direitos do titular:** acesso, exclusão, portabilidade
- **DPO:** identificação do encarregado
- **Compartilhamento:** lista de terceiros que recebem dados

Referências: `references/lgpd-privacy.md`

### Segurança de Dados
- **Armazenamento:** sem dados sensíveis em AsyncStorage
- **Comunicação:** HTTPS obrigatório, SSL pinning recomendado
- **Segredos:** sem API keys hardcoded ou em .env commitado
- **Logs:** sem dados sensíveis em console.log

Referências: `checklists/security-checklist.md`

---

## Configuração de Projeto

A skill detecta automaticamente:

| Indicador | Tipo de Projeto |
|-----------|-----------------|
| `app.json` com chave `"expo"` | Expo Managed Workflow |
| `app.json` + pasta `ios/` ou `android/` | Expo Bare Workflow |
| `package.json` com `react-native` sem `expo` | React Native puro |

---

## Interpretando o Relatório

O relatório gerado (`compliance-report.md`) é dividido em seções:

1. **Resumo Executivo** — contagem por severidade
2. **Apple App Store** — problemas específicos iOS
3. **Google Play Store** — problemas específicos Android
4. **LGPD / Privacidade** — conformidade com lei brasileira
5. **Segurança** — vulnerabilidades de dados
6. **Dependências** — riscos em pacotes de terceiros
7. **Próximos Passos** — ordem de ação recomendada

### Priorização de Correções

```
1. Corrigir todos os 🔴 CRÍTICO
2. Revisar todos os ⚠️ ALERTA (decidir se aplica ao contexto)
3. Considerar ℹ️ INFO para melhor compliance
4. ✅ OK não precisa de ação
```

---

## Limitações Importantes

- Scripts analisam configuração e código estático — não testam runtime
- Verificação de segurança identifica padrões comuns, não é pentest
- Análise LGPD cobre requisitos técnicos; aspectos jurídicos requerem advogado
- Diretrizes das lojas mudam — verifique datas de atualização nos reference files
- Não substitui revisão manual dos checklists antes de submeter

---

## Atualizando a Skill

Os reference files têm datas de atualização no cabeçalho. Quando as diretrizes
mudarem, atualize os arquivos em `references/` e os checks correspondentes nos
scripts. Mantenha `version` e `updated` neste SKILL.md atualizados.

---

## Recursos Adicionais

- `references/` — diretrizes condensadas por plataforma
- `checklists/` — checklists interativos pré-submissão
- `templates/` — templates de documentos legais e formulários
- `scripts/` — automação bash para análise de projeto
- `evals/evals.json` — casos de teste para validar a skill
