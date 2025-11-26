# Guide de Déploiement - NaturaliQCM

Ce document détaille la configuration et les procédures de déploiement automatique pour toutes les plateformes supportées.

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Déploiement Web](#déploiement-web)
3. [Configuration Android](#configuration-android)
4. [Configuration iOS](#configuration-ios)
5. [Déploiement automatique](#déploiement-automatique)
6. [Déploiement manuel](#déploiement-manuel)
7. [Résolution des problèmes](#résolution-des-problèmes)

## 🌐 Vue d'ensemble

NaturaliQCM supporte le déploiement sur plusieurs plateformes :

- **Web** : GitHub Pages, Netlify, Vercel
- **Android** : Google Play Store (Internal, Beta, Production)
- **iOS** : App Store (TestFlight, Production)

### Documentation détaillée

- 📱 **[Guide de déploiement Web complet](docs/DEPLOYMENT_WEB.md)** - Toutes les options web (GitHub Pages, Netlify, Vercel)
- 🤖 **Android** - Configuration Google Play (voir ci-dessous)
- 🍎 **iOS** - Configuration App Store (voir ci-dessous)

## 🌐 Déploiement Web

Pour un guide complet du déploiement web, consultez **[docs/DEPLOYMENT_WEB.md](docs/DEPLOYMENT_WEB.md)**.

### Déploiement rapide

#### GitHub Pages (déjà configuré)

```bash
# Automatique à chaque push sur main
git push origin main

# Ou via tag
git tag v1.0.0-web
git push origin v1.0.0-web
```

L'application sera disponible à : `https://naciro2010.github.io/NaturaliQCM/`

#### Netlify (recommandé pour production)

1. Configurer les secrets GitHub :
   - `NETLIFY_AUTH_TOKEN`
   - `NETLIFY_SITE_ID`

2. Déployer :
   ```bash
   git push origin main
   # ou
   Actions → Deploy to Netlify → Run workflow
   ```

#### Preview des Pull Requests

Chaque PR obtient automatiquement une URL de preview via Netlify !

### Fonctionnalités web activées

✅ **PWA complète** - Fonctionne offline, installable
✅ **SEO optimisé** - Meta tags, Open Graph, Twitter Cards
✅ **Performance** - Cache optimisé, CDN, compression
✅ **Sécurité** - Headers CSP, HTTPS, protection XSS
✅ **Monitoring** - Support Analytics intégré

## 🚀 Configuration initiale

### Prérequis

- Compte développeur Google Play Console (99€ unique)
- Compte développeur Apple Developer Program (99€/an)
- Accès administrateur au repository GitHub
- Flutter SDK 3.24.0+
- Ruby 3.2+ et Bundler
- Fastlane installé

### Installation des dépendances

```bash
# Installer Fastlane globalement
gem install fastlane

# Installer les dépendances Android
cd android
bundle install

# Installer les dépendances iOS
cd ../ios
bundle install
```

## 🤖 Configuration Android

### 1. Créer la clé de signature (Keystore)

```bash
keytool -genkey -v -keystore android/app/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias naturaliqcm
```

**Important**: Sauvegarder précieusement :
- Le fichier `keystore.jks`
- Le mot de passe du keystore
- Le mot de passe de la clé
- L'alias de la clé

### 2. Créer le fichier key.properties (local uniquement)

Créer `android/key.properties` :

```properties
storePassword=votre_mot_de_passe_keystore
keyPassword=votre_mot_de_passe_cle
keyAlias=naturaliqcm
storeFile=keystore.jks
```

**Note**: Ce fichier est dans `.gitignore` et ne doit JAMAIS être commité.

### 3. Configurer Google Play Console

#### a. Créer l'application

1. Aller sur [Google Play Console](https://play.google.com/console)
2. Créer une nouvelle application
3. Remplir les informations de base (nom, description, catégorie)
4. Package name: `fr.naturalisation.qcm`

#### b. Créer un compte de service

1. Dans Google Play Console → Paramètres → Accès à l'API
2. Créer un nouveau compte de service
3. Télécharger le fichier JSON de clé
4. Accorder les permissions nécessaires au compte de service :
   - Gérer les versions de production
   - Gérer les versions de test

### 4. Configurer les secrets GitHub pour Android

Aller dans **Settings → Secrets and variables → Actions** et ajouter :

```bash
# Encoder le keystore en base64
base64 -i android/app/keystore.jks | pbcopy

# Encoder la clé JSON de Google Play en base64
base64 -i google-play-key.json | pbcopy
```

Secrets à créer :

| Secret | Description | Exemple |
|--------|-------------|---------|
| `ANDROID_KEYSTORE_BASE64` | Keystore encodé en base64 | `MIIKqgIBAzCC...` |
| `ANDROID_KEYSTORE_PASSWORD` | Mot de passe du keystore | `mon_mot_de_passe` |
| `ANDROID_KEY_ALIAS` | Alias de la clé | `naturaliqcm` |
| `ANDROID_KEY_PASSWORD` | Mot de passe de la clé | `mon_mot_de_passe` |
| `GOOGLE_PLAY_JSON_KEY_BASE64` | Clé JSON Google Play en base64 | `ewogICJ0eXBlI...` |

## 🍎 Configuration iOS

### 1. Créer l'App ID

1. Aller sur [Apple Developer Portal](https://developer.apple.com)
2. Certificates, Identifiers & Profiles → Identifiers
3. Créer un nouveau App ID
   - Bundle ID: `fr.naturalisation.qcm`
   - Capabilities: Push Notifications, Sign in with Apple, etc.

### 2. Créer l'application sur App Store Connect

1. Aller sur [App Store Connect](https://appstoreconnect.apple.com)
2. Mes Apps → Nouvelle App
3. Remplir les informations
4. Bundle ID: `fr.naturalisation.qcm`

### 3. Configurer Match (gestion des certificats)

Match permet de synchroniser les certificats et profils de provisioning via Git.

#### a. Créer un repository privé pour les certificats

```bash
# Créer un nouveau repository privé sur GitHub
# Exemple: https://github.com/votre-organisation/certificates
```

#### b. Initialiser Match

```bash
cd ios
bundle exec fastlane match init
# Choisir 'git' comme storage mode
# Entrer l'URL du repository: git@github.com:votre-organisation/certificates.git
```

#### c. Générer les certificats

```bash
# Générer les certificats et profils de provisioning
bundle exec fastlane match appstore

# Entrer un mot de passe pour chiffrer les certificats
# Ce mot de passe sera nécessaire pour le CI/CD
```

### 4. Créer une clé API App Store Connect

1. App Store Connect → Users and Access → Keys → App Store Connect API
2. Créer une nouvelle clé avec le rôle "Developer"
3. Télécharger le fichier `.p8`
4. Noter l'Issuer ID et le Key ID

### 5. Créer une clé SSH pour Match

```bash
# Générer une clé SSH dédiée pour Match
ssh-keygen -t ed25519 -C "match-github" -f ~/.ssh/match_deploy_key

# Ajouter la clé publique aux Deploy Keys du repository de certificats
# (Settings → Deploy Keys → Add deploy key)
# Cocher "Allow write access"
cat ~/.ssh/match_deploy_key.pub
```

### 6. Créer un mot de passe spécifique à l'application

1. Aller sur [appleid.apple.com](https://appleid.apple.com)
2. Sécurité → Mots de passe spécifiques aux apps
3. Générer un nouveau mot de passe
4. Copier le mot de passe généré

### 7. Configurer les secrets GitHub pour iOS

```bash
# Encoder la clé API App Store Connect en base64
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy

# Encoder la clé SSH Match en base64
base64 -i ~/.ssh/match_deploy_key | pbcopy
```

Secrets à créer :

| Secret | Description | Exemple |
|--------|-------------|---------|
| `APP_STORE_CONNECT_API_KEY_BASE64` | Clé API .p8 en base64 | `LS0tLS1CRUdJ...` |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID de la clé API | `AB12CD34EF` |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID | `12345678-1234-1234-1234-123456789012` |
| `APPLE_ID` | Apple ID du compte développeur | `dev@example.com` |
| `APPLE_TEAM_ID` | Team ID | `ABCD123456` |
| `APPLE_ITC_TEAM_ID` | App Store Connect Team ID | `987654321` |
| `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` | Mot de passe spécifique | `abcd-efgh-ijkl-mnop` |
| `MATCH_GIT_URL` | URL du repository Match | `git@github.com:org/certificates.git` |
| `MATCH_PASSWORD` | Mot de passe de chiffrement Match | `mot_de_passe_fort` |
| `MATCH_SSH_KEY_BASE64` | Clé SSH Match en base64 | `LS0tLS1CRUdJ...` |

## 🚀 Déploiement automatique

### Android

Le déploiement Android est déclenché :

1. **Manuellement** via GitHub Actions :
   ```
   Actions → Deploy Android → Run workflow
   Choisir le track: internal / beta / production
   ```

2. **Automatiquement** lors d'un push de tag :
   ```bash
   git tag v1.0.0-android
   git push origin v1.0.0-android
   ```

### iOS

Le déploiement iOS est déclenché :

1. **Manuellement** via GitHub Actions :
   ```
   Actions → Deploy iOS → Run workflow
   Choisir la lane: beta / production
   ```

2. **Automatiquement** lors d'un push de tag :
   ```bash
   git tag v1.0.0-ios
   git push origin v1.0.0-ios
   ```

## 🔧 Déploiement manuel

### Android

```bash
# 1. Build et déploiement en test interne
cd android
bundle exec fastlane internal

# 2. Build et déploiement en beta
bundle exec fastlane beta

# 3. Build et déploiement en production
bundle exec fastlane production
```

### iOS

```bash
# 1. Build et déploiement sur TestFlight
cd ios
bundle exec fastlane beta

# 2. Build et déploiement sur App Store
bundle exec fastlane production
```

## 🛠️ Résolution des problèmes

### Android

#### Erreur: "Invalid keystore format"

```bash
# Vérifier le keystore
keytool -list -v -keystore android/app/keystore.jks
```

#### Erreur: "Google Play API error"

- Vérifier que le compte de service a les bonnes permissions
- S'assurer que l'API Google Play Android Developer est activée

### iOS

#### Erreur: "No valid code signing identity"

```bash
# Resynchroniser les certificats
cd ios
bundle exec fastlane match appstore --readonly false
```

#### Erreur: "Could not find a matching code signing identity"

- Vérifier que le Bundle ID correspond
- S'assurer que les profils de provisioning sont valides
- Regénérer les certificats si nécessaire

#### Erreur: "Invalid authentication credentials"

- Vérifier l'Apple ID et le mot de passe spécifique
- Vérifier que la clé API App Store Connect est valide

### Logs et debugging

```bash
# Android - voir les logs Fastlane
cd android
bundle exec fastlane internal --verbose

# iOS - voir les logs Fastlane
cd ios
bundle exec fastlane beta --verbose
```

## 📚 Ressources

### Documentation officielle

- [Flutter deployment](https://docs.flutter.dev/deployment)
- [Fastlane](https://docs.fastlane.tools/)
- [Google Play Console](https://play.google.com/console/about/)
- [App Store Connect](https://developer.apple.com/app-store-connect/)

### Guides utiles

- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS Code Signing](https://developer.apple.com/support/code-signing/)

## 🔒 Sécurité

**IMPORTANT** : Ne jamais commiter :
- Les keystores (`.jks`)
- Les fichiers `key.properties`
- Les clés API (`.json`, `.p8`)
- Les clés SSH privées
- Les mots de passe en clair

Tous ces fichiers sont listés dans `.gitignore`.

## 📞 Support

Pour toute question :
- Ouvrir une [issue](https://github.com/naciro2010/NaturaliQCM/issues)
- Consulter la documentation Fastlane
- Vérifier les logs des GitHub Actions

---

**Note** : Garder ce document à jour lors des changements de configuration.
