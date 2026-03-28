# Guia: Preencher App Privacy Labels — Apple App Store

> Atualizado: 2026-03-28
> Acesse: **App Store Connect > [Seu App] > App Privacy**

As Privacy Labels são exibidas na página do app na App Store antes de o usuário fazer download.
São obrigatórias e devem refletir com precisão os dados coletados.

---

## As Três Categorias Principais

### 1. Data Used to Track You (Dados usados para rastrear você)
Dados **combinados com dados de outros apps, sites ou apps de terceiros** para fins de publicidade,
ou compartilhados com data brokers.

**Declare aqui se:**
- O app usa IDFA (Identifier for Advertisers)
- O app usa cookies para cross-app tracking
- O app compartilha dados com plataformas de advertising
- O app usa SDKs de atribuição (Branch, Adjust, Appsflyer)

**Exige:** App Tracking Transparency (ATT) para iOS 14.5+

### 2. Data Linked to You (Dados vinculados a você)
Dados coletados e **associados à identidade do usuário** (conta, nome, email, etc.)

**Declare aqui se:**
- O app tem sistema de login/conta
- Os dados podem ser rastreados de volta ao usuário

### 3. Data Not Linked to You (Dados não vinculados a você)
Dados coletados mas **não associados** à identidade do usuário (anônimos ou pseudoanonimizados).

**Declare aqui se:**
- Crash logs sem informações de identificação
- Analytics com IDs anônimos
- Diagnósticos técnicos

---

## Tipos de Dados — Quando Declarar

### Contact Info (Informações de Contato)
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Name | ✓ se tem perfil | | |
| Email Address | ✓ se usa email para login | | |
| Phone Number | ✓ se coleta telefone | | |
| Physical Address | ✓ se coleta endereço | | |
| Other User Contact Info | ✓ se coleta outros dados de contato | | |

### Health & Fitness
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Health | ✓ se app de saúde com conta | | |
| Fitness | ✓ se app fitness com conta | | |

### Financial Info
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Payment Info | ✓ se armazena dados de pagamento | | |
| Credit Info | | | |
| Other Financial Info | ✓ se armazena histórico de transações | | |

### Location
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Precise Location | ✓ se armazenada com conta | ✓ se anônima | ✓ se para publicidade |
| Coarse Location | ✓ se armazenada com conta | ✓ se anônima | |

### Sensitive Info
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Sensitive Info | ✓ se coleta dados sensíveis (raça, religião, etc.) | | |

### Contacts
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Contacts | ✓ se sincroniza ou armazena contatos | | |

### User Content
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Emails or Text Messages | ✓ se app tem chat | | |
| Photos or Videos | ✓ se armazena fotos enviadas pelo usuário | | |
| Audio Data | ✓ se armazena gravações | | |
| Gameplay Content | ✓ se tem conteúdo de jogo | | |
| Customer Support | ✓ se tem chat de suporte | | |
| Other User Content | ✓ se tem outros UGC | | |

### Browsing History
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Browsing History | ✓ se rastreia URLs em WebView | | |

### Search History
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Search History | ✓ se armazena buscas do usuário | | |

### Identifiers
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| User ID | ✓ para quase todos os apps com conta | | |
| Device ID | | ✓ para analytics anônimos | ✓ se para advertising (IDFA) |

### Purchases
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Purchase History | ✓ se armazena histórico de IAP | | |

### Usage Data (Mais comum)
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Product Interaction | ✓ se analytics vinculado à conta | ✓ se analytics anônimo | |
| Advertising Data | | | ✓ sempre |
| Other Usage Data | ✓ ou ✓ dependendo do caso | | |

### Diagnostics (Muito comum — Sentry/Crashlytics)
| Tipo | Linked | Not Linked | Track |
|------|--------|------------|-------|
| Crash Data | | ✓ geralmente anônimo | |
| Performance Data | | ✓ geralmente anônimo | |
| Other Diagnostic Data | | ✓ geralmente anônimo | |

---

## Exemplos por Tipo de App

### App simples sem conta (ex: calculadora, app offline)
```
Data Not Collected ✅
(sem coleta de dados)
```

### App com conta + Firebase Analytics + Sentry
```
Data Linked to You:
  - User ID (Account identifier gerado internamente)
  - Email Address (login)
  - Product Interaction (Firebase Analytics → eventos do app)

Data Not Linked to You:
  - Crash Data (Sentry — sem PII se configurado corretamente)
  - Performance Data (Sentry)
```

### App de social + câmera + localização
```
Data Linked to You:
  - Name (perfil)
  - Email Address (login)
  - Photos or Videos (fotos enviadas)
  - Precise Location (se geotag nas fotos)
  - User ID
  - Product Interaction (analytics)

Data Not Linked to You:
  - Crash Data
  - Coarse Location (se analytics de região)

Data Used to Track You:
  (apenas se usa IDFA para advertising)
```

---

## Finalidades dos Dados

Para cada tipo de dado declarado, informar a finalidade:

| Finalidade | Descrição |
|-----------|-----------|
| Third-Party Advertising | Mostrar anúncios de terceiros |
| Developer's Advertising or Marketing | Seu próprio marketing |
| Analytics | Entender uso do app |
| Product Personalization | Personalizar experiência |
| App Functionality | Necessário para o app funcionar |
| Other Purposes | Outros fins específicos |

---

## Processo de Preenchimento

1. **Acesse** App Store Connect > [App] > App Privacy
2. **Clique** em "Edit" ou "Get Started"
3. Para cada tipo de dado que o app coleta:
   - Selecione a categoria
   - Indique se é Linked, Not Linked, ou Tracking
   - Selecione a(s) finalidade(s)
   - Indique se é obrigatório ou opcional para o app
4. **Salve** e publique junto com a próxima versão

---

## SDKs Comuns → Privacy Labels

| SDK | Categorias Típicas |
|-----|-------------------|
| Firebase Analytics | Product Interaction (Linked ou Not Linked) |
| Firebase Crashlytics | Crash Data (Not Linked) |
| Sentry | Crash Data, Performance Data (Not Linked) |
| Firebase Authentication | User ID, Email (Linked) |
| expo-notifications | Device ID (Linked se push token armazenado) |
| expo-location | Precise/Coarse Location (Linked ou Not Linked) |
| Google Sign-In | Name, Email, User ID (Linked) |
| Apple Sign-In | Email (opcionalmente), User ID (Linked) |

---

## Dicas Importantes

1. **Privacy Labels ≠ Privacy Policy** — Labels são um resumo visual, não o documento completo
2. **Deve ser consistente com a Privacy Policy** — dados declarados em um devem estar no outro
3. **Atualizar com cada versão** que introduza nova coleta de dados
4. **Apple verifica** — Privacy Labels incorretas são motivo de rejeição
5. **"Not Collected" não é uma opção** — se não coleta, simplesmente não declara aquela categoria
6. **Tracking** exige ATT — se declarar "Used to Track You", deve ter ATT implementado

---

## Após Preencher

- [ ] Revisar contra a Privacy Policy para consistência
- [ ] Verificar que ATT está implementado se declarou "Used to Track You"
- [ ] Guardar screenshot das configurações para referência futura
- [ ] Rever a cada novo SDK ou feature adicionada ao app
