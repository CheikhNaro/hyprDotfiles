hl.on("hyprland.start", function()
    -- Important: importer l'environnement avant de démarrer la target systemd
    hl.exec_cmd("bash -c 'systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH && systemctl --user start hyprland-session.target'")

    hl.exec_cmd("xhost +SI:localuser:root")
    
    -- Clipboard history (clipse) — géré par systemd user service
    hl.exec_cmd("systemctl --user start clipse.service")

    -- Wayle daemon (panneau, etc.)
    hl.exec_cmd("~/.cargo/bin/wayle panel start &")
    
    -- Notifications (dunst)
    hl.exec_cmd("dunst &")

    -- Agent Polkit (hyprpolkitagent)
    hl.exec_cmd("/usr/libexec/hyprpolkitagent &")

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

    -- Préchauffage Rofi : charge les icônes GTK + miniatures wallpapers en mémoire
    -- pour que Alt+Space et Super+W ouvrent instantanément
    hl.exec_cmd("bash -c '~/.config/hypr/scripts/rofi-preload.sh &'")

    -- Noctalia (docs.noctalia.dev)
    hl.exec_cmd("noctalia &")
end)

hl.on("hyprland.shutdown", function()
    os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
    os.execute("pkill -f wayle 2>/dev/null")
    os.execute("pkill -f dunst 2>/dev/null")
end)
