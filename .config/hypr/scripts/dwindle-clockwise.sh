#!/bin/bash
# dwindle-clockwise.sh
# Écoute les événements Hyprland et, avant chaque nouvelle fenêtre,
# s'assure que le split se fait toujours dans le sens horaire.
#
# Principe : quand une fenêtre s'ouvre (openwindow), on refocus
# la dernière fenêtre tuilée ajoutée (la "pointe" de la spirale)
# pour que le prochain split parte d'elle → spirale horaire stricte.

SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - "UNIX-CONNECT:$SOCK" | while IFS= read -r event; do
    case "$event" in
        openwindow*)
            # Récupère la liste des fenêtres tuilées du workspace actif,
            # triée par ordre d'apparition (at = position dans le layout)
            # et focus la dernière ajoutée (la pointe de la spirale)
            hyprctl -j clients 2>/dev/null | python3 -c "
import json, sys, subprocess

clients = json.load(sys.stdin)

# Workspace actif
active_ws = subprocess.run(
    ['hyprctl', '-j', 'activeworkspace'],
    capture_output=True, text=True
).stdout
ws_id = json.loads(active_ws)['id']

# Fenêtres tuilées sur ce workspace, triées par at[0] puis at[1]
tiled = [
    c for c in clients
    if not c['floating'] and c['workspace']['id'] == ws_id
]

if len(tiled) >= 2:
    # La dernière dans l'ordre du layout = la pointe de la spirale
    # (celle avec le at le plus en bas-droite)
    tip = max(tiled, key=lambda c: (c['at'][1], c['at'][0]))
    subprocess.run(['hyprctl', 'dispatch', 'focuswindow', f'address:{tip[\"address\"]}'])
"
            ;;
    esac
done
