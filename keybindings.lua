-- {{{ Mouse bindings }}}
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- mouse wheel
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))

-- {{{ Keyboard bindings }}}
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
    awful.key({                   }, "XF86Sleep",             function () awful.util.spawn("systemctl suspend") end),
    awful.key({                   }, "XF86Suspend",           function () awful.util.spawn("systemctl hibernate") end),

    -- Media
    awful.key({                   }, "XF86AudioMute",         function () set_volume("toggle")   end),
    awful.key({                   }, "XF86AudioLowerVolume",  function () set_volume("decrease") end),
    awful.key({                   }, "XF86AudioRaiseVolume",  function () set_volume("increase") end),

    awful.key({                   }, "XF86AudioNext",         function () awful.util.spawn(home .."/bin/notify_mpd next") end),
    awful.key({                   }, "XF86AudioPlay",         function () awful.util.spawn(home .."/bin/notify_mpd toggle") end),
    awful.key({                   }, "XF86AudioStop",         function () awful.util.spawn(home .."/bin/notify_mpd stop") end),
    awful.key({                   }, "XF86AudioPrev",         function () awful.util.spawn(home .."/bin/notify_mpd prev") end),

    awful.key({                   }, "XF86WebCam",            function () awful.util.spawn(home .."/bin/notify_mpd switch") end),
    awful.key({                   }, "XF86Display",           function () awful.util.spawn(home .."/bin/notify_mpd") end),

    -- Prompt
    awful.key({ modkey },            "r",                     function () mypromptbox[mouse.screen]:run() end),

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
        g.x = w.x + w.width - g.width - 2*beautiful.border_width
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
        g.y = w.y + w.height - g.height - 2*beautiful.border_width
        c:geometry(g)
      end
    end),
    awful.key({ modkey, "Shift" }, "t", function (c)
      titlebar_disable(c)
    end),
    awful.key({ modkey, "Control" }, "t", function (c)
      c.sticky =  not c.sticky
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
