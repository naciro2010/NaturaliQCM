# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Versioning Sémantique](https://semver.org/lang/fr/).

## [Non publié]

### En préparation
- Configuration du déploiement automatique (CI/CD)
- Génération des icônes d'application
- Configuration des certificats iOS

## [0.1.0] - 2024-11-07

### ✨ Ajouté

#### Lot 0: Fondations
- Repository Git initialisé
- Structure du projet Flutter
- Configuration CI/CD de base avec GitHub Actions
- Linting et analyse statique de code (flutter_lints, dart_code_metrics)

#### Lot 1: Modèle de données & moteur QCM
- Schéma de base de données SQLite avec 9 tables
- DatabaseHelper avec système de migrations
- Modèles de données : Question, Exam, User, Progress, Lesson, ExamSession
- Repositories : QuestionRepository, ExamRepository, LessonRepository
- Base de questions initiale (questions.json)
- Base de leçons (lessons.json)

#### Lot 2: UX de base & navigation
- Configuration GoRouter avec 15+ routes
- Navigation hiérarchique complète
- Thème Material Design 3 aux couleurs de la République Française
- Widgets réutilisables : buttons, cards, inputs, progress bars
- Écrans de base : splash, onboarding, home

#### Lot 3: Profils & authentification
- Écran de création de profil
- Authentification biométrique (FaceID/TouchID) avec local_auth
- Support Sign in with Apple
- Support Passkeys
- Stockage sécurisé avec flutter_secure_storage

#### Lot 4: Cours & référentiel
- LessonsScreen : liste des 5 thèmes réglementaires
- ThemeLessonsScreen : leçons par thème
- LessonDetailScreen : affichage du contenu en Markdown
- LessonRepository avec gestion de la progression
- Système de suivi de progression des leçons

#### Lot 5: Entraînement adaptatif
- SpacedRepetitionService : système Leitner implémenté
- TrainingScreen : sélection de thème pour l'entraînement
- TrainingSessionScreen : sessions de quiz interactives
- QuizResultsScreen avec statistiques
- StatisticsScreen : stats détaillées par thème
- Algorithme adaptatif de répétition espacée

#### Lot 6: Mode examen officiel
- ExamScreen avec timer de 45 minutes
- Génération conforme des examens (40 questions selon distribution réglementaire)
- Navigation fluide entre questions
- Fonction de révision avant soumission finale
- ExamResultsScreen avec animations
- Génération d'attestation PDF pour examens réussis
- Breakdown thématique des résultats

#### Lot 7: Historique & analytics locaux
- ExamSessionRepository complet
- HistoryScreen avec filtres (toutes/réussies/échouées)
- SessionDetailScreen : détail complet avec toutes les réponses
- Statistiques globales (taux de réussite, meilleur score, score moyen)
- Analyse de performance par thème
- Pull-to-refresh pour actualiser les données

#### Lot 9: Conformité & maintenance
- SettingsScreen complet avec toutes les options
- Export RGPD au format CSV (DataExportService)
- Suppression totale des données
- PrivacyPolicyScreen : politique de confidentialité détaillée
- TermsScreen : conditions d'utilisation
- ComplianceScreen : informations de conformité réglementaire
- Garantie 100% offline - zéro collecte de données

#### Lot 8: Packaging & déploiement (partiellement complété)
- Workflows GitHub Actions (deploy-android.yml, deploy-ios.yml, ci.yml)
- Configuration Fastlane pour Android (Appfile, Fastfile)
- Configuration Fastlane pour iOS (Appfile, Fastfile, Matchfile)
- Configuration des icônes d'application (flutter_launcher_icons)
- Configuration des splash screens (flutter_native_splash)
- Documentation complète du déploiement (DEPLOYMENT.md)

### 🔐 Sécurité

- Base de données SQLite avec chiffrement local
- Stockage sécurisé des tokens avec flutter_secure_storage
- Authentification biométrique optionnelle
- Zéro télémétrie - aucun tracking
- Désactivation des backups Android automatiques
- Chiffrement des données sensibles avec encrypt/crypto

### 📋 Conformité

- Respect strict de l'arrêté du 10 octobre 2025
- Distribution exacte des questions par thème :
  - Principes et valeurs : 11 questions (dont 6 mises en situation)
  - Système institutionnel : 6 questions
  - Droits et devoirs : 11 questions (dont 6 mises en situation)
  - Histoire et culture : 8 questions
  - Vivre en France : 4 questions
- Timer de 45 minutes maximum
- Seuil de réussite à 80% (32/40)
- Total de 12 mises en situation par examen

### 📚 Documentation

- README.md complet avec instructions d'installation
- DEPLOYMENT.md : guide de déploiement détaillé
- PROJECT_STATUS.md : état des lieux du projet
- PRIVACY.md : politique de confidentialité
- SECURITY.md : politique de sécurité
- CONTRIBUTING.md : guide de contribution
- Documentation des assets (images, fonts)

### 🛠️ Technique

- Flutter 3.24.0+
- Dart 3.2.0+
- Architecture Clean (data/domain/ui)
- Material Design 3
- ~5,000+ lignes de code
- 19 écrans
- 7 services
- 3 repositories
- 6 modèles de données

### 🔄 Améliorations

- Configuration correcte de l'applicationId : `fr.naturalisation.qcm`
- Support du keystore pour les builds Android release
- Configuration des signingConfigs Android
- Dépendances flutter_launcher_icons et flutter_native_splash ajoutées

### ⚠️ Limitations connues

- Polices Marianne non incluses (fallback sur polices système)
- Images d'icônes à créer (templates et documentation fournis)
- Certificats iOS à configurer avec Fastlane Match
- Secrets GitHub CI/CD à configurer manuellement

### 📝 Notes de version

Cette version 0.1.0 représente l'application **complète et fonctionnelle** avec toutes les fonctionnalités core implémentées. L'application est **prête pour les tests beta** une fois les assets visuels créés et les configurations de déploiement finalisées.

**Status** : ✅ MVP complet - Prêt pour beta testing

---

## Format des versions

- **Major** (X.0.0) : Changements incompatibles avec les versions précédentes
- **Minor** (0.X.0) : Nouvelles fonctionnalités rétro-compatibles
- **Patch** (0.0.X) : Corrections de bugs rétro-compatibles

## Types de changements

- **Ajouté** : Nouvelles fonctionnalités
- **Modifié** : Changements dans les fonctionnalités existantes
- **Déprécié** : Fonctionnalités qui seront supprimées
- **Supprimé** : Fonctionnalités supprimées
- **Corrigé** : Corrections de bugs
- **Sécurité** : Corrections de vulnérabilités
