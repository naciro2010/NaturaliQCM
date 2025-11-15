# Web Assets

Ce répertoire contient les assets nécessaires pour le déploiement web de NaturaliQCM.

## Icônes requises

Les icônes suivantes doivent être créées et placées dans le dossier `icons/`:

- `Icon-192.png` - Icône 192x192 pixels
- `Icon-512.png` - Icône 512x512 pixels
- `Icon-maskable-192.png` - Icône maskable 192x192 pixels
- `Icon-maskable-512.png` - Icône maskable 512x512 pixels

## Favicon

Le fichier `favicon.png` doit être une icône 16x16 ou 32x32 pixels.

## Génération des icônes

Pour générer les icônes à partir d'une image source, vous pouvez utiliser:

```bash
# Utiliser ImageMagick
convert source.png -resize 192x192 web/icons/Icon-192.png
convert source.png -resize 512x512 web/icons/Icon-512.png
convert source.png -resize 192x192 web/icons/Icon-maskable-192.png
convert source.png -resize 512x512 web/icons/Icon-maskable-512.png
convert source.png -resize 32x32 web/favicon.png
```

Ou utiliser un outil en ligne comme [favicon.io](https://favicon.io/) ou [realfavicongenerator.net](https://realfavicongenerator.net/).
