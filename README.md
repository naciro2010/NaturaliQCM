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

## 🚀 Installation

### Prérequis

- Flutter SDK 3.2+
- Xcode 14+ (pour iOS)
- Android Studio / Android SDK 33+ (pour Android)

### Étapes

```bash
# Cloner le repository
git clone https://github.com/naciro2010/NaturaliQCM.git
cd NaturaliQCM

# Installer les dépendances
flutter pub get

# Lancer sur émulateur/device
flutter run
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

## 📦 Build

### iOS

```bash
cd ios
bundle exec fastlane beta
```

### Android

```bash
cd android
bundle exec fastlane beta
```

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
