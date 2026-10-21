-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- v0.56.0 made the spring simulation more accurate, which makes old spring
-- configs feel much slower; these values restore the pre-0.56 "easy" feel
-- (see https://github.com/hyprwm/Hyprland/discussions/15495)
hl.curve("easy", { type = "spring", mass = 1, stiffness = 878.5, dampening = 59.29 })

-- Speeds are in deciseconds: everything lands within ~300ms to stay snappy.
hl.animation({ leaf = "global",         enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",         enabled = true, speed = 4,    bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",        enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",      enabled = true, speed = 3,    bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",     enabled = true, speed = 2,    bezier = "quick",        style = "popin 85%" })
hl.animation({ leaf = "fadeIn",         enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",        enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",           enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",         enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",       enabled = true, speed = 3,    bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "layersOut",      enabled = true, speed = 1.5,  bezier = "quick",        style = "fade" })
hl.animation({ leaf = "fadeLayersIn",   enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",  enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",     enabled = true, speed = 3,    bezier = "easeOutQuint", style = "slidefade 15%" })
