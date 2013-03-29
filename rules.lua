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
    --
    -- WM_CLASS(STRING) = "Download", "Firefox"
    --{ rule = { class = "Firefox", instance="Download" },
    --  properties = { floating = true } },
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
    { rule = { class = "Firefox", role="Manager" },
      properties = { floating = true } },
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
