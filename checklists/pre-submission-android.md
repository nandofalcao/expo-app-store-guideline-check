# Checklist Pré-Submissão — Google Play Store

> Versão: 1.0 | Atualizado: 2026-03-28
> Complete este checklist antes de cada submissão ao Google Play.

---

## 1. Configuração Básica

- [ ] `expo.android.package` definido (ex: `com.empresa.app`)
- [ ] `expo.version` atualizado (semver)
- [ ] `expo.android.versionCode` incrementado em relação à última publicação
- [ ] Ícone adaptativo configurado (`adaptiveIcon` com `foregroundImage` e `backgroundColor`)
- [ ] Splash Screen configurada
- [ ] Target SDK Version: 34+ (obrigatório) ou 35 (recomendado para 2025/2026)
- [ ] Formato de build: **AAB** (Android App Bundle), não APK

---

## 2. Permissões Android

- [ ] Apenas permissões **necessárias** declaradas no AndroidManifest.xml
- [ ] Nenhuma permissão declarada que não seja usada pelo app
- [ ] Permissões sensíveis (CAMERA, CONTACTS, LOCATION) com justificativa clara
- [ ] Para `ACCESS_BACKGROUND_LOCATION`: aprovação especial solicitada se necessário
- [ ] `INTERNET` declarada (necessária para apps com backend)
- [ ] Permissões do Android 13+ (`READ_MEDIA_IMAGES`, etc.) usadas no lugar de `READ_EXTERNAL_STORAGE`

---

## 3. Data Safety Section

**Preencher em Google Play Console > App content > Data safety:**

- [ ] Data Safety Section **preenchida** (obrigatório — app não pode ser publicado sem ela)
- [ ] Dados coletados pelo app declarados corretamente:
  - [ ] Dados de localização (se usa GPS)
  - [ ] Dados pessoais (nome, email, etc.)
  - [ ] Dados financeiros (se tem IAP)
  - [ ] Dados de saúde/fitness (se aplicável)
  - [ ] Dados de dispositivo (Advertising ID se usa ads)
  - [ ] Dados de desempenho (crash logs se usa Sentry/Crashlytics)
  - [ ] Dados de atividade do app (analytics)
- [ ] Dados compartilhados com terceiros declarados
- [ ] Política de criptografia em trânsito indicada (TLS/HTTPS)
- [ ] Opção de solicitação de exclusão indicada (se implementada)
- [ ] Data Safety consistente com a Privacy Policy

---

## 4. Privacy & Legal

- [ ] **Privacy Policy URL** configurada no Google Play Console
- [ ] Privacy Policy acessível **dentro do app**
- [ ] Privacy Policy em português (e inglês se app internacional)
- [ ] Privacy Policy atualizada com todos os dados e SDKs de terceiros

---

## 5. Content Rating

- [ ] Questionário de **Content Rating (IARC)** preenchido no Play Console
- [ ] Classificação correta para o público-alvo
- [ ] Se app para crianças: cumprir Families Policy
  - [ ] Sem publicidade de terceiros não aprovados
  - [ ] Sem analytics que coletam dados de menores
  - [ ] Consentimento parental para compras

---

## 6. In-App Purchase (se aplicável)

- [ ] **Google Play Billing** usado para compras digitais
- [ ] Nenhum link para compra externa de conteúdo digital
- [ ] Preços exibidos antes da confirmação
- [ ] Termos de assinatura claros (duração, renovação automática)
- [ ] Compras testadas no ambiente de Sandbox do Google Play

---

## 7. Funcionalidade e Performance

- [ ] App testado em **device físico** (não apenas emulador)
- [ ] Testado em múltiplos tamanhos de tela (phone, tablet, foldable se aplicável)
- [ ] Testado no Android 7 (API 24) — versão mínima suportada pelo Expo atual
- [ ] Testado no Android 15 (API 35) — versão mais recente
- [ ] Sem crashes no fluxo principal
- [ ] Backend **ativo e acessível**
- [ ] Sem funcionalidades "Em Breve" na UI
- [ ] Modo escuro testado (se o app suporta)
- [ ] Comportamento com permissões negadas testado

---

## 8. Store Listing (Google Play Console)

- [ ] **Screenshots** do app real (não mockups)
  - [ ] Phone: mínimo 2, até 8 screenshots
  - [ ] Tablet 7" (recomendado)
  - [ ] Tablet 10" (recomendado)
- [ ] **Feature Graphic** (1024x500 JPG/PNG)
- [ ] **App Preview** (vídeo) — opcional mas recomendado
- [ ] Título do app (máx. 50 caracteres)
- [ ] Descrição curta (máx. 80 caracteres)
- [ ] Descrição completa (máx. 4000 caracteres)
- [ ] Categoria correta selecionada
- [ ] Tags relevantes selecionadas
- [ ] País/regiões de distribuição configurados

---

## 9. Account Management

- [ ] Google Play Developer Account verificado
- [ ] Se Developer Verification obrigatório no país: documentação pronta
- [ ] Endereço de email de contato válido e monitorado
- [ ] Conta do banco configurada para pagamentos (se tem IAP)

---

## 10. Build e Publicação

- [ ] Build AAB gerado via EAS Build (produção)
- [ ] Testado via **Internal Testing** antes de promover
- [ ] Testado via **Closed Testing (Alpha)** com usuários reais
- [ ] Keystore guardada em local seguro (perda = impossível atualizar o app)
- [ ] `eas.json` configurado com `buildType: "app-bundle"` para produção
- [ ] Assinatura do app configurada (preferencial: Play App Signing do Google)

---

## 11. Políticas Específicas (se aplicável)

**Saúde/Fitness:**
- [ ] Dados de saúde não usados para fins de publicidade
- [ ] Certificação médica se necessária (ex: apps de diagnóstico)

**Finance/Fintech:**
- [ ] Conformidade com regulamentações financeiras locais
- [ ] KYC (Know Your Customer) implementado se necessário

**Menores de 18 anos:**
- [ ] Families Policy cumprida
- [ ] COPPA compliance (se distribuído nos EUA)

**VPN:**
- [ ] Uso declarado e aprovado pela política do Google

---

## Verificação Final

Execute o scan automático antes de publicar:

```bash
bash scripts/scan-project.sh .
```

Confirme que:
- [ ] Nenhum item CRÍTICO no relatório
- [ ] Todos os itens acima deste checklist estão marcados
- [ ] Internal Testing testado por ao menos 3 dias com feedback positivo
- [ ] Data Safety Section preenchida e salva

---

## Referências

- [Google Play Developer Policy](https://support.google.com/googleplay/android-developer/answer/16810878)
- [Data Safety Section Help](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Target API Level Requirements](https://support.google.com/googleplay/android-developer/answer/11926878)
- `references/google-play-store.md` — diretrizes condensadas
- `templates/data-safety-form.md` — guia para preencher Data Safety
