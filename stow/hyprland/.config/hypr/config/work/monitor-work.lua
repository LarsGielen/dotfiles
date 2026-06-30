-- https://wiki.hypr.land/Configuring/Basics/Monitors/

local primary   = "desc:Iiyama North America PL2797Q 12328405B3274"
local secondary = "desc:Iiyama North America PL2783Q 1143192701169"
local laptop    = "desc:BOE 0x093E"

hl.monitor({ output = primary,   mode = "preferred", position = "0x0",        scale = 1 })
hl.monitor({ output = secondary, mode = "preferred", position = "auto-right", scale = 1, transform = 3 })
hl.monitor({ output = laptop,    mode = "preferred", position = "auto-left",  scale = 1 })
hl.monitor({ output = "",        mode = "preferred", position = "auto",       scale = 1, mirror = "laptop" })

hl.workspace_rule({ workspace = "1", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "2", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "3", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "4", monitor = secondary, persistent = true, layout = "scrolling" })
hl.workspace_rule({ workspace = "5", monitor = secondary, persistent = true, layout = "scrolling" })
hl.workspace_rule({ workspace = "6", monitor = laptop,    persistent = true })
