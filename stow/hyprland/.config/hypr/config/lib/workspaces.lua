-- Workspace layout shared by the two-monitor desks: 1-3 on the main screen,
-- 4-5 on the portrait side screen with the "even" layout (layout-even.lua).
local M = {}

function M.dual(primary, secondary)
    for ws = 1, 3 do
        hl.workspace_rule({ workspace = tostring(ws), monitor = primary, persistent = true })
    end
    for ws = 4, 5 do
        hl.workspace_rule({ workspace = tostring(ws), monitor = secondary, persistent = true, layout = "lua:even" })
    end

    -- Visit 4 first so the side screen comes up on it, then settle on 1.
    hl.on("hyprland.start", function()
        hl.dispatch(hl.dsp.focus({ workspace = 4 }))
        hl.dispatch(hl.dsp.focus({ workspace = 1 }))
    end)
end

return M
