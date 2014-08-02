-- Standard awesome library
local gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local scratch = require("scratch")
local vicious = require("vicious")
local functions = require("functions")

-- {{{ Error handling
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = err })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
settings = {}
-- This is used later as the default settings.terminal and settings.editor to run.
settings.terminal = "termite"
settings.editor = "vim"
settings.terminal_cmd = settings.terminal .. " -e "
settings.editor_cmd = settings.terminal_cmd .. settings.editor
-- Default modkey
settings.mod = "Mod4"
settings.home = awful.util.pread("echo $HOME | tr -d '\n'")
settings.timeout = 5
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .."/themes/solarized/theme.lua")
functions.init({beautiful=beautiful})

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
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
  -- awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, awful.layout.layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
  { "manual", settings.terminal_cmd .. "man\\ awesome" },
  { "edit config", settings.editor_cmd .. "\\ " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", awesome.quit } }

mymainmenu = awful.menu({
  items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "open settings.terminal", settings.terminal } }
})

mylauncher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = settings.terminal
-- }}}

-- {{{ Wibox
-- Create a textclock widget
w = {}
w.textclock = awful.widget.textclock()
w.load = functions.textbox()
w.load_text = "[load <span color=\"" .. beautiful.fg_focus ..  "\">$4 $5 $6</span>] "
vicious.register(w.load, vicious.widgets.uptime, w.load_text, settings.timeout)
w.mem = functions.textbox()
w.mem_text = "[mem <span color=\"" .. beautiful.fg_focus ..  "\">$1%</span>] "
vicious.register(w.mem, vicious.widgets.mem, w.mem_text, settings.timeout)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ settings.mod }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ settings.mod }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end) )
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
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end),
    awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(w.load)
  right_layout:add(w.mem)
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(w.textclock)
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
  --awful.button({ }, 4, awful.tag.viewnext),
  --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  --awful.key({ settings.mod,           }, "Left",   awful.tag.viewprev     ),
  --awful.key({ settings.mod,           }, "Right",  awful.tag.viewnext     ),
  --awful.key({ settings.mod,           }, "Escape", awful.tag.history.restore),

  -- focus by direction
  awful.key({ settings.mod,           }, "h",
 function ()
      awful.client.focus.global_bydirection("left")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ settings.mod,           }, "j",
 function ()
      --awful.client.focus.byidx( 1)
      awful.client.focus.global_bydirection("down")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ settings.mod,           }, "k",
 function ()
      --awful.client.focus.byidx(-1)
      awful.client.focus.global_bydirection("up")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ settings.mod,           }, "l",
 function ()
      awful.client.focus.global_bydirection("right")
      if client.focus then client.focus:raise() end
    end),
  -- focus urgent, focus next
  awful.key({ settings.mod,           }, "u", awful.client.urgent.jumpto),
  awful.key({ settings.mod,           }, "Tab", function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),

  -- Layout manipulation
  awful.key({ settings.mod, "Shift"   }, "h", function () awful.client.swap.global_bydirection("left")   end),
  awful.key({ settings.mod, "Shift"   }, "j", function () awful.client.swap.global_bydirection("down")   end),
  awful.key({ settings.mod, "Shift"   }, "k", function () awful.client.swap.global_bydirection("up")     end),
  awful.key({ settings.mod, "Shift"   }, "l", function () awful.client.swap.global_bydirection("right")  end),
  awful.key({ settings.mod, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ settings.mod, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ settings.mod,           }, "w", function () mymainmenu:toggle() end),

  -- Standard program
  awful.key({ settings.mod,           }, "Return", function () awful.util.spawn(settings.terminal) end),
  awful.key({ settings.mod, "Control" }, "r", awesome.restart),
  awful.key({ settings.mod, "Control" }, "q", awesome.quit),

  awful.key({ settings.mod, "Control" }, "h", function () awful.tag.incnmaster( 1) end),
  awful.key({ settings.mod, "Control" }, "l", function () awful.tag.incnmaster(-1) end),
  awful.key({ settings.mod,           }, "space", function () awful.layout.inc( 1) end),
  awful.key({ settings.mod, "Shift"   }, "space", function () awful.layout.inc(-1) end),

  awful.key({ settings.mod, "Control" }, "n", awful.client.restore),

  -- Prompt
  awful.key({ settings.mod            }, "r", function () mypromptbox[mouse.screen]:run() end),

  awful.key({ settings.mod            }, "x", function ()
    awful.prompt.run(
      { prompt = "Run Lua code: " },
      mypromptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
  end),

  -- Menubar
  awful.key({ settings.mod            }, "p", function () menubar.show() end),

  -- Media
  awful.key({ settings.mod            }, "F3",  function () awful.util.spawn(settings.home .."/bin/notify_mpd switch", false) end),
  awful.key({ settings.mod            }, "F4",  function () awful.util.spawn(settings.home .."/bin/notify_mpd", false) end),

  awful.key({ settings.mod            }, "F5",  function () awful.util.spawn(settings.home .."/bin/notify_mpd stop", false) end),
  awful.key({ settings.mod            }, "F6",  function () awful.util.spawn(settings.home .."/bin/notify_mpd toggle", false) end),
  awful.key({ settings.mod            }, "F7",  function () awful.util.spawn(settings.home .."/bin/notify_mpd prev", false) end),
  awful.key({ settings.mod            }, "F8",  function () awful.util.spawn(settings.home .."/bin/notify_mpd next", false) end),

  awful.key({ settings.mod            }, "F10",  function () awful.util.spawn(settings.home .."/bin/notify_volume toggle", false) end),
  awful.key({ settings.mod            }, "F11",  function () awful.util.spawn(settings.home .."/bin/notify_volume decrease", false) end),
  awful.key({ settings.mod            }, "F12",  function () awful.util.spawn(settings.home .."/bin/notify_volume increase", false) end),

  -- Scratchpad
  -- scratch.pad.toggle({vert, horiz, instance, screen})
  awful.key({ settings.mod,           }, "s", function ()
    scratch.pad.toggle({screen=mouse.screen})
  end),
  awful.key({ settings.mod            }, "c", function ()
    scratch.pad.toggle({vert="bottom", horiz="center", instance=1, screen=0})
  end)
)

clientkeys = awful.util.table.join(
  awful.key({ settings.mod,           }, "f", function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ settings.mod, "Shift"   }, "q", function (c) c:kill()             end),
  awful.key({ settings.mod, "Control" }, "space", function(c)
    awful.client.floating.toggle()
    if awful.client.floating.get(c) then
      awful.titlebar.show(c)
      if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
      end
    else
      awful.titlebar.hide(c)
    end
  end),
  awful.key({ settings.mod, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ settings.mod,           }, "o",    awful.client.movetoscreen            ),
  awful.key({ settings.mod,           }, "t", function (c) awful.titlebar.toggle(c) end),
  awful.key({ settings.mod, "Shift"   }, "t", function (c) c.ontop = not c.ontop end),
  awful.key({ settings.mod, "Control" }, "t", function (c) c.sticky =  not c.sticky end),
  awful.key({ settings.mod,           }, "n", function (c) c.minimized = true end),
  awful.key({ settings.mod,           }, "m", function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
  end),
  awful.key({ settings.mod, "Shift"   }, "m", function (c) functions.move(c) end),
  awful.key({ settings.mod, "Shift"   }, "r", function (c) functions.resize(c) end),
  -- Scratchpad
  -- pad.set(c, {vert, horiz, width, height, sticky, instance, screen})
  awful.key({ settings.mod, "Shift" }, "s", function (c)
    scratch.pad.set(c, {vert="center", horiz="center", width=0.5, height=0.5,
      sticky=true, instance=0, screen=mouse.screen})
  end),
  awful.key({ settings.mod, "Shift" }, "c", function (c)
    scratch.pad.set(c, {vert="bottom", horiz="center", width=1000, height=400,
      sticky=true, instance=1, screen=0})
  end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ settings.mod }, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
         awful.tag.viewonly(tag)
      end
    end),
    awful.key({ settings.mod, "Control" }, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
       awful.tag.viewtoggle(tag)
      end
    end),
    awful.key({ settings.mod, "Shift" }, "#" .. i + 9, function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.movetotag(tag)
        end
     end
    end),
    awful.key({ settings.mod, "Control", "Shift" }, "#" .. i + 9, function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.toggletag(tag)
        end
      end
    end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ settings.mod }, 1, awful.mouse.client.move),
  awful.button({ settings.mod }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      keys = clientkeys,
      buttons = clientbuttons } },
  { rule = { class = "MPlayer" },
    properties = { floating = true } },
  { rule = { class = "pinentry" },
    properties = { floating = true } },
  { rule = { class = "gimp" },
    properties = { floating = true } },
  -- Set Firefox to always map on tags number 2 of screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { tag = tags[1][2] } },
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
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  -- Create titlebar for all windows, then hide it for most windows
  -- necessary to toggle the titlebar
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
    end) )

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(awful.titlebar.widget.iconwidget(c))
  left_layout:buttons(buttons)

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(awful.titlebar.widget.floatingbutton(c))
  right_layout:add(awful.titlebar.widget.maximizedbutton(c))
  right_layout:add(awful.titlebar.widget.stickybutton(c))
  right_layout:add(awful.titlebar.widget.ontopbutton(c))
  right_layout:add(awful.titlebar.widget.closebutton(c))

  -- The title goes in the middle
  local middle_layout = wibox.layout.flex.horizontal()
  local title = awful.titlebar.widget.titlewidget(c)
  title:set_align("center")
  middle_layout:add(title)
  middle_layout:buttons(buttons)

  -- Now bring it all together
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)
  layout:set_middle(middle_layout)

  awful.titlebar(c):set_widget(layout)

  -- Hide it for most clients
  if (c.type ~= "dialog") then
    awful.titlebar.hide(c)
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
