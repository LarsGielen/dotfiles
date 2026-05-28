require("config.default.autostart")

hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.focus({ workspace = 4 }))
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end)
