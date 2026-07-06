#!/bin/bash
# Daemon pour les sons d'événements système (notifications + alimentation)

PIDFILE="/tmp/events-daemon.pid"

# Éviter de lancer plusieurs instances — tuer la précédente proprement
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    pkill -P "$(cat "$PIDFILE")" 2>/dev/null
    kill "$(cat "$PIDFILE")" 2>/dev/null
fi
echo $$ > "$PIDFILE"

# Chemins des sons (Thème Harmony)
readonly SND_NOTIF="/usr/share/sounds/Harmony/stereo/message-new-instant.ogg"
readonly SND_PLUG="/usr/share/sounds/Harmony/stereo/power-plug.ogg"
readonly SND_UNPLUG="/usr/share/sounds/Harmony/stereo/power-unplug.ogg"

# Apps à ignorer (ont leurs propres sons ou spamment)
readonly IGNORED_APPS="discord|telegram|spotify|vlc|mpv|satty|hyprpicker|ocr-tool|vesktop"

# 1. Gestion des sons de notifications (via dbus-monitor)
monitor_notifications() {
    dbus-monitor "interface='org.freedesktop.Notifications',member='Notify'" | \
    while read -r line; do
        if [[ "$line" == *"member=Notify"* ]]; then
            read -r app_line
            # Comparaison en minuscules sans fork (bash natif)
            app="${app_line,,}"
            if ! [[ "$app" =~ $IGNORED_APPS ]]; then
                pw-play "$SND_NOTIF" &
            fi
        fi
    done
}

# 2. Gestion de l'alimentation (branché / débranché)
monitor_power() {
    local last_state
    last_state=$(< /sys/class/power_supply/AC/online 2>/dev/null || \
                 grep -r "" /sys/class/power_supply/*/online 2>/dev/null | head -c1)
    ~/.config/hypr/scripts/hypridle-manager.sh

    upower --monitor | grep --line-buffered "line_power\|battery" | while read -r line; do
        sleep 0.5
        # Lire directement dans sysfs (plus rapide qu'invoquer upower)
        local state
        state=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo "$last_state")

        if [ "$state" != "$last_state" ]; then
            if [ "$state" = "1" ]; then
                pw-play "$SND_PLUG" &
            else
                pw-play "$SND_UNPLUG" &
            fi
            ~/.config/hypr/scripts/hypridle-manager.sh
            last_state="$state"
        fi
    done
}

# Lancement des deux processus en arrière-plan
monitor_notifications &
PID_NOTIF=$!
monitor_power &
PID_POWER=$!

# Nettoyage propre à la fermeture
trap "kill $PID_NOTIF $PID_POWER 2>/dev/null; rm -f '$PIDFILE'" EXIT INT TERM

wait
