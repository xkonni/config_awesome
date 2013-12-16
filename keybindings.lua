-- {{{ Mouse bindings }}}
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- mouse wheel
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))

-- {{{ Keyboard bindings }}}
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",    awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",   awful.tag.viewnext       ),
    awful.key({ modkey,           }, "`",       awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape",  awful.tag.history.restore),

    awful.key({ modkey,           }, "h",
        function ()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            --awful.client.focus.byidx( 1)
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            --awful.client.focus.byidx(-1)
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "l",
        function ()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left")   end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down")   end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up")     end),
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right")  end),
    --awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    --awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            --awful.client.focus.history.previous()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal, false) end),
    awful.key({ modkey, "Control" }, "s", function () awful.util.spawn(config .. "/i3lock", false) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    --awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    --awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    --awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    --awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Power
    awful.key({                   }, "XF86HomePage",             function ()
        awful.util.spawn(home .. "/bin/powerswitch 1 0", false)
        awful.util.spawn("systemctl suspend", false)
      end),
    awful.key({                   }, "XF86Mail",           function ()
        awful.util.spawn(home .. "/bin/powerswitch 1 0", false)
        awful.util.spawn("systemctl hibernate", false)
    end),

    -- Media
    awful.key({                   }, "XF86AudioMute",         function () set_volume("toggle")   end),
    awful.key({                   }, "XF86AudioLowerVolume",  function () set_volume("decrease") end),
    awful.key({                   }, "XF86AudioRaiseVolume",  function () set_volume("increase") end),

    awful.key({                   }, "XF86AudioNext",         function () awful.util.spawn(home .."/bin/notify_mpd next", false) end),
    awful.key({                   }, "XF86AudioPlay",         function () awful.util.spawn(home .."/bin/notify_mpd toggle", false) end),
    awful.key({                   }, "XF86AudioStop",         function () awful.util.spawn(home .."/bin/notify_mpd stop", false) end),
    awful.key({                   }, "XF86AudioPrev",         function () awful.util.spawn(home .."/bin/notify_mpd prev", false) end),

    awful.key({                   }, "XF86Eject",             function () awful.util.spawn(home .."/bin/notify_mpd switch", false) end),
    awful.key({                   }, "XF86Tools",             function () awful.util.spawn(home .."/bin/notify_mpd", false) end),

    awful.key({ modkey,           }, "F1",                    function () awful.util.spawn(home .."/bin/powerswitch screen 1", false) end),
    awful.key({ modkey, "Shift"   }, "F1",                    function () awful.util.spawn(home .."/bin/powerswitch screen 0", false) end),
    awful.key({ modkey,           }, "F2",                    function () awful.util.spawn(home .."/bin/powerswitch desklight 1", false) end),
    awful.key({ modkey, "Shift"   }, "F2",                    function () awful.util.spawn(home .."/bin/powerswitch desklight 0", false) end),

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
    awful.key({ modkey }, "p", function() menubar.show() end),
    -- Scratchpad
    -- scratch.pad.toggle(screen)
    awful.key({ modkey }, "s", function () scratch.pad.toggle(mouse.screen) end),
    -- scratch.pad.drop(prog, vert, horiz, width, height, sticky, screen)
    awful.key({ modkey }, "c", function () scratch.drop(terminal, "bottom", "center", 0.7, 0.45, false, 1) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "r",      function (c) resize(c)                         end),
    awful.key({ modkey, "Shift"   }, "m",      function (c) move(c)                           end),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen   end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                          end),
    awful.key({ modkey, "Control" }, "space",
        function (c)
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
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster())  end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                         ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop             end),
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
    -- enable/disable titlebar
    awful.key({ modkey,           }, "t", function (c)
      awful.titlebar.toggle(c)
    end),
    awful.key({ modkey, "Control" }, "t", function (c)
      c.sticky =  not c.sticky
    end),
    -- Scratchpad
    -- scratch.pad.set(c, width, height, sticky) end)
    awful.key({ modkey, "Shift"   }, "s", function (c) scratch.pad.set(c, 0.50, 0.50, true) end)
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
                            if tags[screen][i].selected then
                                awful.tag.history.restore(screen)
                            else
                                awful.tag.viewonly(tags[screen][i])
                            end
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
