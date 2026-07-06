-- Launch applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("flatpak run org.gnome.Calculator"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("wezterm start yazi"))
-- hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + b", hl.dsp.exec_cmd("flatpak run re.sonny.Junction"))
hl.bind(mainMod .. " + 2", hl.dsp.exec_cmd("~/Applications/zen.appimage"))
hl.bind(mainMod .. " + m", hl.dsp.exec_cmd("~/Applications/thunderbird/thunderbird"))
hl.bind(mainMod .. " + q", hl.dsp.exec_cmd("flatpak run org.gtaf.quran"))
hl.bind(mainMod .. " + s", hl.dsp.exec_cmd("flatpak run com.spotify.Client"))
hl.bind(mainMod .. " + t", hl.dsp.exec_cmd("~/Applications/Telegram/Telegram"))
hl.bind(mainMod .. " + d",
    hl.dsp.exec_cmd("~/.config/discord/Discord --enable-features=UseOzonePlatform --ozone-platform=wayland"))
hl.bind(mainMod .. " + y", hl.dsp.exec_cmd("~/.config/hypr/scripts/ocr.sh"))
hl.bind(mainMod .. " + l", hl.dsp.exec_cmd("/usr/bin/wlogout -b 5"))
hl.bind(mainMod .. " + x",
    hl.dsp.exec_cmd(
        "bash -c 'color=$(hyprpicker -a) && notify-send -u low -h int:suppress-sound:1 -a \"hyprpicker\" -i color-select \"Color picked\" \"$color\"'"))
hl.bind(mainMod .. " + w", hl.dsp.exec_cmd("bash -c $HOME/.config/rofi/wallpaper-select.sh"))
hl.bind(mainMod .. " + i",
    hl.dsp.exec_cmd(
        "bash -c 'if hyprctl clients | grep -iq wayle; then hyprctl dispatch focuswindow \"^(.*[Ww]ayle.*)\"; else ~/.cargo/bin/wayle-settings; fi'"))

-- Close window
hl.bind("CTRL + Q", hl.dsp.window.close())



-- Application launcher (rofi)
hl.bind("ALT + Space", hl.dsp.exec_cmd("bash $HOME/.config/rofi/rofi-dropdown.sh"))

-- Snappy Switcher (Alt+Tab)
hl.bind("ALT + Tab", hl.dsp.exec_cmd("snappy-switcher next --mod alt"))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("snappy-switcher next --workspace --mod super"))

-- Toggle floating — resize+center uniquement à l'aller (→ floating)
-- Au retour (→ tiled) : reset de la taille pour que Hyprland redistribue équitablement
hl.bind(mainMod .. " + f", function()
    local win = hl.get_active_window()
    local is_floating = win and win.floating

    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))

    if is_floating then
        -- Retour en tiled : force Hyprland à redistribuer l'espace équitablement
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch resizewindowpixel exact 0 0,address:" .. (win and win.address or "")))
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch layoutmsg reset"))
    else
        -- Passage en floating : centrage + taille confortable
        local m = hl.get_active_monitor()
        hl.dispatch(hl.dsp.window.resize({ x = math.floor(m.width * 0.75), y = math.floor(m.height * 0.7) }))
        hl.dispatch(hl.dsp.window.center())
    end
end)
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/toggle-monitor.sh"))

-- Maximize / restorezz
hl.bind(mainMod .. " + up", hl.dsp.window.fullscreen_state({ internal = 1, client = 0, action = "set" }))
hl.bind(mainMod .. " + down", hl.dsp.window.fullscreen_state({ internal = 0, client = 0, action = "set" }))

-- Focus direction
hl.bind("ALT + left", hl.dsp.focus({ direction = "left" }))
hl.bind("ALT + right", hl.dsp.focus({ direction = "right" }))
hl.bind("ALT + up", hl.dsp.focus({ direction = "up" }))
hl.bind("ALT + down", hl.dsp.focus({ direction = "down" }))

-- Swap de fenêtres tuilées (échange la fenêtre active avec sa voisine)
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.swap({ direction = "d" }))

-- Snap floating window to half screen
hl.bind(mainMod .. " + SHIFT + left", function()
    local m = hl.get_active_monitor()
    hl.dispatch(hl.dsp.window.move({ x = m.x, y = m.y }))
    hl.dispatch(hl.dsp.window.resize({ x = math.floor(m.width / 2), y = m.height }))
end)
hl.bind(mainMod .. " + SHIFT + right", function()
    local m = hl.get_active_monitor()
    local half = math.floor(m.width / 2)
    hl.dispatch(hl.dsp.window.move({ x = m.x + half, y = m.y }))
    hl.dispatch(hl.dsp.window.resize({ x = half, y = m.height }))
end)

-- Switch workspaces (1-10)
for i = 1, 10 do
    local key = i % 10
    if key ~= 2 then
        hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    end
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + H", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ workspace = "special:magic" }))

-- Navigate workspaces with scroll wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.exec_cmd("~/.config/hypr/scripts/scroll_workspaces.sh next"))
hl.bind(mainMod .. " + mouse_up", hl.dsp.exec_cmd("~/.config/hypr/scripts/scroll_workspaces.sh prev"))

-- Navigate workspaces with Page Up / Page Down
hl.bind(mainMod .. " + page_down", hl.dsp.exec_cmd("~/.config/hypr/scripts/scroll_workspaces.sh next"))
hl.bind(mainMod .. " + page_up", hl.dsp.exec_cmd("~/.config/hypr/scripts/scroll_workspaces.sh prev"))
hl.bind(mainMod .. " + SHIFT + page_down", hl.dsp.exec_cmd("~/.config/hypr/scripts/scroll_workspaces.sh next move"))
hl.bind(mainMod .. " + SHIFT + page_up", hl.dsp.exec_cmd("~/.config/hypr/scripts/scroll_workspaces.sh prev move"))

-- Resize submap
hl.bind("CTRL + SHIFT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("mouse:272", hl.dsp.submap("reset"), { mouse = true })
end)

-- Mouse drag / resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("bash $HOME/.config/hypr/scripts/swayosd-custom.sh vol-up"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("bash $HOME/.config/hypr/scripts/swayosd-custom.sh vol-down"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("bash $HOME/.config/hypr/scripts/swayosd-custom.sh vol-mute"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("bash $HOME/.config/hypr/scripts/swayosd-custom.sh mic-mute"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("bash $HOME/.config/hypr/scripts/swayosd-custom.sh br-up"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("bash $HOME/.config/hypr/scripts/swayosd-custom.sh br-down"),
    { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Capture d'écran & Enregistrement — menu style GNOME
-- PrtScr : ouvre le menu (ou arrête l'enregistrement en cours)
hl.bind("Print", hl.dsp.exec_cmd("bash -c '$HOME/.config/hypr/scripts/hyprscreenshot.sh'"))

-- Emoji picker (HyprEmoji)
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("~/.local/bin/hypremoji"))

-- Clipboard history (clipse-gui)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("clipse-gui"))

-- Recharger la configuration
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
