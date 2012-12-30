-- Standard awesome library
awful = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
beauty = require("beautiful")
-- Notification library
naughty = require("naughty")

-- 3.5
-- require("wibox")
-- textbox - migrated to wibox.widget.textbox()
-- imagebox - migrated to wibox.widget.imagebox()
-- systray - migrated to wibox.widget.systray())

-- get hostname
host = awful.util.pread("hostname | tr -d '\n'")
home = awful.util.pread("echo $HOME | tr -d '\n'")

-- Themes define colours, icons, and wallpapers
beautiful.init(home .."/.config/awesome/themes/black-blue/theme.lua")
--beautiful.init("/usr/share/awesome/themes/sky/theme.lua")

-- {{{ Variable definitions
-- This is used later as the default terminal and editor to run.
-- terminal = 'lxterminal'
terminal = 'urxvt'
terminal_class = 'URxvt'
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor


--if host == "remembrance" then
--  terminal = 'lxterminal'
--  terminal_class = 'Lxterminal'
--end

if host == "silence" or host == "remembrance" then
  vicious = require("vicious")
end


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

-- test if window floats
function floats(c)
  local ret = false
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
    ret = true
  end
  return ret
end

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

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })


-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- create arrow widgets
--status_right = widget({ type= "textbox" })
--status_left = widget({ type= "textbox" })
--status_center = widget({ type= "textbox" })
--status_right.text="<span color=\"#268bd2\">⮀</span>"
--status_left.text="<span color=\"#268bd2\">⮂ </span>"
--status_center.text="<span color=\"#268bd2\"> ▎</span>"

-- Create load widget
myload = widget({ type= "textbox" })
myload.text =  awful.util.pread(home .. "/bin/tmux-mem-cpu-load 0 0")
mytimer = timer({ timeout = 5 })
mytimer:add_signal("timeout", function()
                    myload.text = awful.util.pread(home .. "/bin/tmux-mem-cpu-load 0 0")
                  end)
mytimer:start()

-- Create a batwidget
batwidget = widget({ type = "textbox" })
batwidgeton = 0
-- Register widget
if host == "silence" then
  vicious.register(batwidget, vicious.widgets.bat, " $1$2% $3", 31, "BAT1")
  batwidgeton = 1
end
if host == "remembrance" then
  vicious.register(batwidget, vicious.widgets.bat, " $1$2% $3", 31, "BAT0")
  batwidgeton = 1
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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            theme.tasklist_right,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and theme.tasklist_center_left or nil,
        s == 1 and mysystray or nil,
        theme.tasklist_center_left,
        myload,
        s == 2 and theme.tasklist_left or nil,
        s == 1 and batwidgeton == 0 and theme.tasklist_left or nil,
        s == 1 and batwidgeton == 1 and theme.tasklist_center_left or nil,
        s == 1 and batwidgeton == 1 and batwidget or nil,
        s == 1 and batwidgeton == 1 and theme.tasklist_left or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
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
    awful.key({ modkey,           }, "q",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "w",  awful.tag.viewnext       ),
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

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
    awful.key({ modkey,           }, "b", function () awful.util.spawn(home .."/bin/chromium") end),
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
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),

    -- resize floating windows
    awful.key({ modkey, "Shift"   }, "Right",
    function(c)
      if floats(c) then
        local g = c:geometry()
        local w = screen[c.screen].workarea
        local inc = 100
        --if c.screen == 2 then
        --  w.width = w.width + screen[1].workarea.width
        --end
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
        g.x = w.x + w.width - g.width
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
        g.y = w.y + w.height - g.height
        c:geometry(g)
      end
    end),
    -- toggle always on top
    awful.key({ modkey,           }, "t",
        function (c)
          if floats(c) then
            c.above = not c.above
          end
        end),
    awful.key({ modkey, "Shift" }, "t", function (c)
      if c.titlebar then
        awful.titlebar.remove(c)
      else
        awful.titlebar.add(c, { modkey = modkey })
      end
    end)
--    awful.key({ modkey,           }, "m",
--        function (c)
--            --c.maximized_horizontal = not c.maximized_horizontal
--            --c.maximized_vertical   = not c.maximized_vertical
--            --awful.client.togglemarked()
--        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
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
                  end),
        -- all minimized clients are restored
        awful.key({ modkey, "Shift"   }, "n",
            function()
                local tag = awful.tag.selected()
                    for i=1, #tag:clients() do
                        tag:clients()[i].minimized=false
                        tag:clients()[i]:redraw()
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
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Pavucontrol" },
      properties = { floating = true } },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { class = "Exe" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Wicd-client.py" },
      properties = { floating = true } },
    { rule = { class = "Iceweasel", role="Manager" },
      properties = { floating = true } },
    { rule = { class = "Google-chrome" },
      properties = {    tag = tags[screen. count()][1] } },
    { rule = { class = "com-mathworks-util-PostVMInit" },
      callback = function(c)
        awful.titlebar.add(c)
      end
    },
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
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })
    -- Add a titlebar if client floats

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

-- outdated??
        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("focus", function(c)
  c.border_color = beautiful.border_focus
  if floats(c) then
    -- if not awful.rules.match(c, { class = "Pidgin" }) then
    if (not awful.rules.match(c, { class = "Pidgin" })) and (not awful.rules.match(c, { class = terminal_class })) then
      awful.titlebar.add(c)
    end
  end
end)

client.add_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
  if floats(c) then
    -- if not awful.rules.match(c, { class = "Pidgin" }) then
    if (not awful.rules.match(c, { class = "Pidgin" })) and (not awful.rules.match(c, { class = terminal_class })) then
      awful.titlebar.remove(c)
    end
  end
end)
client.add_signal("mark", function(c)
  c.border_color = beautiful.border_marked
end)

-- Autorun programs
awful.util.spawn(home .."/bin/autostart")
