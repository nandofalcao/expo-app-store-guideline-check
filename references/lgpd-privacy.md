# LGPD e Privacidade — Referência para Apps Mobile

> Última atualização: 2026-03-28
> Lei 13.709/2018: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/L13709.htm
> ANPD: https://www.gov.br/anpd/pt-br

> **AVISO LEGAL:** Este documento fornece referências técnicas para conformidade com a LGPD.
> Não substitui assessoria jurídica especializada. Consulte um advogado para conformidade legal completa.

---

## Os 10 Princípios da LGPD (Art. 6º)

### 1. Finalidade
- Dados coletados apenas para propósitos **específicos, explícitos e legítimos**
- Não usar dados para finalidades incompatíveis com o informado
- **Aplicação em apps:** declarar na Privacy Policy exatamente para que serve cada dado

### 2. Adequação
- Tratamento compatível com as finalidades informadas ao titular
- Contexto do tratamento deve ser coerente com o que o usuário espera
- **Aplicação em apps:** não usar dados de localização coletados para navegação para fins de marketing

### 3. Necessidade (Data Minimization)
- Coletar apenas os dados **mínimos necessários** para a finalidade declarada
- Princípio fundamental: se não precisa, não coleta
- **Aplicação em apps:** não solicitar permissão de câmera se o app não usa câmera

### 4. Livre Acesso
- Titular tem direito de consultar seus dados **gratuitamente, a qualquer momento**
- Acesso fácil e sem obstáculos
- **Aplicação em apps:** botão "Ver meus dados" acessível, preferencialmente dentro do app

### 5. Qualidade dos Dados
- Dados devem ser **exatos, claros, relevantes e atualizados**
- Mecanismo para o titular corrigir dados incorretos
- **Aplicação em apps:** tela de edição de perfil funcional, dados desatualizados devem ser atualizáveis

### 6. Transparência
- Informações **claras, precisas e facilmente acessíveis** sobre o tratamento
- Identificação do controlador e do DPO
- **Aplicação em apps:** Privacy Policy em linguagem clara, acessível no menu do app

### 7. Segurança
- Medidas técnicas e administrativas para **proteger dados** de acessos não autorizados
- Prevenção de destruição, perda, alteração, comunicação indevida
- **Aplicação em apps:** encriptação, HTTPS, armazenamento seguro, sem API keys expostas

### 8. Prevenção
- Medidas para **prevenir danos** ao titular
- Adotar medidas antes que incidentes ocorram
- **Aplicação em apps:** security audit regular, pentest, monitoramento de incidentes

### 9. Não Discriminação
- Tratamento não discriminatório baseado em dados pessoais
- Proibido usar dados para discriminação ilícita, abusiva, ou de grupos vulneráveis
- **Aplicação em apps:** não usar dados de perfil para recusar serviços ilegalmente

### 10. Responsabilização e Prestação de Contas
- Demonstrar adoção de medidas eficazes de conformidade
- Documentar processos de tratamento
- **Aplicação em apps:** manter registro de atividades de tratamento (ROPA)

---

## Bases Legais para Tratamento (Art. 7º)

Cada operação de coleta de dados precisa de uma base legal:

| Base Legal | Quando Usar |
|-----------|-------------|
| **Consentimento** | Tratamentos opcionais (marketing, analytics opcionais) |
| **Execução de contrato** | Dados necessários para o serviço (ex: email para login) |
| **Obrigação legal** | Dados exigidos por lei |
| **Interesse legítimo** | Segurança, prevenção de fraude, melhorias do serviço |
| **Proteção de crédito** | Scores de crédito |

### Consentimento (Art. 8º)
- Deve ser **livre, informado e inequívoco**
- Em **destaque** — não no meio de um bloco de texto
- Para propósitos específicos — não "consinto com tudo"
- **Revogável a qualquer momento** com facilidade igual à do consentimento
- **Não pode ser pré-marcado** (opt-out não serve como consentimento)

---

## Direitos dos Titulares (Art. 18)

O app deve fornecer mecanismos para exercer estes direitos:

| Direito | Prazo de Resposta | Como Implementar |
|---------|-------------------|------------------|
| Confirmação de tratamento | 15 dias | Tela "Meus Dados" |
| Acesso aos dados | 15 dias | Export de dados ou visualização |
| Correção de dados | Sem prazo específico | Edição de perfil |
| Anonimização / Bloqueio | Sem prazo específico | Botão de suspensão de conta |
| Portabilidade | Sem prazo específico | Export em formato legível |
| Eliminação dos dados | Sem prazo específico | **Account Deletion** |
| Revogação de consentimento | Imediato | Toggle de consentimento |
| Revisão de decisões automatizadas | 15 dias | Canal de contato |

### Account Deletion — Implementação Técnica
- **Obrigatório para lojas:** Apple (obrigatório desde 2023) e Google (fortemente recomendado)
- Deve estar acessível **dentro do app** (não apenas por email)
- Excluir ou anonimizar **todos os dados** (incluindo backups, salvo obrigação legal)
- Confirmar exclusão por email/notificação

---

## Requisitos Técnicos para Apps

### Política de Privacidade
**Conteúdo mínimo obrigatório:**
- Dados coletados e finalidade de cada um
- Base legal para cada tipo de tratamento
- Compartilhamento com terceiros (nomear SDKs e parceiros)
- Retenção de dados (por quanto tempo cada dado é mantido)
- Direitos do titular e como exercê-los
- Como entrar em contato com o DPO
- Como solicitar exclusão de dados
- Data da última atualização

**Onde disponibilizar:**
- URL pública (para App Store Connect e Google Play Console)
- Dentro do app (acessível sem login)
- Na tela de cadastro/onboarding (antes de coletar dados)

### Consentimento — UX Recomendada
```
Tela de onboarding:
[Título claro]
[Descrição do que é coletado e por quê]
[Link para Privacy Policy completa]
[Botão: "Concordar e Continuar"]
[Botão: "Ver configurações de privacidade"]
```

Nunca:
- Pré-selecionar consentimento
- Esconder opção de recusar
- Tornar difícil revogar consentimento

### Segurança Técnica
- **Encriptação em trânsito:** TLS 1.2+ (HTTPS obrigatório)
- **Encriptação em repouso:** para dados sensíveis (use expo-secure-store)
- **Acesso mínimo:** princípio do menor privilégio para APIs/banco de dados
- **Logs:** sem dados pessoais em logs de produção
- **Backups:** política de retenção e exclusão nos backups
- **Autenticação:** senhas com hash (bcrypt/Argon2), não armazenar em texto claro
- **Tokens:** validade limitada, renovação segura

### DPO (Encarregado de Dados) — Art. 41
- Obrigatório para controladores de dados
- Pode ser pessoa física, jurídica, ou prestador de serviços
- Deve ser identificado publicamente (nome e contato na Privacy Policy)
- Canal de comunicação direto com titulares e ANPD

### Notificação de Incidentes — Art. 48
- Em caso de vazamento ou acesso indevido:
- Notificar a **ANPD** em prazo razoável (72h é referência europeia, LGPD não especifica)
- Notificar **titulares afetados** se puder causar dano relevante
- Incluir: natureza dos dados, titulares afetados, medidas tomadas

---

## Crianças e Adolescentes (Art. 14)

- Dados de menores de 18 anos: **consentimento dos pais ou responsáveis legais**
- Crianças (até 12 anos): tratamento somente com **consentimento específico** dos pais
- Sem coleta de dados além do mínimo necessário para participação
- Sem compartilhamento com terceiros sem consentimento parental

---

## Transferência Internacional de Dados (Art. 33)

Se dados são enviados para servidores fora do Brasil (AWS, Google Cloud, Firebase, etc.):
- País destino deve ter nível de proteção adequado (Art. 33, I) **ou**
- Cláusulas contratuais padrão com o prestador **ou**
- Consentimento específico e destacado do titular

**Na prática:** A maioria dos grandes provedores (AWS, GCP, Azure, Firebase) possui
certificações e cláusulas contratuais que atendem esse requisito. Documente.

---

## LGPD vs Apple/Google Requirements

| Requisito | LGPD | Apple | Google Play |
|-----------|------|-------|-------------|
| Privacy Policy | Obrigatório | Obrigatório | Obrigatório |
| Account Deletion | Obrigatório (eliminação) | Obrigatório (desde 2023) | Fortemente recomendado |
| Consentimento | Obrigatório (bases legais) | ATT para tracking | Data Safety disclosure |
| Acesso aos dados | Obrigatório (15 dias) | Não especificado | Não especificado |
| DPO | Obrigatório | Não requerido | Não requerido |
| Notificação de incidente | Obrigatório | Não especificado | Não especificado |

---

## Checklist de Conformidade LGPD

- [ ] Privacy Policy completa, em português, acessível no app e via URL pública
- [ ] Mapeamento de dados (quais dados, por quê, por quanto tempo, com quem)
- [ ] Base legal documentada para cada tipo de tratamento
- [ ] Consentimento explícito antes de coletar dados não-essenciais
- [ ] Tela de gerenciamento de privacidade/consentimento no app
- [ ] Account deletion funcional e acessível dentro do app
- [ ] Mecanismo de acesso aos dados do usuário
- [ ] Mecanismo de exportação de dados (portabilidade)
- [ ] DPO identificado na Privacy Policy com canal de contato
- [ ] Encriptação de dados sensíveis em repouso e em trânsito
- [ ] Política de retenção de dados definida e implementada
- [ ] Processo de resposta a incidentes documentado
- [ ] Contratos de processamento de dados com terceiros (SDKs, APIs)
- [ ] Revisão periódica de conformidade (mínimo anual)

---

## Recursos

- [Lei 13.709/2018 (LGPD)](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/L13709.htm)
- [ANPD — Guias Orientativos](https://www.gov.br/anpd/pt-br/documentos-e-publicacoes)
- [ANPD — Resolução CD/ANPD nº 4/2023 (Fiscalização)](https://www.gov.br/anpd/pt-br)
- [ISO/IEC 27001](https://www.iso.org/isoiec-27001-information-security.html) — referência de segurança
