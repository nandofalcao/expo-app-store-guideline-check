# Motivos Comuns de Rejeição — Apple e Google Play

> Última atualização: 2026-03-28
> Baseado em casos reais e documentação oficial das lojas

---

## Top 10 — Apple App Store

### 1. Crashes e Bugs Óbvios
**Frequência:** Muito Alta
**Guideline:** 2.1 App Completeness

**Sintomas:**
- App trava durante o fluxo principal
- Telas em branco ou que não carregam
- Botões que não funcionam
- Backend offline durante review

**Soluções:**
- Testar em device real (não apenas simulador)
- Testar em iPad se app é universal
- Garantir que o backend está ativo e acessível durante todo período de review
- Usar TestFlight com beta testers externos antes de submeter
- Testar com conta de demo limpa (sem dados de desenvolvimento)

---

### 2. Privacy Manifest Ausente ou Incompleto
**Frequência:** Alta (desde 2024)
**Guideline:** Apple Privacy Requirements 2024

**Sintomas:**
- ITMS-91053: Missing API declaration
- Rejeição indicando APIs não declaradas
- Build rejeitado na validação do Xcode/EAS

**Soluções:**
- Adicionar `expo.ios.privacyManifests` no app.json com todas as APIs do RN Core
- Verificar dependências de terceiros (Sentry, Firebase, etc.)
- Usar `npx expo-doctor` para verificar configuração
- Ver `references/react-native-expo.md` para configuração completa

---

### 3. Metadata Incorreto
**Frequência:** Alta
**Guideline:** 2.3 Accurate Metadata

**Sintomas:**
- Screenshots não refletem a versão atual do app
- Screenshots com dispositivos desatualizados
- Descrição menciona funcionalidades que não existem
- Palavras-chave no nome do app

**Soluções:**
- Tirar screenshots frescos antes de cada submissão
- Usar dispositivos do tamanho certo (iPhone 6.9", 6.5", iPad 12.9")
- Remover qualquer "Coming Soon" da descrição
- Garantir que a categoria está correta

---

### 4. Demo Account Não Fornecida
**Frequência:** Alta
**Guideline:** 2.1 App Completeness

**Sintomas:**
- Email do App Review solicitando credenciais
- Rejeição por não conseguir acessar o conteúdo do app

**Soluções:**
- Sempre fornecer demo account em App Review Notes
- Credenciais devem funcionar sem configuração adicional
- Incluir instruções se o fluxo for complexo
- Para app com câmera/localização: gravações de vídeo do funcionamento ajudam

---

### 5. Account Deletion Ausente
**Frequência:** Média-Alta (obrigatório desde junho/2023)
**Guideline:** 5.1.1(ix)

**Sintomas:**
- "We noticed that your app allows users to create an account but does not have the option to initiate deletion of their account from within the app"

**Soluções:**
- Adicionar opção de exclusão de conta em Configurações/Perfil do app
- A exclusão deve excluir TODOS os dados do usuário (ou anonimizar)
- Pode ter período de 30 dias antes da exclusão definitiva (mas deve ser claro)
- Não aceitar "envie email para deletar" — deve ser autoserviço

---

### 6. Restore Purchases Ausente
**Frequência:** Média
**Guideline:** 3.1.1

**Sintomas:**
- Rejeição em apps com IAP sem botão de restore

**Soluções:**
- Adicionar botão "Restaurar Compras" visível
- Implementar `purchasesAreRestored` callback
- Testar restore com conta de Sandbox que já comprou

---

### 7. Usage Descriptions Genéricas
**Frequência:** Média
**Guideline:** 5.1.1

**Sintomas:**
- "The purpose string in the NSCameraUsageDescription key is not sufficient"

**Soluções:**
- Descriptions devem explicar o propósito real, não apenas afirmar que o app precisa
- Ruim: "This app needs camera access"
- Bom: "Usamos a câmera para você fotografar suas plantas e receber identificação automática"
- Referenciar a funcionalidade específica que usa a permissão

---

### 8. WebView Wrapper
**Frequência:** Média
**Guideline:** 4.2 Minimum Functionality

**Sintomas:**
- App é essencialmente um website aberto em WebView
- Sem funcionalidade nativa significativa
- UI identical ao website da empresa

**Soluções:**
- Adicionar valor nativo (notificações push, acesso à câmera, biometria, offline)
- Garantir que a experiência nativa é significativamente melhor que o website
- Se é um app híbrido, a WebView deve ser complemento, não a funcionalidade principal

---

### 9. Conteúdo UGC Sem Moderação
**Frequência:** Média-Baixa
**Guideline:** 1.2 User Generated Content

**Sintomas:**
- App permite usuários postarem conteúdo sem mecanismo de denúncia
- Ausência de Report/Block buttons

**Soluções:**
- Adicionar botão de "Denunciar" em todo conteúdo de usuários
- Implementar botão de "Bloquear usuário"
- Ter mecanismo de moderação (automático ou manual)
- Mencionar mecanismos de moderação no App Review Notes

---

### 10. Backend Inativo durante Review
**Frequência:** Média-Baixa
**Guideline:** 2.1 App Completeness

**Sintomas:**
- Reviewers não conseguem usar o app por erros de rede/API

**Soluções:**
- Manter ambiente de produção estável durante todo o período de review (até 7 dias)
- Se usar feature flags, garantir que todas as features estão habilitadas para o reviewer
- Monitorar uptime com alertas
- Fornecer IP de localização dos reviewers para whitelist se necessário (Apple usa IPs em Cupertino, CA)

---

## Top 10 — Google Play Store

### 1. Violação da Política de Dados do Usuário
**Frequência:** Alta
**Policy:** User Data Policy

**Sintomas:**
- App removido por coleta de dados sem disclosure
- Warning sobre práticas de privacidade

**Soluções:**
- Preencher Data Safety Section corretamente
- Declarar TODOS os SDKs que coletam dados
- Privacy Policy acessível e atualizada
- Não coletar mais dados do que o declarado

---

### 2. Target API Level Desatualizado
**Frequência:** Alta
**Policy:** Target API Requirements

**Sintomas:**
- "Your app currently targets API level X. It needs to target API level Y or higher"
- App impedido de ser publicado/atualizado

**Soluções:**
- Atualizar `targetSdkVersion` no build.gradle ou app.json
- Testar comportamento em Android 14/15 antes de publicar
- Verificar se todas as dependências suportam o novo target SDK

---

### 3. Permissões Excessivas ou Injustificadas
**Frequência:** Média-Alta
**Policy:** Permissions Policy

**Sintomas:**
- "Your app requests permissions that are not used by your app's functionality"
- Rejeição por permissão hazardous sem justificativa

**Soluções:**
- Remover permissões não utilizadas do AndroidManifest.xml
- Para permissões sensíveis: adicionar justificativa clara no Store Listing
- Para `ACCESS_BACKGROUND_LOCATION`: aprovação especial necessária

---

### 4. Data Safety Section Incompleta ou Incorreta
**Frequência:** Média-Alta
**Policy:** Data Safety

**Sintomas:**
- Warning indicando que Data Safety não reflete comportamento real do app
- Formulário não preenchido

**Soluções:**
- Preencher Data Safety completamente no Play Console
- Incluir todos os SDKs de terceiros que coletam dados
- Manter sincronizado com a Privacy Policy
- Ver template em `templates/data-safety-form.md`

---

### 5. Spam / Conteúdo Repetitivo
**Frequência:** Média
**Policy:** Spam and Minimum Functionality

**Sintomas:**
- App muito similar a outro app do mesmo desenvolvedor
- Funcionalidade mínima
- Conteúdo gerado programaticamente

**Soluções:**
- Garantir que o app tem valor único e funcionalidade significativa
- Evitar publicar múltiplos apps idênticos com apenas o tema diferente

---

### 6. Violação da Política de Pagamentos
**Frequência:** Média
**Policy:** Payments

**Sintomas:**
- App com compras digitais que não usam Google Play Billing
- Link para comprar fora do Google Play para conteúdo digital

**Soluções:**
- Usar Google Play Billing para todos os conteúdos digitais
- Remover links/botões para compra externa de conteúdo digital
- User Choice Billing disponível em alguns países (checkout alternativo)

---

### 7. Conteúdo Inadequado para a Classificação
**Frequência:** Média
**Policy:** Restricted Content

**Sintomas:**
- App classificado inadequadamente
- Conteúdo adulto em app classificado para todas as idades

**Soluções:**
- Preencher Content Rating Questionnaire honestamente
- Classificar corretamente (IARC)
- Não expor conteúdo adulto em apps para menores

---

### 8. Ícone, Screenshot ou Descrição Enganosos
**Frequência:** Média
**Policy:** Store Listing and Promotion

**Sintomas:**
- Screenshots prometem funcionalidades não existentes
- Ícone imita app famoso

**Soluções:**
- Screenshots e preview de app devem refletir experiência real
- Ícone deve ser original
- Descrição sem claims não verificáveis ("o melhor", "o único")

---

### 9. Uso Indevido de Permissões de Acessibilidade
**Frequência:** Baixa-Média
**Policy:** Device and Network Abuse

**Sintomas:**
- App usa AccessibilityService para coleta de dados não declarada

**Soluções:**
- Usar AccessibilityService apenas para funcionalidades de acessibilidade real
- Qualquer uso não-padrão requer aprovação especial

---

### 10. Violação de Propriedade Intelectual
**Frequência:** Baixa-Média
**Policy:** Intellectual Property

**Sintomas:**
- App usa marca registrada de terceiros sem autorização
- Conteúdo protegido por copyright

**Soluções:**
- Verificar se nome, ícone e conteúdo não violam IP de terceiros
- Obter licenças necessárias para músicas, imagens, fontes
- Remover qualquer referência não autorizada a marcas registradas

---

## Dicas Gerais para Evitar Rejeições

1. **Testar em device real** antes de qualquer submissão
2. **Ler a rejeição completamente** — os revisores incluem detalhes específicos
3. **Responder com screenshots** quando contestar uma rejeição
4. **Manter um changelog** do que foi alterado para facilitar re-submissão
5. **Usar TestFlight/Internal Testing** extensivamente antes de produção
6. **Monitorar o app após aprovação** — apps podem ser removidos depois
7. **Manter Privacy Policy atualizada** conforme o app evolui
