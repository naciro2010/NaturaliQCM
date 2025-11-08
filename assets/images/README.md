# Assets - Images et Icônes

Ce répertoire contient les images nécessaires pour l'application NaturaliQCM.

## 📱 Icônes d'application requises

Pour générer les icônes d'application, vous devez créer les fichiers suivants :

### Icône principale
- **Fichier** : `icon.png`
- **Dimensions** : 1024x1024 px minimum
- **Format** : PNG avec transparence
- **Usage** : Icône de base pour iOS et Android

### Icône adaptative Android
- **Fichier** : `icon_foreground.png`
- **Dimensions** : 1024x1024 px
- **Format** : PNG avec transparence
- **Usage** : Partie avant de l'icône adaptative Android
- **Note** : La couleur de fond est définie en blanc (#FFFFFF) dans pubspec.yaml

### Splash screen
- **Fichier** : `splash_logo.png`
- **Dimensions** : 1080x1920 px recommandé (ou ratio 9:16)
- **Format** : PNG avec transparence
- **Usage** : Logo affiché sur l'écran de démarrage (thème clair)

- **Fichier** : `splash_logo_dark.png`
- **Dimensions** : 1080x1920 px recommandé
- **Format** : PNG avec transparence
- **Usage** : Logo affiché sur l'écran de démarrage (thème sombre)

## 🎨 Design recommandé

Pour respecter l'identité visuelle de l'application :

- **Couleurs principales** :
  - Bleu RF : `#000091` (bleu de France)
  - Rouge RF : `#E1000F` (rouge Marianne)
  - Blanc : `#FFFFFF`

- **Style** :
  - Épuré et moderne
  - Symboles : drapeau français, Marianne, livre/document
  - Typographie : Marianne (police officielle de l'État français)

## 🚀 Génération des icônes

Une fois les fichiers PNG créés dans ce répertoire, exécutez :

```bash
# Générer les icônes d'application
flutter pub run flutter_launcher_icons

# Générer les splash screens
flutter pub run flutter_native_splash:create
```

## 📝 Outils recommandés

### Création d'icônes
- **Figma** : Pour le design vectoriel
- **Adobe Illustrator** : Pour les designs professionnels
- **Canva** : Pour des créations rapides
- **GIMP/Photoshop** : Pour l'édition d'images

### Ressources gratuites
- [Flaticon](https://www.flaticon.com/) : Icônes gratuites
- [Freepik](https://www.freepik.com/) : Ressources graphiques
- [Unsplash](https://unsplash.com/) : Photos libres de droits

## ⚠️ Notes importantes

1. **Droits d'auteur** : Assurez-vous d'avoir les droits sur toutes les images utilisées
2. **Qualité** : Utilisez toujours des images haute résolution
3. **Transparence** : Les icônes iOS ne doivent PAS avoir de transparence (remove_alpha_ios: true)
4. **Taille** : Respectez les dimensions minimales recommandées
5. **Tests** : Testez les icônes sur différents appareils et versions d'OS

## 📦 Structure finale

Une fois les icônes générées, vous aurez :

```
assets/images/
├── README.md (ce fichier)
├── icon.png
├── icon_foreground.png
├── splash_logo.png
└── splash_logo_dark.png
```

## 🔗 Ressources officielles

- [Guide Flutter - App Icons](https://docs.flutter.dev/deployment/ios#add-an-app-icon)
- [Material Design - Product Icons](https://material.io/design/iconography/product-icons.html)
- [Apple - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Android - Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
