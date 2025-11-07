# Assets - Polices

Ce répertoire contient les polices de caractères utilisées dans l'application NaturaliQCM.

## 📝 Police Marianne

**Marianne** est la police officielle de l'identité visuelle de l'État français depuis 2019.

### Fichiers requis

- **Fichier** : `Marianne-Regular.ttf`
  - **Poids** : 400 (Regular)
  - **Usage** : Texte standard

- **Fichier** : `Marianne-Bold.ttf`
  - **Poids** : 700 (Bold)
  - **Usage** : Titres, emphase

### Où obtenir la police Marianne ?

La police Marianne est disponible gratuitement sur le site officiel :

1. **Site officiel** : [systeme-de-design.gouv.fr](https://www.systeme-de-design.gouv.fr/elements-d-interface/fondamentaux-de-l-identite-de-l-etat/typographie/)

2. **Téléchargement** :
   - Aller sur la page Typographie du Système de Design de l'État
   - Télécharger le pack de polices Marianne
   - Extraire les fichiers `.ttf` pour Regular et Bold
   - Placer les fichiers dans ce répertoire

3. **Licence** :
   - La police Marianne est sous licence Open Font License (OFL)
   - Utilisation libre pour tous projets

### Alternative - Police de secours

Si la police Marianne n'est pas disponible, l'application utilisera automatiquement les polices système par défaut :
- **Android** : Roboto
- **iOS** : San Francisco

L'application reste pleinement fonctionnelle avec ces polices de secours.

## 📦 Installation

Une fois les fichiers placés dans ce répertoire :

```bash
assets/fonts/
├── README.md (ce fichier)
├── Marianne-Regular.ttf
└── Marianne-Bold.ttf
```

Exécutez :

```bash
flutter pub get
```

Les polices seront automatiquement intégrées à l'application.

## 🎨 Usage dans le code

Les polices Marianne sont déjà configurées dans le thème de l'application :

```dart
// Theme configuration (déjà implémenté)
ThemeData(
  fontFamily: 'Marianne',
  // ...
)
```

Aucune modification de code n'est nécessaire.

## ⚠️ Note

La police Marianne n'est **pas obligatoire** pour le fonctionnement de l'application. Elle améliore uniquement l'esthétique et l'alignement avec l'identité visuelle de l'État français.

## 🔗 Ressources

- [Système de Design de l'État](https://www.systeme-de-design.gouv.fr/)
- [Charte graphique de l'État](https://www.gouvernement.fr/charte/charte-graphique)
- [Open Font License](https://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)
