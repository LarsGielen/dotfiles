-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    misc = {
        -- 0 off, 1 always, 2 fullscreen only. Fullscreen-only keeps adaptive
        -- sync off the desktop and off panels that do not support it.
        vrr = 2,
    },

    render = {
        -- 0 off, 1 on, 2 auto (only windows tagged content = "game").
        -- Hyprland already requires a solitary fullscreen window before it will
        -- scan out, so 1 is safe and avoids depending on clients tagging
        -- themselves -- XWayland games under Proton do not.
        direct_scanout = 1,
    },
})
