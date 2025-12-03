# 🌐 Déploiement Web - NaturaliQCM

## ✅ Modifications pour la Compatibilité Web

Ce document décrit les modifications apportées pour rendre l'application compatible avec le déploiement web via GitHub Actions.

### 📦 Dépendances Ajoutées

```yaml
# pubspec.yaml
sqflite_common_ffi: ^2.3.0          # Support FFI pour SQLite
sqflite_common_ffi_web: ^0.4.0+2    # SQLite pour Web via IndexedDB
universal_html: ^2.2.4               # Détection de plateforme
```

### 🗂️ Architecture Multi-Plateforme

L'application utilise maintenant des **imports conditionnels** pour charger le bon code selon la plateforme:

```
lib/
├── data/
│   ├── database_helper.dart         # Export conditionnel
│   ├── database_helper_mobile.dart  # Implementation mobile (sqflite)
│   ├── database_helper_web.dart     # Implementation web (IndexedDB)
│   └── database_helper_stub.dart    # Stub (jamais utilisé)
│
└── core/services/
    ├── biometric_service.dart       # Export conditionnel
    ├── biometric_service_mobile.dart  # Mobile (local_auth)
    ├── biometric_service_web.dart     # Web (stub - non disponible)
    │
    ├── apple_auth_service.dart
    ├── apple_auth_service_mobile.dart
    ├── apple_auth_service_web.dart
    │
    ├── passkey_service.dart
    ├── passkey_service_mobile.dart
    └── passkey_service_web.dart
```

### 🔄 Fonctionnement des Imports Conditionnels

```dart
// database_helper.dart
export 'database_helper_stub.dart'
    if (dart.library.io) 'database_helper_mobile.dart'
    if (dart.library.html) 'database_helper_web.dart';
```

- **Mobile (Android/iOS)**: Utilise `database_helper_mobile.dart` avec sqflite natif
- **Web**: Utilise `database_helper_web.dart` avec sqflite_common_ffi_web (IndexedDB)
- **Stub**: Jamais utilisé, juste pour la compilation

### 📊 Base de Données Web

La version web utilise **sqflite_common_ffi_web** qui:
- Stocke les données dans **IndexedDB** du navigateur
- Compatible avec le schéma SQLite existant
- Fonctionne de manière identique à la version mobile
- Données persistantes localement (offline-first)

### 🔐 Limitations Web

Certaines fonctionnalités ne sont pas disponibles sur web:

| Fonctionnalité | Mobile | Web | Solution Web |
|----------------|--------|-----|--------------|
| Authentification biométrique | ✅ | ❌ | Retourne `isAvailable() = false` |
| Sign in with Apple | ✅ | ❌ | Retourne `isAvailable() = false` |
| Passkeys Android | ✅ | ❌ | Retourne `isAvailable() = false` |
| Base de données SQLite | ✅ | ✅ | IndexedDB via sqflite_common_ffi_web |
| Stockage sécurisé | ✅ | ⚠️ | Limité (utilise SharedPreferences) |

Les services d'authentification retournent gracieusement des erreurs sur web sans crasher l'application.

### 🎨 Assets Créés

Des icônes placeholder ont été générées:
- `assets/images/icon.png` (1024x1024)
- `assets/images/splash_logo.png`
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`
- `web/favicon.png`

**Note**: Ces icônes sont des placeholders basiques. Pour la production, remplacez-les par des designs professionnels.

### 🚀 Déploiement via GitHub Actions

Trois workflows sont disponibles:

#### 1. GitHub Pages
```bash
# Automatique sur push main ou manuel
git push origin main
# OU
# Actions → Deploy Web → Run workflow
```
URL: `https://naciro2010.github.io/NaturaliQCM/`

#### 2. Netlify
```bash
# Automatique sur push main ou manuel
# Actions → Deploy to Netlify → Run workflow
```
Secrets requis:
- `NETLIFY_AUTH_TOKEN`
- `NETLIFY_SITE_ID`

#### 3. Vercel
Configuration via `vercel.json` (déploiement manuel ou via Vercel CLI)

### ✅ Tests

Les tests passent sur toutes les plateformes:
```bash
# Mobile
flutter test

# Web (via CI)
flutter test --platform chrome
```

### 📝 Code Modifié

**Fichiers modifiés:**
- `pubspec.yaml` - Ajout des dépendances web
- `lib/data/database_helper.dart` - Export conditionnel
- `lib/core/services/biometric_service.dart` - Export conditionnel
- `lib/core/services/apple_auth_service.dart` - Export conditionnel
- `lib/core/services/passkey_service.dart` - Export conditionnel

**Fichiers créés:**
- Implementations mobile (*_mobile.dart)
- Implementations web (*_web.dart)
- Stubs (*_stub.dart)
- Assets placeholder (icons, splash)

### 🔧 Développement Local Web

```bash
# Lancer en mode web
flutter run -d chrome

# Ou pour une page web serveur
flutter run -d web-server --web-port 8080

# Build de production
flutter build web --release
```

### 🎯 Prochaines Étapes

1. ✅ **Déploiement automatique configuré** via GitHub Actions
2. ⚠️ **Remplacer les icônes placeholder** par de vrais designs
3. ⚠️ **Configurer les secrets GitHub** pour Netlify si utilisé
4. ✅ **L'app est fonctionnelle sur web** avec base de données locale

### 📞 Support

- **Mobile**: Toutes les fonctionnalités disponibles
- **Web**: Fonctionnalités core disponibles, auth biométrique désactivée
- **Offline**: Fonctionne 100% offline sur les deux plateformes

---

**Date**: 3 décembre 2024
**Version**: 0.1.0+1
**Status**: ✅ **Prêt pour déploiement web via GitHub Actions**
