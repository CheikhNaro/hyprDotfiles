#!/usr/bin/env bash
# scripts/apply_theme.sh
# Usage : apply_theme.sh "Nom du thème"
# Applique le thème, met à jour globals.conf et theme.conf

KITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
GLOBALS="$KITTY_DIR/globals.conf"
THEME_CONF="$KITTY_DIR/theme.conf"
THEMES_DIR="$KITTY_DIR/themes"
THEME_NAME="$1"

if [ -z "$THEME_NAME" ]; then
  echo "Usage: apply_theme.sh \"Nom du thème\"" >&2
  exit 1
fi

THEME_FILE="$THEMES_DIR/${THEME_NAME}.conf"

if [ ! -f "$THEME_FILE" ]; then
  echo "Thème introuvable : $THEME_FILE" >&2
  exit 1
fi

# Mettre à jour globals.conf
sed -i "s/^current_theme .*/current_theme $THEME_NAME/" "$GLOBALS"

# Mettre à jour theme.conf
cat > "$THEME_CONF" <<EOF
# theme.conf
# Fichier généré automatiquement par scripts/apply_theme.sh
# Ne pas éditer manuellement

include $THEME_FILE
EOF

# Recharger toutes les instances Kitty vivantes
kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null

echo "✓ Thème appliqué : $THEME_NAME"
