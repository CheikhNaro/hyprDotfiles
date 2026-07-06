#!/bin/bash

# Dossier temporaire pour la capture
IMAGE="/tmp/ocr_snapshot.png"

# 1. Sélectionner la zone et capturer
grim -g "$(slurp)" "$IMAGE"

# Vérifier si l'utilisateur a annulé la capture (Echap)
if [ ! -f "$IMAGE" ]; then
    exit 0
fi

# 2. Exécuter Tesseract (Français + Anglais)
# Le "-" indique à tesseract de renvoyer le résultat sur la sortie standard
TEXT=$(tesseract "$IMAGE" - -l fra+eng 2>/dev/null)

# 3. Nettoyer l'image temporaire
rm "$IMAGE"

# 4. Envoyer dans le presse-papiers et notifier
if [ -n "$TEXT" ]; then
    echo "$TEXT" | wl-copy
    notify-send -a "ocr-tool" "OCR Réussi" "Le texte a été copié !" -i edit-paste
else
    notify-send -a "ocr-tool" "OCR Échec" "Aucun texte n'a pu être détecté." -i dialog-error
fi
