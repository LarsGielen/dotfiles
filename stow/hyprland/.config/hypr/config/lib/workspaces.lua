-- Workspace layout shared by the two-monitor desks: 1-3 on the main screen,
-- 4-5 on the portrait side screen with the "even" layout (layout-even.lua).
local M = {}

-- `default` marks the workspace a monitor opens on when it connects; without it
-- Hyprland picks the first free ID (7), which also happens on dock hotplug.
function M.dual(primary, secondary)
    for ws = 1, 3 do
        hl.workspace_rule({ workspace = tostring(ws), monitor = primary, persistent = true, default = ws == 1 })
    end
    for ws = 4, 5 do
        hl.workspace_rule({ workspace = tostring(ws), monitor = secondary, persistent = true, default = ws == 4, layout = "lua:even" })
    end
end

return M
