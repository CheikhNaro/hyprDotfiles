hl.on("hyprland.start", function()
    -- Important: importer l'environnement avant de démarrer la target systemd
    hl.exec_cmd("bash -c 'systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH && systemctl --user start hyprland-session.target && sleep 1 && ~/.cargo/bin/wayle panel start'")

    hl.exec_cmd("xhost +SI:localuser:root")
    hl.exec_cmd("qs -d")
    -- Clipboard history (clipse) — géré par systemd user service
    hl.exec_cmd("systemctl --user start clipse.service")

    -- Daemon mode for wayle-settings (instant popup on hotkey)
    hl.exec_cmd("~/.cargo/bin/wayle-settings --gapplication-service")

    -- Déverrouiller le trousseau de clés
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")

    -- Daemon pour les sons d'évènements (Chargeur et Notifications) + Idle management
    hl.exec_cmd("~/.config/hypr/scripts/events-daemon.sh")

    -- Snappy Switcher (Alt+Tab rapide)
    hl.exec_cmd("snappy-switcher --daemon")

    -- SwayOSD Server
    hl.exec_cmd("swayosd-server")

    -- Dwindle clockwise enforcer (refocus la pointe de la spirale avant chaque split)
    hl.exec_cmd("bash -c '~/.config/hypr/scripts/dwindle-clockwise.sh &'")
end)

hl.on("hyprland.shutdown", function()
    os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)
