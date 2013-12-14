-- Create a stats widget
local widget_stats = wibox.layout.fixed.horizontal()
-- "from" and "to" define coordinates of  a line along which the gradient spreads
local stats_grad = { type = "linear", from = { 0, 0 }, to = { 0, 18 }, stops = { { 0, "#dc322f" }, { 0.5, "#808000" }, { 1, "#859900" }}}
local stats_vol = { type = "linear", from = { 0, 0 }, to = { 0, 18 }, stops = { { 0, "#859900" }, { 0.5, "#566600" }, { 1, "#426600" }}}

-- invisible widget_separator with fixed width
local widget_sep = wibox.widget.base.empty_widget()
widget_sep.fit = function() return 3, 8 end
-- widget_separator arrow
local widget_sep_arrow = mwidget_arrow({"<span font_weight=\"ultrabold\">⮃</span>"}, {beautiful.fg_focus}, {beautiful.bg_normal}, 3)

-- Create a clock widget
local widget_clock = awful.widget.textclock(" %d %b %Y %H:%M ")
-- clock tooltip
local tooltip_clock = awful.tooltip({ objects = { widget_clock }, timeout = timeout_tooltip, timer_function = function()
  local title = os.date("%A %d %B %Y")
  local tlen = string.len(title)
  local text
  text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
         " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
  local day = os.date("%e")
  local date = awful.util.pread("cal | col -bx | sed '1d;s:^:    :;s:$:  :'")
  date = string.gsub(date, day, "<span color=\""..beautiful.fg_normal.."\">"..day.."</span>")
  text = text..date.." "
  return text
end})

-- {{{ CPU
vicious.cache(vicious.widgets.cpu)
local widget_cpu = wibox.layout.fixed.horizontal()
local widget_cpu_icon = mwidget_icon("◈", "top")
local widget_cpu_text = wibox.widget.textbox()
local widget_cpu_graph = awful.widget.graph()
local tooltip_cpu

widget_cpu_text.fit = function() return 35, 8 end
vicious.register(widget_cpu_text, vicious.widgets.cpu, " $1%", timeout_short)

widget_cpu_graph:set_width(30)
widget_cpu_graph:set_background_color(beautiful.bg_normal)
widget_cpu_graph:set_color(stats_grad)
widget_cpu_graph:set_border_color(beautiful.bg_normal)
vicious.register(widget_cpu_graph, vicious.widgets.cpu, "$1", timeout_medium)

tooltip_cpu = awful.tooltip({ objects = { widget_cpu }, timeout = timeout_tooltip, timer_function = function()
  info_cpu = vicious.widgets.cpu()
  local title = "cpu usage"
  local tlen = string.len(title)
  local text
  text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
         " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
  for core = 2, #info_cpu do
    text = text.." ◈ core"..(core-1).." <span color=\""..beautiful.fg_normal.."\">"..info_cpu[core].."</span> % "
    if core < #info_cpu then
      text = text.."\n"
    end
  end
  return text
end})

widget_cpu:add(widget_cpu_icon)
widget_cpu:add(widget_cpu_text)
widget_cpu:add(widget_cpu_graph)
-- }}} CPU

-- {{{ MEM
vicious.cache(vicious.widgets.mem)
local widget_mem = wibox.layout.fixed.horizontal()
local widget_mem_icon = mwidget_icon("◌", "top")
local widget_mem_text = wibox.widget.textbox()
local widget_mem_graph = awful.widget.graph()
local tooltip_mem

widget_mem_text.fit = function() return 35, 8 end
vicious.register(widget_mem_text, vicious.widgets.mem, " $1%", timeout_short)

widget_mem_graph:set_width(30)
widget_mem_graph:set_background_color(beautiful.bg_normal)
widget_mem_graph:set_color(stats_grad)
widget_mem_graph:set_border_color(beautiful.bg_normal)
vicious.register(widget_mem_graph, vicious.widgets.mem, "$1", timeout_medium)

tooltip_mem = awful.tooltip({ objects = { widget_mem }, timeout = timeout_tooltip, timer_function = function()
  local info_mem = vicious.widgets.mem()
  local title = "memory &amp; swap usage"
  local tlen = string.len(title)-4
  local text
  text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
         " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"..
         " ◌ memory <span color=\""..beautiful.fg_normal.."\">"..fstring(info_mem[2], 5).."/"..fstring(info_mem[3], 5).."</span> MB \n"..
         " ○ swap   <span color=\""..beautiful.fg_normal.."\">"..fstring(info_mem[6], 5).."/"..fstring(info_mem[7], 5).."</span> MB "
   return text
 end})

widget_mem:add(widget_mem_icon)
widget_mem:add(widget_mem_text)
widget_mem:add(widget_mem_graph)
-- }}} MEM

-- {{{ HDD
local widget_hdd
if HDD then
  widget_hdd = wibox.layout.fixed.horizontal()
  vicious.cache(vicious.widgets.fs)
  local widget_hdd_icon = mwidget_icon("⛁ ")
  local widget_hdd_bars = wibox.layout.fixed.horizontal()
  local widget_hdd_bar = {}
  local tooltip_hdd

  for p = 1, #HDD do
    widget_hdd_bar[p] = awful.widget.progressbar()
    widget_hdd_bar[p]:set_vertical(true)
    widget_hdd_bar[p]:set_height(20)
    widget_hdd_bar[p]:set_width(5)
    widget_hdd_bar[p]:set_background_color(beautiful.bg_normal)
    widget_hdd_bar[p]:set_color(stats_grad)
    vicious.register(widget_hdd_bar[p], vicious.widgets.fs,
      function (widget, args)
        return args["{"..HDD[p].." used_p}"]
      end,
    timeout_long)
    widget_hdd_bars:add(widget_hdd_bar[p])
    widget_hdd_bars:add(widget_sep)
  end

  tooltip_hdd = awful.tooltip({ objects = { widget_hdd } , timeout = timeout_tooltip, timer_function = function()
    info_hdd = vicious.widgets.fs()
    local title = "harddisk information"
    local tlen = string.len(title)
    local text
      text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
             " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
      for p = 1, #HDD do
        text = text.." ⛁ on "..
                 fstring(HDD[p], 10).." <span color=\""..beautiful.fg_normal.."\">"..
                 fstring(info_hdd["{"..HDD[p].." used_p}"], 3).."%  "..
                 fstring(info_hdd["{"..HDD[p].." used_gb}"], 5).."/"..
                 fstring(info_hdd["{"..HDD[p].." size_gb}"], 5).."</span> GB "
        if p < #HDD then
          text = text.."\n"
        end
      end
    return text
  end})

  widget_hdd:add(widget_hdd_icon)
  widget_hdd:add(widget_hdd_bars)
end
-- }}} HDD

-- {{{ MUSIC
if MPD then
  vicious.cache(vicious.widgets.mpd)
  widget_mpd = wibox.layout.fixed.horizontal()
  local widget_mpd_icon = mwidget_icon("▸")
  local widget_mpd_text = wibox.widget.textbox()
  local tooltip_mpd

  widget_mpd_text.fit = function(widget, width, height)
    local w, h = wibox.widget.textbox.fit(widget, width, height)
    return 300, h
  end
  vicious.register(widget_mpd_text, vicious.widgets.mpd,
    function (widget, args)
      if args["{state}"] == "Stop" then
        widget_mpd_icon:set_text("▹")
        return " - "
      elseif args["{state}"] == "Pause" then
        widget_mpd_icon:set_text("▹")
      else
        widget_mpd_icon:set_text("▸")
      end
      return args["{Artist}"].." - "..args["{Title}"]
    end,
  timeout_medium, MPD)

  tooltip_mpd = awful.tooltip({ objects = { widget_mpd }, timeout = timeout_tooltip, timer_function = function()
    local info_mpd = vicious.widgets.mpd(MPD)
    local title = "music information"
    local tlen = string.len(title)
    local len = math.max(string.len(info_mpd["{Artist}"]), string.len(info_mpd["{Album}"]), string.len(info_mpd["{Title}"]), 10)
    local text
    text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
           " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
    if info_mpd["{state}"] == "Stop" then
      text = text.." Status <span color=\""..beautiful.fg_normal.."\">"..fstring("stopped", len).." </span>"
    else
      if info_mpd["{state}"] == "Play" then
        text = text.." Status <span color=\""..beautiful.fg_normal.."\">"..fstring("playing" , len).." </span>\n"
      else
        text = text.." Status <span color=\""..beautiful.fg_normal.."\">"..fstring("paused", len).." </span>\n"
      end
      text = text.." Artist <span color=\""..beautiful.fg_normal.."\">"..fstring(info_mpd["{Artist}"], len).." </span>\n"..
                   " Album  <span color=\""..beautiful.fg_normal.."\">"..fstring(info_mpd["{Album}"], len).." </span>\n"..
                   " Title  <span color=\""..beautiful.fg_normal.."\">"..fstring(info_mpd["{Title}"], len).." </span>"
    end
    return text
  end})

  widget_mpd:add(widget_mpd_icon)
  widget_mpd:add(widget_mpd_text)
end
-- }}} MUSIC

-- {{{ VOLUME
vicious.cache(vicious.widgets.volume)
local widget_vol = wibox.layout.fixed.horizontal()
widget_vol_icon = mwidget_icon("♫")
widget_vol_bar = awful.widget.progressbar()
local tooltip_vol

widget_vol_bar:set_vertical(true)
widget_vol_bar:set_height(18)
widget_vol_bar:set_width(6)
widget_vol_bar:set_background_color(beautiful.bg_normal)
widget_vol_bar:set_color(stats_vol)
widget_vol_bar:set_border_color(beautiful.bg_normal)
vicious.register(widget_vol_bar, vicious.widgets.volume,
  function(widget, args)
    if args[2] == "♫" then
      widget_vol_bar:set_color(stats_vol)
      icon = "♫ "
    else
      widget_vol_bar:set_color(beautiful.fg_normal .. "40")
      icon = " ♯ "
    end
    widget_vol_icon:set_text(icon)
    return args[1]
  end,
timeout_medium, "Master")

tooltip_vol = awful.tooltip({ objects = { widget_vol }, timeout = timeout_tooltip, timer_function = function()
  local info_vol = vicious.widgets.volume(widget, "Master")
  local title = "volume information"
  local tlen = string.len(title)
  local text
  text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
         " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
  if info_vol[2] == "♫" then
    text = text.." state  <span color=\""..beautiful.fg_normal.."\">"..fstring("on", 3).." </span>\n"
  else
    text = text.." state  <span color=\""..beautiful.fg_normal.."\">"..fstring("off", 3).." </span>\n"
  end
  text = text.." volume <span color=\""..beautiful.fg_normal.."\">"..fstring(info_vol[1], 3).." </span> %"
  return text
end})

widget_vol:add(widget_vol_icon)
widget_vol:add(widget_vol_bar)
widget_vol:buttons(
  awful.util.table.join(
    awful.button({ }, 1, function() set_volume("toggle") end),
    awful.button({ }, 4, function() set_volume("increase") end),
    awful.button({ }, 5, function() set_volume("decrease") end)
))
-- }}} VOLUME

-- {{{ BATTERY
local widget_bat
if BAT then
  widget_bat = wibox.layout.fixed.horizontal()
  vicious.cache(vicious.widgets.bat)
  local widget_bat_icon = mwidget_icon("⚡")
  local widget_bat_text = wibox.widget.textbox()
  local tooltip_bat

  widget_bat_text.fit = function() return 50, 8 end
  vicious.register(widget_bat_text, vicious.widgets.bat, " $1$2%", timeout_medium, BAT)

  tooltip_bat = awful.tooltip({ objects = { widget_bat }, timeout = timeout_tooltip, timer_function = function()
    local info_bat = vicious.widgets.bat(widget, BAT)
    local title = "battery information"
    local tlen = string.len(title)
    local text
    text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
           " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
    if info_bat[1] == "-" then
      text = text.." ⚫ status    <span color=\""..beautiful.fg_normal.."\">"..fstring("discharging", 12).." </span>\n"
    else
      text = text.." ⚫ status    <span color=\""..beautiful.fg_normal.."\">"..fstring("charging", 12).." </span>\n"
    end
    text = text.." ⚡ charge    <span color=\""..beautiful.fg_normal.."\">"..fstring(info_bat[2], 11).."% </span>\n"..
                 " ◴ time left <span color=\""..beautiful.fg_normal.."\">"..fstring(info_bat[3], 12).." </span>"
    return text
  end})

  widget_bat:add(widget_bat_icon)
  widget_bat:add(widget_bat_text)
end
-- }}} BATTERY

-- {{{ MESSAGES
local widget_msg = wibox.layout.fixed.horizontal()
local widget_msg_icon = mwidget_icon("✉ ")
local tooltip_msg
messages = {}
messages.count = 0

local tooltip_msg = awful.tooltip({ objects = { widget_msg }, timeout = timeout_tooltip, timer_function = function()
  local title = "messages"
  local tlen = string.len(title)
  local text
  text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
         " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
  if (messages.count > 0) then
    for m=1, messages.count do
      text = text .."<span color=\"".. beautiful.fg_normal .."\">".. messages[m].name ..": </span>".. messages[m].text
      if (m < messages.count) then
        text = text .."\n"
      end
    end
  else
    text = text .."no messages"
  end
  return text
end})

widget_msg_text = wibox.widget.textbox()
widget_msg_text:set_text("-")
widget_msg:add(widget_msg_icon)
widget_msg:add(widget_msg_text)
widget_msg:buttons(
  awful.util.table.join(
    awful.button({ }, 1, function() message({action='reset'}) end)
))
-- }}} MESSAGES

-- {{{ NETWORK
local widget_net
widget_net = wibox.layout.fixed.horizontal()
vicious.cache(vicious.widgets.net)
local widget_net_icon_up = mwidget_icon("↑")
local widget_net_text_up = wibox.widget.textbox()
local widget_net_graph_up = awful.widget.graph()
local widget_net_icon_down = mwidget_icon("↓")
local widget_net_text_down = wibox.widget.textbox()
local widget_net_graph_down = awful.widget.graph()
local tooltip_net

vicious.register(widget_net_text_up, vicious.widgets.net,
  function (widget, args)
    for iface = 1, #NET do
      if (args["{"..NET[iface].." carrier}"] == 1) then
        return args["{" ..NET[iface].. " up_kb}"].."kb/s"
      end
    end
    return "0"
  end,
timeout_short)

widget_net_graph_up:set_width(30)
widget_net_graph_up:set_background_color(beautiful.bg_normal)
widget_net_graph_up:set_color(stats_grad)
widget_net_graph_up:set_border_color(beautiful.bg_normal)
vicious.register(widget_net_graph_up, vicious.widgets.net,
  function (widget, args)
    for iface = 1, #NET do
      if (args["{"..NET[iface].." carrier}"] == 1) then
        return args["{" ..NET[iface].. " up_kb}"]
      end
    end
    return "0"
  end,
timeout_short)

vicious.register(widget_net_text_down, vicious.widgets.net,
  function (widget, args)
    for iface = 1, #NET do
      if (args["{"..NET[iface].." carrier}"] == 1) then
        return args["{" ..NET[iface].. " down_kb}"].."kb/s"
      end
    end
    return "0"
  end,
timeout_short)

widget_net_graph_down:set_width(30)
widget_net_graph_down:set_background_color(beautiful.bg_normal)
widget_net_graph_down:set_color(stats_grad)
widget_net_graph_down:set_border_color(beautiful.bg_normal)
vicious.register(widget_net_graph_down, vicious.widgets.net,
  function (widget, args)
    for iface = 1, #NET do
      if (args["{"..NET[iface].." carrier}"] == 1) then
        return args["{" ..NET[iface].. " down_kb}"]
      end
    end
    return "0"
  end,
timeout_short)

tooltip_net = awful.tooltip({ objects = { widget_net }, timeout = timeout_tooltip, timer_function = function()
  local info_net = vicious.widgets.net(widget, net)
  local title = "network information"
  local tlen = string.len(title)
  local text
  text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
         " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
  for iface = 1, #NET do
    if (info_net["{"..NET[iface].." carrier}"] == 1) then
      text = text..
        " ↑ "..fstring(NET[iface], 6)..fstring(" up ", 6).."<span color=\""..beautiful.fg_normal.."\">"..fstring(info_net["{"..NET[iface].." up_kb}"  ], 8).." </span> kb/s\n"..
        fstring("sum ", 15).."<span color=\""..beautiful.fg_normal.."\">"..fstring(info_net["{"..NET[iface].." tx_mb}"  ], 8).." </span> MB\n"..
        " ↓ "..fstring(NET[iface], 6)..fstring(" down ", 6).."<span color=\""..beautiful.fg_normal.."\">"..fstring(info_net["{"..NET[iface].." down_kb}"], 8).." </span> kb/s\n"..
        fstring("sum ", 15).."<span color=\""..beautiful.fg_normal.."\">"..fstring(info_net["{"..NET[iface].." rx_mb}"  ], 8).." </span> MB\n"
      return text
    end
  end
  return ""
end})

widget_net:add(widget_net_icon_up)
widget_net:add(widget_net_text_up)
widget_net:add(widget_sep)
widget_net:add(widget_net_graph_up)
widget_net:add(widget_net_icon_down)
widget_net:add(widget_net_text_down)
widget_net:add(widget_sep)
widget_net:add(widget_net_graph_down)
-- }}} NETWORK

-- Put stats widget together
if MPD then
  widget_stats:add(widget_mpd)
  widget_stats:add(widget_sep_arrow)
end
widget_stats:add(widget_cpu)
widget_stats:add(widget_sep_arrow)
widget_stats:add(widget_mem)
widget_stats:add(widget_sep_arrow)
if HDD then
widget_stats:add(widget_hdd)
widget_stats:add(widget_sep_arrow)
end
widget_stats:add(widget_vol)
if BAT then
  widget_stats:add(widget_sep_arrow)
  widget_stats:add(widget_bat)
end
widget_stats:add(widget_sep_arrow)
widget_stats:add(widget_msg)
widget_stats:add(widget_sep_arrow)
widget_stats:add(widget_net)

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
    awful.button({ }, 1,
      function (c)
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
    awful.button({ }, 3,
      function ()
        if instance then
          instance:hide()
          instance = nil
        else
          instance = awful.menu.clients({ width=250 })
        end
      end),
    awful.button({ }, 4,
      function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
      end),
    awful.button({ }, 5,
      function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
      end)
  )

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
    left_layout:add(mytaglist[s])
    left_layout:add(mwidget_arrow({"⮀"}, {beautiful.bg_normal}, {beautiful.fg_focus}))
    left_layout:add(mwidget_bg(beautiful.fg_focus, mypromptbox[s]))
    left_layout:add(mwidget_arrow({"⮀"}, {beautiful.fg_focus}, {beautiful.bg_normal}))

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mwidget_arrow({"⮂", "⮂"}, {beautiful.fg_focus, beautiful.bg_normal}, {beautiful.bg_normal, beautiful.fg_focus}))
    right_layout:add(widget_stats)
    if s == 1 then
      right_layout:add(widget_sep_arrow)
      right_layout:add(wibox.widget.systray())
    end
    right_layout:add(widget_sep_arrow)
    right_layout:add(widget_clock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
