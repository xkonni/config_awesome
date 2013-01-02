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

if host == "silence" then
  vicious = require("vicious")
  BAT = "BAT1"
  laptop = 1

elseif host == "remembrance" then
  vicious = require("vicious")
  BAT = "BAT0"
  laptop = 1

else
  laptop = 0
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
function arrow_widget(fg, bg, direction)
  local widget_bg = wibox.widget.background()
  local widget_fg = wibox.widget.textbox()

  local arrow="|"
  if direction == "left"   then arrow = " ⮂" end
  if direction == "right"  then arrow = "⮀ " end

  widget_fg:set_font("Anonymous Pro for Powerline 20")
  widget_fg:set_markup("<span color=\"".. fg .. "\">".. arrow .."</span>")
  widget_bg:set_bg(bg)

  widget_bg:set_widget(widget_fg)
  return widget_bg
end

-- color the background of a widget
function bg_widget(bg, widget)
  local widget_bg = wibox.widget.background()
  widget_bg:set_bg(bg)
  widget_bg:set_widget(widget)
  return widget_bg
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
-- change size in 3.5
-- 15:33 < psychon> sep = wibox.widget.base.empty_widget()
-- 15:33 < psychon> sep.fit = function() return 20, 8 end
-- 14:39 < psychon>
--    mybox.fit = function(widget, width, height)
--      local width, height = wibox.widget.textbox.fit(widget, width, height)
--      return math.min(width, 100), height end

-- Create a separator widget with a fixed width
sep = wibox.widget.base.empty_widget()
sep.fit = function() return 3, 8 end

-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create load widget
myload = wibox.widget.textbox()
myload:set_markup("<span color=\"".. theme.bg_focus .."\">".. awful.util.pread(home .."/bin/tmux-mem-cpu-load 0 0") .."</span>")
myload_timer = timer({ timeout = 5 })
myload_timer:connect_signal("timeout", function()
                    myload:set_markup("<span color=\"".. theme.bg_focus .."\">".. awful.util.pread(home .."/bin/tmux-mem-cpu-load 0 0") .."</span>")
                  end)
myload_timer:start()

if laptop == 1 then
  -- Create a batwidget
  batwidget = wibox.widget.textbox()
  vicious.register(batwidget, vicious.widgets.bat, " $1$2% $3", 31, BAT)
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
    left_layout:add(arrow_widget(theme.bg_normal, theme.fg_focus, "right"))
    left_layout:add(bg_widget(theme.fg_focus, mypromptbox[s]))
    left_layout:add(arrow_widget(theme.fg_focus, theme.bg_normal, "right"))

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(arrow_widget(theme.fg_focus, theme.bg_normal, "left"))
    right_layout:add(bg_widget(theme.fg_focus, myload))
    if s == 1 then
      right_layout:add(arrow_widget(theme.bg_focus, theme.fg_focus, "left"))
      right_layout:add(wibox.widget.systray())
      if laptop == 1 then
      --if (s == 1 and laptop == 0) then
        --batwidget:set_text("bla")
        right_layout:add(arrow_widget(theme.fg_focus, theme.bg_focus, "left"))
        right_layout:add(bg_widget(theme.fg_focus, batwidget))
        right_layout:add(arrow_widget(theme.bg_normal, theme.fg_focus, "left"))
      else
        right_layout:add(arrow_widget(theme.bg_normal, theme.bg_focus, "left"))
      end
    else
      right_layout:add(arrow_widget(theme.bg_normal, theme.fg_focus, "left"))
    end
    right_layout:add(mytextclock)
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
                  titlebar_disable(c)
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
    { rule = { class = "Google-chrome" },
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
  if floats(c) then
    if (not awful.rules.match(c, { class = "Pidgin" })) and (not awful.rules.match(c, { class = terminal_class })) then
      titlebar_enable(c)
    end
  end
end)

-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
  if floats(c) then
    if (not awful.rules.match(c, { class = "Pidgin" })) and (not awful.rules.match(c, { class = terminal_class })) then
      titlebar_disable(c)
    end
  end
end)

-- Autorun programs
awful.util.spawn(home .."/bin/autostart")
