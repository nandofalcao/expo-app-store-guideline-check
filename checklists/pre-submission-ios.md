# Checklist Pré-Submissão — Apple App Store

> Versão: 1.0 | Atualizado: 2026-03-28
> Complete este checklist antes de cada submissão ao App Store.

---

## 1. Configuração Básica

- [ ] `expo.ios.bundleIdentifier` definido e único
- [ ] `expo.version` atualizado (semver)
- [ ] `expo.ios.buildNumber` incrementado em relação à última submissão
- [ ] Ícone do app em alta resolução (1024x1024 PNG, sem transparência)
- [ ] Splash Screen configurada
- [ ] iOS SDK mínimo: iOS 16+ (ou 18+ a partir de abril/2026)
- [ ] `expo.ios.supportsTablet` explicitamente definido
- [ ] Orientação do app configurada (`orientation` no app.json)

---

## 2. Privacy Manifest

- [ ] `expo.ios.privacyManifests` configurado no app.json
- [ ] `NSPrivacyAccessedAPICategoryUserDefaults` declarado (React Native Core usa)
- [ ] `NSPrivacyAccessedAPICategoryFileTimestamp` declarado (React Native Core usa)
- [ ] `NSPrivacyAccessedAPICategorySystemBootTime` declarado (React Native Core usa)
- [ ] `NSPrivacyAccessedAPICategoryDiskSpace` declarado (React Native Core usa)
- [ ] APIs de terceiros (Sentry, Firebase, etc.) verificadas e declaradas
- [ ] `NSPrivacyTracking: false` (ou `true` se usa tracking — com ATT implementado)

---

## 3. Permissões (Usage Descriptions)

**Câmera (se usa expo-camera ou expo-image-picker):**
- [ ] `NSCameraUsageDescription` com descrição específica (não genérica)

**Microfone (se usa expo-av):**
- [ ] `NSMicrophoneUsageDescription` com descrição específica

**Localização (se usa expo-location):**
- [ ] `NSLocationWhenInUseUsageDescription` com descrição específica
- [ ] Se usa background location: `NSLocationAlwaysAndWhenInUseUsageDescription` com justificativa

**Galeria (se usa expo-image-picker):**
- [ ] `NSPhotoLibraryUsageDescription` com descrição específica
- [ ] Se salva na galeria: `NSPhotoLibraryAddUsageDescription`

**Outros (verificar se o app usa):**
- [ ] `NSContactsUsageDescription` (expo-contacts)
- [ ] `NSCalendarsUsageDescription` (expo-calendar)
- [ ] `NSFaceIDUsageDescription` (expo-local-authentication)
- [ ] `NSBluetoothAlwaysUsageDescription` (Bluetooth)
- [ ] `NSMotionUsageDescription` (expo-sensors)
- [ ] `NSUserTrackingUsageDescription` (se usa tracking/ATT)

---

## 4. Privacy & Legal

- [ ] **Privacy Policy URL** configurada no app.json (`privacyPolicyUrl`)
- [ ] Privacy Policy acessível **dentro do app** (sem necessidade de login)
- [ ] Privacy Policy em português (e inglês se app tem usuários internacionais)
- [ ] Privacy Policy atualizada com todos os dados coletados atualmente
- [ ] **Privacy Labels** preenchidos no App Store Connect
  - [ ] Data Used to Track You
  - [ ] Data Linked to You
  - [ ] Data Not Linked to You

---

## 5. Account & Authentication

- [ ] Se app tem criação de conta: **Account Deletion** implementado dentro do app
  - [ ] Acessível em Configurações/Perfil sem precisar de suporte
  - [ ] Exclui ou anonimiza todos os dados do usuário
  - [ ] Mensagem de confirmação clara antes de deletar
- [ ] Se tem login social (Google/Apple/Facebook): configurado corretamente
- [ ] **Sign in with Apple** implementado se app tem outros métodos de login de terceiros

---

## 6. In-App Purchase (se aplicável)

- [ ] **Restore Purchases** botão visível e funcional
- [ ] Preços visíveis antes da compra
- [ ] Termos de assinatura claramente exibidos (duração, preço, renovação)
- [ ] Trial period claramente comunicado
- [ ] Cancelamento explicado (direto para configurações do iOS)
- [ ] Compras testadas no ambiente Sandbox

---

## 7. App Tracking Transparency (se usa tracking)

- [ ] `expo-tracking-transparency` instalado
- [ ] `NSUserTrackingUsageDescription` configurado no app.json
- [ ] Diálogo de ATT exibido antes de inicializar SDKs de tracking
- [ ] SDKs de tracking desabilitados se usuário negar

---

## 8. Funcionalidade e Performance

- [ ] App testado em **device físico** (não apenas simulador)
- [ ] Testado no iPhone com tela menor suportada
- [ ] Testado no iPad (se `supportsTablet: true`)
- [ ] Sem crashes no fluxo principal
- [ ] Sem telas em branco ou estados de loading infinito
- [ ] Todas as URLs e links funcionando
- [ ] Backend **ativo e acessível** (manter por até 7 dias durante review)
- [ ] Sem funcionalidades "Em Breve" ou "Coming Soon" na UI
- [ ] Funcionalidades que requerem permissão testadas com permissão negada

---

## 9. Store Listing (App Store Connect)

- [ ] **Screenshots** tirados do app real (não mockups)
  - [ ] iPhone 6.9" (obrigatório)
  - [ ] iPhone 6.5" (recomendado)
  - [ ] iPad 12.9" (se universal)
- [ ] **App Preview** (vídeo) — opcional mas recomendado
- [ ] Título do app sem keywords spam (máx. 30 caracteres)
- [ ] Subtítulo descritivo (máx. 30 caracteres)
- [ ] Descrição precisa e sem claims não verificáveis
- [ ] Keywords relevantes (máx. 100 caracteres)
- [ ] Categoria primária correta
- [ ] **Age Rating** preenchido (Content Rights)
- [ ] **Copyright** preenchido (ex: "© 2026 Empresa Ltda")

---

## 10. App Review Notes

- [ ] **Demo account** fornecida (email + senha que funciona sem configuração)
- [ ] Instruções de uso se o fluxo for complexo
- [ ] Explicação de qualquer funcionalidade não-óbvia
- [ ] Gravação de vídeo se o app usa hardware (câmera, GPS) que revisor pode não ter acesso

---

## 11. Build e Submissão

- [ ] Build gerado via EAS Build (produção)
- [ ] Build testado via TestFlight antes de submeter para review
- [ ] **Bitcode** configurado conforme necessário (verify EAS settings)
- [ ] Certificados e Provisioning Profiles válidos
- [ ] DSYM arquivos incluídos (para crash reporting)

---

## Verificação Final

Execute o scan automático antes de submeter:

```bash
bash scripts/scan-project.sh .
```

Confirme que:
- [ ] Nenhum item CRÍTICO no relatório
- [ ] Todos os itens acima deste checklist estão marcados
- [ ] TestFlight testado com ao menos 5 testers externos

---

## Referências

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Expo Apple Privacy Guide](https://docs.expo.dev/guides/apple-privacy/)
- `references/apple-app-store.md` — diretrizes condensadas
- `references/common-rejections.md` — evitar rejeições comuns
