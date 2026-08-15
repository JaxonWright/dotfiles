-- Personal window rules (restored from the pre-Quattro windowrules.conf).

-- Dedicated workspaces for apps.
o.window("brave-browser", { workspace = "1" })
o.window("discord", { workspace = "2 silent" })
o.window("Spotify", { workspace = "3 silent" })

-- Steam: tiled on workspace 4.
o.window({ class = "^(steam)$" }, { workspace = "4 silent", tile = true })
o.window({ class = "steam", title = "Steam" }, { tile = true })
o.window({ class = "steam", title = "Friends List" }, { tile = true })
