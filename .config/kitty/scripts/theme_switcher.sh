#!/usr/bin/env bash
# scripts/theme_switcher.sh
# Lance kitten themes pour sélectionner un thème,
# puis applique le choix via apply_theme.sh

KITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
GLOBALS="$KITTY_DIR/globals.conf"

# Lire le thème courant depuis globals.conf
CURRENT=$(grep '^current_theme' "$GLOBALS" | sed 's/^current_theme //')

# kitten themes écrit le thème choisi dans theme.conf directement.
# On le lance, puis on resync globals.conf avec le résultat.
kitten themes --reload-in=all

# Lire le thème nouvellement sélectionné depuis theme.conf
NEW_THEME=$(grep '^include' "$KITTY_DIR/theme.conf" \
  | sed "s|.*themes/||;s|\.conf$||")

if [ -n "$NEW_THEME" ] && [ "$NEW_THEME" != "$CURRENT" ]; then
  sed -i "s/^current_theme .*/current_theme $NEW_THEME/" "$GLOBALS"
  echo "✓ Thème appliqué : $NEW_THEME"
else
  echo "— Thème inchangé : $CURRENT"
fi
