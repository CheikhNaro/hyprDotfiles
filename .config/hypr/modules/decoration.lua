-- General window behavior
layerrule = blur, rofi

hl.config({
    general = {
        gaps_in          = 2,
        gaps_out         = 0,
        border_size      = 0,
        -- Bordures désactivées (border_size = 0) — gradients conservés en commentaire
        -- col              = {
        --     active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
        --     inactive_border = "rgba(595959aa)",
        -- },
        resize_on_border = true,
        -- allow_tearing    = true, -- Désactivé (PC non-gaming)
        layout           = "dwindle",
        snap             = {
            enabled     = true,
            window_gap  = 10,
            monitor_gap = 10,
        },
    },
})

-- Window appearance
hl.config({
    decoration = {
        rounding         = 0,
        rounding_power   = 8,
        active_opacity   = 1.0,
        inactive_opacity = 0.85,
        shadow           = {
            enabled      = false,
            range        = 2,
            render_power = 2,
        },
        blur             = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            new_optimizations = true,
            vibrancy          = 0.0,
        },
    },
})

-- Dwindle layout configuration — spirale dans le sens des aiguilles d'une montre
-- force_split = 2 : toujours vers la droite/bas + alternance V→H→V automatique = horaire
hl.config({
    dwindle = {
        preserve_split               = true, -- conserve la direction du split après fermeture
        smart_split                  = false,
        smart_resizing               = false,
        use_active_for_splits        = true, -- le script pré-focus la bonne fenêtre
        permanent_direction_override = true, -- la direction forcée ne change pas
        force_split                  = 2,    -- 0=auto 1=gauche/haut 2=droite/bas (horaire)
        split_width_multiplier       = 1.0,
    },
})

-- Master layout : partage 50/50 équitable entre les deux premières fenêtres
hl.config({
    master = {
        mfact          = 0.5,     -- 50% maître / 50% slaves → partage équitable
        new_status     = "slave", -- toute nouvelle fenêtre arrive côté slave
        new_on_top     = true,    -- la nouvelle slave arrive en haut de la zone slave
        orientation    = "left",  -- fenêtre maître à gauche, slaves à droite
        smart_resizing = true,    -- le maître se redimensionne intelligemment
    },
})

-- Keybind behavior
hl.config({
    binds = {
        allow_workspace_cycles   = false,
        workspace_back_and_forth = true, -- SUPER+N deux fois = retour au workspace précédent
    },
})

-- Miscellaneous
hl.config({
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        -- vrr                      = 2, -- VRR/FreeSync en fullscreen uniquement (Désactivé, PC non-gaming)
        enable_swallow           = true,
        swallow_regex            = "^(wezterm|kitty|Alacritty)$",
        focus_on_activate        = true, -- transporte vers le workspace de l'app si elle est déjà ouverte
        render_unfocused_fps     = 15,   -- limite le rendu en arrière-plan (défaut = 15)
    },
})

-- Ecosystem
hl.config({
    ecosystem = {
        no_update_news = true, -- désactive le popup de mise à jour après pacman -Syu
    },
})

-- Rendu & performance
hl.config({
    render = {
        -- direct_scanout        = 2,    -- auto : active en fullscreen 'game' (réduit la latence) (Désactivé)
        new_render_scheduling = true, -- triple buffering auto, améliore les FPS sur laptop
    },
})

-- Curseur
hl.config({
    cursor = {
        hide_on_key_press        = false,
        inactive_timeout         = 10, -- cache le curseur après 10s d'inactivité
        -- no_break_fs_vrr          = 2,  -- évite les spikes FPS en fullscreen VRR (auto : actif si content type 'game')
        warp_on_change_workspace = 1,  -- le curseur suit la dernière fenêtre active du workspace
    },
})
