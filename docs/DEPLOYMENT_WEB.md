# Guide de Déploiement Web - NaturaliQCM

Ce document détaille les différentes options de déploiement web pour NaturaliQCM avec leurs configurations respectives.

## 📋 Table des matières

1. [Options de déploiement](#options-de-déploiement)
2. [GitHub Pages](#github-pages)
3. [Netlify](#netlify)
4. [Vercel](#vercel)
5. [Build local](#build-local)
6. [Optimisations PWA](#optimisations-pwa)

## 🚀 Options de déploiement

NaturaliQCM supporte plusieurs plateformes de déploiement :

| Plateforme | Coût | Facilité | Performance | SSL | CDN | Recommandé pour |
|------------|------|----------|-------------|-----|-----|-----------------|
| **GitHub Pages** | Gratuit | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ | ❌ | Projets open source |
| **Netlify** | Gratuit | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | ✅ | Production recommandé |
| **Vercel** | Gratuit | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | ✅ | Applications modernes |
| **Firebase Hosting** | Gratuit | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ | ✅ | Intégration Firebase |

## 📄 GitHub Pages

### Configuration automatique

Le déploiement sur GitHub Pages est déjà configuré et se déclenche :

1. **Automatiquement** à chaque push sur `main`
2. **Manuellement** via GitHub Actions
3. **Par tag** avec le format `v*-web`

### Configuration requise

1. Activer GitHub Pages dans les paramètres du repository :
   - Settings → Pages
   - Source : GitHub Actions

2. L'application sera disponible à :
   ```
   https://[username].github.io/NaturaliQCM/
   ```

### Déploiement manuel

```bash
# Créer un tag pour déclencher le déploiement
git tag v1.0.0-web
git push origin v1.0.0-web

# Ou déclencher manuellement via GitHub Actions
# Actions → Deploy Web → Run workflow
```

### Limites

- Pas de CDN global
- Pas de support des variables d'environnement
- URLs avec base path (`/NaturaliQCM/`)

## 🎯 Netlify (Recommandé)

Netlify offre la meilleure expérience pour les applications Flutter Web avec CDN global, previews automatiques, et analytics.

### Configuration initiale

1. **Créer un compte Netlify**
   - Aller sur [netlify.com](https://netlify.com)
   - S'inscrire gratuitement

2. **Créer un nouveau site**
   - Sites → Add new site → Import an existing project
   - Connecter votre repository GitHub
   - Configuration automatique via `netlify.toml`

3. **Obtenir les tokens**
   ```bash
   # Depuis le Netlify Dashboard
   # User settings → Applications → Personal access tokens
   # Créer un nouveau token
   ```

4. **Configurer les secrets GitHub**

   Aller dans `Settings → Secrets and variables → Actions` et ajouter :

   | Secret | Description | Où le trouver |
   |--------|-------------|---------------|
   | `NETLIFY_AUTH_TOKEN` | Token d'authentification | User Settings → Applications → Personal access tokens |
   | `NETLIFY_SITE_ID` | ID du site | Site settings → General → Site details → API ID |

### Déploiement

#### Automatique (via GitHub Actions)

```bash
# Production
git push origin main
# ou
git tag v1.0.0-web-netlify
git push origin v1.0.0-web-netlify

# Preview
# Actions → Deploy to Netlify → Run workflow → Select "preview"
```

#### Via Netlify CLI

```bash
# Installer Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Build
flutter build web --release

# Deploy en preview
netlify deploy --dir=build/web

# Deploy en production
netlify deploy --dir=build/web --prod
```

### Fonctionnalités Netlify

- ✅ **Deploy Previews** : Chaque PR obtient une URL de preview
- ✅ **CDN Global** : Distribution mondiale ultra-rapide
- ✅ **SSL automatique** : HTTPS activé par défaut
- ✅ **Headers personnalisés** : Sécurité et cache optimisés
- ✅ **Redirects** : Support du routing SPA
- ✅ **Analytics** : Suivi des visiteurs (option payante)

### Configuration personnalisée

Le fichier `netlify.toml` à la racine du projet configure :

- Headers de sécurité (CSP, X-Frame-Options, etc.)
- Cache pour les assets statiques
- Redirects pour le routing SPA
- Plugin Lighthouse pour les audits

## ⚡ Vercel

Vercel est une excellente alternative à Netlify, particulièrement optimisé pour les frameworks modernes.

### Configuration initiale

1. **Créer un compte Vercel**
   - Aller sur [vercel.com](https://vercel.com)
   - S'inscrire avec GitHub

2. **Importer le projet**
   - Dashboard → Add New → Project
   - Importer depuis GitHub
   - Configuration automatique via `vercel.json`

3. **Configuration build**

   Vercel détecte automatiquement Flutter mais vous pouvez personnaliser :

   ```json
   Build Command: flutter build web --release
   Output Directory: build/web
   Install Command: flutter pub get
   ```

### Déploiement

#### Via Vercel Dashboard

1. Push sur GitHub déclenche automatiquement le déploiement
2. Chaque branche obtient une URL unique
3. Les PRs obtiennent des previews automatiques

#### Via Vercel CLI

```bash
# Installer Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel

# Deploy en production
vercel --prod
```

### Fonctionnalités Vercel

- ✅ **Preview Deployments** : URL unique par commit
- ✅ **Edge Network** : CDN ultra-rapide
- ✅ **Instant Rollbacks** : Retour arrière en un clic
- ✅ **Analytics** : Metrics de performance inclus
- ✅ **Web Vitals** : Monitoring automatique

## 🔨 Build local

Pour tester ou déployer manuellement :

### Build de développement

```bash
# Build rapide pour tests
flutter build web --debug

# Servir localement
cd build/web
python3 -m http.server 8000
# Ouvrir http://localhost:8000
```

### Build de production

```bash
# Build optimisé
flutter build web --release

# Avec base-href personnalisé
flutter build web --release --base-href="/chemin/"

# Avec rendu CanvasKit (meilleure qualité)
flutter build web --release --web-renderer canvaskit

# Avec rendu HTML (plus léger)
flutter build web --release --web-renderer html

# Auto (détection automatique)
flutter build web --release --web-renderer auto
```

### Options de build avancées

```bash
# Build avec profil
flutter build web --profile

# Build avec tree-shaking des icônes
flutter build web --release --tree-shake-icons

# Build avec source maps
flutter build web --release --source-maps

# Build avec dart2js optimisations
flutter build web --release --dart2js-optimization O4
```

## 🎨 Optimisations PWA

### Service Worker

Flutter génère automatiquement un service worker pour :
- Caching des assets
- Fonctionnement offline
- Mises à jour en arrière-plan

### Manifest.json

Le fichier `web/manifest.json` configure :
- Nom et icônes de l'application
- Couleurs de thème
- Mode d'affichage (standalone)
- Raccourcis d'application
- Catégories (education, reference)

### Meta Tags SEO

Le fichier `web/index.html` inclut :
- Meta tags Open Graph (partage Facebook)
- Twitter Cards
- SEO optimisé
- Icônes iOS

## 🔒 Sécurité

### Headers de sécurité (configurés automatiquement)

```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Content-Security-Policy: [politique stricte]
```

### HTTPS

Toutes les plateformes (GitHub Pages, Netlify, Vercel) fournissent HTTPS automatiquement avec des certificats SSL gratuits.

## 📊 Performance

### Optimisations appliquées

1. **Tree-shaking** : Code inutilisé supprimé
2. **Minification** : JS/CSS compressés
3. **Lazy loading** : Chargement différé des routes
4. **Cache statique** : Assets cachés pour 1 an
5. **Compression** : Gzip/Brotli activés

### Métriques cibles

- **First Contentful Paint (FCP)** : < 1.8s
- **Largest Contentful Paint (LCP)** : < 2.5s
- **Time to Interactive (TTI)** : < 3.8s
- **Cumulative Layout Shift (CLS)** : < 0.1
- **Lighthouse Score** : > 90/100

## 🔍 Monitoring

### Netlify Analytics

```bash
# Activer dans le dashboard Netlify
# Site settings → Analytics → Enable
```

### Vercel Analytics

```bash
# Activer dans le dashboard Vercel
# Project → Analytics → Enable
```

### Google Analytics

Pour ajouter Google Analytics :

1. Obtenir un ID de suivi (G-XXXXXXXXXX)
2. Ajouter dans `web/index.html` avant `</head>` :

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

## 🐛 Dépannage

### Erreur 404 sur les routes

**Problème** : Les routes Flutter ne fonctionnent pas (404)

**Solution** :
- Vérifier que les redirects sont configurés (déjà fait dans `netlify.toml` et `vercel.json`)
- Pour d'autres plateformes, configurer les rewrites SPA

### Assets non chargés

**Problème** : Images ou fonts manquants

**Solution** :
```bash
# Vérifier le base-href
flutter build web --release --base-href="/"

# Vérifier les chemins dans pubspec.yaml
```

### Erreurs CORS

**Problème** : Erreurs de Cross-Origin

**Solution** :
- Les assets locaux ne devraient pas avoir de problème CORS
- Pour les APIs externes, configurer les headers CORS côté serveur

### Build trop lent

**Problème** : Le build prend trop de temps

**Solution** :
```bash
# Utiliser le cache
flutter pub get
flutter build web --release

# Désactiver les source maps en production
flutter build web --release --no-source-maps

# Utiliser le rendu HTML (plus rapide)
flutter build web --release --web-renderer html
```

## 📚 Ressources

### Documentation officielle

- [Flutter Web deployment](https://docs.flutter.dev/deployment/web)
- [Netlify Docs](https://docs.netlify.com/)
- [Vercel Docs](https://vercel.com/docs)
- [GitHub Pages](https://pages.github.com/)

### Outils utiles

- [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci)
- [WebPageTest](https://www.webpagetest.org/)
- [GTmetrix](https://gtmetrix.com/)

## 📝 Checklist de déploiement

Avant de déployer en production :

- [ ] Tester l'application localement en build release
- [ ] Vérifier que tous les assets se chargent correctement
- [ ] Tester sur différents navigateurs (Chrome, Firefox, Safari, Edge)
- [ ] Tester sur mobile (iOS et Android)
- [ ] Vérifier les meta tags et Open Graph
- [ ] Tester le mode offline (PWA)
- [ ] Vérifier les performances avec Lighthouse
- [ ] Configurer le monitoring/analytics
- [ ] Tester le routing (navigation entre pages)
- [ ] Vérifier le favicon et les icônes

---

**Note** : Ce guide est maintenu à jour. N'hésitez pas à ouvrir une issue pour toute question ou amélioration.
