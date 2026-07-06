-- Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Spring bounce : arrive vite (P1.x bas), dépasse la cible (P1.y > 1), settle proprement (P2.y = 1)
-- P1 = { 0.08, 1.32 } → impulsion initiale forte + overshoot 32%
-- P2 = { 0.38, 1.00 } → retour fluide sur la taille finale, sans traîner
hl.curve("bounce", { type = "bezier", points = { { 0.08, 1.32 }, { 0.38, 1.0 } } })

-- Global
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })

-- Courbe ultra-rapide pour l'effet "Allumage TV"
hl.curve("tv_on", { type = "bezier", points = { { 0.0, 1.0 }, { 0.0, 1.0 } } })
hl.curve("tv_off", { type = "bezier", points = { { 1.0, 0.0 }, { 1.0, 0.0 } } })

-- Windows (Boing In / Reverse Bounce Out)
hl.curve("boingOut", { type = "spring", mass = 1, stiffness = 80, dampening = 6 })
hl.animation({ leaf = "windows", enabled = true, speed = 4.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "bounce", style = "popin 0%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.0, spring = "boingOut", style = "popin 1%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.0, bezier = "bounce", style = "popin 0%" })

-- Fade
hl.animation({ leaf = "fade", enabled = true, speed = 4.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3.5, bezier = "easeOutQuint" })

-- Layers
hl.animation({ leaf = "layers", enabled = true, speed = 4.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4.0, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 4.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3.5, bezier = "easeOutQuint" })

-- Workspaces (Effet voiture qui freine)
hl.curve("carBrake", { type = "bezier", points = { { 0.1, 0.9 }, { 0.2, 1.0 } } })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5.0, bezier = "carBrake", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 5.0, bezier = "carBrake", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5.0, bezier = "carBrake", style = "slide" })

-- Special workspace (scratchpad)
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.0, bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4.0, bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "slidevert" })
-- Misc
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
