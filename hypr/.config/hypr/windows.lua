-- Personal window rules (restored from the pre-Quattro windowrules.conf).

-- Dedicated workspaces for apps.
o.window("brave-browser", { workspace = "1" })
-- Chat apps share workspace 2 and stay unfocused on autostart.
for _, class in ipairs({ "discord", "signal", "grok-bot" }) do
  o.window(class, { workspace = "2 silent", no_initial_focus = true, focus_on_activate = false })
end

-- Arrange workspace 2 as discord | grok | signal columns once all three are
-- open, then leave it as ordinary dwindle so the splits stay resizable. Dwindle
-- alone places them by whichever app maps first on boot. Weights are widths.
local chat_columns = {
  { class = "discord", weight = 0.521 },
  { class = "grok-bot", weight = 0.298 },
  { class = "signal", weight = 0.181 },
}

local function chat_windows()
  local by_class, tiled = {}, 0
  for _, window in ipairs(hl.get_workspace_windows("2")) do
    if not window.floating then
      by_class[window.class] = window
      tiled = tiled + 1
    end
  end
  if tiled ~= #chat_columns then return nil end
  for _, column in ipairs(chat_columns) do
    if not by_class[column.class] then return nil end
  end
  return by_class
end

local function target(window)
  return "address:" .. window.address
end

-- Expects the fresh dwindle tree that rebuild_chat leaves: one full-height
-- window beside a stacked pair. Turns it into discord | (grok | signal).
-- swapsplit and togglesplit only act on the focused window, so focus is
-- restored after.
local function arrange_chat(previous)
  local windows = chat_windows()
  if not windows then return end
  local discord, grok, signal = windows["discord"], windows["grok-bot"], windows["signal"]

  local single
  for _, window in pairs(windows) do
    if not single or window.size.y > single.size.y then single = window end
  end
  if single.address ~= discord.address then
    hl.dispatch(hl.dsp.window.swap({ window = target(discord), target = target(single) }))
  end
  windows = chat_windows()
  if windows["discord"].at.x > windows["grok-bot"].at.x then
    hl.dispatch(hl.dsp.focus({ window = target(discord) }))
    hl.dispatch(hl.dsp.layout("swapsplit"))
  end
  windows = chat_windows()
  if windows["grok-bot"].at.x == windows["signal"].at.x then
    hl.dispatch(hl.dsp.focus({ window = target(grok) }))
    hl.dispatch(hl.dsp.layout("togglesplit"))
  end
  windows = chat_windows()
  if windows["grok-bot"].at.x > windows["signal"].at.x then
    hl.dispatch(hl.dsp.window.swap({ window = target(grok), target = target(signal) }))
  end
  if previous then hl.dispatch(hl.dsp.focus({ window = target(previous) })) end

  -- A resize moves the window's right edge: discord sets the outer split,
  -- then grok the inner one.
  windows = chat_windows()
  local span = windows["signal"].at.x + windows["signal"].size.x - windows["discord"].at.x
  for i = 1, #chat_columns - 1 do
    local window = chat_windows()[chat_columns[i].class]
    hl.dispatch(hl.dsp.window.resize({ window = target(window), x = math.floor(span * chat_columns[i].weight), y = window.size.y }))
  end
end

-- Bouncing through another layout makes dwindle rebuild the workspace from
-- scratch, whatever splits it had. Rule changes land on the next tick.
local function rebuild_chat()
  if not chat_windows() then return end
  local previous = hl.get_active_window()
  hl.workspace_rule({ workspace = "2", layout = "master" })
  hl.timer(function()
    hl.workspace_rule({ workspace = "2", layout = "dwindle" })
    hl.timer(function() arrange_chat(previous) end, { timeout = 100, type = "oneshot" })
  end, { timeout = 100, type = "oneshot" })
end

local chat_classes = {}
for _, column in ipairs(chat_columns) do
  chat_classes[column.class] = true
end
hl.on("window.open", function(window)
  if window and chat_classes[window.class] then
    -- Give the window a moment to map and land on workspace 2.
    hl.timer(rebuild_chat, { timeout = 1500, type = "oneshot" })
  end
end)

-- Opt every window out of Omarchy's default opacity (0.985 active, 0.96
-- inactive, and 0.985 inactive for browsers). This also keeps Signal's
-- true-black OLED theme (see signal/signal-oled-patch) actually black.
o.window(".*", { tag = "-default-opacity", opacity = "1 1" })
o.window("fastpotify", { workspace = "3 silent" })

-- Steam: workspace 4, unfocused on autostart. Omarchy floats every steam
-- window by default (see default/hypr/apps/steam.lua) because the dialogs and
-- context menus tile badly, so only opt the two real windows back into tiling.
o.window({ class = "^steam$" }, { workspace = "4 silent", no_initial_focus = true, focus_on_activate = false })
o.window({ class = "^steam$", title = "^Steam$" }, { tile = true })
o.window({ class = "^steam$", title = "Friends List" }, { tile = true })
