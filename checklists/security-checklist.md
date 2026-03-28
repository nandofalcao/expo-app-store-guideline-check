# Checklist de Segurança de Dados

> Versão: 1.0 | Atualizado: 2026-03-28
> Baseado em OWASP Mobile Top 10 e boas práticas para React Native/Expo

---

## 1. Armazenamento de Dados

### Dados Sensíveis
- [ ] Tokens de autenticação armazenados em `expo-secure-store` (encriptado)
- [ ] Senhas NUNCA armazenadas localmente
- [ ] Dados de cartão de crédito NUNCA armazenados localmente (use tokenização)
- [ ] Informações de saúde e documentos em armazenamento encriptado
- [ ] `AsyncStorage` usado APENAS para dados não-sensíveis (preferências, cache)

### Verificação do Armazenamento
```typescript
// ✅ Correto — dados sensíveis
import * as SecureStore from 'expo-secure-store';
await SecureStore.setItemAsync('authToken', token);

// ❌ Incorreto — dados sensíveis
import AsyncStorage from '@react-native-async-storage/async-storage';
await AsyncStorage.setItem('authToken', token); // NÃO fazer isso
```

- [ ] Busca por `AsyncStorage.setItem` com palavras como token/auth/password não encontra matches
- [ ] Sem dados de usuário em cookies não-encriptados

---

## 2. Comunicação Segura

### HTTPS / TLS
- [ ] Todos os endpoints de API usam HTTPS
- [ ] Sem URLs `http://` hardcoded no código (exceto localhost)
- [ ] Versão TLS mínima: TLS 1.2 (TLS 1.3 recomendado)
- [ ] Certificados SSL válidos e não expirados nos endpoints

### Android Network Security
- [ ] `android:usesCleartextTraffic="false"` no AndroidManifest (padrão no Android 9+)
- [ ] `network_security_config.xml` não permite cleartext para domínios de produção
- [ ] Sem `cleartextTrafficPermitted="true"` global no build de produção

### iOS App Transport Security (ATS)
- [ ] Sem `NSAllowsArbitraryLoads: true` no Info.plist de produção
- [ ] Exceções de ATS documentadas e justificadas (se necessário)

---

## 3. Segredos e Chaves de API

### No Código-Fonte
- [ ] Sem API keys hardcoded em arquivos `.ts`, `.tsx`, `.js`, `.jsx`
- [ ] Sem tokens ou senhas em código-fonte
- [ ] Sem connection strings de banco de dados expostas
- [ ] Busca por padrões comuns de segredos sem matches:
  ```bash
  grep -rn "api_key\|secret_key\|private_key" src/ --include="*.ts"
  ```

### Em Arquivos de Configuração
- [ ] Arquivos `.env` com valores reais não commitados no git
- [ ] `.gitignore` inclui: `.env`, `.env.local`, `.env.production`, `.env.staging`
- [ ] `.env.example` presente com valores de placeholder (sem segredos reais)
- [ ] `eas.json` não contém segredos (usar EAS Secrets)
- [ ] `app.json` não contém segredos em `expo.extra`

### Variáveis de Ambiente Corretas
```bash
# Verificar .gitignore
cat .gitignore | grep "\.env"

# Verificar se .env está rastreado (não deve estar)
git status .env
```

---

## 4. Autenticação e Sessão

- [ ] Tokens JWT com tempo de expiração curto (access token: 15min-1h)
- [ ] Refresh tokens com expiração maior (ex: 30 dias) e rotação
- [ ] Logout invalida tokens no servidor (não apenas no cliente)
- [ ] Sem tokens em URLs (use Authorization header)
- [ ] Implementação de "revogar todas as sessões" disponível para usuário
- [ ] Rate limiting no endpoint de login (proteção a força bruta)
- [ ] Multi-factor authentication (MFA) para contas sensíveis (recomendado)

---

## 5. Injeção e Validação

- [ ] Inputs do usuário validados antes de enviar para API
- [ ] Sem uso de `eval()` ou `new Function()` no código
- [ ] Sem interpolação de strings não-sanitizadas em queries
- [ ] Sem XSS em WebViews (se usa renderização de HTML do usuário)
- [ ] Deep linking verifica origem antes de executar ações

---

## 6. Privacidade em Logs

- [ ] Logs de produção não incluem dados pessoais
- [ ] Logs não incluem tokens, senhas ou segredos
- [ ] `console.log` com dados sensíveis removidos antes do release
- [ ] Crash reporters (Sentry, Crashlytics) com PII scrubbing configurado
- [ ] Configuração de logging diferente para dev/produção

```typescript
// Biblioteca recomendada para logging seguro
import * as Logger from 'react-native-logs';
// Configurar para desabilitar em produção
```

---

## 7. Proteção do Código (Build de Produção)

- [ ] Modo release/produção ativo no build (não debug)
- [ ] Minificação e ofuscação habilitadas no build de produção
- [ ] `__DEV__` e código de desenvolvimento removidos do build
- [ ] Remote Debugger desabilitado em produção
- [ ] Flipper desabilitado em produção

### EAS Build — verificar eas.json:
```json
{
  "build": {
    "production": {
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

---

## 8. Biometria e Autenticação Local

- [ ] Face ID/Touch ID via `expo-local-authentication` (não implementação customizada)
- [ ] Fallback para PIN/senha se biometria não disponível
- [ ] Autenticação local não substitui autenticação de servidor para operações críticas
- [ ] Re-autenticação solicitada para ações sensíveis (pagamentos, exclusão de conta)

---

## 9. Atualizações e Dependências

- [ ] `npm audit` ou `yarn audit` sem vulnerabilidades críticas/altas
- [ ] Dependências atualizadas (verificar com `npx npm-check-updates`)
- [ ] React Native na versão LTS mais recente
- [ ] Expo SDK na versão mais recente (ou LTS)
- [ ] Processo de atualização de dependências documentado (ex: mensal)

---

## 10. Tratamento de Dados Sensíveis em Memória

- [ ] Senhas limpas da memória após uso (difícil em JS, mas evitar persistência desnecessária)
- [ ] Clipboard limpo após copiar dados sensíveis (opcional, mas boa prática)
- [ ] Screenshots bloqueados em telas com dados financeiros ou de saúde (Android: `FLAG_SECURE`, iOS: similar)

---

## 11. SSL Pinning (Recomendado para Apps Críticos)

Para apps financeiros, de saúde ou com dados muito sensíveis:

- [ ] SSL Pinning implementado para endpoints críticos
- [ ] Certificado inclui backup pins (para rotação segura)
- [ ] Processo de atualização de pins documentado

```bash
# Instalar
npm install react-native-ssl-pinning
```

---

## Verificação Automática

Execute o check de segurança:
```bash
bash scripts/check-security.sh .
```

---

## OWASP Mobile Top 10 (2023) — Cobertura

| Risco | Coberto | Como |
|-------|---------|------|
| M1: Improper Credential Usage | ✅ | Seções 1, 3, 4 |
| M2: Inadequate Supply Chain Security | ✅ | Seção 9 |
| M3: Insecure Authentication/Authorization | ✅ | Seção 4 |
| M4: Insufficient Input/Output Validation | ✅ | Seção 5 |
| M5: Insecure Communication | ✅ | Seção 2 |
| M6: Inadequate Privacy Controls | ✅ | Seção 6, `checklists/privacy-compliance.md` |
| M7: Insufficient Binary Protections | ✅ | Seção 7 |
| M8: Security Misconfiguration | ✅ | Seções 2, 3 |
| M9: Insecure Data Storage | ✅ | Seção 1 |
| M10: Insufficient Cryptography | ✅ | Seções 1, 2, 4 |

---

## Referências

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [React Native Security](https://reactnative.dev/docs/security)
- [Expo Security Guide](https://docs.expo.dev/guides/security/)
- [expo-secure-store](https://docs.expo.dev/versions/latest/sdk/securestore/)
