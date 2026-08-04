-- https://wiki.hypr.land/Configuring/Basics/Monitors/

local primary   = "desc:AOC CU34G2XP 1Q1R2HA002745"
local secondary = "desc:Samsung Electric Company S24R35x H4TM800282"

-- Secondary is rotated 90deg (transform = 1), so its logical size is 1080x1920.
-- Its physical pixels are coarser than the primary's (3.62 vs 4.36 px/mm on the
-- vertical axis), so the pointer can only line up physically at one height --
-- matching them would need scale ~0.83, which is not worth the blurrier text.
-- Tuned so the handover is correct around the middle of the screen; lower the
-- number to push the secondary up, raise it to pull it down.
local secondary_y = -201

hl.monitor({ output = primary,   mode = "3440x1440@180.00", position = "0x0", scale = 1 })
hl.monitor({
  output    = secondary,
  mode      = "preferred",
  position  = "-1080x" .. secondary_y,
  scale     = 1,
  transform = 1,
})
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "2", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "3", monitor = primary,   persistent = true })
hl.workspace_rule({ workspace = "4", monitor = secondary, persistent = true, layout = "lua:even" })
hl.workspace_rule({ workspace = "5", monitor = secondary, persistent = true, layout = "lua:even" })

hl.workspace_rule({ workspace = "special:Game", monitor = primary, persistent = false, layout = "monocle" })
