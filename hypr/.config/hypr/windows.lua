-- Personal window rules (restored from the pre-Quattro windowrules.conf).

-- Dedicated workspaces for apps.
o.window("brave-browser", { workspace = "1" })
-- Chat apps share workspace 2 and stay unfocused on autostart.
for _, class in ipairs({ "discord", "signal", "grok-bot" }) do
  o.window(class, { workspace = "2 silent", no_initial_focus = true, focus_on_activate = false })
end

-- Workspace 2 tiles the chat apps as fixed columns, ordered by class rather
-- than by whichever app happens to map first on boot. Weights are relative
-- widths; any other window gets an average share and goes on the right.
local chat_columns = {
  { class = "discord", weight = 0.522 },
  { class = "grok-bot", weight = 0.299 },
  { class = "signal", weight = 0.179 },
}
hl.layout.register("chat", {
  recalculate = function(ctx)
    local order, weight = {}, {}
    for i, column in ipairs(chat_columns) do
      order[column.class], weight[column.class] = i, column.weight
    end

    local targets = {}
    for _, target in ipairs(ctx.targets) do
      targets[#targets + 1] = target
    end
    local function class_of(target)
      return target.window and target.window.class or ""
    end
    table.sort(targets, function(a, b)
      local oa, ob = order[class_of(a)] or math.huge, order[class_of(b)] or math.huge
      if oa ~= ob then return oa < ob end
      return a.index < b.index
    end)

    local total = 0
    for _, target in ipairs(targets) do
      total = total + (weight[class_of(target)] or 1 / #chat_columns)
    end
    local x = ctx.area.x
    for i, target in ipairs(targets) do
      local w = ctx.area.w * (weight[class_of(target)] or 1 / #chat_columns) / total
      if i == #targets then w = ctx.area.x + ctx.area.w - x end
      target:place({ x = x, y = ctx.area.y, w = w, h = ctx.area.h })
      x = x + w
    end
  end,
})
hl.workspace_rule({ workspace = "2", layout = "lua:chat" })

-- Signal is patched to a true-black OLED theme (see signal/signal-oled-patch),
-- so opt it out of Omarchy's default window opacity: at 0.96 the wallpaper
-- shows through and the background is no longer actually black.
o.window("signal", { tag = "-default-opacity", opacity = "1 1" })
o.window("fastpotify", { workspace = "3 silent" })

-- Steam: workspace 4, unfocused on autostart. Omarchy floats every steam
-- window by default (see default/hypr/apps/steam.lua) because the dialogs and
-- context menus tile badly, so only opt the two real windows back into tiling.
o.window({ class = "^steam$" }, { workspace = "4 silent", no_initial_focus = true, focus_on_activate = false })
o.window({ class = "^steam$", title = "^Steam$" }, { tile = true })
o.window({ class = "^steam$", title = "Friends List" }, { tile = true })
