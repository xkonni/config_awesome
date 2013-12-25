-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
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
-- Error handling
require("error")

-- Settings
settings = require("settings")
-- Themes define colours, icons, and wallpapers
beautiful.init(settings.theme)
-- Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- Tags
tags = {}
for s = 1, screen.count() do
  tags[s] = awful.tag(settings.tags, s, settings.layouts[1])
end
-- {{{ Menu
mymainmenu = awful.menu({
  items = { { "awesome", settings.myawesomemenu, beautiful.awesome_icon },
            { "open terminal", settings.terminal } }
})
-- Launcher
mylauncher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = settings.terminal
-- }}}

-- {{{ Wibox
widgets = require("widgets")
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ settings.modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ settings.modkey }, 3, awful.client.toggletag),
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
    awful.button({ }, 1, function () awful.layout.inc(settings.layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(settings.layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(settings.layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(settings.layouts, -1) end)))
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
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(widgets.textclock)
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
  --awful.key({ settings.modkey,           }, "Left",   awful.tag.viewprev     ),
  --awful.key({ settings.modkey,           }, "Right",  awful.tag.viewnext     ),
  --awful.key({ settings.modkey,           }, "Escape", awful.tag.history.restore),

  -- focus by direction
  awful.key({ settings.modkey,           }, "h",
 function ()
      awful.client.focus.global_bydirection("left")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ settings.modkey,           }, "j",
 function ()
      --awful.client.focus.byidx( 1)
      awful.client.focus.global_bydirection("down")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ settings.modkey,           }, "k",
 function ()
      --awful.client.focus.byidx(-1)
      awful.client.focus.global_bydirection("up")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ settings.modkey,           }, "l",
 function ()
      awful.client.focus.global_bydirection("right")
      if client.focus then client.focus:raise() end
    end),
  -- focus urgent, focus next
  awful.key({ settings.modkey,           }, "u", awful.client.urgent.jumpto),
  awful.key({ settings.modkey,           }, "Tab", function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),

  -- Layout manipulation
  awful.key({ settings.modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left")   end),
  awful.key({ settings.modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down")   end),
  awful.key({ settings.modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up")     end),
  awful.key({ settings.modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right")  end),
  awful.key({ settings.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ settings.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ settings.modkey,           }, "w", function () mymainmenu:toggle() end),

  -- Standard program
  awful.key({ settings.modkey,           }, "Return", function () awful.util.spawn(settings.terminal) end),
  awful.key({ settings.modkey, "Control" }, "r", awesome.restart),
  awful.key({ settings.modkey, "Shift"   }, "q", awesome.quit),

  awful.key({ settings.modkey, "Control" }, "h", function () awful.tag.incnmaster( 1)      end),
  awful.key({ settings.modkey, "Control" }, "l", function () awful.tag.incnmaster(-1)      end),
  awful.key({ settings.modkey,           }, "space", function () awful.layout.inc(settings.layouts,  1) end),
  awful.key({ settings.modkey, "Shift"   }, "space", function () awful.layout.inc(settings.layouts, -1) end),

  awful.key({ settings.modkey, "Control" }, "n", awful.client.restore),

  -- Prompt
  awful.key({ settings.modkey            }, "r", function () mypromptbox[mouse.screen]:run() end),

  awful.key({ settings.modkey            }, "x", function ()
    awful.prompt.run(
      { prompt = "Run Lua code: " },
      mypromptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
  end),

  -- Menubar
  awful.key({ settings.modkey            }, "p", function () menubar.show() end),

  -- Power
  awful.key({ settings.modkey, "Control" }, "s", function () awful.util.spawn(config .. "/i3lock", false) end),
  awful.key({                            }, "XF86HomePage", function ()
      awful.util.spawn(home .. "/bin/powerswitch 1 0", false)
      awful.util.spawn("systemctl suspend", false)
    end),
  awful.key({                            }, "XF86Mail", function ()
      awful.util.spawn(home .. "/bin/powerswitch 1 0", false)
      awful.util.spawn("systemctl hibernate", false)
  end),

  -- Media
  awful.key({                            }, "XF86AudioMute",        function () functions.set_volume("toggle")   end),
  awful.key({                            }, "XF86AudioLowerVolume", function () functions.set_volume("decrease") end),
  awful.key({                            }, "XF86AudioRaiseVolume", function () functions.set_volume("increase") end),

  awful.key({                            }, "XF86AudioNext", function () awful.util.spawn(home .."/bin/notify_mpd next", false) end),
  awful.key({                            }, "XF86AudioPlay", function () awful.util.spawn(home .."/bin/notify_mpd toggle", false) end),
  awful.key({                            }, "XF86AudioStop", function () awful.util.spawn(home .."/bin/notify_mpd stop", false) end),
  awful.key({                            }, "XF86AudioPrev", function () awful.util.spawn(home .."/bin/notify_mpd prev", false) end),

  awful.key({                            }, "XF86Eject", function () awful.util.spawn(home .."/bin/notify_mpd switch", false) end),
  awful.key({                            }, "XF86Tools", function () awful.util.spawn(home .."/bin/notify_mpd", false) end),

  awful.key({ settings.modkey,           }, "F1", function () awful.util.spawn(home .."/bin/powerswitch screen 1", false) end),
  awful.key({ settings.modkey, "Shift"   }, "F1", function () awful.util.spawn(home .."/bin/powerswitch screen 0", false) end),
  awful.key({ settings.modkey,           }, "F2", function () awful.util.spawn(home .."/bin/powerswitch desklight 1", false) end),
  awful.key({ settings.modkey, "Shift"   }, "F2", function () awful.util.spawn(home .."/bin/powerswitch desklight 0", false) end),

  -- Scratchpad
  -- scratch.pad.toggle(screen)
  awful.key({ settings.modkey,           }, "s", function ()
    scratch.pad.toggle(mouse.screen)
  end),
  -- scratch.pad.drop(prog, vert, horiz, width, height, sticky, screen)
  awful.key({ settings.modkey            }, "c", function ()
    scratch.drop(settings.terminal, "bottom", "center", 0.7, 0.45, false, 1)
  end)
)

clientkeys = awful.util.table.join(
  awful.key({ settings.modkey,           }, "f", function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ settings.modkey, "Shift"   }, "c", function (c) c:kill()             end),
  awful.key({ settings.modkey, "Control" }, "space",  awful.client.floating.toggle           ),
  awful.key({ settings.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ settings.modkey,           }, "o",    awful.client.movetoscreen            ),
  awful.key({ settings.modkey,           }, "t", function (c) c.ontop = not c.ontop      end),
  awful.key({ settings.modkey,           }, "n", function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end),
  awful.key({ settings.modkey,           }, "m", function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
  end),
  -- Scratchpad
  awful.key({ settings.modkey, "Shift" }, "s", function (c)
    scratch.pad.set(c, 0.50, 0.50, true)
  end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ settings.modkey }, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
         awful.tag.viewonly(tag)
      end
    end),
    awful.key({ settings.modkey, "Control" }, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
       awful.tag.viewtoggle(tag)
      end
    end),
    awful.key({ settings.modkey, "Shift" }, "#" .. i + 9, function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.movetotag(tag)
        end
     end
    end),
    awful.key({ settings.modkey, "Control", "Shift" }, "#" .. i + 9, function ()
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
  awful.button({ settings.modkey }, 1, awful.mouse.client.move),
  awful.button({ settings.modkey }, 3, awful.mouse.client.resize))

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
    -- Match all new clients, notify name and class
    --{ rule = { },
    --  properties = { },
    --  callback = function(c)
    --    local cname=c.name
    --    local cclass=c.class
    --    naughty.notify({title="new window", text="name: "..cname.." class: "..cclass})
    --  end
    --},
    -- Struts
    --{ rule = { class = "Pidgin", role="buddy_list" },
    --  properties = {
    --    floating = true,
    --     tag = tags[screen.count()][2]
    --  },
    --  callback = function(c)
    --    local w = screen[screen.count()].workarea
    --    local g = c:geometry()
    --      g.x = w.x + w.width - 150
    --      g.y = w.y
    --      g.width = 150
    --      g.height = w.height
    --    c:struts( { right = 150 } )
    --    c:geometry(g)
    --  end
    --},
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "mpv" },
      properties = { floating = true } },
    { rule = { class = "Pavucontrol" },
      properties = { floating = true } },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { class = "Plugin-container" },
      properties = { floating = true } },
    { rule = { class = "Wine" },
      properties = {
        floating = true,
        full_screen = true }
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
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  local titlebars_enabled = false
  if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
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
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
