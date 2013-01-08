-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library - need global access
naughty = require("naughty")
local menubar = require("menubar")
-- Widgets
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

-- {{{ Host specific
-- get hostname, home and awesome directories
host  = awful.util.pread("hostname | tr -d '\n'")
home  = awful.util.pread("echo $HOME | tr -d '\n'")
config= awful.util.getdir("config")

-- default values
local timeout_short  = 3
local timeout_medium = 15
local timeout_long   = 60
local cores = 2
local partitions = { "/", "/home"}

-- host overrides
if host == "silence" then
  BAT = "BAT1"
  laptop = 1
  partitions = { "/", "/home", "/extra"}
elseif host == "remembrance" then
  BAT = "BAT0"
  laptop = 1
  partitions = { "/", "/home", "/extra"}
elseif host == "annoyance" then
  timeout_short  = 1
  timeout_medium = 5
  timeout_long   = 60
  cores = 8
  partitions = { "/", "/home", "/extra", "/extra/src"}
end
-- }}} Host specific

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(config .. "/themes/solarized/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = 'urxvt'
terminal_class = 'URxvt'
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Functions
-- create an arrow as transition between fg and bg color
function mwidget_arrow(fg, bg, direction)
  local widget_bg = wibox.widget.background()
  local widget_fg = wibox.widget.textbox()

  local arrow="|"
  if direction == "cleft"   then arrow = "⮃" end
  if direction == "cright"  then arrow = "⮁" end
  if direction == "left"   then arrow = "⮂" end
  if direction == "right"  then arrow = "⮀" end

  widget_fg:set_font("Anonymous Pro for Powerline 18")
  widget_fg:set_markup("<span color=\"".. fg .. "\">".. arrow .."</span>")
  widget_bg:set_bg(bg)

  widget_bg:set_widget(widget_fg)
  return widget_bg
end

function mwidget_icon(symbol)
  local mwidget_icon = wibox.widget.textbox()
  mwidget_icon:set_font("Anonymous Pro for Powerline 14")
  mwidget_icon:set_text(symbol)
  return mwidget_icon
end

-- color the background of a widget
function mwidget_bg(bg, widget)
  local widget_bg = wibox.widget.background()
  widget_bg:set_bg(bg)
  widget_bg:set_widget(widget)
  return widget_bg
end

-- return a string with fixed length
-- cut off at the end of filled with
-- whitespaces at the beginning
function prettystring(str, length, fill, center)
  if string.len(str) > length then
    str=string.sub(str, 1, length-1).."…"
  elseif fill then
    local num=length-string.len(str)
    if center then
      local left = math.floor(num/2)
      local right = num-left
      str = string.rep(fill, left)..str..string.rep(fill, right)
    else
      str = string.rep(fill, num)..str
    end
  end
  return str
end

-- test if window floats
function floats(c)
  local ret = false
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
    ret = true
  end
  return ret
end

function titlebar_enable(c)
  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(awful.titlebar.widget.iconwidget(c))

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(awful.titlebar.widget.floatingbutton(c))
  right_layout:add(awful.titlebar.widget.maximizedbutton(c))
  right_layout:add(awful.titlebar.widget.stickybutton(c))
  right_layout:add(awful.titlebar.widget.ontopbutton(c))
  right_layout:add(awful.titlebar.widget.closebutton(c))

  -- The title goes in the middle
  local title = awful.titlebar.widget.titlewidget(c)
  title:buttons(awful.util.table.join(
          awful.button({ }, 1, function()
              client.focus = c
              c:raise()
              awful.mouse.client.move(c)
          end),
          awful.button({ }, 3, function()
              client.focus = c
              c:raise()
              awful.mouse.client.resize(c)
          end)
          ))

  -- Now bring it all together
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)
  layout:set_middle(title)

  awful.titlebar(c):set_widget(layout)
end

function titlebar_disable(c)
  awful.titlebar(c, {size=0})
end
-- }}} Functions

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myusermenu = {
   { "reconfigure", awesome.restart },
   { "logout", awesome.quit },
   { "login trixi", "dm-tool switch-to-user trixi" },
 }
myappmenu = {
   { "terminal", terminal }
 }
mylogoutmenu = {
   { "suspend", "systemctl suspend"},
   { "hibernate", "systemctl hibernate"},
   { "reboot", "systemctl reboot"},
   { "shutdown", "systemctl shutdown"}
}

mymainmenu = awful.menu({ items = {
                                    { "user", myusermenu },
                                    { "app", myappmenu },
                                    { "system", mylogoutmenu }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a separator widget with a fixed width
sep = wibox.widget.base.empty_widget()
sep.fit = function() return 3, 8 end

-- Create a clock widget
widget_clock = awful.widget.textclock(" %d %b %Y %H:%M ")
tooltip_clock = awful.tooltip({ objects = { widget_clock }})
tooltip_clock:set_text("bla")
timer_clock = timer({ timeout = timeout_long })
timer_clock:connect_signal("timeout", function()
  local title = os.date("%A %d %B %Y")
  local len = string.len(title)+2
  local text
  text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
         " "..string.rep("-", len).." \n"
         --" Time <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..prettystring(os.date("%H:%M"), 18, " ").." </span>\n"..
         --" Date <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..prettystring(os.date("%a %b %d %Y"), 18, " ").." </span>"
  local day = awful.util.pread("date +%d | sed 's/^0/ /' | tr -d '\n'")
  local date = awful.util.pread("cal | sed '1d;$d;s/^/   /;s/$/ /;s:"..day..":<span weight=\"bold\" color=\""..theme.fg_normal.."\">"..day.."</span>:'")
  date = " "..date.." "
  text = text..date
  tooltip_clock:set_text(text)
end)
timer_clock:start()
timer_clock:emit_signal("timeout")

-- Create a stats widget
local widget_stats = wibox.layout.fixed.horizontal()
local stats_fg = theme.fg_normal
local stats_graph = theme.bg_normal
local stats_bg = theme.fg_focus
local stats_sep = theme.bg_focus
-- "from" and "to" define coordinates of  a line along which the gradient spreads
local stats_grad = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#dc322f" }, { 0.5, "#808000" }, { 1, "#859900" }}}

-- separator
widget_stats_arrow = mwidget_arrow(stats_sep, stats_bg, "cleft")

-- {{{ CPU
vicious.cache(vicious.widgets.cpu)
widget_cpu = wibox.layout.fixed.horizontal()
-- icon
widget_cpu_icon = mwidget_icon("☉")
-- text
widget_cpu_text = wibox.widget.textbox()
widget_cpu_text.fit = function() return 35, 8 end
vicious.register(widget_cpu_text, vicious.widgets.cpu, " $1%", timeout_short)
-- graph
widget_cpu_graph = awful.widget.graph()
widget_cpu_graph:set_width(30)
widget_cpu_graph:set_background_color(stats_bg)
--widget_cpu_graph:set_color(stats_graph)
widget_cpu_graph:set_color(stats_grad)
widget_cpu_graph:set_border_color(stats_bg)
vicious.register(widget_cpu_graph, vicious.widgets.cpu, "$1", timeout_medium)
-- cpu tooltip
tooltip_cpu = awful.tooltip({ objects = { widget_cpu }})
vicious.register(tooltip_cpu, vicious.widgets.cpu,
  function (widget,args)
    local title = "cpu usage"
    local len = string.len(title)+2
    local text
    text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
           " "..string.rep("-", len).." \n"
    for core = 1, cores do
      text = text.." ☉ core"..core.." <span color=\""..theme.fg_normal.."\">"..args[core+1].."</span> % "
      if core < cores then
        text = text.."\n"
      end
    end
    tooltip_cpu:set_text(text)
    return
  end, timeout_medium)
-- put it together
widget_cpu:add(widget_cpu_icon)
widget_cpu:add(widget_cpu_text)
widget_cpu:add(widget_cpu_graph)
-- }}} CPU

-- {{{ MEM
vicious.cache(vicious.widgets.mem)
widget_mem = wibox.layout.fixed.horizontal()
-- icon
widget_mem_icon = mwidget_icon("⚈")
-- mem text
widget_mem_text = wibox.widget.textbox()
widget_mem_text.fit = function() return 35, 8 end
vicious.register(widget_mem_text, vicious.widgets.mem, " $1%", timeout_short)
-- mem bar
widget_mem_graph = awful.widget.graph()
widget_mem_graph:set_width(30)
widget_mem_graph:set_background_color(stats_bg)
--widget_mem_graph:set_color(stats_graph)
widget_mem_graph:set_color(stats_grad)
widget_mem_graph:set_border_color(stats_bg)
vicious.register(widget_mem_graph, vicious.widgets.mem, "$1", timeout_medium)
-- mem tooltip
tooltip_mem = awful.tooltip({ objects = { widget_mem }})
vicious.register( tooltip_mem, vicious.widgets.mem,
  function (widget,args)
    local title = "memory &amp; swap usage"
    local tlen = string.len(title)+2-4
    tooltip_mem:set_text(
      " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
      " "..string.rep("-", tlen).." \n"..
      " ⚈ memory <span color=\""..theme.fg_normal.."\">"..prettystring(args[2], 5, " ").."/"..prettystring(args[3], 5, " ").."</span> MB \n"..
      " ⚈ swap   <span color=\""..theme.fg_normal.."\">"..prettystring(args[6], 5, " ").."/"..prettystring(args[7], 5, " ").."</span> MB ")
     return
  end, timeout_medium)
-- put it together
widget_mem:add(widget_mem_icon)
widget_mem:add(widget_mem_text)
widget_mem:add(widget_mem_graph)
-- }}} MEM

-- {{{ HDD
vicious.cache(vicious.widgets.fs)
widget_hdd = wibox.layout.fixed.horizontal()
-- hdd icon
widget_hdd_icon = mwidget_icon("⛁ ")
-- hdd bars
widget_hdd_bars = wibox.layout.fixed.horizontal()
widget_hdd_bar = {}
for p = 1, #partitions do
  widget_hdd_bar[p] = awful.widget.progressbar()
  widget_hdd_bar[p]:set_vertical(true)
  widget_hdd_bar[p]:set_height(20)
  widget_hdd_bar[p]:set_width(5)
  widget_hdd_bar[p]:set_background_color(stats_bg)
  widget_hdd_bar[p]:set_color(stats_grad)
  vicious.register(widget_hdd_bar[p], vicious.widgets.fs,
    function (widget, args)
      return args["{"..partitions[p].." used_p}"]
  end, timeout_long)
  widget_hdd_bars:add(widget_hdd_bar[p])
  widget_hdd_bars:add(sep)
end
-- hdd tooltip
tooltip_hdd = awful.tooltip({ objects = { widget_hdd }})
vicious.register(tooltip_hdd, vicious.widgets.fs,
  function (widget,args)
    local title = "harddisk information"
    local tlen = string.len(title)+2
    local text
      text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
             " "..string.rep("-", tlen).." \n"
      for p = 1, #partitions do
        text = text.." ⛁ on "..
                 prettystring(partitions[p], 10, " ").." <span color=\""..theme.fg_normal.."\">"..
                 prettystring(args["{"..partitions[p].." used_p}"], 3, " ").."%  "..
                 prettystring(args["{"..partitions[p].." used_gb}"], 5, " ").."/"..
                 prettystring(args["{"..partitions[p].." size_gb}"], 5, " ").."</span> GB "
        if p < #partitions then
          text = text.."\n"
        end
      end
    tooltip_hdd:set_text(text)
    return
end, timeout_long)
-- put it together
widget_hdd:add(widget_hdd_icon)
widget_hdd:add(widget_hdd_bars)
-- }}} HDD

-- {{{ MUSIC
if not laptop then
  vicious.cache(vicious.widgets.mpd)
  widget_mpd = wibox.layout.fixed.horizontal()
  -- mpd icon
  widget_mpd_icon = mwidget_icon("♫ ")
  -- mpd text
  widget_mpd_text = wibox.widget.textbox()
  widget_mpd_text.fit = function(widget, width, height)
    local w, h = wibox.widget.textbox.fit(widget, width, height)
    return math.min(w, 300), h
  end
  vicious.register(widget_mpd_text, vicious.widgets.mpd,
    function (widget, args)
      if args["{state}"] == "Stop" then
        return " ✖ "
      else
        return args["{Artist}"].." - "..args["{Title}"].." "
      end
  end, timeout_medium)
  -- mpd tooltip
  tooltip_mpd = awful.tooltip({ objects = { widget_mpd }})
  vicious.register(tooltip_mpd, vicious.widgets.mpd,
    function (widget,args)
      local title = "music information"
      local tlen = string.len(title)+2
      local len = math.max(string.len(args["{Artist}"]), string.len(args["{Album}"]), string.len(args["{Title}"]), 10)
      local text
      text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
             " "..string.rep("-", tlen).." \n"
      if args["{state}"] == "Stop" then
        text = text.." Status <span color=\""..theme.fg_normal.."\">"..prettystring("stopped", len, " ").." </span>"
      else
        if args["{state}"] == "Play" then
          text = text.." Status <span color=\""..theme.fg_normal.."\">"..prettystring("playing" , len, " ").." </span>\n"
        else
          text = text.." Status <span color=\""..theme.fg_normal.."\">"..prettystring("paused", len, " ").." </span>\n"
        end
        text = text.." Artist <span color=\""..theme.fg_normal.."\">"..prettystring(args["{Artist}"], len, " ").." </span>\n"..
                     " Album  <span color=\""..theme.fg_normal.."\">"..prettystring(args["{Album}"], len, " ").." </span>\n"..
                     " Title  <span color=\""..theme.fg_normal.."\">"..prettystring(args["{Title}"], len, " ").." </span>"
      end
      tooltip_mpd:set_text(text)
      return
    end, timeout_medium)
  -- put it together
  widget_mpd:add(widget_mpd_icon)
  widget_mpd:add(widget_mpd_text)
end
-- }}} MUSIC

-- {{{ BATTERY
if laptop then
  vicious.cache(vicious.widgets.bat)
  widget_bat = wibox.layout.fixed.horizontal()
  -- bat icon
  widget_bat_icon = mwidget_icon("⚡ ")
  -- bat text
  widget_bat_text = wibox.widget.textbox()
  widget_bat_text.fit = function() return 40, 8 end
  vicious.register(widget_bat_text, vicious.widgets.bat, " $1$2%", timeout_medium, BAT)
  -- bat tooltip
  tooltip_bat = awful.tooltip({ objects = { widget_bat }})
  vicious.register( tooltip_bat, vicious.widgets.bat,
    function (widget,args)
      local title = "battery information"
      local tlen = string.len(title)+2
      local text
      text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
             " "..string.rep("-", tlen).." \n"
      if args[1] == "-" then
        text = text.." ⚫ status    <span color=\""..theme.fg_normal.."\">"..prettystring("discharging", 12, " ").." </span>\n"
      else
        text = text.." ⚫ status    <span color=\""..theme.fg_normal.."\">"..prettystring("charging", 12, " ").." </span>\n"
      end
      text = text.." ⚡ charge    <span color=\""..theme.fg_normal.."\">"..prettystring(args[2], 11, " ").."% </span>\n"..
                   " ◴ time left <span color=\""..theme.fg_normal.."\">"..prettystring(args[3], 12, " ").." </span>"
      tooltip_bat:set_text(text)
      return
    end, timeout_medium, BAT)
  -- put it together
  widget_bat:add(widget_bat_icon)
  widget_bat:add(widget_bat_text)
end
-- }}} BATTERY

-- Put stats widget together
widget_stats:add(widget_cpu)
widget_stats:add(widget_stats_arrow)
widget_stats:add(widget_mem)
widget_stats:add(widget_stats_arrow)
widget_stats:add(widget_hdd)
if not laptop then
  widget_stats:add(widget_stats_arrow)
  widget_stats:add(widget_mpd)
else
  widget_stats:add(widget_stats_arrow)
  widget_stats:add(widget_bat)
end

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(sep)
    left_layout:add(mytaglist[s])
    left_layout:add(mwidget_arrow(theme.bg_normal, theme.fg_focus, "right"))
    left_layout:add(mwidget_bg(theme.fg_focus, mypromptbox[s]))
    left_layout:add(mwidget_arrow(theme.fg_focus, theme.bg_normal, "right"))

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mwidget_arrow(theme.fg_focus, theme.bg_normal, "left"))
    right_layout:add(mwidget_bg(theme.fg_focus, widget_stats))
    if s == 1 then
      right_layout:add(mwidget_arrow(theme.bg_focus, theme.fg_focus, "left"))
      right_layout:add(wibox.widget.systray())
      right_layout:add(mwidget_bg(theme.bg_focus, sep))
      right_layout:add(mwidget_arrow(theme.bg_normal, theme.bg_focus, "left"))
    else
      right_layout:add(mwidget_arrow(theme.bg_normal, theme.fg_focus, "left"))
    end
    right_layout:add(widget_clock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- mouse wheel
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "`",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "b", function () awful.util.spawn("chromium") end),
    awful.key({ modkey,           }, "v", function () awful.util.spawn("/usr/bin/thunar") end),
    awful.key({ modkey, "Control" }, "s", function () awful.util.spawn("/usr/bin/xscreensaver-command -lock") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    -- Power
    awful.key({                   }, "XF86HomePage", function () awful.util.spawn("systemctl suspend") end),
    awful.key({                   }, "XF86Mail", function () awful.util.spawn("systemctl hibernate") end),

    -- Media
    awful.key({                   }, "XF86AudioMute", function () awful.util.spawn(home .."/bin/notify_volume toggle") end),
    awful.key({                   }, "XF86AudioLowerVolume", function () awful.util.spawn(home .."/bin/notify_volume decrease") end),
    awful.key({                   }, "XF86AudioRaiseVolume", function () awful.util.spawn(home .."/bin/notify_volume increase") end),

    awful.key({                   }, "XF86Eject", function () awful.util.spawn(home .."/bin/switchmpd.sh") end),
    awful.key({                   }, "XF86Tools", function () awful.util.spawn(home .."/bin/notify_music") end),

    awful.key({                   }, "XF86AudioNext", function () awful.util.spawn(home .."/bin/notify_music next") end),
    awful.key({                   }, "XF86AudioPlay", function () awful.util.spawn(home .."/bin/notify_music toggle") end),
    awful.key({                   }, "XF86AudioStop", function () awful.util.spawn(home .."/bin/notify_music stop") end),
    awful.key({                   }, "XF86AudioPrev", function () awful.util.spawn(home .."/bin/notify_music prev") end),

    awful.key({ modkey,           }, "XF86AudioLowerVolume", function () awful.util.spawn(home .."/bin/notify_music volume -5") end),
    awful.key({ modkey,           }, "XF86AudioRaiseVolume", function () awful.util.spawn(home .."/bin/notify_music volume +5") end),

    awful.key({                   }, "XF86Display", function () awful.util.spawn(home .."/bin/myxrandr") end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",
              function (c)
                  awful.client.floating.toggle()
                  if floats(c) then
                    titlebar_enable(c)
                  else
                    titlebar_disable(c)
                  end
              end),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

    -- resize floating windows
    awful.key({ modkey, "Shift"   }, "Right",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local w = screen[c.screen].workarea
        local inc = 100
        inc_p = w.x + w.width - g.x - g.width
        if inc > inc_p then
          inc = inc_p
        end
        g.width = g.width + inc
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Shift"   }, "Left",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local dec = 100
        local min = 200
        dec_p = g.width - min
        if dec > dec_p then
          dec = dec_p
        end
        g.width = g.width - dec
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Shift"   }, "Up",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local dec = 100
        local min = 200
        dec_p = g.height - min
        if dec > dec_p then
          dec = dec_p
        end
        g.height = g.height - dec
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Shift"   }, "Down",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local w = screen[c.screen].workarea
        local inc = 100
        inc_p = w.y + w.height - g.y - g.height
        if inc > inc_p then
          inc = inc_p
        end
        g.height = g.height + inc
        c:geometry(g)
      end
    end),

    -- move floating windows to screen edges
    awful.key({ modkey, "Control"   }, "Right",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local w = screen[c.screen].workarea
        g.x = w.x + w.width - g.width - 2
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Control"   }, "Left",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local w = screen[c.screen].workarea
        g.x = w.x
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Control"   }, "Up",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local w = screen[c.screen].workarea
        g.y = w.y
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Control"   }, "Down",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local w = screen[c.screen].workarea
        g.y = w.y + w.height - g.height - 2
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Shift" }, "t", function (c)
      titlebar_disable(c)
    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    -- match all new clients, notify name and class
    --{ rule = { },
    --  properties = { },
    --  callback = function(c)
    --    local cname=c.name
    --    local cclass=c.class
    --    naughty.notify({title="new window", text="name: "..cname.." class: "..cclass})
    --  end
    --},
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "mplayer2" },
      properties = { floating = true } },
    { rule = { class = "Pavucontrol" },
      properties = { floating = true } },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { class = "Exe" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Iceweasel", role="Manager" },
      properties = { floating = true } },
    { rule = { class = "chromium" },
      properties = {    tag = tags[screen. count()][1] } },
    { rule = { class = "Gimp", role="gimp-toolbox" },
      properties = {
        floating = true,
      },
      callback = function(c)
        local w = screen[screen.count()].workarea
        local strutwidth = 180
        local g = c:geometry()
          g.x = w.x + w.width - strutwidth
          g.y = w.y
          g.width = strutwidth
          g.height = w.height/5*3
        c:struts( { right = strutwidth } )
        c:geometry(g)
      end
    },
    { rule = { class = "Pidgin", role="buddy_list" },
      properties = {
        floating = true,
        -- tag = tags[screen.count()][2]
        tag = tags[1][2]
      },
      callback = function(c)
        local w = screen[screen.count()].workarea
        local strutwidth = 180
        local g = c:geometry()
          g.x = w.x + w.width - strutwidth
          g.y = w.y
          g.width = strutwidth
          g.height = w.height/5*3
        c:struts( { right = strutwidth } )
        c:geometry(g)
      end
    },
    { rule = { class = "Pidgin", role="conversation" },
      properties = {
        floating = true,
        -- tag = tags[screen.count()][2]
        tag = tags[1][2]
      },
      callback = function(c)
        local w = screen[screen.count()].workarea
        local winwidth = 600
        local strutwidth = 180
        local g = c:geometry()
          g.x = w.x + w.width - winwidth + strutwidth
          g.y = w.y + w.height/5*3
          g.width = winwidth
          g.height = w.height/5*2
        c:geometry(g)
      end
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        titlebar_enable(c)
    end
end)

-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
  --if floats(c) then
  --  if (not awful.rules.match(c, { class = "Pidgin" })) and (not awful.rules.match(c, { class = terminal_class })) then
  --    titlebar_enable(c)
  --  end
  --end
end)

-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
  --if floats(c) then
  --  if (not awful.rules.match(c, { class = "Pidgin" })) and (not awful.rules.match(c, { class = terminal_class })) then
  --    titlebar_disable(c)
  --  end
  --end
end)

-- Autorun programs
awful.util.spawn(home .."/bin/autostart")
