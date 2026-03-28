# React Native / Expo — Verificações Específicas

> Última atualização: 2026-03-28
> Documentação Expo: https://docs.expo.dev

---

## Expo SDK — Versões e Compatibilidade

| SDK | Status | Suporte iOS | Suporte Android |
|-----|--------|-------------|-----------------|
| SDK 52 | Atual | iOS 16+ | Android 7+ (API 24+) |
| SDK 51 | LTS | iOS 15.1+ | Android 6+ (API 23+) |
| SDK 50 | Deprecated | iOS 13+ | Android 6+ |
| SDK 49 e anteriores | EOL | Não recomendado | Não recomendado |

**Verificar:** `expo upgrade` para atualizar para o SDK mais recente.

---

## Privacy Manifest (iOS) no Expo

### Configuração no app.json

```json
{
  "expo": {
    "ios": {
      "privacyManifests": {
        "NSPrivacyTracking": false,
        "NSPrivacyTrackingDomains": [],
        "NSPrivacyCollectedDataTypes": [],
        "NSPrivacyAccessedAPITypes": [
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
            "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
          },
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryFileTimestamp",
            "NSPrivacyAccessedAPITypeReasons": ["C617.1"]
          },
          {
            "NSPrivacyAccessedAPICategorySystemBootTime": "35F9.1",
            "NSPrivacyAccessedAPITypeReasons": ["35F9.1"]
          }
        ]
      }
    }
  }
}
```

### APIs usadas pelo React Native Core
O React Native core utiliza internamente:
- `NSPrivacyAccessedAPICategoryUserDefaults` (reason: CA92.1)
- `NSPrivacyAccessedAPICategoryFileTimestamp` (reason: C617.1)
- `NSPrivacyAccessedAPICategorySystemBootTime` (reason: 35F9.1)
- `NSPrivacyAccessedAPICategoryDiskSpace` (reason: E174.1)

**Sempre declare todas as 4 APIs acima** mesmo sem usar módulos adicionais.

---

## expo-secure-store

Armazenamento encriptado para dados sensíveis:

```bash
npx expo install expo-secure-store
```

```typescript
import * as SecureStore from 'expo-secure-store';

// Salvar
await SecureStore.setItemAsync('authToken', token);

// Ler
const token = await SecureStore.getItemAsync('authToken');

// Deletar
await SecureStore.deleteItemAsync('authToken');
```

**Regra:** Use expo-secure-store para tokens, senhas, chaves de API.
Use AsyncStorage apenas para dados não-sensíveis (preferências, cache).

---

## expo-tracking-transparency (ATT)

```bash
npx expo install expo-tracking-transparency
```

```typescript
import { requestTrackingPermissionsAsync } from 'expo-tracking-transparency';

// Antes de inicializar Firebase Analytics, Amplitude, etc.
const { status } = await requestTrackingPermissionsAsync();
if (status === 'granted') {
  // Inicializar SDKs de tracking
}
```

No `app.json`, adicionar:
```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSUserTrackingUsageDescription": "Usamos seus dados para personalizar a experiência e melhorar o app."
      }
    }
  }
}
```

---

## Permissões Comuns no Expo

### Câmera
```json
{
  "expo": {
    "plugins": [
      [
        "expo-camera",
        {
          "cameraPermission": "Permitir que $(PRODUCT_NAME) acesse sua câmera para tirar fotos."
        }
      ]
    ]
  }
}
```

### Localização
```json
{
  "expo": {
    "plugins": [
      [
        "expo-location",
        {
          "locationAlwaysAndWhenInUsePermission": "Usamos sua localização para mostrar pontos próximos.",
          "locationWhenInUsePermission": "Usamos sua localização para mostrar pontos próximos."
        }
      ]
    ]
  }
}
```

### Notificações Push
```json
{
  "expo": {
    "plugins": [
      [
        "expo-notifications",
        {
          "icon": "./assets/notification-icon.png",
          "color": "#ffffff",
          "sounds": ["./assets/notification-sound.wav"]
        }
      ]
    ]
  }
}
```

---

## Expo OTA Updates (Over-The-Air)

### Limitações das Lojas
- OTA updates **não podem** mudar funcionalidade core do app
- Não podem adicionar novas permissões via OTA
- Podem: corrigir bugs, atualizar conteúdo, ajustar UI
- Apple: OTA que muda funcionalidade primária = rejeição
- Google: OTA permitido com mais flexibilidade

### Configuração
```json
{
  "expo": {
    "updates": {
      "enabled": true,
      "fallbackToCacheTimeout": 0,
      "url": "https://u.expo.dev/seu-project-id"
    },
    "runtimeVersion": {
      "policy": "sdkVersion"
    }
  }
}
```

---

## Deep Linking e Universal Links

### Configuração Básica
```json
{
  "expo": {
    "scheme": "meuapp",
    "ios": {
      "associatedDomains": ["applinks:meuapp.com"]
    },
    "android": {
      "intentFilters": [
        {
          "action": "VIEW",
          "autoVerify": true,
          "data": [
            {
              "scheme": "https",
              "host": "meuapp.com",
              "pathPrefix": "/app"
            }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}
```

### Arquivo apple-app-site-association (iOS)
Hospedar em `https://meuapp.com/.well-known/apple-app-site-association`:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.empresa.app",
        "paths": ["/app/*"]
      }
    ]
  }
}
```

---

## EAS Build

### Configuração eas.json
```json
{
  "cli": {
    "version": ">= 7.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "ios": { "simulator": false },
      "android": { "buildType": "apk" }
    },
    "production": {
      "ios": { "resourceClass": "m-medium" },
      "android": { "buildType": "app-bundle" }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "seu@email.com",
        "ascAppId": "123456789"
      },
      "android": {
        "serviceAccountKeyPath": "./play-store-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

### EAS Secrets (para credenciais no build)
```bash
# Adicionar secret
eas secret:create --scope project --name MY_API_KEY --value "valor_secreto"

# Usar no app.config.js
export default {
  expo: {
    extra: {
      apiUrl: process.env.API_URL,  // NÃO use process.env para secrets do cliente!
    }
  }
}
```

**Atenção:** `expo.extra` é incluído no bundle do app — não coloque secrets lá!
Secrets devem estar apenas no servidor/backend.

---

## React Native New Architecture (Fabric + TurboModules)

A partir do React Native 0.74+, a New Architecture é padrão.
Para Expo SDK 52+, New Architecture está habilitada por padrão.

```json
{
  "expo": {
    "newArchEnabled": true
  }
}
```

Verificar compatibilidade de módulos nativos com New Architecture antes de habilitar.

---

## Configuração para as Lojas

### app.json Completo (Exemplo Recomendado)
```json
{
  "expo": {
    "name": "Meu App",
    "slug": "meu-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "scheme": "meuapp",
    "privacyPolicyUrl": "https://meuapp.com/privacidade",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "supportsTablet": false,
      "bundleIdentifier": "com.empresa.meuapp",
      "buildNumber": "1",
      "privacyPolicyUrl": "https://meuapp.com/privacidade",
      "infoPlist": {
        "NSCameraUsageDescription": "Usamos a câmera para você tirar fotos de perfil.",
        "NSPhotoLibraryUsageDescription": "Acessamos a galeria para você escolher uma foto de perfil."
      },
      "privacyManifests": {
        "NSPrivacyTracking": false,
        "NSPrivacyAccessedAPITypes": [
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
            "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
          },
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryFileTimestamp",
            "NSPrivacyAccessedAPITypeReasons": ["C617.1"]
          },
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategorySystemBootTime",
            "NSPrivacyAccessedAPITypeReasons": ["35F9.1"]
          },
          {
            "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryDiskSpace",
            "NSPrivacyAccessedAPITypeReasons": ["E174.1"]
          }
        ]
      }
    },
    "android": {
      "package": "com.empresa.meuapp",
      "versionCode": 1,
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "permissions": [
        "CAMERA",
        "READ_MEDIA_IMAGES"
      ]
    },
    "plugins": [
      "expo-router",
      [
        "expo-camera",
        {
          "cameraPermission": "Usamos a câmera para você tirar fotos de perfil."
        }
      ]
    ]
  }
}
```

---

## Recursos

- [Expo Documentation](https://docs.expo.dev)
- [Expo Apple Privacy Manifest Guide](https://docs.expo.dev/guides/apple-privacy/)
- [EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [Expo Security Best Practices](https://docs.expo.dev/guides/security/)
- [React Native Security](https://reactnative.dev/docs/security)
