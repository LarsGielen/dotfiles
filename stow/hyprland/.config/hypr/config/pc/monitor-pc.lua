-- https://wiki.hypr.land/Configuring/Basics/Monitors/

local primary   = "desc:AOC CU34G2XP 1Q1R2HA002745"
local secondary = "desc:Samsung Electric Company S24R35x H4TM800282"

hl.monitor({ output = primary,   mode = "3440x1440@180.00", position = "0x0",       scale = 1 })
hl.monitor({ output = secondary, mode = "preferred",        position = "auto-left", scale = 1, transform = 1 })
hl.monitor({ output = "",        mode = "preferred",        position = "auto",      scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "2", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "3", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "4", monitor = secondary, persistent = true, layout = "scrolling" })
hl.workspace_rule({ workspace = "5", monitor = secondary, persistent = true, layout = "scrolling" })

hl.workspace_rule({ workspace = "special:Game", monitor = primary, persistent = false, layout = "monocle" })
