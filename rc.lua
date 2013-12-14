-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")
wibox = require("wibox")
beautiful = require("beautiful")
naughty = require("naughty")
menubar = require("menubar")
scratch = require("scratch")
vicious = require("vicious")

-- {{{ Variable definitions
-- get hostname, home and awesome directories
host    = awful.util.pread("hostname | tr -d '\n'")
home    = awful.util.pread("echo $HOME | tr -d '\n'")
config  = awful.util.getdir("config")

-- Themes define colours, icons, and wallpapers
beautiful.init(config .. "/themes/solarized/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = 'termite'
terminal_class = 'Termite'
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

timeout_tooltip = 1
timeout_short   = 3
timeout_medium  = 15
timeout_long    = 120
HDD = { "/" }
NET = { "eth0", "lo" }

-- Default modkey.
modkey = "Mod4"

-- host overrides
if host == "silence" then
  timeout_short   = 5
  timeout_medium  = 20
  BAT = "BAT1"
  HDD = { "/", "/home", "/extra"}
  NET = { "wlan0", "eth0", "lo"}
elseif host == "annoyance" then
  timeout_short   = 2
  timeout_medium  = 5
  HDD = { "/", "/home", "/extra", "/extra/src"}
  MPD = { nil, localhost, nil }
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ includes
require("error")
require("functions")
require("tags")
require("menu")
require("widgets")
require("keybindings")
require("rules")
require("signals")
-- }}}
