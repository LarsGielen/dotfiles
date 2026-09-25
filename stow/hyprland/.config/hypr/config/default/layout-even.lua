-- Custom "even" tiling layout.  Register with hl.layout.register, use as "lua:even".
-- https://wiki.hypr.land/Configuring/Layouts/Custom-Layouts/
--
-- Windows share the workspace equally and always stay fully visible (no scrolling):
--     1 window  -> 100%
--     2 windows -> 50% / 50%
--     3 windows -> 33% each
-- Up to three they stack vertically (rows), which suits a portrait monitor.
-- From four on, rows get too thin, so it switches to a two-column panel grid:
--     4 windows -> 2x2
--     5 windows -> 2x2 with the fifth stretched full-width along the bottom
--     6 windows -> 2x3
--     ...
-- Opening or closing a window makes Hyprland re-run recalculate(), so it
-- re-balances automatically.
--
-- No manual resizing (yet): Hyprland discards the delta of a mouse-drag resize
-- before a Lua layout ever sees it, and custom layouts have no resize callback,
-- so per-window sizing isn't wired up.  Revisit if the engine grows a resize
-- hook for custom layouts.

local MAX_STACKED_ROWS = 3
local GRID_COLUMNS = 2

hl.layout.register("even", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        if n <= MAX_STACKED_ROWS then
            for i, target in ipairs(ctx.targets) do
                target:place(ctx:row(i, n))
            end
            return
        end

        local rows = math.ceil(n / GRID_COLUMNS)
        for i, target in ipairs(ctx.targets) do
            local is_lone_last = i == n and n % GRID_COLUMNS ~= 0
            if is_lone_last then
                -- An odd window out would leave an empty cell; give it the whole row.
                local area = ctx.area
                target:place({
                    x = area.x,
                    y = area.y + area.h * (rows - 1) / rows,
                    w = area.w,
                    h = area.h / rows,
                })
            else
                target:place(ctx:grid_cell(i, GRID_COLUMNS, rows))
            end
        end
    end,
})
