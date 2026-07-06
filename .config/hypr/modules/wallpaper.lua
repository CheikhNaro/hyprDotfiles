-- On utilise le fond d'écran actuellement sélectionné
local wallpaper = "$HOME/.cache/current-wallpaper"

hl.on("hyprland.start", function()
    -- awww-daemon est déjà démarré depuis autostart.lua
    -- Ce bloc gère les tâches post-affichage (matugen, gtk, sddm)
    hl.exec_cmd([[bash -c '
        REAL_WP=$(readlink -f "]] .. wallpaper .. [[")
        MATUGEN_JSON=$(matugen image "$REAL_WP" --prefer saturation --json hex)
        echo "$MATUGEN_JSON" | ~/.config/rofi/update-wayle-palette.py "$REAL_WP"
        gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
        gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
        test -f "$HOME/.cache/sddm-colors.tmp" && { rm -f /usr/share/sddm/themes/thyx/theme.conf.user 2>/dev/null; cp "$HOME/.cache/sddm-colors.tmp" /usr/share/sddm/themes/thyx/theme.conf.user 2>/dev/null; }
        cp "$REAL_WP" /usr/share/sddm/themes/thyx/background.jpg 2>/dev/null
    ']])
end)

-- Applique automatiquement le fond d'écran à tout nouveau moniteur branché
hl.on("monitor.added", function(monitor)
    hl.exec_cmd("bash -c 'awww img --transition-type fade --transition-step 150 $(readlink -f " .. wallpaper .. ")'")
end)
