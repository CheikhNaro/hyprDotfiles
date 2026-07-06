#!/bin/bash
# Gère le profil d'énergie et lance le bon hypridle selon l'état AC/batterie

# Arrêter l'instance existante de hypridle proprement
killall -q -w hypridle 2>/dev/null

if grep -qE "Charging|Full" /sys/class/power_supply/*/status 2>/dev/null; then
    hypridle -c ~/.config/hypr/hypridle/ac.conf &
else
    hypridle -c ~/.config/hypr/hypridle/bat.conf &
fi

# Note: powerprofilesctl réglé sur "performance" dans les deux cas — ligne unifiée
powerprofilesctl set performance 2>/dev/null || powerprofilesctl set balanced 2>/dev/null

# Pont wayle idle → systemd-inhibit (pour que hypridle respecte l'inhibition wayle)
pkill -f "wayle-idle-bridge.sh" 2>/dev/null
~/.config/hypr/scripts/wayle-idle-bridge.sh &
