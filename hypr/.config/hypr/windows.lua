-- Personal window rules (restored from the pre-Quattro windowrules.conf).

-- Dedicated workspaces for apps.
o.window("brave-browser", { workspace = "1" })
-- Chat apps share workspace 2 and stay unfocused on autostart.
for _, class in ipairs({ "discord", "signal", "grok-bot" }) do
  o.window(class, { workspace = "2 silent", no_initial_focus = true, focus_on_activate = false })
end

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
