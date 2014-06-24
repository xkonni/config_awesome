awful = require("awful")

settings = {}
settings.config       = awful.util.getdir("config")
settings.home         = awful.util.pread("echo $HOME | tr -d '\n'")
settings.host         = awful.util.pread("hostname | tr -d '\n'")
settings.terminal     = "urxvt"
settings.editor       = "vim"
settings.filemanager  = "thunar"
settings.terminal_cmd = settings.terminal .. " -e "
settings.modkey       = "Mod4"
settings.theme        = settings.config .. "/themes/solarized/theme.lua"
settings.timeout      = 3
settings.notify       = 1

-- host overrides
if settings.host == "annoyance" then
  settings.interface    = "eth0"
  settings.mpd = 1
elseif settings.host == "silence" then
  settings.timeout = 5
  settings.interface = "wlan0"
  settings.battery  = "BAT1"
elseif settings.host == "ns3knecht" then
  settings.timeout = 1
  settings.notify = 0
end

layouts = require("layouts")
layouts.termfair.nmaster = 3
layouts.termfair.ncol = 1
layouts.centerfair.nmaster = 2
layouts.centerfair.ncol = 1

settings.layouts      = {
  --awful.layout.suit.floating,
  --layouts.cascade,
  --layouts.cascadetile,
  --layouts.centerfair,
  --layouts.termfair,
  --layouts.uselessfair,
  --layouts.uselesspiral,
  layouts.uselesstile,
  layouts.uselesstile.left,
  layouts.uselesstile.bottom,
  layouts.uselesstile.top,
  layouts.centerwork,
  --awful.layout.suit.tile,
  --awful.layout.suit.tile.left,
  --awful.layout.suit.tile.bottom,
  --awful.layout.suit.tile.top,
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
  { "switch user",  "dm-tool switch-to-greeter"},
  { "restart",      awesome.restart },
  { "quit",         awesome.quit } }

return settings
