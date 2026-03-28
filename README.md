# mobile-app-compliance-checker

Skill agnóstica de ferramenta para verificar conformidade de apps React Native/Expo
com as diretrizes da **Apple App Store**, **Google Play Store**, **LGPD** e boas
práticas de privacidade e segurança.

## O Que Verifica

| Domínio | Exemplos de Verificações |
|---------|--------------------------|
| Apple App Store | Privacy Manifest, Usage Descriptions, Account Deletion, IAP |
| Google Play Store | Target API Level, Data Safety Section, Permissões |
| LGPD / Privacidade | Política de Privacidade, Consentimento, Direitos do Titular |
| Segurança | AsyncStorage com dados sensíveis, API keys hardcoded, HTTPS |
| Dependências | Vulnerabilidades conhecidas, SDKs que coletam dados |

## Uso Rápido

```bash
# Na raiz do seu projeto Expo/React Native:
bash /caminho/para/skill/scripts/scan-project.sh .

# Relatório gerado em:
# ./.compliance-report/report_YYYYMMDD_HHMMSS.md
```

## Instalação

### Claude Code

```bash
# Copiar para diretório de skills do Claude Code
cp -r mobile-app-compliance-checker/ ~/.claude/skills/

# Ou referenciar localmente no projeto via .claude/settings.json
```

### OpenCode

```bash
# Adicionar referência ao SKILL.md nas instruções customizadas
# Copiar conteúdo de SKILL.md para .opencode/instructions.md
```

### GitHub Copilot

```bash
# Adicionar ao arquivo de instruções customizadas
cat SKILL.md >> .github/copilot-instructions.md
```

### Uso Standalone (sem LLM)

```bash
# Clonar o repositório
git clone https://github.com/nandofalcao/mobile-app-compliance-checker

# Executar na raiz do projeto React Native/Expo
bash mobile-app-compliance-checker/scripts/scan-project.sh /caminho/do/projeto
```

## Estrutura

```
mobile-app-compliance-checker/
├── SKILL.md                          # Skill principal (< 500 linhas)
├── references/
│   ├── apple-app-store.md            # Diretrizes Apple condensadas
│   ├── google-play-store.md          # Diretrizes Google Play condensadas
│   ├── lgpd-privacy.md               # Requisitos LGPD + Privacidade
│   ├── react-native-expo.md          # Verificações específicas RN/Expo
│   └── common-rejections.md          # Motivos comuns de rejeição + soluções
├── checklists/
│   ├── pre-submission-ios.md         # Checklist pré-submissão iOS
│   ├── pre-submission-android.md     # Checklist pré-submissão Android
│   ├── privacy-compliance.md         # Checklist privacidade/LGPD
│   └── security-checklist.md         # Checklist segurança de dados
├── scripts/
│   ├── scan-project.sh               # Orquestrador principal
│   ├── check-permissions.sh          # Analisa permissões declaradas
│   ├── check-privacy-manifest.sh     # Verifica iOS Privacy Manifest
│   ├── check-data-safety.sh          # Verifica Data Safety (Android)
│   ├── check-expo-config.sh          # Analisa app.json / app.config.js
│   ├── check-dependencies.sh         # Analisa dependências
│   ├── check-security.sh             # Verifica práticas de segurança
│   └── generate-report.sh            # Gera relatório consolidado
├── templates/
│   ├── privacy-policy-pt-br.md       # Template Política de Privacidade (PT-BR)
│   ├── terms-of-use-pt-br.md         # Template Termos de Uso (PT-BR)
│   ├── data-safety-form.md           # Guia Data Safety Google Play
│   └── app-privacy-labels.md         # Guia Privacy Labels Apple
├── evals/
│   └── evals.json                    # Casos de teste
└── README.md
```

## Níveis de Severidade

| Nível | Símbolo | Significado |
|-------|---------|-------------|
| CRITICAL | 🔴 | Causará rejeição nas lojas — corrigir imediatamente |
| WARNING | ⚠️ | Pode causar rejeição ou problema futuro — revisar |
| INFO | ℹ️ | Boa prática recomendada — considerar |
| OK | ✅ | Conformidade verificada |

## Requisitos

- `bash` 3.2+
- `node` 14+ (para parsing JSON quando necessário)
- `jq` (opcional, melhora a saída JSON)
- Sem outras dependências externas

## Compatibilidade

| Projeto | Suporte |
|---------|---------|
| Expo Managed Workflow | ✅ Completo |
| Expo Bare Workflow | ✅ Completo |
| React Native puro | ✅ Parcial (sem verificações Expo-específicas) |

## Atualizações de Diretrizes

As diretrizes das lojas mudam com frequência. Cada arquivo em `references/`
tem uma data de última atualização no cabeçalho. Verifique as fontes oficiais
regularmente:

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policy](https://support.google.com/googleplay/android-developer/answer/16810878)
- [ANPD — Autoridade Nacional de Proteção de Dados](https://www.gov.br/anpd/pt-br)

## Aviso Legal

Esta skill fornece verificações técnicas automatizadas e referências educacionais.
**Não substitui assessoria jurídica.** Para conformidade completa com LGPD e
outros marcos regulatórios, consulte um profissional de direito especializado
em proteção de dados.

## Licença

MIT — veja [LICENSE](LICENSE)
