local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local home    = os.getenv("HOME")
local dots    = home .. "/dotfiles"

hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("uwsm stop"))

hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("qs ipc call bar toggle"), { release = true })

---------------------------
--- Launch Applications ---
---------------------------

hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("uwsm app -- kitty"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("uwsm app -- kitty zsh -ic \"y; exec zsh\""))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("uwsm app -- vivaldi-stable --profile-directory=\"Default\""))
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd("rofi -show drun -run-command 'uwsm app -- {cmd}'"))
hl.bind("PRINT",                hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

-------------------------
--- WINDOW MANAGEMENT ---
-------------------------

-- Toggle between current and last-visited workspace
hl.bind(mainMod .. " + grave", hl.dsp.focus({ workspace = "previous" }))

hl.bind(mainMod .. " + C",         hl.dsp.window.close())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Snap with Master
hl.bind(mainMod .. " + mouse:274", hl.dsp.layout("swapwithmaster"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

----------------------
--- RESIZE SUBMAP ---
----------------------

local STEP = 40

hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("left",   hl.dsp.window.resize({ x = -STEP, y = 0,     relative = true }))
    hl.bind("right",  hl.dsp.window.resize({ x =  STEP, y = 0,     relative = true }))
    hl.bind("up",     hl.dsp.window.resize({ x = 0,     y = -STEP, relative = true }))
    hl.bind("down",   hl.dsp.window.resize({ x = 0,     y =  STEP, relative = true }))
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
end)
