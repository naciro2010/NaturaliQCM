#!/bin/bash

# Créer les répertoires
mkdir -p assets/images web/icons

# Fonction pour créer une icône SVG simple
create_svg_icon() {
    local size=$1
    local output=$2
    local dark=$3
    
    local bg_color="#FFFFFF"
    local circle_color="#000091"
    local text_color="#FFFFFF"
    
    if [ "$dark" = "dark" ]; then
        bg_color="#000033"
    fi
    
    cat > "$output" << EOF
<svg width="$size" height="$size" xmlns="http://www.w3.org/2000/svg">
  <rect width="$size" height="$size" fill="$bg_color"/>
  <circle cx="$(($size/2))" cy="$(($size/2))" r="$(($size/3))" fill="$circle_color"/>
  <text x="$(($size/2))" y="$(($size/2 + $size/8))" font-size="$(($size/2))" fill="$text_color" text-anchor="middle" font-family="Arial, sans-serif" font-weight="bold">N</text>
</svg>
EOF
}

# Créer les SVG temporaires
echo "🎨 Création des icônes SVG..."
create_svg_icon 1024 /tmp/icon.svg
create_svg_icon 192 /tmp/icon-192.svg  
create_svg_icon 512 /tmp/icon-512.svg
create_svg_icon 32 /tmp/favicon.svg
create_svg_icon 1080 /tmp/splash.svg
create_svg_icon 1080 /tmp/splash_dark.svg dark

echo "✅ Fichiers SVG créés"

# Pour l'instant, copier les SVG comme placeholder
# (Flutter peut utiliser des SVG, ou on les convertira plus tard)
cp /tmp/icon.svg assets/images/icon.svg
cp /tmp/icon-192.svg web/icons/icon-192.svg
cp /tmp/icon-512.svg web/icons/icon-512.svg
cp /tmp/favicon.svg web/favicon.svg
cp /tmp/splash.svg assets/images/splash_logo.svg
cp /tmp/splash_dark.svg assets/images/splash_logo_dark.svg

echo "✅ Icônes SVG copiées"

# Créer des PNG minimaux (1x1) en attendant
# PNG 1x1 transparent encodé en base64
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > /tmp/transparent.png

# Copier comme placeholder pour les fichiers PNG requis
cp /tmp/transparent.png assets/images/icon.png 2>/dev/null || true
cp /tmp/transparent.png assets/images/icon_foreground.png 2>/dev/null || true
cp /tmp/transparent.png assets/images/splash_logo.png 2>/dev/null || true
cp /tmp/transparent.png assets/images/splash_logo_dark.png 2>/dev/null || true
cp /tmp/transparent.png web/icons/Icon-192.png 2>/dev/null || true
cp /tmp/transparent.png web/icons/Icon-512.png 2>/dev/null || true
cp /tmp/transparent.png web/icons/Icon-maskable-192.png 2>/dev/null || true
cp /tmp/transparent.png web/icons/Icon-maskable-512.png 2>/dev/null || true
cp /tmp/transparent.png web/favicon.png 2>/dev/null || true

echo "✅ PNG placeholders créés"
ls -lh assets/images/
ls -lh web/icons/

