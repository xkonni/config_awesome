-- Standard awesome library
local gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
wibox = require("wibox")
beautiful = require("beautiful")
naughty = require("naughty")
menubar = require("menubar")
scratch = require("scratch")
vicious = require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}


-- {{{ Variable definitions
-- get hostname, home and awesome directories
host  = awful.util.pread("hostname | tr -d '\n'")
home  = awful.util.pread("echo $HOME | tr -d '\n'")
config= awful.util.getdir("config")

-- Themes define colours, icons, and wallpapers
beautiful.init(config .. "/themes/solarized/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = 'termite'
terminal_class = 'Termite'
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = 'dwb'

timeout_tooltip = 1
timeout_short   = 3
timeout_medium  = 15
timeout_long    = 120
partitions = { "/" }

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    --awful.layout.suit.floating
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
    --awful.layout.suit.magnifier,
}

-- host overrides
if host == "silence" then
  BAT = "BAT1"
  local timeout_short   = 5
  local timeout_medium  = 20
  partitions = { "/", "/home", "/extra"}
elseif host == "annoyance" then
  MPD = { nil, localhost, nil }
  timeout_short   = 2
  timeout_medium  = 5
  partitions = { "/", "/home", "/extra", "/extra/src"}
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
require("functions")
require("tags")
require("menu")
require("widgets")
require("keybindings")
require("rules")
require("signals")
-- }}}

-- Autorun programs
awful.util.spawn(home .."/bin/autostart")
