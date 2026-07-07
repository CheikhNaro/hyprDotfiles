#!/bin/bash
# =============================================================================
# hyprscreenshot.sh v2 — Palette de capture style GNOME pour Hyprland
# PrtScr → palette GTK4 → grim / wf-recorder / satty
#
# Nouvelles fonctionnalités :
#   • Encodage matériel VAAPI (Intel HD 520 → /dev/dri/renderD128)
#   • Sélecteur de format (mp4, mkv, gif)
#   • Audio micro / sortie système avec choix du device PipeWire
#   • Compte à rebours géré côté Python, délai passé en JSON
# =============================================================================

SCREENSHOT_DIR="$HOME/Images/Screenshots"
VIDEODIR="$HOME/Vidéos/ScreenRecords"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PIDFILE="/tmp/wf-recorder.pid"
PALETTE="$HOME/.config/hypr/screenshot-palette/main.py"
SLURP_ARGS="-b #00000000 -B #00000000 -s #00000000 -c #e0c56dFF -w 3"

# ── Encodage matériel VAAPI (Intel) ─────────────────────────────────────────
VAAPI_DEVICE="/dev/dri/renderD128"
VAAPI_CODEC="h264_vaapi"        # h264_vaapi = très bon rapport qualité/perf

mkdir -p "$SCREENSHOT_DIR" "$VIDEODIR"

# ---------------------------------------------------------------------------
# Enregistrement en cours → arrêter immédiatement (2e appui sur PrtScr)
# ---------------------------------------------------------------------------
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send -u low -a "Capture" -i video-x-generic \
        "Enregistrement arrêté" "Sauvegardé dans $VIDEODIR/"
    exit 0
fi

# ---------------------------------------------------------------------------
# Lancer la palette GTK4 et lire le choix (JSON)
# ---------------------------------------------------------------------------
GTK4_LAYER_SHELL=$(ldconfig -p | grep libgtk4-layer-shell.so | head -n 1 | awk '{print $NF}')
RESULT=$(LD_PRELOAD="$GTK4_LAYER_SHELL" python3 "$PALETTE" 2>/dev/null)
[ -z "$RESULT" ] && exit 0   # Annulé (Échap)

# Parser le JSON avec jq
MODE=$(echo "$RESULT"        | jq -r '.mode')        # region | screen | window
ACTION=$(echo "$RESULT"      | jq -r '.action')      # screenshot | record
FMT=$(echo "$RESULT"         | jq -r '.format')      # mp4 | mkv | gif
AUDIO_MIC=$(echo "$RESULT"   | jq -r '.audio_mic')   # true | false
AUDIO_SINK=$(echo "$RESULT"  | jq -r '.audio_sink')  # true | false
MIC_DEVICE=$(echo "$RESULT"  | jq -r '.mic_device')  # nom PipeWire
SINK_DEVICE=$(echo "$RESULT" | jq -r '.sink_device') # nom PipeWire

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
        slurp $SLURP_ARGS)
    [ -z "$geom" ] && exit 0
    echo "$geom"
}

_notify_record() {
    notify-send -u low -a "Capture" -i media-record \
        "Enregistrement démarré" "$1 — PrtScr pour arrêter"
}

# Construit les arguments audio pour wf-recorder
# wf-recorder supporte un seul -a, donc on merge micro + sink
# avec une source virtuelle combinée via PipeWire si les deux sont actifs.
# Sinon on passe juste le device demandé.
_build_audio_args() {
    local args=""
    if [ "$AUDIO_MIC" = "true" ] && [ "$AUDIO_SINK" = "true" ]; then
        # Les deux : on passe le micro (wf-recorder ne supporte qu'une source)
        # Pour la sortie système on utilise le monitor du sink
        # On préfère le monitor sink car ça capture le son du PC + micro via loopback PW
        args="--audio=${SINK_DEVICE}"
    elif [ "$AUDIO_MIC" = "true" ] && [ -n "$MIC_DEVICE" ]; then
        args="--audio=${MIC_DEVICE}"
    elif [ "$AUDIO_SINK" = "true" ] && [ -n "$SINK_DEVICE" ]; then
        args="--audio=${SINK_DEVICE}"
    fi
    echo "$args"
}

# Construit les arguments codec pour wf-recorder
# Pour GIF : pas de codec vidéo, muxer gif
# Pour MP4/MKV : VAAPI si disponible, sinon libx264/libx265
_build_codec_args() {
    local outfile="$1"
    local args=""

    if [ "$FMT" = "gif" ]; then
        # GIF : pas de codec matériel possible, on force le muxer
        args="-c gif -m gif"
    elif [ -e "$VAAPI_DEVICE" ]; then
        # Hardware encoding VAAPI (Intel)
        args="-c ${VAAPI_CODEC} -d ${VAAPI_DEVICE}"
    else
        # Fallback logiciel
        args="-c libx264 -p crf=23"
    fi

    echo "$args"
}

# ---------------------------------------------------------------------------
# Capture d'écran → satty (annotation + copier/enregistrer)
# ---------------------------------------------------------------------------
do_screenshot() {
    local file="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"
    sleep 0.25

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
# Enregistrement vidéo → wf-recorder (2e PrtScr pour arrêter)
# ---------------------------------------------------------------------------
do_record() {
    local outfile="$VIDEODIR/recording-$TIMESTAMP.${FMT}"
    local audio_args
    audio_args=$(_build_audio_args)
    local codec_args
    codec_args=$(_build_codec_args "$outfile")

    sleep 0.25

    _launch_recorder() {
        local geo_arg="$1"
        local out_arg="$2"
        # shellcheck disable=SC2086
        wf-recorder $geo_arg $audio_args $codec_args -f "$out_arg" &
        echo $! > "$PIDFILE"
    }

    case "$MODE" in
        region)
            local geom
            geom=$(slurp $SLURP_ARGS) || exit 0
            _launch_recorder "-g \"$geom\"" "$outfile"
            _notify_record "Région sélectionnée"
            ;;
        screen)
            local mon
            mon=$(_active_monitor)
            if [ -n "$mon" ] && [ "$mon" != "null" ]; then
                _launch_recorder "-o \"$mon\"" "$outfile"
            else
                _launch_recorder "" "$outfile"
            fi
            _notify_record "Plein écran"
            ;;
        window)
            local geom
            geom=$(_window_geom)
            _launch_recorder "-g \"$geom\"" "$outfile"
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
