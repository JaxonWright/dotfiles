-- Personal window rules (restored from the pre-Quattro windowrules.conf).

-- Dedicated workspaces for apps.
o.window("brave-browser", { workspace = "1" })
o.window("discord", { workspace = "2 silent", no_initial_focus = true })
o.window("fastpotify", { workspace = "3 silent" })

-- Steam: workspace 4, unfocused on autostart. Omarchy floats every steam
-- window by default (see default/hypr/apps/steam.lua) because the dialogs and
-- context menus tile badly, so only opt the two real windows back into tiling.
o.window({ class = "^steam$" }, { workspace = "4 silent", no_initial_focus = true })
o.window({ class = "^steam$", title = "^Steam$" }, { tile = true })
o.window({ class = "^steam$", title = "Friends List" }, { tile = true })
