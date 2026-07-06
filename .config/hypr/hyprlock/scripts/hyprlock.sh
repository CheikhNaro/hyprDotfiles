#!/usr/bin/env bash

if [[ "$(playerctl -p spotify status 2>/dev/null)" == "Playing" ]]; then
    pkill glava

    glava &
    sleep 0.6

    hyprctl dispatch focuswindow class:glava
    sleep 0.1

    hyprctl dispatch fullscreen

    hyprlock --config ~/.config/hypr/hyprlock/music.conf
else
    hyprlock
fi

pkill glava

# Annule tout fullscreen orphelin laissé par glava
hyprctl dispatch fullscreen 0 2>/dev/null
