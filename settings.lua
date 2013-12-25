awful = require("awful")
settings = {}
settings.terminal     = "xterm"
settings.editor       = os.getenv("EDITOR") or "nano"
settings.terminal_cmd = settings.terminal .. " -e "
settings.modkey       = "Mod4"
settings.theme        = "/usr/share/awesome/themes/default/theme.lua"
settings.layouts      = {
  --awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  --awful.layout.suit.fair,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.spiral,
  --awful.layout.suit.spiral.dwindle,
  --awful.layout.suit.max,
  --awful.layout.suit.max.fullscreen,
  --awful.layout.suit.magnifier
}
settings.tags = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }

settings.myawesomemenu = {
  { "manual",       settings.terminal_cmd .. " man awesome" },
  { "edit config",  settings.terminal_cmd .. settings.editor .. awesome.conffile },
  { "restart",      awesome.restart },
  { "quit",         awesome.quit } }

return settings
