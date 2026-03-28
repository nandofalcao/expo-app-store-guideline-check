# Diretrizes Apple App Store — Referência Condensada

> Última atualização: 2026-03-28
> Fonte oficial: https://developer.apple.com/app-store/review/guidelines/
> Próximos requisitos: https://developer.apple.com/news/upcoming-requirements/

---

## Requisitos Ativos (2025/2026)

| Requisito | Prazo | Status |
|-----------|-------|--------|
| Privacy Manifest (PrivacyInfo.xcprivacy) | Desde maio/2024 | **Obrigatório** |
| iOS 18 SDK mínimo para novos apps | Abril/2026 | **Obrigatório** |
| Account Deletion (se criação de conta) | Desde junho/2023 | **Obrigatório** |
| App Tracking Transparency | Desde iOS 14.5 | **Obrigatório se tracking** |

---

## 1. Safety (Segurança do Usuário)

### 1.1 Conteúdo Objectionável
- Sem conteúdo pornográfico, violento, preconceituoso ou que promova atividades ilegais
- Conteúdo com nudez artística deve ser classificado adequadamente (17+)

### 1.2 Conteúdo Gerado por Usuário (UGC)
- **Obrigatório:** Botão de Report/Block para conteúdo de outros usuários
- **Obrigatório:** Mecanismo de moderação de conteúdo
- **Obrigatório:** Filtro de material ofensivo
- Apps de chat/fórum precisam de sistema de denúncia funcional

### 1.3 Kids Category (Apps para Crianças)
- Sem analytics de terceiros (exceto COPPA-compliant)
- Sem publicidade de terceiros
- Sem compras dentro do app sem aprovação parental explícita
- Sem links externos sem aprovação parental
- Política de privacidade específica para menores

### 1.5 Developer Information
- Conta de desenvolvedor válida e verificada
- Informações de contato atualizadas

---

## 2. Performance (Desempenho)

### 2.1 App Completeness
- **Rejeição mais comum:** App com crashes óbvios, botões que não funcionam, telas em branco
- Sem funcionalidades "Em breve" ou "Coming Soon" em UI
- Backend deve estar ativo e acessível durante review
- Demo accounts devem funcionar durante todo o período de review

### 2.2 Beta Testing
- Apps em beta devem usar TestFlight, não a App Store
- Não distribuir versões de teste pela App Store

### 2.3 Accurate Metadata
- Screenshots devem refletir o app real (não mockups genéricos)
- Descrição deve corresponder à funcionalidade real
- Nome do app não deve conter palavras-chave spam
- Sem mentions de concorrentes no nome ou descrição
- Ícone não pode imitar ícones de outros apps ou marcas

### 2.4 Hardware Compatibility
- **2.4.1:** Definir explicitamente se suporta iPad (`supportsTablet`)
- Apps universais devem funcionar bem em todos os tamanhos suportados
- Suporte a 64-bit obrigatório (já atendido por React Native moderno)

### 2.5 Software Requirements
- Somente APIs públicas do iOS — sem private APIs
- Expo e React Native usam apenas APIs públicas (geralmente OK)
- Verificar se plugins nativos customizados não usam private APIs

---

## 3. Business (Modelos de Negócio)

### 3.1 Payments — CRÍTICO
- **Todo conteúdo digital consumível dentro do app** deve usar In-App Purchase (IAP)
- Não redirecionar usuário para comprar fora do app para conteúdo digital
- **Exceções:** compras físicas, serviços prestados fora do app, B2B com aprovação

### 3.1.1 In-App Purchase Rules
- Preços devem ser visíveis antes da compra
- Sem preços "por tempo limitado" enganosos
- Consumíveis vs não-consumíveis devem ser classificados corretamente

### 3.1.2 Subscriptions
- **Obrigatório:** Botão "Restore Purchases" funcional
- Termos de assinatura claros (preço, duração, renovação automática)
- Cancelamento deve ser fácil
- Trial periods claramente comunicados

### 3.2 Other Business Models
- Freemium: funcionalidade básica deve funcionar sem pagamento
- Apps gratuitos não podem solicitar pagamento para usar

---

## 4. Design

### 4.1 Copycats
- Sem ícones que imitam apps famosos (Instagram, WhatsApp, etc.)
- Sem nomes que causem confusão com outros apps
- Design original — não copiar UI de outros apps

### 4.2 Minimum Functionality
- App deve ter funcionalidade nativa significativa
- **WebView wrappers** sem valor adicional são rejeitados
- Sem apps que são apenas um link para website

### 4.5 Apple Sites and Services
- Não usar APIs da Apple de formas não documentadas
- Não implicar afiliação com a Apple

---

## 5. Legal

### 5.1 Privacy — SEÇÃO MAIS IMPORTANTE

#### 5.1.1 Data Collection and Storage
- **Privacy Policy obrigatória** — URL configurada no App Store Connect
- Privacy Policy deve estar acessível dentro do app
- Privacy Manifest (`PrivacyInfo.xcprivacy`) obrigatório
- Coletar apenas dados necessários para a funcionalidade
- Dados de saúde/fitness só para funcionalidades de saúde
- **Sem dados de usuário para publicidade sem consentimento explícito**

#### 5.1.1(ix) Account Deletion — CRÍTICO
Se o app permite criação de conta:
- **Obrigatório:** Mecanismo de exclusão de conta dentro do app
- Deve excluir ou anonimizar todos os dados do usuário
- Disponível sem entrar em contato com suporte

#### 5.1.2 Data Use and Sharing
- Declarar todos os dados coletados nas Privacy Labels (App Store Connect)
- Não compartilhar dados com terceiros sem disclosure
- Dados de localização: limitar ao mínimo necessário

#### Privacy Labels (App Store Connect)
Declarar cada tipo de dado:
- **Data Used to Track You:** dados usados para tracking cross-app
- **Data Linked to You:** dados associados à identidade do usuário
- **Data Not Linked to You:** dados coletados de forma anônima

#### App Tracking Transparency (ATT)
- **Obrigatório desde iOS 14.5** se o app usa tracking
- Deve solicitar permissão antes de acessar IDFA
- Sem tracking se usuário negar

### 5.2 Intellectual Property
- Sem uso não autorizado de marcas registradas
- Direitos autorais respeitados (músicas, imagens, fontes)

### 5.3 Gaming, Gambling
- Cassinos e apostas requerem licença no país
- Simulated gambling (moeda virtual) = classificação 17+

### 5.4 VPN Apps
- Requerem justificativa clara e não podem coletar dados do usuário

### 5.6 Developer Code of Conduct
- Não enganar usuários com comportamento inesperado
- Não coletar dados sem consentimento
- Não usar técnicas dark patterns para compras

---

## Privacy Manifest — Detalhes Técnicos

### APIs que exigem declaração de motivo:

| API | Reason Codes Disponíveis |
|-----|--------------------------|
| `NSPrivacyAccessedAPICategoryUserDefaults` | C617.1, AC6B.1, CA92.1, 1C8F.1 |
| `NSPrivacyAccessedAPICategoryFileTimestamp` | C617.1, 3B52.1, 0A2A.1 |
| `NSPrivacyAccessedAPICategorySystemBootTime` | 35F9.1 |
| `NSPrivacyAccessedAPICategoryDiskSpace` | E174.1, 85F4.1 |
| `NSPrivacyAccessedAPICategoryActiveKeyboards` | 3EC4.1, 54BD.1 |

### Exemplo no app.json (Expo):
```json
{
  "expo": {
    "ios": {
      "privacyManifests": {
        "NSPrivacyAccessedAPITypes": [
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
            "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
          },
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryFileTimestamp",
            "NSPrivacyAccessedAPITypeReasons": ["C617.1"]
          }
        ],
        "NSPrivacyCollectedDataTypes": [],
        "NSPrivacyTracking": false
      }
    }
  }
}
```

---

## Motivos de Rejeição Mais Comuns (Apple)

1. **Crash durante review** — teste em device real antes de submeter
2. **Privacy Manifest ausente ou incompleto**
3. **Metadata incorreto** — screenshots desatualizados ou não refletem o app
4. **Sem demo account** — fornecer credenciais no App Review Notes
5. **Sem Account Deletion** — se o app tem criação de conta
6. **Usage Descriptions muito genéricas** — descrever o propósito real
7. **Backend inativo** durante review
8. **Funcionalidades incompletas** no build submetido

---

## Recursos de Conformidade (Apple)

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Privacy Manifest Files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [Upcoming Requirements](https://developer.apple.com/news/upcoming-requirements/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
