# Documentation NaturaliQCM

Bienvenue dans la documentation de NaturaliQCM, l'application de préparation à l'examen civique français.

## 📚 Guides disponibles

### Déploiement

- **[DEPLOYMENT_WEB.md](DEPLOYMENT_WEB.md)** - Guide complet pour le déploiement web
  - GitHub Pages
  - Netlify (recommandé)
  - Vercel
  - Build local et optimisations
  - PWA et SEO
  - Monitoring et analytics

- **[../DEPLOYMENT.md](../DEPLOYMENT.md)** - Guide général de déploiement
  - Vue d'ensemble des plateformes
  - Configuration Android (Google Play)
  - Configuration iOS (App Store)
  - Déploiement automatique via CI/CD

## 🚀 Démarrage rapide

### Développement local

```bash
# Cloner le repository
git clone https://github.com/naciro2010/NaturaliQCM.git
cd NaturaliQCM

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run

# Lancer sur web
flutter run -d chrome
```

### Build

```bash
# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release
```

## 📖 Structure du projet

```
NaturaliQCM/
├── android/              # Code natif Android
├── ios/                  # Code natif iOS
├── web/                  # Configuration web (index.html, manifest.json)
├── lib/                  # Code source Dart/Flutter
│   ├── models/          # Modèles de données
│   ├── screens/         # Écrans de l'application
│   ├── services/        # Services (DB, storage, etc.)
│   ├── utils/           # Utilitaires
│   └── widgets/         # Widgets réutilisables
├── assets/              # Assets (images, données)
│   ├── content/         # Contenu éducatif
│   ├── questions/       # Questions QCM
│   ├── images/          # Images et icônes
│   └── data/            # Données statiques
├── test/                # Tests unitaires et d'intégration
├── docs/                # Documentation
└── .github/             # Configuration GitHub Actions
    └── workflows/       # Workflows CI/CD
```

## 🔧 Configuration

### Variables d'environnement

Le projet utilise un fichier `.env` pour la configuration locale. Voir `.env.example` pour les variables disponibles.

### Secrets GitHub

Pour le déploiement automatique, configurer ces secrets :

#### Web (Netlify)
- `NETLIFY_AUTH_TOKEN` - Token d'authentification Netlify
- `NETLIFY_SITE_ID` - ID du site Netlify

#### Android
- `ANDROID_KEYSTORE_BASE64` - Keystore encodé en base64
- `ANDROID_KEYSTORE_PASSWORD` - Mot de passe du keystore
- `ANDROID_KEY_ALIAS` - Alias de la clé
- `ANDROID_KEY_PASSWORD` - Mot de passe de la clé
- `GOOGLE_PLAY_JSON_KEY_BASE64` - Clé JSON Google Play en base64

#### iOS
- `APP_STORE_CONNECT_API_KEY_BASE64` - Clé API App Store Connect
- `APP_STORE_CONNECT_API_KEY_ID` - ID de la clé API
- `APP_STORE_CONNECT_API_ISSUER_ID` - Issuer ID
- `APPLE_ID` - Apple ID
- `APPLE_TEAM_ID` - Team ID Apple
- `MATCH_PASSWORD` - Mot de passe Match
- `MATCH_GIT_URL` - URL du repo Match
- Etc. (voir [DEPLOYMENT.md](../DEPLOYMENT.md))

## 🧪 Tests

```bash
# Lancer tous les tests
flutter test

# Tests avec couverture
flutter test --coverage

# Tests spécifiques
flutter test test/models/question_test.dart

# Tests d'intégration
flutter test integration_test/
```

## 📊 CI/CD

Le projet utilise GitHub Actions pour l'intégration continue :

### Workflows disponibles

- **ci.yml** - Tests et builds automatiques sur chaque push/PR
- **deploy-web.yml** - Déploiement sur GitHub Pages
- **deploy-netlify.yml** - Déploiement sur Netlify
- **pr-preview.yml** - Preview automatique des PRs
- **deploy-android.yml** - Déploiement sur Google Play
- **deploy-ios.yml** - Déploiement sur App Store
- **release.yml** - Création de releases avec changelog

### Déclencheurs

- **Push** sur `main`, `develop`, ou branches `claude/**`
- **Pull Request** vers `main` ou `develop`
- **Tag** avec formats spécifiques (`v*-web`, `v*-android`, `v*-ios`)
- **Manuel** via GitHub Actions UI

## 🛠️ Outils de développement

### Extensions VS Code recommandées

- Flutter
- Dart
- Flutter Intl
- GitLens
- Error Lens

### Configuration IDE

Le projet inclut des configurations pour :
- VS Code (`.vscode/`)
- Android Studio
- IntelliJ IDEA

## 📝 Conventions de code

### Style

Le projet utilise les conventions Dart officielles :

```bash
# Formatter le code
dart format .

# Analyser le code
flutter analyze

# Linter
flutter pub run dart_code_linter:metrics analyze lib
```

### Commits

Format des messages de commit :

```
type(scope): message

Types:
- feat: Nouvelle fonctionnalité
- fix: Correction de bug
- docs: Documentation
- style: Formatage, point-virgules manquants, etc.
- refactor: Refactorisation du code
- perf: Amélioration des performances
- test: Ajout de tests
- chore: Maintenance, tâches diverses
```

Exemples :
```
feat(quiz): ajouter le mode chronométré
fix(questions): corriger l'affichage des images
docs(deployment): mettre à jour le guide Netlify
```

## 🤝 Contribution

Voir [CONTRIBUTING.md](../CONTRIBUTING.md) pour les guidelines de contribution.

## 📄 Licence

Ce projet est sous licence GNU General Public License v3.0. Voir [LICENSE](../LICENSE) pour plus de détails.

## 📞 Support

- **Issues** : [GitHub Issues](https://github.com/naciro2010/NaturaliQCM/issues)
- **Discussions** : [GitHub Discussions](https://github.com/naciro2010/NaturaliQCM/discussions)
- **Email** : Voir [SECURITY.md](../SECURITY.md)

## 🔗 Liens utiles

### Ressources officielles

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)

### Guides spécifiques

- [Flutter Web](https://docs.flutter.dev/platform-integration/web)
- [Flutter Android](https://docs.flutter.dev/deployment/android)
- [Flutter iOS](https://docs.flutter.dev/deployment/ios)

### Outils

- [Pub.dev](https://pub.dev/) - Packages Dart & Flutter
- [FlutterGems](https://fluttergems.dev/) - Packages curatés
- [Zapp.run](https://zapp.run/) - Playground Flutter en ligne

---

**Dernière mise à jour** : Novembre 2025
