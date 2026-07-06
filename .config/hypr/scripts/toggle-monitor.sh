#!/bin/bash
FILE="$HOME/.config/hypr/modules/monitors.lua"

if grep -q 'mirror' "$FILE"; then
    # Passe en mode ÉTENDU
    cat > "$FILE" << 'EOF'
-- Écran intégré du laptop
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- Moniteur externe HDMI (Étendu)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1680x1050@60",
    position = "1920x0",
    scale    = 1,
})

-- Fallback : tout autre moniteur branché (auto)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
EOF
    notify-send -u low "Écrans" "Mode: Étendu (Moniteur à droite)"
else
    # Passe en mode MIROIR
    cat > "$FILE" << 'EOF'
-- Écran intégré du laptop
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- Moniteur externe HDMI (Miroir)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1680x1050@60",
    position = "auto",
    scale    = 1,
    mirror   = "eDP-1",
})

-- Fallback : tout autre moniteur branché (auto)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
EOF
    notify-send -u low "Écrans" "Mode: Miroir (Écran dupliqué)"
fi

hyprctl reload
