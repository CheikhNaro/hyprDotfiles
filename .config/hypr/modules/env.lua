-- Curseurs (uniformisés à 48 partout)
hl.env("XCURSOR_THEME",    "volantes")
hl.env("XCURSOR_SIZE",     "48")
hl.env("HYPRCURSOR_THEME", "volantes")
hl.env("HYPRCURSOR_SIZE",  "48")

-- Toolkit backends Wayland et QT
hl.env("GDK_BACKEND",                          "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",                      "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION",  "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",          "1")
hl.env("QT_QPA_PLATFORMTHEME",                 "qt6ct") -- ou qt6ct selon ton installation

-- Specs XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Applications tierces (Firefox, Electron, Jeux, GTK)
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GTK_USE_PORTAL", "1")

-- GNOME Keyring (SSH Agent)
hl.env("SSH_AUTH_SOCK", "$XDG_RUNTIME_DIR/keyring/ssh")
