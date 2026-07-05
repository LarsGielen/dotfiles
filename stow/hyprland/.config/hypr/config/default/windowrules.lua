-- Quickshell modal overlays (launcher / session menu / auth prompt)
hl.layer_rule({ match = { namespace = "quickshell-overlay" }, blur = true, ignore_alpha = 0.4 })

-- Floating
hl.window_rule({ match = { title = "Open File" }, float = true, center = true })
hl.window_rule({ match = { title = "Save File" }, float = true, center = true })
hl.window_rule({ match = { class = "thunar", title = ".*Rename.*" },           float = true, center = true })
hl.window_rule({ match = { class = "thunar", title = "File Operation Progress" }, float = true, center = true })

hl.window_rule({ match = { class = "steam", title = "Sign in to Steam" }, center = true })

-- General
-- Ignore maximize requests from apps.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

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
