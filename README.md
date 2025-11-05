# NaturaliQCM

Application mobile de préparation à l'examen civique français, 100% offline et conforme à l'arrêté du 10 octobre 2025.

## 📋 Description

NaturaliQCM est une application Flutter (iOS/Android) qui permet de se préparer efficacement à l'examen civique français requis pour l'obtention de la naturalisation. L'application respecte strictement les exigences réglementaires de l'arrêté du 10 octobre 2025.

### Caractéristiques principales

- ✅ **Conforme à l'arrêté du 10 octobre 2025** : 40 questions, 45 minutes, seuil de réussite à 80% (32/40)
- 🔒 **100% offline** : toutes les données stockées localement et chiffrées
- 🔐 **Sécurité** : authentification biométrique (FaceID/TouchID/Passkeys)
- 📚 **Contenu complet** : cours, entraînements ciblés, examens blancs
- 📊 **Suivi de progression** : historique des sessions, statistiques par thème
- ♿ **Accessible** : support VoiceOver/TalkBack, contrastes AA

### Répartition réglementaire des questions

Chaque examen blanc contient exactement :

- **Principes et valeurs** : 11 questions (dont 6 mises en situation)
- **Système institutionnel** : 6 questions
- **Droits et devoirs** : 11 questions (dont 6 mises en situation)
- **Histoire et culture** : 8 questions
- **Vivre en France** : 4 questions

**Total** : 40 questions (dont 12 mises en situation)

## 🏗️ Architecture technique

### Stack

- **Framework** : Flutter 3.2+ (Dart)
- **Base de données** : SQLite avec chiffrement
- **Stockage sécurisé** : flutter_secure_storage (Keychain/Keystore)
- **UI** : Material Design 3
- **CI/CD** : GitHub Actions + Fastlane

### Structure du projet

```
lib/
├── data/
│   ├── dao/              # Data Access Objects
│   ├── models/           # Modèles de données
│   └── database_helper.dart
├── domain/
│   └── use_cases/        # Logique métier
├── ui/
│   ├── screens/          # Écrans
│   ├── widgets/          # Composants réutilisables
│   └── themes/           # Thèmes Material 3
└── features/
    ├── auth_local/       # Authentification locale
    ├── lessons/          # Cours et leçons
    ├── training/         # Entraînement ciblé
    ├── exam/             # Mode examen
    └── history/          # Historique et progression

assets/
├── content/              # Leçons (JSON/Markdown)
├── questions/            # Banque de questions
└── images/               # Ressources graphiques

tooling/
├── ingest.dart          # Import du référentiel
└── verify_referential.dart  # Validation conformité
```

## 🚀 Installation et Développement Local

### Prérequis

- Flutter SDK 3.24.0+
- Dart SDK 3.2.0+
- Xcode 14+ (pour iOS)
- Android Studio / Android SDK 33+ (pour Android)
- Ruby 3.2+ avec Bundler (pour le déploiement)

### Configuration de l'environnement

#### 1. Installer Flutter

```bash
# macOS (avec Homebrew)
brew install flutter

# Ou télécharger depuis https://flutter.dev/docs/get-started/install

# Vérifier l'installation
flutter doctor
```

#### 2. Configurer les émulateurs

**Android:**
```bash
# Lancer Android Studio
# Tools → Device Manager → Create Device
# Ou via ligne de commande:
flutter emulators --create

# Lister les émulateurs disponibles
flutter emulators
```

**iOS (macOS uniquement):**
```bash
# Installer Xcode depuis l'App Store
# Installer les outils en ligne de commande
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Ouvrir le simulateur
open -a Simulator
```

### Installation du projet

```bash
# 1. Cloner le repository
git clone https://github.com/naciro2010/NaturaliQCM.git
cd NaturaliQCM

# 2. Installer les dépendances Flutter
flutter pub get

# 3. Vérifier la configuration
flutter doctor -v

# 4. Lister les devices disponibles
flutter devices
```

### Lancement en mode développement

```bash
# Lancer sur l'appareil/émulateur connecté
flutter run

# Lancer en mode debug avec hot reload
flutter run --debug

# Lancer en mode release (performance optimale)
flutter run --release

# Lancer sur un device spécifique
flutter run -d <device_id>

# Exemples:
flutter run -d chrome              # Web
flutter run -d emulator-5554       # Android emulator
flutter run -d "iPhone 15 Pro"     # iOS simulator
```

### Commandes de développement utiles

```bash
# Hot reload (dans le terminal Flutter)
r

# Hot restart (redémarrage complet)
R

# Ouvrir DevTools
flutter run --observatory-port=9100

# Activer le logging verbose
flutter run -v

# Nettoyer le projet
flutter clean && flutter pub get
```

### Structure des données de développement

Les données de test sont stockées localement dans :
- **iOS**: `~/Library/Application Support/naturaliqcm/`
- **Android**: `/data/data/fr.naturalisation.qcm/`
- **Simulateur iOS**: `~/Library/Developer/CoreSimulator/Devices/<UUID>/`

### Debugging

```bash
# Afficher les logs en temps réel
flutter logs

# Logs Android spécifiques
adb logcat | grep flutter

# Logs iOS spécifiques
log stream --predicate 'eventMessage contains "flutter"'

# DevTools (interface graphique de debugging)
flutter pub global activate devtools
flutter pub global run devtools
```

### Générer les assets et les icônes

```bash
# Générer les icônes d'application (si configuré)
flutter pub run flutter_launcher_icons:main

# Générer le splash screen (si configuré)
flutter pub run flutter_native_splash:create
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Analyse statique
flutter analyze

# Métriques de code
dart run dart_code_metrics:metrics analyze lib
```

## 📦 Build et Déploiement

### Builds locaux

#### Android

```bash
# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release

# Build App Bundle (pour Google Play)
flutter build appbundle --release

# Les fichiers générés se trouvent dans:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS

```bash
# Build iOS (sans code signing pour test)
flutter build ios --debug --no-codesign

# Build iOS release
flutter build ios --release

# Build avec Xcode directement
open ios/Runner.xcworkspace
# Product → Archive
```

### Déploiement automatique (CI/CD)

Le projet utilise GitHub Actions pour automatiser les déploiements.

#### Déploiement Android

```bash
# Via GitHub Actions (dans l'interface web):
# Actions → Deploy Android → Run workflow
# Choisir le track: internal / beta / production

# Ou via tag Git:
git tag v1.0.0-android
git push origin v1.0.0-android
```

#### Déploiement iOS

```bash
# Via GitHub Actions (dans l'interface web):
# Actions → Deploy iOS → Run workflow
# Choisir la lane: beta / production

# Ou via tag Git:
git tag v1.0.0-ios
git push origin v1.0.0-ios
```

### Déploiement manuel avec Fastlane

#### Prérequis Fastlane

```bash
# Installer Ruby et Bundler
brew install ruby
gem install bundler

# Installer les dépendances Fastlane
cd android && bundle install
cd ../ios && bundle install
```

#### Android - Google Play

```bash
cd android

# Test interne (pour les testeurs internes)
bundle exec fastlane internal

# Beta (pour les testeurs beta ouverts/fermés)
bundle exec fastlane beta

# Production (déploiement public)
bundle exec fastlane production
```

#### iOS - App Store

```bash
cd ios

# TestFlight (pour les testeurs beta)
bundle exec fastlane beta

# App Store (déploiement public)
bundle exec fastlane production
```

### Configuration du déploiement

Pour configurer le déploiement automatique, consultez le guide détaillé:

📖 **[Guide de Déploiement Complet](DEPLOYMENT.md)**

Ce guide couvre:
- Configuration des comptes développeurs (Google Play, App Store)
- Génération des clés de signature
- Configuration des secrets GitHub
- Gestion des certificats iOS avec Match
- Résolution des problèmes courants

## 📖 Conformité réglementaire

Cette application implémente fidèlement les exigences de l'arrêté du 10 octobre 2025 relatif au test de connaissance de la langue française et des valeurs de la République :

- **Distribution stricte** des questions par thématique
- **Durée maximale** : 45 minutes
- **Seuil de réussite** : 80% (32 réponses correctes sur 40)
- **Questions de connaissance publiques** (conformément à l'annexe I)

**Références légales** :
- [Arrêté du 10 octobre 2025](https://www.legifrance.gouv.fr/)
- [Annexe I - Programme et connaissances](https://www.legifrance.gouv.fr/)

## 🔐 Sécurité et confidentialité

- **Zéro collecte de données** : aucune télémétrie, aucun tracking
- **Chiffrement local** : base de données chiffrée avec SQLCipher
- **Biométrie** : authentification via FaceID/TouchID/Passkeys
- **Contrôle total** : export/effacement complet des données à tout moment

## 🤝 Contribution

Les contributions sont bienvenues ! Veuillez consulter [CONTRIBUTING.md](CONTRIBUTING.md) pour les guidelines.

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## 🛡️ Sécurité

Pour signaler une vulnérabilité de sécurité, consultez [SECURITY.md](SECURITY.md).

## 📞 Support

Pour toute question ou assistance :
- Ouvrir une [issue](https://github.com/naciro2010/NaturaliQCM/issues)
- Consulter la [documentation](https://github.com/naciro2010/NaturaliQCM/wiki)

## 🗺️ Roadmap

- [x] **Lot 0** : Fondations (repo, CI, qualité)
- [x] **Lot 1** : Modèle de données & moteur QCM
- [x] **Lot 2** : UX de base & navigation
- [x] **Lot 3** : Profils & authentification
- [x] **Lot 4** : Cours & référentiel
- [x] **Lot 5** : Entraînement adaptatif
- [x] **Lot 6** : Mode examen officiel
- [x] **Lot 7** : Historique & analytics locaux
- [ ] **Lot 8** : Packaging & déploiement
- [x] **Lot 9** : Conformité & maintenance

## ✨ Fonctionnalités implémentées

### 🎓 Mode Examen Officiel
- Timer de 45 minutes avec compte à rebours
- 40 questions conformes à la distribution réglementaire
- Navigation entre questions avec révision avant soumission
- Résultats détaillés avec breakdown par thème
- Génération d'attestation PDF pour examens réussis
- Validation automatique de la conformité

### 📊 Historique & Statistiques
- Liste complète des sessions d'examen
- Filtres (toutes/réussies/échouées)
- Statistiques globales (taux de réussite, meilleur score, score moyen)
- Détails de session avec toutes les réponses et explications
- Analyse de performance par thème

### 🎯 Entraînement Adaptatif
- Algorithme de répétition espacée (système Leitner)
- Sessions d'entraînement ciblées par thème
- Progression personnalisée
- Statistiques détaillées par thème

### 📚 Cours & Leçons
- Contenu éducatif pour les 5 thèmes
- Leçons organisées par sous-thèmes
- Suivi de progression des leçons
- Liens entre questions et leçons

### ⚙️ Paramètres & Conformité RGPD
- Export complet des données (CSV)
- Suppression totale des données
- Politique de confidentialité détaillée
- Conditions d'utilisation
- Informations de conformité réglementaire
- 100% offline - zéro collecte de données

### 🔐 Sécurité & Authentification
- Authentification biométrique (FaceID/TouchID)
- Support Passkeys et Sign in with Apple
- Base de données chiffrée localement
- Stockage sécurisé (Keychain/Keystore)

---

**Note** : Cette application est un outil de préparation indépendant et n'est pas affiliée au gouvernement français.
