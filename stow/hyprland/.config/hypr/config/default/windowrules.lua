-- Visual
hl.layer_rule({ match = { namespace = "rofi" },        blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "eww-sysmon" },  blur = true, ignore_alpha = 0 })

-- Notifications
hl.layer_rule({ match = { namespace = "swaync-control-center" },     blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.5 })

-- Floating
hl.window_rule({ match = { title = "Open File" }, float = true, center = true })
hl.window_rule({ match = { title = "Save File" }, float = true, center = true })
hl.window_rule({ match = { class = "thunar", title = ".*Rename.*" },           float = true, center = true })
hl.window_rule({ match = { class = "thunar", title = "File Operation Progress" }, float = true, center = true })

hl.window_rule({ match = { class = "steam", title = "Sign in to Steam" }, center = true })

-- General
-- Ignore maximize requests from apps.
-- hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland
hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Vivaldi: open in fake fullscreen, making it maximize inside a window
hl.window_rule({ match = { class = "vivaldi-stable" }, suppress_event = "fullscreen" })

-- File Picker
hl.window_rule({
    match = { class = "^(file_chooser)$" },
    float = true,
    center = true,
    size = { 1000, 650 },
})

-- Godot Engine
hl.window_rule({
    match = { class = "org.godotengine.Editor", title = ".*Please Confirm.*" },
    float = true,
    size = { 300, 100 },
    move = { "cursor_x-(monitor_w*0.5)", "cursor_y-(monitor_h*0.5)" },
})
hl.window_rule({
    match = { class = "org.godotengine.Editor", title = ".*Create Folder.*" },
    float = true,
    size = { 300, 300 },
    move = { "cursor_x-(monitor_w*0.5)", "cursor_y-(monitor_h*0.5)" },
})
hl.window_rule({
    match = { class = "org.godotengine.Editor", title = ".*Create New Scene.*" },
    float = true,
    size = { 660, 600 },
    center = true,
})
hl.window_rule({
    match = { class = "org.godotengine.Editor", title = ".*Create New Node.*" },
    float = true,
    size = { 900, 600 },
    center = true,
})

-- Steam UI
-- hl.window_rule({ match = { class = "steam" }, workspace = "special:steam silent" })

-- Game mode: toggle via SUPER + SHIFT + G (see bindings.lua).
-- When disabled, gamescope windows open as regular tiled windows.
-- local game_rules = {
--     hl.window_rule({ match = { class = "gamescope" },  tag = "+game" }),
--     hl.window_rule({ match = { tag = "game" }, workspace = "name:game silent" }),
--     hl.window_rule({ match = { tag = "game" }, fullscreen = true }),
--     hl.window_rule({ match = { tag = "game" }, tile = true }),
-- }
-- local game_enabled = true
-- _G.toggle_game_mode = function()
--     game_enabled = not game_enabled
--     for _, rule in ipairs(game_rules) do
--         rule:set_enabled(game_enabled)
--     end
--     hl.exec_cmd("notify-send 'Game mode " .. (game_enabled and "on" or "off") .. "'")
-- end
