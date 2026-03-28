# Guia: Preencher Data Safety Section — Google Play

> Atualizado: 2026-03-28
> Fonte: https://support.google.com/googleplay/android-developer/answer/10787469

O formulário Data Safety é **obrigatório** para publicar no Google Play.
Acesse: **Google Play Console > [Seu App] > App content > Data safety**

---

## Visão Geral do Processo

```
1. Coleta de dados → 2. Uso de dados → 3. Compartilhamento → 4. Práticas de segurança
```

---

## Seção 1: Coleta e Uso de Dados

### Pergunta: "O app coleta ou compartilha algum tipo de dado obrigatório do usuário?"

**Resposta baseada no tipo de app:**
- App sem backend, sem analytics, sem crashes: provavelmente **NÃO**
- A maioria dos apps React Native com Firebase/Sentry: **SIM**

---

## Categorias de Dados — Como Mapear

### 📍 Localização

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Localização aproximada | App usa `expo-location` com `Accuracy.Low/Balanced` |
| Localização precisa | App usa `expo-location` com `Accuracy.High/BestForNavigation` |

**Perguntas adicionais:**
- Processada em tempo real? Se localiza em segundo plano = SIM
- Compartilhada com terceiros? Se envia para servidor ou analytics = SIM
- Obrigatória para funcionar? Se sem localização o app não funciona = SIM

---

### 👤 Informações Pessoais

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Nome | Tem cadastro com nome |
| Endereço de email | Login por email ou cadastro |
| IDs de usuário | Gera ID único por usuário |
| Endereço (físico) | Tem entrega ou endereço de cobrança |
| Número de telefone | Verificação por SMS ou WhatsApp |
| Raça e etnia | [Se relevante para o app] |
| Crenças políticas ou religiosas | [Se relevante] |
| Orientação sexual | [Se relevante] |
| Outras informações | Nome de usuário, foto de perfil, data de nascimento |

---

### 💳 Informações Financeiras

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Informações de pagamento | App processa pagamentos diretamente |
| Histórico de compras | Armazena histórico de compras (IAP) |
| Score de crédito | [Fintech] |
| Outras finanças | Saldo, transações, etc. |

**Nota:** Se usa Google Play Billing, o Google trata o pagamento — declare apenas se armazena histórico.

---

### 🏥 Saúde e Condicionamento Físico

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Informações de saúde | App coleta dados de saúde (pressão, glicose, etc.) |
| Informações de condicionamento | Passos, exercícios, calorias, sono |

---

### 📨 Mensagens

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Emails | App lê emails do dispositivo |
| SMS ou MMS | App lê SMS |
| Outras mensagens no app | App tem chat interno |

---

### 📸 Fotos e Vídeos

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Fotos | App lê/armazena fotos do usuário |
| Vídeos | App lê/armazena vídeos do usuário |

**Quando declarar:** Se usa `expo-image-picker` e ENVIA as fotos para um servidor.
Se as fotos ficam apenas no dispositivo: provavelmente não precisa declarar.

---

### 🔊 Arquivos de Áudio

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Gravações de voz ou som | App grava áudio do usuário |
| Arquivos de música | App acessa biblioteca de músicas |
| Outros arquivos de áudio | |

---

### 📂 Arquivos e Documentos

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Arquivos e documentos | App acessa e/ou armazena documentos do usuário |

---

### 📅 Calendário

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Eventos de calendário | App lê ou escreve no calendário (`expo-calendar`) |

---

### 👥 Contatos

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Contatos | App lê lista de contatos (`expo-contacts`) |

---

### 📊 Atividade no App

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Interações com o app | Firebase Analytics, Amplitude, etc. coletam isso |
| Histórico de pesquisas no app | App tem busca interna com histórico |
| Outros conteúdos gerados pelo usuário | Posts, comentários, avaliações |

---

### 🌐 Histórico de Navegação na Web

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Histórico de navegação na web | App usa WebView e rastreia URLs visitadas |

---

### 📈 Informações e Desempenho do App

| Subcategoria | Quando declarar |
|-------------|-----------------|
| Logs de falha | **Sentry, Firebase Crashlytics** — declare sempre |
| Diagnósticos | Dados de performance, tempos de carregamento |

---

### 📱 IDs de Dispositivo ou Outros

| Subcategoria | Quando declarar |
|-------------|-----------------|
| ID do dispositivo | Advertising ID (GAID) — SDKs de anúncio usam isso |

**SDKs que usam Advertising ID:** Google AdMob, Firebase Analytics (em alguns casos),
Branch, Adjust, Appsflyer, Amplitude.

---

## Práticas de Segurança

### Dados criptografados em trânsito?
- **SIM** se usa HTTPS em todas as APIs (deve ser SIM)

### Você fornece uma maneira de os usuários solicitarem que seus dados sejam excluídos?
- **SIM** se implementou Account Deletion (obrigatório Apple, recomendado Google)
- Especificar se é automático (dentro do app) ou por solicitação (email)

---

## Exemplos Práticos por Tipo de App

### App de Controle Pessoal (sem conta, sem analytics)
```
Coleta dados? NÃO
```

### App com Firebase + Sentry (sem localização, sem câmera)
```
✅ Logs de falha (Sentry/Crashlytics)
✅ Diagnósticos (performance)
✅ Atividade no app (Firebase Analytics)
✅ IDs de dispositivo (Firebase — se usa Analytics)

Todos usados para melhorar o app.
Não compartilhados com terceiros (além dos próprios SDKs).
Criptografados em trânsito: SIM
Exclusão de dados: SIM (se implementou account deletion)
```

### App com Câmera + Localização + Login
```
✅ Email (login)
✅ ID de usuário (gerado internamente)
✅ Fotos (se enviadas ao servidor)
✅ Localização aproximada ou precisa
✅ Atividade no app (analytics)
✅ Logs de falha (crash reporting)

Localização: obrigatória para funcionar? Depende do app.
Fotos: compartilhadas com terceiros? Depende.
```

---

## Dicas Finais

1. **Seja preciso, não excessivo** — declare o que coleta de fato, não o que pode vir a coletar
2. **Consistência é obrigatória** — Data Safety deve bater com a Privacy Policy
3. **Atualizar após novos SDKs** — cada novo SDK pode requerer nova declaração
4. **Google pode auditar** — apps com Data Safety inconsistente podem ser removidos
5. **Salvar rascunho** — o formulário permite salvar rascunhos antes de publicar

---

## SDKs Comuns → Data Safety

| SDK | Dados que coleta | Categorias a declarar |
|-----|-----------------|----------------------|
| Firebase Analytics | Eventos, propriedades de usuário | App activity, Device IDs |
| Firebase Crashlytics | Crashes, stack traces, device info | App info & performance |
| Sentry | Errors, device info, breadcrumbs | App info & performance |
| Amplitude | Eventos, sessões, user properties | App activity |
| Google AdMob | Advertising ID, comportamento | Device IDs, App activity |
| Branch | Device ID, atribuição | Device IDs, App activity |
| Expo Notifications | Push token | Device IDs |

---

## Após Preencher

- [ ] Revisar com a Privacy Policy para consistência
- [ ] Salvar e publicar no Play Console
- [ ] Guardar cópia local em `docs/data-safety.md` do projeto
- [ ] Rever a cada novo SDK adicionado ao projeto
