-- Détection dynamique des moniteurs physiquement connectés
local function get_active_monitors()
    local monitors = {}
    -- On interroge le kernel pour savoir quels écrans sont branchés (même avant que Hyprland soit totalement lancé)
    local handle = io.popen(
    "for f in /sys/class/drm/*/status; do if [ \"$(cat $f 2>/dev/null)\" = \"connected\" ]; then echo $f; fi; done")
    if handle then
        local result = handle:read("*a")
        handle:close()
        for line in result:gmatch("[^\r\n]+") do
            -- Extrait "eDP-1" de "/sys/class/drm/card1-eDP-1/status"
            local mon = line:match("card%d+-(.-)/status")
            if mon then
                table.insert(monitors, mon)
            end
        end
    end
    -- Fallback si rien n'est détecté
    if #monitors == 0 then
        table.insert(monitors, "")
    end
    return monitors
end

local active_monitors = get_active_monitors()

-- Assigne 5 workspaces persistants pour chaque moniteur connecté
for m_idx, mon in ipairs(active_monitors) do
    local start_ws = (m_idx - 1) * 5 + 1
    local end_ws = m_idx * 5

    for i = start_ws, end_ws do
        local rule = {
            workspace  = tostring(i),
            persistent = true,
            default    = (i == start_ws),
        }
        if mon ~= "" then
            rule.monitor = mon
        end
        hl.workspace_rule(rule)
    end
end



-- Satty (screenshot annotation)
hl.window_rule({
    name      = "float-satty",
    match     = { class = "^(com\\.gabm\\.satty)$" },
    float     = true,
    center    = true,
    size      = { 1920, 1080 },
    animation = "none",
})
-- Float specific applications
hl.window_rule({
    name  = "float-clipse-gui",
    match = { title = "^(Clipse GUI)$" },
    float = true,
    move  = "cursor -50% -50%",
    size  = { 600, 700 },
})
hl.window_rule({
    name            = "float-system-monitor",
    match           = { initial_class = "org.gnome.SystemMonitor" },
    float           = true,
    center          = false,
    persistent_size = true,
    suppress_event  = "maximize",    -- empêche la system monitor de s'ouvrir maximisée
    size            = { 1000, 900 }, -- taille flottante par défaut
})
hl.window_rule({
    name            = "float-wayle-settings-class",
    match           = { initial_class = ".*[Ww]ayle.*" },
    float           = true,
    center          = true,
    persistent_size = true,
    suppress_event  = "maximize",
    size            = { 1200, 800 },
})
hl.window_rule({
    name            = "float-Spotify",
    match           = { initial_class = "Spotify" },
    float           = true,
    center          = true,
    persistent_size = true,
    suppress_event  = "maximize",
    size            = { 1600, 900 },
})
hl.window_rule({
    name   = "float-wayle-settings-title",
    match  = { title = ".*[Ww]ayle.*[Ss]ettings.*" },
    float  = true,
    center = true,
    size   = { 800, 600 },
})
hl.window_rule({
    name            = "float-calculator",
    match           = { initial_class = "org.gnome.Calculator" },
    float           = true,
    center          = true,
    persistent_size = true,
    suppress_event  = "maximize",   -- empêche la calculatrice de s'ouvrir maximisée
    size            = { 420, 600 }, -- taille flottante par défaut
})
hl.window_rule({
    name            = "float-horloge",
    match           = { initial_class = "org.gnome.clocks" },
    float           = true,
    center          = true,
    persistent_size = true,
    suppress_event  = "maximize",   -- empêche la calculatrice de s'ouvrir maximisée
    size            = { 420, 600 }, -- taille flottante par défaut
})
hl.window_rule({
    name            = "float-amberol",
    match           = { initial_class = "io.bassi.Amberol" },
    float           = true,
    center          = false,
    persistent_size = true,
    suppress_event  = "maximize",   -- empêche la calculatrice de s'ouvrir maximisée
    size            = { 450, 700 }, -- taille flottante par défaut
})
hl.window_rule({
    name            = "float-gnome-Notes",
    match           = { initial_class = "org.gnome.Notes" },
    float           = true,
    center          = false,
    persistent_size = true,
    suppress_event  = "maximize",   -- empêche la gnome notes de s'ouvrir maximisée
    size            = { 700, 600 }, -- taille flottante par défaut
})

hl.window_rule({
    name            = "float-localsend",
    match           = { initial_class = "localsend_app" },
    float           = true,
    center          = true,
    persistent_size = true,
    suppress_event  = "maximize",
    size            = { 450, 700 },
})

hl.window_rule({
    name            = "float-nautilus",
    match           = { class = "org.gnome.Nautilus" },
    float           = true,
    center          = true,
    persistent_size = true,
    suppress_event  = "maximize",
    size            = { 1000, 720 },
})
hl.window_rule({
    name            = "float-protonmail",
    match           = { class = "chrome-jnpecgipniidlgicjocehkhajgdnjekh-Default" },
    float           = true,
    center          = true,
    persistent_size = true,
    suppress_event  = "maximize",
    size            = { 1200, 900 },
})

hl.window_rule({
    name            = "float-junction",
    match           = { class = "re.sonny.Junction" },
    float           = true,
    center          = true,
    persistent_size = true,
})

-- HyprEmoji (emoji picker)
hl.window_rule({
    name  = "hypremoji",
    match = { title = "^(HyprEmoji)$" },
    float = true,
    move  = "cursor -50% -5%",
})

-- Screenshot Palette (GTK4, positionnée via layer-shell)
hl.layer_rule({ match = { namespace = "^(screenshot%-palette)$" }, animation = "popin 80%" })

-- Global rules
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- Tearing pour les jeux (active allow_tearing du côté fenêtre)
hl.window_rule({
    name      = "tearing-games",
    match     = { content = "game" },
    immediate = true,
})

-- Inhibition d'inactivité pour les médias (empêche la mise en veille)
hl.window_rule({ name = "idle-inhibit-mpv", match = { class = "mpv" }, idle_inhibit = "fullscreen" })
hl.window_rule({ name = "idle-inhibit-vlc", match = { class = "vlc" }, idle_inhibit = "fullscreen" })
hl.window_rule({ name = "idle-inhibit-spotify", match = { class = "spotify" }, idle_inhibit = "focus", pin = false })
hl.window_rule({ name = "idle-inhibit-spotify-init", match = { initial_class = "Spotify" }, pin = false })
hl.window_rule({ name = "no-fullscreen-spotify", match = { class = "spotify" }, suppress_event = "maximize, fullscreen" })

-- Désactiver le blur sur les apps qui n'en ont pas besoin (économie GPU)
hl.window_rule({ name = "no-blur-zen", match = { class = "zen" }, no_blur = true })
hl.window_rule({ name = "no-blur-discord", match = { class = "discord" }, no_blur = true })
hl.window_rule({ name = "no-blur-telegram", match = { class = "telegram" }, no_blur = true })

-- Layer rules : blur pour la topbar Quickshell
-- (vérifier le namespace exact avec : hyprctl layers)
hl.layer_rule({ match = { namespace = "quickshell" }, blur = true, ignore_alpha = 0.5 })

-- Affichage instantané de snappy-switcher (désactive le fade-in de Hyprland)
hl.layer_rule({ match = { namespace = "snappy-switcher" }, no_anim = true })

-- Désactiver l'animation pour les outils de capture d'écran et color picker
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "slurp" }, no_anim = true })
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })

-- Apparition au centre pour rofi (fade) car Hyprland ne peut pas "dérouler" seulement le bas d'une fenêtre centrée
hl.layer_rule({ match = { namespace = "^(rofi)$" }, animation = "fade" })

-- Animation pour wlogout
hl.layer_rule({ match = { namespace = "^(logout_dialog)$" }, animation = "popin 80%" })
