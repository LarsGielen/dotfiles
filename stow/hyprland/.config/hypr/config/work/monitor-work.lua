-- https://wiki.hypr.land/Configuring/Basics/Monitors/

local workspaces = require("config.lib.workspaces")

local primary   = "desc:iiyama Corporation PL2797Q 12328405B3274"
local secondary = "desc:iiyama Corporation PL2791Q 1153923421661"
local laptop    = "desc:BOE 0x093E"

hl.monitor({ output = primary,   mode = "preferred", position = "0x0",        scale = 1 })
hl.monitor({ output = secondary, mode = "preferred", position = "-1440x-560", scale = 1, transform =  1})
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = laptop })
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- The laptop screen is off while docked, but must come back when undocked or
-- there is no screen at all, so it follows the primary monitor's presence.
local function update_laptop()
    local docked = false
    for _, monitor in ipairs(hl.get_monitors()) do
        if "desc:" .. monitor.description == primary then
            docked = true
        end
    end
    hl.monitor({ output = laptop, mode = "preferred", position = "auto-right", scale = 1, disabled = docked })
end

update_laptop()
hl.on("monitor.added", update_laptop)
hl.on("monitor.removed", update_laptop)

workspaces.dual(primary, secondary)
