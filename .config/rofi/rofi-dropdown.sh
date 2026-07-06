#!/bin/bash

# Lancer rofi avec un caractère invisible (Espace sans chasse / Zero-width space)
# Cela force Rofi à ne trouver aucun résultat et donc à s'ouvrir avec une taille minimale.
rofi -show drun -show-icons -filter "$(echo -e '\u200B')" &

# Attendre que la couche (layer) Rofi soit complètement ouverte via IPC Hyprland
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if [[ "$line" == "openlayer>>rofi" ]]; then
        # Léger délai pour s'assurer que Rofi a le focus d'entrée
        sleep 0.05
        wtype -k BackSpace
        break
    fi
done
