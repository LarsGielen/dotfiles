-- Custom "even" tiling layout.  Register with hl.layout.register, use as "lua:even".
-- https://wiki.hypr.land/Configuring/Layouts/Custom-Layouts/
--
-- Windows share the workspace equally and always stay fully visible (no scrolling):
--     1 window  -> 100%
--     2 windows -> 50% / 50%
--     3 windows -> 33% each
--     ...
-- They stack vertically (rows), which suits a portrait monitor.  Opening or
-- closing a window makes Hyprland re-run recalculate(), so it re-balances
-- automatically.
--
-- No manual resizing (yet): Hyprland discards the delta of a mouse-drag resize
-- before a Lua layout ever sees it, and custom layouts have no resize callback,
-- so per-window sizing isn't wired up.  Revisit if the engine grows a resize
-- hook for custom layouts.

hl.layout.register("even", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        for i, target in ipairs(ctx.targets) do
            target:place(ctx:row(i, n))
        end
    end,
})
