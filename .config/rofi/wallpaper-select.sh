#!/bin/bash
WALLPAPER_DIR="$HOME/Images/Wallpaper"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"

mkdir -p "$CACHE_DIR"

thumb_for() {
    local src="$1"
    local thumb="$CACHE_DIR/$(basename "${src%.*}").jpg"
    if [ -f "$thumb" ]; then
        echo "$thumb"
    else
        echo "$src"
    fi
}

gen_missing_thumbs() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | sort -z |
    while IFS= read -r -d '' file; do
        thumb="$CACHE_DIR/$(basename "${file%.*}").jpg"
        [ ! -f "$thumb" ] && magick "$file" -thumbnail 240x240^ -gravity center -extent 240x240 "$thumb" 2>/dev/null
    done
}

if [ "$1" = "--list" ]; then
    # Génère les miniatures manquantes en arrière-plan (ne bloque pas l'affichage)
    (gen_missing_thumbs >/dev/null 2>&1 &)
    if [ -n "$2" ]; then
        WALLPAPER_PATH="$WALLPAPER_DIR/$2"
        ln -sf "$WALLPAPER_PATH" "$HOME/.cache/current-wallpaper"
        
        (
            ~/.cargo/bin/wayle wallpaper set "$WALLPAPER_PATH"
            sleep 0.2
            wallust run "$WALLPAPER_PATH"
            WALLUST_JSON="$(cat ~/.cache/wallust/colors.json)"
            cp "$WALLPAPER_PATH" "/usr/share/sddm/themes/pixie/assets/background.jpg" 2>/dev/null
            cp "$HOME/.config/sddm-theme/theme.conf" "/usr/share/sddm/themes/pixie/theme.conf" 2>/dev/null
            gen_missing_thumbs
            gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
            gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
            pkill swayosd-server; swayosd-server &
            nautilus -q
            magick "$WALLPAPER_PATH" -resize 1920x1080^ -quality 85 "$HOME/.cache/wlogout-bg.jpg" 2>/dev/null
            echo "$WALLUST_JSON" | ~/.config/rofi/update-wayle-palette.py "$HOME/.cache/wlogout-bg.jpg"
            echo "$WALLUST_JSON" | python3 ~/.config/hypr/scripts/generate-hyprtoolkit.py
        ) </dev/null >/dev/null 2>&1 & disown
    fi

    # Garder la sélection à la même place après un clic
    echo -en "\0keep-selection\x1ftrue\n"

    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | sort -z | while IFS= read -r -d '' file; do
        name="${file##*/}"
        base="${name%.*}"
        thumb="$CACHE_DIR/$base.jpg"
        if [ -f "$thumb" ]; then
            printf "%s\0icon\x1f%s\n" "$name" "$thumb"
        else
            printf "%s\0icon\x1f%s\n" "$name" "$file"
        fi
    done
    exit 0
fi

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
rofi -modi "wallpaper:$SELF --list" -show wallpaper \
    -theme ~/.config/rofi/wallpaper.rasi \
    -p "" -filter "$(echo -e '\u200B')" &

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if [[ "$line" == "openlayer>>rofi" ]]; then
        sleep 0.05
        wtype -k BackSpace
        break
    fi
done
