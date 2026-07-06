#!/bin/bash
# =============================================================================
# hyprscreenshot.sh — Palette de capture style GNOME pour Hyprland
# PrtScr → palette GTK4/libadwaita → grim/wf-recorder/satty
# =============================================================================

SCREENSHOT_DIR="$HOME/Images/Screenshots"
VIDEODIR="$HOME/Vidéos/ScreenRecords"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PIDFILE="/tmp/wf-recorder.pid"
PALETTE="$HOME/.config/hypr/screenshot-palette/main.py"
SLURP_ARGS="-b #00000000 -B #00000000 -s #00000000 -c #e0c56dFF -w 3"

mkdir -p "$SCREENSHOT_DIR" "$VIDEODIR"

# ---------------------------------------------------------------------------
# Enregistrement en cours → arrêter immédiatement
# ---------------------------------------------------------------------------
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send -u low -a "Capture" -i video-x-generic \
        "Enregistrement arrêté" "Sauvegardé dans $VIDEODIR/"
    exit 0
fi

# ---------------------------------------------------------------------------
# Lancer la palette GTK4 et lire le choix
# ---------------------------------------------------------------------------
GTK4_LAYER_SHELL=$(ldconfig -p | grep libgtk4-layer-shell.so | head -n 1 | awk '{print $NF}')
RESULT=$(LD_PRELOAD="$GTK4_LAYER_SHELL" python3 "$PALETTE" 2>/dev/null)
[ -z "$RESULT" ] && exit 0   # Annulé (Échap)

MODE="${RESULT%%:*}"      # region | screen | window
ACTION="${RESULT##*:}"    # screenshot | record

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
_active_monitor() {
    hyprctl activeworkspace -j | jq -r '.monitor'
}

_window_geom() {
    local geom
    geom=$(hyprctl clients -j | jq -r '.[] | select(.mapped==true and .hidden==false) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp $SLURP_ARGS)
    if [ -z "$geom" ]; then
        exit 0
    fi
    echo "$geom"
}

_notify_record() {
    notify-send -u low -a "Capture" -i media-record \
        "Enregistrement démarré" "$1 — PrtScr pour arrêter"
}

# ---------------------------------------------------------------------------
# Capture d'écran → satty (annotation + copier/enregistrer)
# ---------------------------------------------------------------------------
do_screenshot() {
    local file="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"
    sleep 0.25   # laisser la palette se fermer

    case "$MODE" in
        region)
            local geom
            geom=$(slurp $SLURP_ARGS) || exit 0
            grim -g "$geom" - | ~/.cargo/bin/satty --filename - \
                --output-filename "$file"
            ;;
        screen)
            local mon
            mon=$(_active_monitor)
            if [ -n "$mon" ] && [ "$mon" != "null" ]; then
                grim -o "$mon" - | ~/.cargo/bin/satty --filename - \
                    --output-filename "$file"
            else
                grim - | ~/.cargo/bin/satty --filename - \
                    --output-filename "$file"
            fi
            ;;
        window)
            local geom
            geom=$(_window_geom)
            grim -g "$geom" - | ~/.cargo/bin/satty --filename - \
                --output-filename "$file"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Enregistrement vidéo → wf-recorder (PrtScr pour arrêter)
# ---------------------------------------------------------------------------
do_record() {
    local outfile="$VIDEODIR/recording-$TIMESTAMP.mp4"
    sleep 0.25

    case "$MODE" in
        region)
            local geom
            geom=$(slurp $SLURP_ARGS) || exit 0
            wf-recorder --audio -g "$geom" -f "$outfile" &
            echo $! > "$PIDFILE"
            _notify_record "Région sélectionnée"
            ;;
        screen)
            local mon
            mon=$(_active_monitor)
            if [ -n "$mon" ] && [ "$mon" != "null" ]; then
                wf-recorder --audio -o "$mon" -f "$outfile" &
            else
                wf-recorder --audio -f "$outfile" &
            fi
            echo $! > "$PIDFILE"
            _notify_record "Plein écran"
            ;;
        window)
            local geom
            geom=$(_window_geom)
            wf-recorder --audio -g "$geom" -f "$outfile" &
            echo $! > "$PIDFILE"
            _notify_record "Fenêtre active"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------
case "$ACTION" in
    screenshot) do_screenshot ;;
    record)     do_record ;;
esac
