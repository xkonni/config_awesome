-- Standard awesome library
local gears = require("gears")
awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
-- skip overriding system-wide notification daemon
local _dbus = dbus; dbus = nil
local naughty = require("naughty")
dbus = _dbus
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local functions = require("functions")
local scratch = require("scratch")
local vicious = require("vicious")
local centerwork = require("layouts.centerwork")
local termfair = require("layouts.termfair")

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
      text = tostring(err) })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
settings = {}
-- This is used later as the default settings.terminal and settings.editor to run.
-- tmp = io.popen("hostname | tr -d '\n'")
tmp = io.popen("hostname")
settings.host = tmp:read()
settings.terminal = "termite"
settings.editor = "vim"
settings.terminal_cmd = settings.terminal .. " -e "
settings.editor_cmd = settings.terminal_cmd .. settings.editor
tmp = io.popen("echo $HOME")
settings.home = tmp:read()
settings.timeout = 5
-- defaults
settings.swap = true
settings.scale = 1.0
settings.bat = false
settings.coretemp = "coretemp.0/hwmon/hwmon2"
-- host specific
if settings.host == "annoyance" then
elseif settings.host == "silence" then
  settings.scale = 1.2
  settings.swap = false
  settings.bat = "BAT0"
  settings.coretemp = "coretemp.0/hwmon/hwmon3"
elseif settings.host == "CHJYRN2" then
  settings.bat = "BAT0"
  settings.coretemp = "coretemp.0/hwmon/hwmon4"
end
settings.sc_width = 1200*settings.scale
settings.sc_height = 600*settings.scale

-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "/themes/solarized/theme.lua")
-- beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
functions.init({theme=beautiful})

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  centerwork,
  -- termfair,
  termfair.center,
  -- centerwork.horizontal,
  -- awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  -- awful.layout.suit.fair,
  -- awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  -- awful.layout.suit.max,
  -- awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.magnifier,
  -- awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
  local instance = nil

  return function ()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 250 } })
    end
  end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
  { "hotkeys", function() return false, hotkeys_popup.show_help end},
  { "manual", settings.terminal_cmd .. " man awesome" },
  { "edit config", settings.editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", functions.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
      { "open terminal", settings.terminal }
    }
  })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
  menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = settings.terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- CPU usage widget
cpuwidget = wibox.widget {
  {
    id = "cpubar",
    color             = "linear:0,0:100,0:0,#268bd2:0.5,#8000cc:1,#cc0000",
    background_color  = beautiful.bg_urgent,
    border_color      = beautiful.bg_focus,
    border_width      = 2,
    paddings          = 2,
    max_value         = 1,
    shape             = gears.shape.octogon,
    bar_shape         = gears.shape.octogon,
    widget            = wibox.widget.progressbar,
  },
  {
    id = "cputext",
    widget = wibox.widget.textbox,
  },
  {
    id = "cputemp",
    widget = wibox.widget.textbox,
  },
  layout = wibox.layout.stack,
  forced_width      = 100*settings.scale,
  forced_height     = 12,
}

-- RAM usage widget
memwidget = wibox.widget {
  {
    id = "membar",
    color             = "linear:0,0:100,0:0,#268bd2:0.5,#8000cc:1,#cc0000",
    background_color  = beautiful.bg_urgent,
    border_color      = beautiful.bg_focus,
    border_width      = 2,
    paddings          = 2,
    max_value         = 1,
    shape             = gears.shape.octogon,
    bar_shape         = gears.shape.octogon,
    widget            = wibox.widget.progressbar,
  },
  {
    id = "memtext",
    widget = wibox.widget.textbox,
  },
  layout = wibox.layout.stack,
  forced_width      = 60*settings.scale,
  forced_height     = 12,
}

-- SWAP usage widget
if (settings.swap) then
  swapwidget = wibox.widget {
    {
      id = "swapbar",
      color             = "linear:0,0:100,0:0,#268bd2:0.5,#8000cc:1,#cc0000",
      background_color  = beautiful.bg_urgent,
      border_color      = beautiful.bg_focus,
      border_width      = 2,
      paddings          = 2,
      max_value         = 100,
      shape             = gears.shape.octogon,
      bar_shape         = gears.shape.octogon,
      widget            = wibox.widget.progressbar,
    },
    {
      id = "swaptext",
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.stack,
    forced_width      = 60*settings.scale,
    forced_height     = 12,
  }
else
  swapwidget = wibox.widget {
    forced_width      = 0,
    forced_height     = 0,
  }
end

-- battery widget
if settings.bat then
  batwidget = wibox.widget {
    {
      id = "batbar",
      color             = "linear:0,0:100,0:0,#268bd2:0.5,#8000cc:1,#cc0000",
      background_color  = beautiful.bg_urgent,
      border_color      = beautiful.bg_focus,
      border_width      = 2,
      paddings          = 2,
      max_value         = 100,
      shape             = gears.shape.octogon,
      bar_shape         = gears.shape.octogon,
      widget            = wibox.widget.progressbar,
    },
    {
      id = "battext",
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.stack,
    forced_width      = 60*settings.scale,
    forced_height     = 12,
  }
else
  batwidget = wibox.widget {
    forced_width      = 0,
    forced_height     = 0,
  }
end

-- update temperature
vicious.cache(vicious.widgets.thermal)
vicious.register(cpuwidget.cputemp, vicious.widgets.thermal,
  function(widget, args)
    return string.format("        %2.1f°C", args[1])
end, 3, { settings.coretemp, "core"} )

-- update CPU
vicious.cache(vicious.widgets.cpu)
vicious.register(cpuwidget.cpubar, vicious.widgets.cpu,
  function (widget, args)
    cpuwidget.cputext:set_text(string.format(" C %3d%%", args[1]))
    return args[1]
end, 3)

-- update RAM/SWAP
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget.membar, vicious.widgets.mem,
  function (widget, args)
    memwidget.memtext:set_text(string.format(" M  %3d%%", args[1]))
    if (settings.swap) then
      swapwidget.swapbar:set_value(args[5])
      swapwidget.swaptext:set_text(string.format(" S  %3s%%", args[5]))
    end
    return args[1]
end, 3)

-- update battery
if settings.bat then
  vicious.cache(vicious.widgets.bat)
  vicious.register(batwidget.batbar, vicious.widgets.bat,
    function (widget, args)
      batwidget.battext:set_text(string.format(" B  %s%3d%%", args[1], args[2]))
      -- return string.format("%d", args[2])
      return string.format("%d", args[2]*100)
  end, 3, settings.bat)
end

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end)
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
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
  awful.button({ }, 3, client_menu_toggle_fn()),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
  end),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
  end))

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc(-1) end),
      awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    mywibox[s]:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        mylauncher,
        mytaglist[s],
        mypromptbox[s],
      },
      mytasklist[s], -- Middle widget
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        cpuwidget,
        memwidget,
        swapwidget,
        batwidget,
        wibox.widget.systray(),
        mytextclock,
        mylayoutbox[s],
      },
  }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
  ))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  awful.key({ modkey,           }, "i",      hotkeys_popup.show_help,
    {description="show help", group="awesome"}),
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
    {description = "view previous", group = "tag"}), awful.key({ modkey,           }, "Right",  awful.tag.viewnext, {description = "view next", group = "tag"}),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),

  -- Focus
  awful.key({ modkey,           }, "h",
    function ()
      awful.client.focus.global_bydirection("left")
    end,
    {description = "focus client to the left", group = "client"}
    ),
  awful.key({ modkey,           }, "j",
    function ()
      awful.client.focus.global_bydirection("down")
    end,
    {description = "focus client below", group = "client"}
    ),
  awful.key({ modkey,           }, "k",
    function ()
      awful.client.focus.global_bydirection("up")
    end,
    {description = "focus client above", group = "client"}
    ),
  awful.key({ modkey,           }, "l",
    function ()
      awful.client.focus.global_bydirection("right")
    end,
    {description = "focus client to the right", group = "client"}
    ),
  awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    {description = "show main menu", group = "awesome"}),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.global_bydirection("left")    end,
    {description = "swap with client to the left", group = "client"}),
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.global_bydirection("down")    end,
    {description = "swap with client below", group = "client"}),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.global_bydirection("up")    end,
    {description = "swap with client above", group = "client"}),
  awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.global_bydirection("right")    end,
    {description = "swap with client to the right", group = "client"}),

  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
    {description = "jump to urgent client", group = "client"}),
  awful.key({ modkey,           }, "Tab",
    function ()
      awful.client.focus.byidx( 1)
    end,
    {description = "focus next", group = "client"}),

  -- Standard program
  awful.key({ modkey,           }, "Return", function () awful.spawn(settings.terminal) end,
    {description = "open a terminal", group = "launcher"}),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
  awful.key({ modkey, "Shift"   }, "q", functions.quit,
    {description = "quit awesome", group = "awesome"}),
  awful.key({ modkey, "Control"   }, "Escape", function () awful.spawn(settings.home .. "/bin/lock.sh") end,
    {description = "lock screen", group = "awesome"}),

  awful.key({ modkey, "Control"   }, "j",     function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control"   }, "k",     function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    {description = "increase the number of columns", group = "layout"}),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    {description = "decrease the number of columns", group = "layout"}),
  awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
    {description = "select next", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    {description = "select previous", group = "layout"}),

  awful.key({ modkey, "Control" }, "n",
    function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        client.focus = c
        c:raise()
      end
    end,
    {description = "restore minimized", group = "client"}),

  -- Prompt
  awful.key({ modkey },            "r",     function () mypromptbox[awful.screen.focused()]:run() end,
    {description = "run prompt", group = "launcher"}),

  awful.key({ modkey, "Shift" }, "u",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[awful.screen.focused()].widget,
        awful.util.eval, nil,
        awful.util.get_cache_dir() .. "/history_eval")
    end,
    {description = "lua execute prompt", group = "awesome"}),
  -- Menubar
  awful.key({ modkey }, "p", function() menubar.show() end,
    {description = "show the menubar", group = "launcher"}),

  -- Screenshots
  awful.key({ "Mod1", "Shift"}, "3", function()
    -- naughty.notify({title="scrot", text="whole screen"})
    awful.spawn.with_shell(settings.home .. "/bin/aw_scrot.sh") end,
    {description = "take screenshot of whole screen", group = "launcher"}),
  awful.key({ "Mod1", "Shift"}, "4", function()
    naughty.notify({title="scrot", text="selection"})
    awful.spawn.with_shell("sleep 1; " .. settings.home .. "/bin/aw_scrot.sh -s") end,
    {description = "take screenshot of selection", group = "launcher"}),

  -- Scratchpad
  -- scratch.pad.toggle({vert, horiz, instance, screen})
  awful.key({ modkey,           }, "a", function ()
    scratch.pad.toggle({horiz="left", instance=0, screen=0}) end,
    {description = "toggle A", group = "scratch"}),
  awful.key({ modkey,           }, "s", function ()
    scratch.pad.toggle({horiz="center", instance=1, screen=0}) end,
    {description = "toggle S", group = "scratch"}),
  awful.key({ modkey,           }, "d", function ()
    scratch.pad.toggle({horiz="right", instance=2, screen=0}) end,
    {description = "toggle D", group = "scratch"}),
  awful.key({ modkey            }, "z", function ()
    scratch.pad.toggle({vert="bottom", horiz="left", instance=3, screen=0}) end,
    {description = "toggle Z", group = "scratch"}),
  awful.key({ modkey            }, "x", function ()
    scratch.pad.toggle({vert="bottom", horiz="center", instance=4, screen=0}) end,
    {description = "toggle X", group = "scratch"}),
  awful.key({ modkey            }, "c", function ()
    scratch.pad.toggle({vert="bottom", horiz="right", instance=5, screen=0}) end,
    {description = "toggle C", group = "scratch"})
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",
    function (c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = "toggle fullscreen", group = "client"}),
  awful.key({ modkey, "Control"   }, "c",      function (c) c:kill()                       end,
    {description = "close", group = "client"}),
  awful.key({ modkey, "Control" }, "space",  function (c)
    awful.client.floating.toggle(c)
    awful.placement.no_offscreen(c)
  end,
    {description = "toggle floating", group = "client"}),
  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
    {description = "move to master", group = "client"}),
  awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
    {description = "move to screen", group = "client"}),
  awful.key({ modkey, "Shift"   }, "o",      function (c) functions.swaptags()             end,
    {description = "swap screens", group = "client"}),
  awful.key({ modkey,           }, "t",      function (c) awful.titlebar.toggle(c)         end,
    {description = "toggle titlebar", group = "client"}),
  awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop            end,
    {description = "toggle keep on top", group = "client"}),
  awful.key({ modkey,           }, "n",
    function (c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end ,
    {description = "minimize", group = "client"}),
  awful.key({ modkey,           }, "m",
    function (c)
      c.maximized = not c.maximized
      c:raise()
    end ,
    {description = "maximize", group = "client"}),
  -- resize
  awful.key({ modkey, "Shift"   }, "m", function (c) functions.move(c) end),
  awful.key({ modkey, "Shift"   }, "r", function (c) functions.resize(c) end),
  -- Scratchpad
  -- pad.set(c, {vert, horiz, width, height, sticky, instance, screen})
  awful.key({ modkey, "Shift" }, "a", function (c)
    scratch.pad.set(c, {horiz="left", width=settings.sc_width, height=settings.sc_height,
      sticky=true, instance=0, screen=0}) end,
    {description = "set A", group = "scratch"}),
  awful.key({ modkey, "Shift" }, "s", function (c)
    scratch.pad.set(c, {horiz="center", width=settings.sc_width, height=settings.sc_height,
      sticky=true, instance=1, screen=0}) end,
    {description = "set S", group = "scratch"}),
  awful.key({ modkey, "Shift" }, "d", function (c)
    scratch.pad.set(c, {horiz="right", width=settings.sc_width, height=settings.sc_height,
    sticky=true, instance=2, screen=0}) end,
    {description = "set D", group = "scratch"}),
  awful.key({ modkey, "Shift" }, "z", function (c)
    scratch.pad.set(c, {vert="bottom", horiz="left", width=settings.sc_width, height=settings.sc_height,
      sticky=true, instance=3, screen=0}) end,
    {description = "set Z", group = "scratch"}),
  awful.key({ modkey, "Shift" }, "x", function (c)
    scratch.pad.set(c, {vert="bottom", horiz="center", width=settings.sc_width, height=settings.sc_height,
      sticky=true, instance=4, screen=0}) end,
    {description = "set X", group = "scratch"}),
  awful.key({ modkey, "Shift" }, "c", function (c)
    scratch.pad.set(c, {vert="bottom", horiz="right", width=settings.sc_width, height=settings.sc_height,
      sticky=true, instance=5, screen=0}) end,
    {description = "set C", group = "scratch"})
  )

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #"..i, group = "tag"}),
    -- Toggle tag.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      {description = "toggle tag #" .. i, group = "tag"}),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = "move focused client to tag #"..i, group = "tag"}),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = { border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen
    },
    -- add titlebar, hide it for 'most' windows
    callback = function (c)
      -- buttons for the titlebar
      local buttons = awful.util.table.join(
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
        )

      awful.titlebar(c) : setup {
        { -- Left
          awful.titlebar.widget.iconwidget(c),
          buttons = buttons,
          layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
          { -- Title
            align  = "center",
            widget = awful.titlebar.widget.titlewidget(c)
          },
          buttons = buttons,
          layout  = wibox.layout.flex.horizontal
        },
        { -- Right
          awful.titlebar.widget.floatingbutton (c),
          awful.titlebar.widget.maximizedbutton(c),
          awful.titlebar.widget.stickybutton   (c),
          awful.titlebar.widget.ontopbutton    (c),
          awful.titlebar.widget.closebutton    (c),
          layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
      }
      -- Only show titlebars for dialogs
      if c.type ~=  "dialog" then
        awful.titlebar.toggle(c)
        awful.titlebar.hide(c)
      end

    end
  },

  -- Floating clients.
  { rule_any = {
      instance = {
        "DTA",  -- Firefox addon DownThemAll.
        "copyq",  -- Includes session name in class.
      },
      class = {
        "Arandr",
        "Gpick",
        "Kruler",
        "MessageWin",  -- kalarm.
        "Sxiv",
        "Wpa_gui",
        "pinentry",
        "veromix",
      "xtightvncviewer"},

      name = {
        "Event Tester",  -- xev.
      },
      role = {
        "AlarmWindow",  -- Thunderbird's calendar.
        "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
      }
  }, properties = { floating = true }},

  -- Set Firefox to always map on the tag named "2" on screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and
    not c.size_hints.user_position
    and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- awful.tag.attached_connect_signal(nil, "property::column_count", function() naughty.notify({title="column_count", text=awful.screen.focused().selected_tag.column_count}) end)
-- awful.tag.attached_connect_signal(nil, "property::master_count", function() naughty.notify({title="master_count", text=awful.screen.focused().selected_tag.master_count}) end)
