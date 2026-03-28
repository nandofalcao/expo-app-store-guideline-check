# Checklist de Conformidade com Privacidade

> Versão: 1.0 | Atualizado: 2026-03-28
> Cobre: LGPD (Brasil) + Apple App Store + Google Play Store

---

## 1. Política de Privacidade

### Existência e Acessibilidade
- [ ] Privacy Policy existe em URL pública e permanente
- [ ] Privacy Policy acessível **dentro do app** (sem login)
- [ ] Link para Privacy Policy na tela de onboarding/cadastro
- [ ] URL configurada no App Store Connect (Apple)
- [ ] URL configurada no Google Play Console
- [ ] Privacy Policy em **português** (para usuários brasileiros)

### Conteúdo da Privacy Policy
- [ ] Dados coletados listados explicitamente
- [ ] Finalidade de uso de cada tipo de dado
- [ ] Base legal para cada tratamento (LGPD)
- [ ] Compartilhamento com terceiros (listar SDKs e parceiros)
- [ ] Política de retenção de dados (por quanto tempo cada dado é mantido)
- [ ] Direitos dos titulares explicados
- [ ] Como exercer cada direito (instrução clara)
- [ ] Nome e contato do DPO/Encarregado de Dados
- [ ] Procedimento em caso de incidente de segurança
- [ ] Data da última atualização
- [ ] Informações sobre transferência internacional (se dados vão para fora do Brasil)

---

## 2. Consentimento

- [ ] Consentimento solicitado **antes** de coletar dados não-essenciais
- [ ] Consentimento em **destaque** (não enterrado em texto)
- [ ] Descrição clara do que está sendo autorizado
- [ ] Link para Privacy Policy completa no momento do consentimento
- [ ] Opção de **recusar** igualmente acessível à opção de aceitar
- [ ] Sem pré-marcação de checkboxes de consentimento
- [ ] Mecanismo de **revogação** de consentimento no app
- [ ] App funciona (com funcionalidade reduzida) para quem recusa dados opcionais
- [ ] Consentimento separado por finalidade (marketing ≠ analytics ≠ essencial)

---

## 3. Dados Coletados — Inventário

Para cada dado coletado, verificar:

| Dado | Coletado? | Base Legal | Finalidade | Retenção | Compartilhado com |
|------|-----------|------------|-----------|----------|-------------------|
| Email | | | | | |
| Nome | | | | | |
| Localização | | | | | |
| Fotos/Vídeos | | | | | |
| Dados de uso | | | | | |
| Device ID | | | | | |
| Crash logs | | | | | |
| Push tokens | | | | | |

- [ ] Inventário de dados preenchido e atualizado
- [ ] Cada dado tem base legal definida
- [ ] Nenhum dado coletado sem finalidade clara

---

## 4. Direitos dos Titulares

### Acesso aos Dados
- [ ] Usuário pode visualizar seus dados dentro do app **ou**
- [ ] Mecanismo de solicitação de acesso (máx. 15 dias de resposta pela LGPD)
- [ ] Resposta em formato legível

### Correção de Dados
- [ ] Usuário pode editar seu perfil e dados básicos
- [ ] Processo para corrigir dados que não estão no app (contato com DPO)

### Exclusão de Dados (Account Deletion)
- [ ] **Funcionalidade de exclusão dentro do app** (obrigatório Apple e LGPD)
- [ ] Exclusão remove **todos** os dados do usuário (incluindo backups, ressalvado obrigação legal)
- [ ] Período de exclusão clara (imediato ou até 30 dias)
- [ ] Confirmação de exclusão enviada por email/notificação
- [ ] Opção de exportar dados antes de excluir (portabilidade)

### Portabilidade
- [ ] Export de dados disponível (JSON, CSV ou formato legível)
- [ ] Processo documentado e comunicado na Privacy Policy

### Revogação de Consentimento
- [ ] Toggle de marketing/analytics nas configurações
- [ ] Ação imediata após revogação
- [ ] App não pede consentimento novamente imediatamente

---

## 5. Segurança dos Dados

- [ ] HTTPS em todos os endpoints de API
- [ ] Dados sensíveis encriptados em repouso (expo-secure-store)
- [ ] Senhas com hash (bcrypt/Argon2) — nunca texto claro
- [ ] Tokens com validade limitada e renovação segura
- [ ] Sem dados pessoais em logs de produção
- [ ] Sem dados sensíveis em AsyncStorage
- [ ] Acesso mínimo a APIs (princípio do menor privilégio)
- [ ] Revisão de segurança realizada antes de cada lançamento major

---

## 6. SDKs de Terceiros

- [ ] Lista de todos os SDKs que coletam dados do usuário
- [ ] DPA (Data Processing Agreement) assinado com cada processador
- [ ] Configurações de privacidade de cada SDK verificadas

**SDKs comuns — verificar:**
- [ ] Firebase Analytics: configuração de data retention, disable para menores
- [ ] Firebase Crashlytics: dados de crash são anonimizados?
- [ ] Amplitude/Mixpanel: user deletion API disponível?
- [ ] Sentry: configuração de PII scrubbing ativa
- [ ] Google Ads/AdMob: conformidade com Families Policy (se app para crianças)
- [ ] Branch/Adjust/Appsflyer: data processing agreement assinado

---

## 7. Crianças e Adolescentes (se aplicável)

- [ ] Classificação do app indica público-alvo (com ou sem menores)
- [ ] Se app para menores: coleta mínima de dados
- [ ] Se app para menores: sem publicidade comportamental de terceiros
- [ ] Consentimento parental implementado (se coleta dados de menores de 12 anos)
- [ ] COPPA compliance verificada (se distribuído nos EUA)

---

## 8. DPO (Encarregado de Dados)

- [ ] DPO identificado (pessoa física ou jurídica)
- [ ] Nome do DPO na Privacy Policy
- [ ] Email/contato do DPO na Privacy Policy e dentro do app
- [ ] Canal de contato com a ANPD configurado
- [ ] DPO treinado sobre LGPD e obrigações do cargo

---

## 9. Resposta a Incidentes

- [ ] Processo documentado para resposta a vazamentos
- [ ] Responsável por coordenar resposta a incidentes definido
- [ ] Checklist de notificação à ANPD disponível
- [ ] Template de notificação aos usuários disponível
- [ ] Monitoramento de segurança ativo (alertas de anomalias)

---

## 10. Revisão e Manutenção

- [ ] Privacy Policy revisada a cada lançamento com novos dados/funcionalidades
- [ ] Privacy Policy com data de "última atualização" visível
- [ ] Revisão anual de conformidade agendada
- [ ] Processo de notificação a usuários quando Privacy Policy muda
- [ ] Registro de atividades de tratamento (ROPA) mantido internamente

---

## Verificação Final

- [ ] Escanear com `bash scripts/scan-project.sh .` e resolver itens CRÍTICOS
- [ ] Consultar `templates/privacy-policy-pt-br.md` para geração/revisão da Privacy Policy
- [ ] Confirmar que Data Safety (Google) e Privacy Labels (Apple) estão consistentes com a Privacy Policy
- [ ] Advogado especializado em LGPD revisou os documentos (recomendado)

---

## Referências

- `references/lgpd-privacy.md` — detalhes da LGPD
- `templates/privacy-policy-pt-br.md` — template de Privacy Policy
- [ANPD — Guias Orientativos](https://www.gov.br/anpd/pt-br/documentos-e-publicacoes)
- [LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/L13709.htm)
