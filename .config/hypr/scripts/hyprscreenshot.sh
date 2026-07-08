#!/bin/bash
# =============================================================================
# hyprscreenshot.sh v4 — Palette de capture style GNOME pour Hyprland
# Capture d'écran (grim + satty) & Enregistrement Vidéo (wf-recorder) Workflow Kooha
# =============================================================================

SCREENSHOT_DIR="$HOME/Images/Screenshots"
VIDEODIR="$HOME/Vidéos/ScreenRecords"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PIDFILE="/tmp/wf-recorder.pid"
MODULEFILE="/tmp/wf-recorder-modules"
PALETTE="$HOME/.config/hypr/screenshot-palette/main.py"
SLURP_ARGS="-b #00000000 -B #00000000 -s #00000000 -c #e0c56dFF -w 1"
SLURP_ARGS_WINDOW="-b #00000000 -B #00000000 -c #00000000 -w 0 -s #ffffff40"

mkdir -p "$SCREENSHOT_DIR" "$VIDEODIR"

# ---------------------------------------------------------------------------
# Enregistrement en cours → gérer 2e appui sur PrtScr
# ---------------------------------------------------------------------------
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    
    # Nettoyer les sinks combinés
    if [ -f "$MODULEFILE" ]; then
        while IFS= read -r mod; do
            pactl unload-module "$mod" 2>/dev/null
        done < "$MODULEFILE"
        rm -f "$MODULEFILE"
    fi
    
    notify-send -u low -a "Capture" -i video-x-generic "Enregistrement arrêté" "Sauvegardé dans $VIDEODIR/"
    exit 0
fi

# ---------------------------------------------------------------------------
# Lancer la palette GTK4 et lire le choix (JSON)
# ---------------------------------------------------------------------------
GTK4_LAYER_SHELL=$(/sbin/ldconfig -p | grep libgtk4-layer-shell.so | head -n 1 | awk '{print $NF}')
RESULT=$(LD_PRELOAD="$GTK4_LAYER_SHELL" python3 "$PALETTE" 2>/dev/null)
[ -z "$RESULT" ] && exit 0   # Annulé (Échap)

# Parser le JSON avec jq
MODE=$(echo "$RESULT"       | jq -r '.mode')
ACTION=$(echo "$RESULT"     | jq -r '.action')
FMT=$(echo "$RESULT"        | jq -r '.format')
FPS=$(echo "$RESULT"        | jq -r '.fps')
AUDIO_MIC=$(echo "$RESULT"  | jq -r '.audio_mic')
AUDIO_SPK=$(echo "$RESULT"  | jq -r '.audio_spk')

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
_active_monitor() {
    hyprctl activeworkspace -j | jq -r '.monitor'
}

_window_geom() {
    local geom
    geom=$(hyprctl clients -j | \
        jq -r '.[] | select(.mapped==true and .hidden==false) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | \
        slurp $SLURP_ARGS_WINDOW)
    [ -z "$geom" ] && exit 0
    echo "$geom"
}

_notify_record() {
    notify-send -u low -a "Capture" -i media-record \
        "Enregistrement démarré" "$1 — PrtScr pour arrêter"
}

_build_audio_args() {
    if [ "$AUDIO_MIC" != "null" ] && [ "$AUDIO_SPK" != "null" ]; then
        local SINK_NAME="wf-recording"
        MODULE_IDS=()
        mod=$(pactl load-module module-null-sink sink_name="$SINK_NAME")
        MODULE_IDS+=("$mod")
        mod=$(pactl load-module module-loopback source="$AUDIO_MIC" sink="$SINK_NAME" latency_msec=20)
        MODULE_IDS+=("$mod")
        mod=$(pactl load-module module-loopback source="${AUDIO_SPK%.monitor}.monitor" sink="$SINK_NAME" latency_msec=20)
        MODULE_IDS+=("$mod")
        printf '%s\n' "${MODULE_IDS[@]}" > "$MODULEFILE"
        echo "--audio=${SINK_NAME}.monitor"
    elif [ "$AUDIO_MIC" != "null" ]; then
        echo "--audio=$AUDIO_MIC"
    elif [ "$AUDIO_SPK" != "null" ]; then
        echo "--audio=$AUDIO_SPK"
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------------
# Capture d'écran → satty
# ---------------------------------------------------------------------------
do_screenshot() {
    local file="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"
    sleep 0.25

    case "$MODE" in
        region)
            local geom
            geom=$(slurp $SLURP_ARGS) || exit 0
            grim -g "$geom" - | ~/.cargo/bin/satty --filename - --output-filename "$file"
            ;;
        screen)
            local mon=$(_active_monitor)
            if [ -n "$mon" ] && [ "$mon" != "null" ]; then
                grim -o "$mon" - | ~/.cargo/bin/satty --filename - --output-filename "$file"
            else
                grim - | ~/.cargo/bin/satty --filename - --output-filename "$file"
            fi
            ;;
        window)
            local geom=$(_window_geom)
            grim -g "$geom" - | ~/.cargo/bin/satty --filename - --output-filename "$file"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Enregistrement vidéo → wf-recorder
# ---------------------------------------------------------------------------
do_record() {
    local outfile="$VIDEODIR/recording-$TIMESTAMP.${FMT}"
    local audio_args=$(_build_audio_args)
    sleep 0.25

    _launch_recorder() {
        local geo_opt="$1"
        local geo_val="$2"
        local cmd=(wf-recorder)

        if [ "$geo_opt" != "none" ]; then
            cmd+=("$geo_opt" "$geo_val")
        fi

        if [ -n "$audio_args" ]; then
            cmd+=("$audio_args")
        fi

        if [ "$FMT" = "gif" ]; then
            cmd+=("-c" "gif" "-m" "gif")
        elif [ "$FMT" = "webm" ]; then
            cmd+=("-c" "libvpx-vp9" "-F" "webm")
        elif [ -e "/dev/dri/renderD128" ]; then
            cmd+=("-c" "h264_vaapi" "-d" "/dev/dri/renderD128")
        else
            cmd+=("-c" "libx264" "-p" "crf=23")
        fi

        if [ -n "$FPS" ] && [ "$FPS" != "null" ]; then
            cmd+=("-r" "$FPS")
        fi

        cmd+=("-f" "$outfile")

        "${cmd[@]}" &
        echo $! > "$PIDFILE"
    }

    case "$MODE" in
        region)
            local geom=$(slurp $SLURP_ARGS) || exit 0
            _launch_recorder "-g" "$geom"
            _notify_record "Région sélectionnée"
            ;;
        screen)
            local mon=$(_active_monitor)
            if [ -n "$mon" ] && [ "$mon" != "null" ]; then
                _launch_recorder "-o" "$mon"
            else
                _launch_recorder "none" ""
            fi
            _notify_record "Plein écran"
            ;;
        window)
            local geom=$(_window_geom)
            _launch_recorder "-g" "$geom"
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
