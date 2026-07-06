-- Keyboard and touchpad
hl.config({
    input = {
        kb_layout    = "ch",
        kb_variant   = "fr",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",
        follow_mouse = 1,
        repeat_rate  = 100,
        repeat_delay = 300,
        sensitivity  = 0.5,
        touchpad     = {
            natural_scroll = true,
        },
    },
})

-- Touchpad gesture
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Per-device configuration
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})