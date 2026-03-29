---
name: mobile-app-compliance-checker
description: >
  Verifies if a React Native/Expo application complies with Apple App Store,
  Google Play Store, LGPD, and privacy policy guidelines. Use this skill
  whenever the user mentions: compliance, app store submission, app store
  rejection, privacy policy, LGPD, data protection, data safety, privacy
  manifest, app review, pre-submission checklist, mobile app security check,
  or any mention of preparing an app for publication in stores. Also trigger
  when the user asks about app permissions, data collection, or privacy
  requirements for mobile apps.
version: "1.0.0"
updated: "2026-03-28"
platforms: [ios, android]
frameworks: [react-native, expo]
---

# Mobile App Compliance Checker

Skill to verify compliance of React Native/Expo apps with Apple App Store,
Google Play Store, LGPD, and privacy/security best practices guidelines.

---

## What This Skill Does

1. **Analyzes the project automatically** via bash scripts
2. **Classifies issues** as: CRITICAL / WARNING / INFO / OK
3. **Generates actionable report** with suggested fixes for each issue
4. **Covers four domains:** Apple App Store, Google Play, LGPD/Privacy, Security

---

## Execution Flow

### Automated Analysis (recommended)

```bash
# At the root of the React Native/Expo project:
bash /path/to/skill/scripts/scan-project.sh .

# The report will be generated at:
# ./.compliance-report/report_YYYYMMDD_HHMMSS.md
```

### Analysis by Domain (when needed to check only one area)

```bash
# Expo configuration only
bash scripts/check-expo-config.sh /project/path

# Permissions only
bash scripts/check-permissions.sh /project/path

# iOS Privacy Manifest only
bash scripts/check-privacy-manifest.sh /project/path

# Google Data Safety only
bash scripts/check-data-safety.sh /project/path

# Security only
bash scripts/check-security.sh /project/path

# Dependencies only
bash scripts/check-dependencies.sh /project/path
```

---

## When to Use Each Resource

| Situation | Resource |
|----------|----------|
| Preparing app for submission | `scripts/scan-project.sh` + relevant checklists |
| Apple rejection | `references/apple-app-store.md` + `references/common-rejections.md` |
| Google Play rejection | `references/google-play-store.md` + `references/common-rejections.md` |
| Configure iOS Privacy Manifest | `references/react-native-expo.md` + `scripts/check-privacy-manifest.sh` |
| Fill Google Data Safety | `templates/data-safety-form.md` + `scripts/check-data-safety.sh` |
| Fill Apple Privacy Labels | `templates/app-privacy-labels.md` |
| Create Privacy Policy | `templates/privacy-policy-pt-br.md` |
| Create Terms of Use | `templates/terms-of-use-pt-br.md` |
| Verify LGPD compliance | `references/lgpd-privacy.md` + `checklists/privacy-compliance.md` |
| Complete iOS checklist | `checklists/pre-submission-ios.md` |
| Complete Android checklist | `checklists/pre-submission-android.md` |
| Verify data security | `checklists/security-checklist.md` + `scripts/check-security.sh` |

---

## Results Structure

Each verification produces results with the following structure:

```json
{
  "id": "EXPO-001",
  "severity": "CRITICAL",
  "category": "apple",
  "title": "Short description of the problem",
  "description": "Detailed explanation",
  "fix": "How to fix",
  "reference": "URL or reference doc",
  "file": "relevant file"
}
```

### Severity Levels

| Level | Symbol | Required Action |
|-------|--------|-----------------|
| CRITICAL | 🔴 | Fix before submitting — will cause rejection |
| WARNING | ⚠️ | Review — may cause rejection or future problem |
| INFO | ℹ️ | Consider — best practice but not mandatory |
| OK | ✅ | Compliance verified |

---

## Verification Domains

### Apple App Store
- **Basic configuration:** bundle identifier, version, build number
- **iOS Permissions:** NS*UsageDescription strings
- **Privacy Manifest:** PrivacyInfo.xcprivacy / expo.ios.privacyManifests
- **App Tracking Transparency:** implementation for tracking
- **Account Deletion:** mandatory if account creation exists
- **IAP/Subscriptions:** restore purchases, visible prices

References: `references/apple-app-store.md`

### Google Play Store
- **Basic configuration:** package name, versionCode
- **Target API Level:** Android 15 (API 35) for new apps 2025+
- **Data Safety Section:** preparation and filling
- **Android Permissions:** `<uses-permission>` justified
- **Content Rating:** questionnaire filled

References: `references/google-play-store.md`

### LGPD / Privacy
- **Privacy Policy:** presence, accessibility, language
- **Consent:** explicit mechanism before collecting data
- **Data subject rights:** access, deletion, portability
- **DPO:** data protection officer identification
- **Sharing:** list of third parties receiving data

References: `references/lgpd-privacy.md`

### Data Security
- **Storage:** no sensitive data in AsyncStorage
- **Communication:** HTTPS mandatory, SSL pinning recommended
- **Secrets:** no hardcoded API keys or committed .env files
- **Logs:** no sensitive data in console.log

References: `checklists/security-checklist.md`

---

## Project Configuration

The skill automatically detects:

| Indicator | Project Type |
|-----------|--------------|
| `app.json` with `"expo"` key | Expo Managed Workflow |
| `app.json` + `ios/` or `android/` folder | Expo Bare Workflow |
| `package.json` with `react-native` without `expo` | Pure React Native |

---

## Interpreting the Report

The generated report (`compliance-report.md`) is divided into sections:

1. **Executive Summary** — count by severity
2. **Apple App Store** — iOS-specific issues
3. **Google Play Store** — Android-specific issues
4. **LGPD / Privacy** — compliance with Brazilian law
5. **Security** — data vulnerabilities
6. **Dependencies** — risks in third-party packages
7. **Next Steps** — recommended action order

### Fix Prioritization

```
1. Fix all 🔴 CRITICAL
2. Review all ⚠️ WARNING (decide if applies to context)
3. Consider ℹ️ INFO for better compliance
4. ✅ OK needs no action
```

---

## Important Limitations

- Scripts analyze configuration and static code — they do not test runtime
- Security verification identifies common patterns, not a pentest
- LGPD analysis covers technical requirements; legal aspects require a lawyer
- Store guidelines change — check update dates in reference files
- Does not replace manual review of checklists before submitting

---

## Updating the Skill

Reference files have update dates in the header. When guidelines change,
update files in `references/` and corresponding checks in scripts. Keep
`version` and `updated` in this SKILL.md current.

---

## Additional Resources

- `references/` — condensed guidelines by platform
- `checklists/` — interactive pre-submission checklists
- `templates/` — legal document templates and forms
- `scripts/` — bash automation for project analysis
- `evals/evals.json` — test cases to validate the skill