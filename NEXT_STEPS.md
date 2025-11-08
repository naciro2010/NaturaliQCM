# 🚀 Prochaines Étapes - NaturaliQCM

Ce document détaille les **actions concrètes** à réaliser pour finaliser et déployer l'application NaturaliQCM.

**État actuel** : Application complète à 90%, prête pour le déploiement 🎉

---

## 📋 Checklist de déploiement

### ✅ Phase 1 : Préparation des Assets (2-4 heures)

#### 1.1 Créer les icônes d'application

**Priorité** : 🔴 HAUTE

**Fichiers à créer dans `assets/images/`** :

- [ ] `icon.png` (1024x1024 px)
  - Icône principale de l'application
  - Format PNG avec transparence
  - Suggestion : Logo avec drapeau français ou Marianne

- [ ] `icon_foreground.png` (1024x1024 px)
  - Partie avant de l'icône adaptative Android
  - Format PNG avec transparence

- [ ] `splash_logo.png` (1080x1920 px)
  - Logo pour l'écran de démarrage (thème clair)
  - Format PNG avec transparence

- [ ] `splash_logo_dark.png` (1080x1920 px)
  - Logo pour l'écran de démarrage (thème sombre)
  - Format PNG avec transparence

**Outils recommandés** :
- Figma (gratuit) : https://www.figma.com/
- Canva : https://www.canva.com/
- GIMP (gratuit) : https://www.gimp.org/

**Couleurs officielles RF** :
- Bleu : `#000091`
- Rouge : `#E1000F`
- Blanc : `#FFFFFF`

**Une fois créés, exécuter** :
```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

#### 1.2 Polices Marianne (optionnel)

**Priorité** : 🟡 BASSE (fallback automatique)

- [ ] Télécharger les polices Marianne depuis https://www.systeme-de-design.gouv.fr/
- [ ] Placer `Marianne-Regular.ttf` dans `assets/fonts/`
- [ ] Placer `Marianne-Bold.ttf` dans `assets/fonts/`

**Note** : L'application fonctionne sans ces polices (fallback sur Roboto/San Francisco)

---

### ✅ Phase 2 : Configuration Android (1-2 heures)

**Priorité** : 🔴 HAUTE

#### 2.1 Créer le keystore de signature

```bash
cd android
keytool -genkey -v -keystore keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias naturaliqcm
```

**IMPORTANT** : Sauvegarder précieusement :
- Le fichier `keystore.jks`
- Les mots de passe (keystore et clé)
- L'alias de la clé

#### 2.2 Créer le fichier key.properties

```bash
# Dans android/key.properties
cp key.properties.example key.properties
# Éditer avec vos vraies valeurs
```

Contenu :
```properties
storePassword=votre_mot_de_passe
keyPassword=votre_mot_de_passe
keyAlias=naturaliqcm
storeFile=keystore.jks
```

#### 2.3 Configuration Google Play Console

- [ ] Créer un compte développeur Google Play (99€ unique)
- [ ] Créer l'application sur Google Play Console
- [ ] Package name : `fr.naturalisation.qcm`
- [ ] Créer un compte de service (API)
- [ ] Télécharger la clé JSON du compte de service

#### 2.4 Configurer les secrets GitHub (Android)

Aller dans **Settings → Secrets and variables → Actions** :

```bash
# Encoder le keystore en base64
base64 -i android/keystore.jks | pbcopy

# Encoder la clé JSON Google Play en base64
base64 -i google-play-key.json | pbcopy
```

Secrets à créer :
- [ ] `ANDROID_KEYSTORE_BASE64`
- [ ] `ANDROID_KEYSTORE_PASSWORD`
- [ ] `ANDROID_KEY_ALIAS`
- [ ] `ANDROID_KEY_PASSWORD`
- [ ] `GOOGLE_PLAY_JSON_KEY_BASE64`

**Documentation complète** : Voir `DEPLOYMENT.md`

---

### ✅ Phase 3 : Configuration iOS (2-3 heures)

**Priorité** : 🔴 HAUTE

#### 3.1 Prérequis

- [ ] Compte Apple Developer Program (99€/an)
- [ ] Xcode installé (macOS uniquement)
- [ ] Fastlane installé

#### 3.2 Créer l'App ID et l'application

- [ ] Créer App ID sur developer.apple.com
  - Bundle ID : `fr.naturalisation.qcm`
  - Capabilities : Sign in with Apple, Push Notifications

- [ ] Créer l'app sur App Store Connect

#### 3.3 Configurer Match (certificats)

```bash
# Créer un repository privé pour les certificats
# Exemple: https://github.com/votre-org/certificates

cd ios
bundle exec fastlane match init
# Choisir 'git'
# Entrer l'URL du repository

# Générer les certificats
bundle exec fastlane match appstore
# Entrer un mot de passe de chiffrement
```

#### 3.4 Créer une clé API App Store Connect

- [ ] App Store Connect → Users and Access → Keys
- [ ] Créer une clé avec rôle "Developer"
- [ ] Télécharger le fichier `.p8`
- [ ] Noter Issuer ID et Key ID

#### 3.5 Créer une clé SSH pour Match

```bash
ssh-keygen -t ed25519 -C "match-github" -f ~/.ssh/match_deploy_key
# Ajouter la clé publique aux Deploy Keys du repo de certificats
cat ~/.ssh/match_deploy_key.pub
```

#### 3.6 Mot de passe spécifique Apple

- [ ] Aller sur appleid.apple.com
- [ ] Sécurité → Mots de passe spécifiques aux apps
- [ ] Générer et copier

#### 3.7 Configurer les secrets GitHub (iOS)

```bash
# Encoder les fichiers en base64
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
base64 -i ~/.ssh/match_deploy_key | pbcopy
```

Secrets à créer :
- [ ] `APP_STORE_CONNECT_API_KEY_BASE64`
- [ ] `APP_STORE_CONNECT_API_KEY_ID`
- [ ] `APP_STORE_CONNECT_API_ISSUER_ID`
- [ ] `APPLE_ID`
- [ ] `APPLE_TEAM_ID`
- [ ] `APPLE_ITC_TEAM_ID`
- [ ] `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`
- [ ] `MATCH_GIT_URL`
- [ ] `MATCH_PASSWORD`
- [ ] `MATCH_SSH_KEY_BASE64`

**Documentation complète** : Voir `DEPLOYMENT.md` sections iOS

---

### ✅ Phase 4 : Premier Build et Test (1-2 heures)

**Priorité** : 🟡 MOYENNE

#### 4.1 Tests locaux

```bash
# Analyser le code
flutter analyze

# Lancer les tests
flutter test

# Build Android (debug)
flutter build apk --debug

# Build Android (release) - nécessite keystore configuré
flutter build apk --release

# Build iOS (nécessite macOS et Xcode)
flutter build ios --debug --no-codesign
```

#### 4.2 Tests sur émulateur/simulateur

```bash
# Lancer l'app sur Android
flutter run -d <android_device_id>

# Lancer l'app sur iOS
flutter run -d "iPhone 15 Pro"
```

#### 4.3 Checklist de test fonctionnel

- [ ] Créer un profil utilisateur
- [ ] Parcourir les leçons
- [ ] Faire une session d'entraînement
- [ ] Passer un examen blanc complet
- [ ] Vérifier l'historique
- [ ] Tester l'export de données
- [ ] Vérifier la suppression de données
- [ ] Tester l'authentification biométrique (sur device réel)

---

### ✅ Phase 5 : Déploiement Beta (30 min - 1 heure)

**Priorité** : 🟠 MOYENNE-HAUTE

#### 5.1 Déploiement Android (Test Interne)

**Via GitHub Actions** :
1. Aller dans **Actions → Deploy Android → Run workflow**
2. Choisir `track: internal`
3. Lancer le workflow

**Ou manuellement** :
```bash
cd android
bundle exec fastlane internal
```

#### 5.2 Déploiement iOS (TestFlight)

**Via GitHub Actions** :
1. Aller dans **Actions → Deploy iOS → Run workflow**
2. Choisir `lane: beta`
3. Lancer le workflow

**Ou manuellement** :
```bash
cd ios
bundle exec fastlane beta
```

#### 5.3 Inviter des testeurs beta

**Android** :
- Google Play Console → Testing → Test interne
- Ajouter des testeurs par email

**iOS** :
- App Store Connect → TestFlight
- Ajouter des testeurs internes/externes

---

### ✅ Phase 6 : Déploiement Production (1-2 semaines)

**Priorité** : 🟢 FUTURE

#### 6.1 Préparer les store listings

**Captures d'écran requises** :
- Android : 5,5" et 7" (min 2 captures)
- iOS : 6,5" et 5,5" (min 3 captures)

**Textes à préparer** :
- [ ] Titre (30 caractères)
- [ ] Description courte (80 caractères)
- [ ] Description complète (4000 caractères)
- [ ] Mots-clés / Tags

#### 6.2 Soumettre pour révision

**Android** :
```bash
cd android
bundle exec fastlane production
```

Puis sur Google Play Console :
- Promouvoir le build de internal → production
- Soumettre pour révision (1-3 jours)

**iOS** :
```bash
cd ios
bundle exec fastlane production
```

Puis sur App Store Connect :
- Soumettre pour révision (1-7 jours)
- Répondre aux questions de conformité

---

## 🎯 Ordre recommandé d'exécution

1. **Créer les assets** (Phase 1) → 2-4h
   - Sans ça, l'app n'a pas d'icône

2. **Configurer Android** (Phase 2) → 1-2h
   - Plus simple et rapide qu'iOS

3. **Premier build Android** (Phase 4.1) → 30min
   - Vérifier que tout compile

4. **Tests fonctionnels** (Phase 4.3) → 1h
   - S'assurer que l'app fonctionne

5. **Configurer iOS** (Phase 3) → 2-3h
   - Plus complexe, nécessite macOS

6. **Déploiement beta** (Phase 5) → 1h
   - Tester sur vrais devices

7. **Déploiement production** (Phase 6) → 1-2 semaines
   - Quand les tests beta sont OK

---

## ⏱️ Estimation totale

| Phase | Durée estimée | Priorité |
|-------|---------------|----------|
| Assets | 2-4h | 🔴 HAUTE |
| Config Android | 1-2h | 🔴 HAUTE |
| Config iOS | 2-3h | 🔴 HAUTE |
| Tests | 1-2h | 🟡 MOYENNE |
| Beta | 1h | 🟠 MOYENNE-HAUTE |
| Production | 1-2 sem | 🟢 FUTURE |

**Total première mise en ligne (beta)** : **8-12 heures de travail**

**Total jusqu'à production** : **8-12h + 1-2 semaines d'attente**

---

## 📞 Besoin d'aide ?

- **Documentation** : Consultez `DEPLOYMENT.md` pour les détails
- **Issues** : Ouvrez une issue sur GitHub
- **CI/CD** : Vérifiez les logs dans Actions
- **Fastlane** : `fastlane action [action_name]` pour l'aide

---

## ✅ Validation finale

Avant de déployer en production, vérifier :

- [ ] Tous les tests passent
- [ ] L'app fonctionne sur Android et iOS
- [ ] Les icônes s'affichent correctement
- [ ] Le splash screen fonctionne
- [ ] Les store listings sont complets
- [ ] La politique de confidentialité est à jour
- [ ] Les captures d'écran sont prêtes
- [ ] Les testeurs beta ont validé
- [ ] Aucun bug critique n'est remonté

---

**Date de création** : 7 novembre 2024
**Dernière mise à jour** : 7 novembre 2024
