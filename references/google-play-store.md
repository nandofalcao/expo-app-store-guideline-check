# Diretrizes Google Play Store — Referência Condensada

> Última atualização: 2026-03-28
> Fonte oficial: https://support.google.com/googleplay/android-developer/answer/16810878
> Prazos: https://support.google.com/googleplay/android-developer/table/12921780

---

## Requisitos Ativos (2025/2026)

| Requisito | Prazo | Status |
|-----------|-------|--------|
| Target API 34 (Android 14) para atualizações | Agosto/2024 | **Obrigatório** |
| Target API 35 (Android 15) para novos apps | 2025/2026 | **Recomendado agora** |
| Data Safety Section preenchida | Obrigatório | **Obrigatório** |
| Developer Verification (Brasil) | Setembro/2026 | **Em breve** |
| AAB format (não APK) para novos apps | Agosto/2021 | **Obrigatório** |

---

## Target API Level

### Cronograma de Exigências
- **API 33 (Android 13):** mínimo para apps existentes até agosto/2023
- **API 34 (Android 14):** obrigatório para novos apps e atualizações desde agosto/2024
- **API 35 (Android 15):** recomendado para 2025/2026 — verificar prazo oficial

### No Expo/React Native
```json
// app.json
{
  "expo": {
    "android": {
      "targetSdkVersion": 35,
      "compileSdkVersion": 35,
      "buildToolsVersion": "35.0.0"
    }
  }
}
```

---

## Data Safety Section — CRÍTICO

### O que é
Formulário obrigatório no Google Play Console > App content > Data safety.
Deve declarar todos os dados que o app coleta, usa e compartilha.

### Categorias de Dados
| Categoria | Exemplos |
|-----------|----------|
| Location | Approximate, Precise, Background |
| Personal info | Name, Email, User ID, Address |
| Financial info | Payment info, Purchase history |
| Health & Fitness | Health info, Fitness info |
| Messages | Emails, SMS, In-app messages |
| Photos & Videos | Photos, Videos |
| Audio | Voice recordings, Music files |
| Files & Docs | Files, Documents |
| Calendar | Calendar events |
| Contacts | Contacts |
| App activity | App interactions, In-app search history |
| Web browsing | Web browsing history |
| App info & performance | Crash logs, Diagnostics |
| Device or other IDs | Device ID, Advertising ID |

### Perguntas do Formulário
Para cada tipo de dado:
1. O app coleta esses dados?
2. Os dados são compartilhados com terceiros?
3. Os dados podem ser solicitados para exclusão?
4. O tratamento é obrigatório ou opcional?
5. A coleta é criptografada em trânsito?

### SDKs que Coletam Dados Automaticamente
- **Firebase Analytics:** App activity, Device IDs
- **Firebase Crashlytics:** App info & performance, Device info
- **Amplitude:** App activity, Device IDs
- **Google AdMob:** Device IDs, App activity
- **Sentry:** App info & performance
- **Branch/Appsflyer/Adjust:** Device IDs, App activity (atribuição)

---

## Políticas de Privacidade e Dados

### User Data Policy
- Coletar apenas dados necessários para as funcionalidades declaradas
- Disclosure claro e em destaque antes de coletar dados sensíveis
- Consentimento explícito para coleta de dados sensíveis
- Privacy Policy obrigatória e acessível

### Permissions Policy
- Solicitar apenas permissões necessárias
- Explicar por que cada permissão é necessária
- Não acessar permissões em background sem justificativa
- Permissões "hazardous" (Location, Contacts, etc.) com uso mínimo

### Permissões de Alto Risco
| Permissão | Requisito Adicional |
|-----------|---------------------|
| ACCESS_BACKGROUND_LOCATION | Aprovação especial + justificativa |
| READ_CONTACTS | Data Safety disclosure obrigatório |
| RECORD_AUDIO | Justificativa clara |
| READ_CALL_LOG | Aprovação especial |
| CAMERA | Disclosure de uso |
| READ_MEDIA_* | Disclosure de acesso |

---

## Conteúdo Restrito

### Conteúdo Proibido
- Conteúdo sexual explícito (sem aprovação especial)
- Material ilegal (drogas, armas ilegais, CSAM)
- Conteúdo que incite violência ou ódio
- Malware, spyware, adware
- Aplicativos de stalking/surveillance sem consentimento

### Conteúdo para Adultos
- Classificar corretamente no Content Rating Questionnaire
- Sem conteúdo adulto visível antes de confirmação de idade
- Seguir políticas de ads se houver publicidade

---

## Famílies Policy (Apps para Crianças)

Se o app é direcionado a menores de 13 anos (ou mistos):
- Sem publicidade de terceiros (exceto aprovados pela política de famílias)
- Sem analytics que coletam dados de crianças
- Sem compras dentro do app sem aprovação parental
- Sem links para conteúdo adulto
- Cumprir COPPA (EUA) e legislações equivalentes

---

## Monetização e Publicidade

### Google Play Billing
- **Obrigatório** para conteúdo digital consumível (mesma regra da Apple)
- Não contornar o sistema de pagamento do Google
- Exceções: apps físicos, B2B, certos apps de streaming

### Políticas de Ads
- Sem anúncios enganosos
- Sem anúncios que simulam notificações do sistema
- Sem anúncios intersticiais inesperados
- Ads devem ser claramente identificados como publicidade
- AdMob: seguir políticas de família se app tem menores

---

## Store Listing e Metadados

### Requisitos de Metadados
- Screenshots devem refletir o app real
- Descrição precisa das funcionalidades
- Título do app: máximo 50 caracteres
- Sem keywords spam no título
- Ícone: PNG 512x512
- Feature Graphic: JPG/PNG 1024x500

### Content Rating
- Preencher questionário de classificação indicativa
- Classificação IARC obrigatória
- Rating incorreto pode causar remoção

---

## Spam e Funcionalidade Mínima

- App deve ter funcionalidade significativa
- Sem apps que são apenas links para websites
- Sem clones idênticos de outros apps
- Sem apps com funcionalidade trivial
- Sem comportamentos enganosos

---

## Developer Verification (2026)

A partir de setembro de 2026, todos os desenvolvedores no Brasil (e outros países)
precisarão verificar identidade/empresa no Google Play Console.

**Preparar agora:**
- Manter dados da conta atualizados
- Empresas: ter documentação jurídica pronta
- Indivíduos: documento de identidade com foto

---

## Formatos de Build

### AAB (Android App Bundle) — Obrigatório
```bash
# EAS Build gera AAB por padrão
eas build --platform android --profile production

# Verificar em eas.json:
{
  "build": {
    "production": {
      "android": {
        "buildType": "app-bundle"
      }
    }
  }
}
```

---

## Recursos de Conformidade (Google)

- [Google Play Developer Policy Center](https://support.google.com/googleplay/android-developer/answer/16810878)
- [Data Safety Section Help](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Target API Level Requirements](https://support.google.com/googleplay/android-developer/answer/11926878)
- [Policy Timelines](https://support.google.com/googleplay/android-developer/table/12921780)
- [Play Console Help](https://support.google.com/googleplay/android-developer/)
