#!/bin/bash

PIDFILE="/tmp/wf-recorder.pid"
VIDEODIR="$HOME/Vidéos/ScreenRecords"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Recording stopped" "Saved to $VIDEODIR/"
    exit 0
fi

mkdir -p "$VIDEODIR"

if [ "$1" = "region" ]; then
    GEOM=$(slurp)
    if [ -z "$GEOM" ]; then
        exit 1
    fi
    wf-recorder -g "$GEOM" -f "$VIDEODIR/recording-$TIMESTAMP.mp4" &
else
    MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
    if [ -n "$MONITOR" ] && [ "$MONITOR" != "null" ]; then
        wf-recorder -o "$MONITOR" -f "$VIDEODIR/recording-$TIMESTAMP.mp4" &
    else
        wf-recorder -f "$VIDEODIR/recording-$TIMESTAMP.mp4" &
    fi
fi

echo $! > "$PIDFILE"
notify-send "Recording started" "Mode: ${1:-fullscreen}"
