# mobile-app-compliance-checker

Tool-agnostic skill to verify compliance of React Native/Expo apps
with **Apple App Store**, **Google Play Store**, **LGPD** guidelines and
privacy and security best practices.

## What It Checks

| Domain | Example Checks |
|--------|----------------|
| Apple App Store | Privacy Manifest, Usage Descriptions, Account Deletion, IAP |
| Google Play Store | Target API Level, Data Safety Section, Permissions |
| LGPD / Privacy | Privacy Policy, Consent, Data Subject Rights |
| Security | AsyncStorage with sensitive data, hardcoded API keys, HTTPS |
| Dependencies | Known vulnerabilities, SDKs that collect data |

## Quick Start

```bash
# At the root of your Expo/React Native project:
bash /path/to/skill/scripts/scan-project.sh .

# Report generated at:
# ./.compliance-report/report_YYYYMMDD_HHMMSS.md
```

## Installation

### Claude Code

```bash
# Copy to Claude Code skills directory
cp -r mobile-app-compliance-checker/ ~/.claude/skills/

# Or reference locally in the project via .claude/settings.json
```

### OpenCode

```bash
# Add reference to SKILL.md in custom instructions
# Copy SKILL.md content to .opencode/instructions.md
```

### GitHub Copilot

```bash
# Add to custom instructions file
cat SKILL.md >> .github/copilot-instructions.md
```

### Standalone Usage (without LLM)

```bash
# Clone the repository
git clone https://github.com/nandofalcao/mobile-app-compliance-checker

# Run at the root of your React Native/Expo project
bash mobile-app-compliance-checker/scripts/scan-project.sh /path/to/project
```

## Structure

```
mobile-app-compliance-checker/
├── SKILL.md                          # Main skill (< 500 lines)
├── references/
│   ├── apple-app-store.md            # Condensed Apple guidelines
│   ├── google-play-store.md          # Condensed Google Play guidelines
│   ├── lgpd-privacy.md               # LGPD + Privacy requirements
│   ├── react-native-expo.md          # RN/Expo specific checks
│   └── common-rejections.md          # Common rejection reasons + solutions
├── checklists/
│   ├── pre-submission-ios.md         # iOS pre-submission checklist
│   ├── pre-submission-android.md     # Android pre-submission checklist
│   ├── privacy-compliance.md         # Privacy/LGPD checklist
│   └── security-checklist.md         # Data security checklist
├── scripts/
│   ├── scan-project.sh               # Main orchestrator
│   ├── check-permissions.sh          # Analyzes declared permissions
│   ├── check-privacy-manifest.sh     # Checks iOS Privacy Manifest
│   ├── check-data-safety.sh          # Checks Data Safety (Android)
│   ├── check-expo-config.sh          # Analyzes app.json / app.config.js
│   ├── check-dependencies.sh         # Analyzes dependencies
│   ├── check-security.sh             # Checks security practices
│   └── generate-report.sh            # Generates consolidated report
├── templates/
│   ├── privacy-policy-pt-br.md       # Privacy Policy Template (PT-BR)
│   ├── terms-of-use-pt-br.md         # Terms of Use Template (PT-BR)
│   ├── data-safety-form.md           # Google Play Data Safety Guide
│   └── app-privacy-labels.md         # Apple Privacy Labels Guide
├── evals/
│   └── evals.json                    # Test cases
└── README.md
```

## Severity Levels

| Level | Symbol | Meaning |
|-------|--------|---------|
| CRITICAL | 🔴 | Will cause store rejection — fix immediately |
| WARNING | ⚠️ | May cause rejection or future issues — review |
| INFO | ℹ️ | Recommended best practice — consider |
| OK | ✅ | Verified compliance |

## Requirements

- `bash` 3.2+
- `node` 14+ (for JSON parsing when needed)
- `jq` (optional, improves JSON output)
- No other external dependencies

## Compatibility

| Project | Support |
|---------|---------|
| Expo Managed Workflow | ✅ Full |
| Expo Bare Workflow | ✅ Full |
| Pure React Native | ✅ Partial (no Expo-specific checks) |

## Guideline Updates

Store guidelines change frequently. Each file in `references/`
has a last update date in the header. Check official sources
regularly:

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policy](https://support.google.com/googleplay/android-developer/answer/16810878)
- [ANPD — National Data Protection Authority](https://www.gov.br/anpd/pt-br)

## Disclaimer

This skill provides automated technical checks and educational references.
**It does not replace legal advice.** For full compliance with LGPD and
other regulatory frameworks, consult a legal professional specialized
in data protection.

## License

MIT — see [LICENSE](LICENSE)