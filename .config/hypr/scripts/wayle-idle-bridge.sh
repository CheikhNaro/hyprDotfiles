#!/bin/bash
# wayle-idle-bridge.sh
# Surveille l'état de wayle idle et pose un vrai inhibiteur systemd-inhibit
# que hypridle respecte (ignore_systemd_inhibit = false).
#
# Principe : quand wayle idle est actif, on lance systemd-inhibit en arrière-plan
# pour bloquer "idle:sleep" — hypridle voit cet inhibiteur et suspend ses timers.

WAYLE="$HOME/.cargo/bin/wayle"
INHIBIT_PID=""

cleanup() {
    [[ -n "$INHIBIT_PID" ]] && kill "$INHIBIT_PID" 2>/dev/null
    exit 0
}
trap cleanup SIGTERM SIGINT

is_wayle_inhibiting() {
    "$WAYLE" idle status 2>/dev/null | grep -qi "active"
}

start_inhibit() {
    if [[ -z "$INHIBIT_PID" ]]; then
        systemd-inhibit \
            --what="idle:sleep" \
            --who="wayle-idle-bridge" \
            --why="Wayle idle inhibit actif" \
            --mode="block" \
            sleep infinity &
        INHIBIT_PID=$!
    fi
}

stop_inhibit() {
    if [[ -n "$INHIBIT_PID" ]]; then
        kill "$INHIBIT_PID" 2>/dev/null
        INHIBIT_PID=""
    fi
}

LAST_STATE=""

while true; do
    if is_wayle_inhibiting; then
        CURRENT="active"
    else
        CURRENT="inactive"
    fi

    if [[ "$CURRENT" != "$LAST_STATE" ]]; then
        if [[ "$CURRENT" == "active" ]]; then
            start_inhibit
        else
            stop_inhibit
        fi
        LAST_STATE="$CURRENT"
    fi

    sleep 5
done
