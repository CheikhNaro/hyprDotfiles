#!/bin/bash
# Script OSD : modifie volume/luminosité puis affiche l'OSD avec le pourcentage

case "$1" in
    vol-up)
        wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 5%+
        pw-play /usr/share/sounds/Harmony/stereo/audio-volume-change.ogg &
        ;;
    vol-down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        pw-play /usr/share/sounds/Harmony/stereo/audio-volume-change.ogg &
        ;;
    vol-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    mic-mute)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    br-up)
        brightnessctl -e4 -n2 set 5%+
        ;;
    br-down)
        brightnessctl -e4 -n2 set 5%-
        ;;
    *)
        exit 1
        ;;
esac

# Affichage OSD après action
case "$1" in
    br-up|br-down)
        # Lire la valeur de la luminosité en une seule commande
        read -r br_val <<< "$(brightnessctl -m | awk -F, '{print substr($4, 1, length($4)-1)}')"
        swayosd-client --custom-progress "$(awk "BEGIN{printf \"%.2f\", $br_val/100}")" \
                       --custom-progress-text "${br_val}%" \
                       --custom-icon "display-brightness-symbolic"
        ;;
    mic-mute)
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
            swayosd-client --custom-progress 0.0 --custom-progress-text "Muet" \
                           --custom-icon "microphone-sensitivity-muted-symbolic"
        else
            swayosd-client --custom-progress 1.0 --custom-progress-text "Activé" \
                           --custom-icon "microphone-sensitivity-high-symbolic"
        fi
        ;;
    vol-up|vol-down|vol-mute)
        vol_line=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        if [[ "$vol_line" == *MUTED* ]]; then
            swayosd-client --custom-progress 0.0 --custom-progress-text "Muet" \
                           --custom-icon "audio-volume-muted-symbolic"
        else
            vol=$(awk '{print int($2 * 100)}' <<< "$vol_line")
            if   (( vol < 33 )); then icon="audio-volume-low-symbolic"
            elif (( vol < 67 )); then icon="audio-volume-medium-symbolic"
            else                      icon="audio-volume-high-symbolic"
            fi
            swayosd-client --custom-progress "$(awk "BEGIN{printf \"%.2f\", $vol/100}")" \
                           --custom-progress-text "${vol}%" \
                           --custom-icon "$icon"
        fi
        ;;
esac
