-- Create a separator widget with a fixed width
sep = wibox.widget.base.empty_widget()
sep.fit = function() return 3, 8 end

-- Create a clock widget
widget_clock = awful.widget.textclock(" %d %b %Y %H:%M ")
-- clock tooltip
tooltip_clock = awful.tooltip({ objects = { widget_clock }, timeout = timeout_tooltip, timer_function = function()
  local title = os.date("%A %d %B %Y")
  local len = string.len(title)+2
  local text
  text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
         " "..string.rep("-", len).." \n"
  local day = awful.util.pread("date +%d | sed 's/^0/ /' | tr -d '\n'")
  local date = awful.util.pread("cal | sed '1d;$d;s/^/   /;s/$/ /;s:"..day..":<span weight=\"bold\" color=\""..theme.fg_normal.."\">"..day.."</span>:'")
  text = text.." "..date.." "
  return text
end})

-- Create a stats widget
widget_stats = wibox.layout.fixed.horizontal()
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
-- cpu icon
widget_cpu_icon = mwidget_icon("◈")
-- cpu text
widget_cpu_text = wibox.widget.textbox()
widget_cpu_text.fit = function() return 35, 8 end
vicious.register(widget_cpu_text, vicious.widgets.cpu, " $1%", timeout_short)
-- cpu graph
widget_cpu_graph = awful.widget.graph()
widget_cpu_graph:set_width(30)
widget_cpu_graph:set_background_color(stats_bg)
widget_cpu_graph:set_color(stats_grad)
widget_cpu_graph:set_border_color(stats_bg)
vicious.register(widget_cpu_graph, vicious.widgets.cpu, "$1", timeout_medium)
-- cpu tooltip
tooltip_cpu = awful.tooltip({ objects = { widget_cpu }, timeout = timeout_tooltip, timer_function = function()
  info_cpu = vicious.widgets.cpu()
  local title = "cpu usage"
  local len = string.len(title)+2
  local text
  text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
         " "..string.rep("-", len).." \n"
  for core = 2, #info_cpu do
    text = text.." ◈ core"..(core-1).." <span color=\""..theme.fg_normal.."\">"..info_cpu[core].."</span> % "
    if core < #info_cpu then
      text = text.."\n"
    end
  end
  return text
end})
-- put it together
widget_cpu:add(widget_cpu_icon)
widget_cpu:add(widget_cpu_text)
widget_cpu:add(widget_cpu_graph)
-- }}} CPU

-- {{{ MEM
vicious.cache(vicious.widgets.mem)
widget_mem = wibox.layout.fixed.horizontal()
-- mem icon
widget_mem_icon = mwidget_icon("◌")
-- mem text
widget_mem_text = wibox.widget.textbox()
widget_mem_text.fit = function() return 35, 8 end
vicious.register(widget_mem_text, vicious.widgets.mem, " $1%", timeout_short)
-- mem bar
widget_mem_graph = awful.widget.graph()
widget_mem_graph:set_width(30)
widget_mem_graph:set_background_color(stats_bg)
widget_mem_graph:set_color(stats_grad)
widget_mem_graph:set_border_color(stats_bg)
vicious.register(widget_mem_graph, vicious.widgets.mem, "$1", timeout_medium)
-- mem tooltip
tooltip_mem = awful.tooltip({ objects = { widget_mem }, timeout = timeout_tooltip, timer_function = function()
  info_mem = vicious.widgets.mem()
  local title = "memory &amp; swap usage"
  local tlen = string.len(title)+2-4
  local text
  text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
         " "..string.rep("-", tlen).." \n"..
         " ◌ memory <span color=\""..theme.fg_normal.."\">"..prettystring(info_mem[2], 5, " ").."/"..prettystring(info_mem[3], 5, " ").."</span> MB \n"..
         " ○ swap   <span color=\""..theme.fg_normal.."\">"..prettystring(info_mem[6], 5, " ").."/"..prettystring(info_mem[7], 5, " ").."</span> MB "
   return text
 end})
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
tooltip_hdd = awful.tooltip({ objects = { widget_hdd } , timeout = timeout_tooltip, timer_function = function()
  info_hdd = vicious.widgets.fs()
  local title = "harddisk information"
  local tlen = string.len(title)+2
  local text
    text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
           " "..string.rep("-", tlen).." \n"
    for p = 1, #partitions do
      text = text.." ⛁ on "..
               prettystring(partitions[p], 10, " ").." <span color=\""..theme.fg_normal.."\">"..
               prettystring(info_hdd["{"..partitions[p].." used_p}"], 3, " ").."%  "..
               prettystring(info_hdd["{"..partitions[p].." used_gb}"], 5, " ").."/"..
               prettystring(info_hdd["{"..partitions[p].." size_gb}"], 5, " ").."</span> GB "
      if p < #partitions then
        text = text.."\n"
      end
    end
  return text
end})
-- put it together
widget_hdd:add(widget_hdd_icon)
widget_hdd:add(widget_hdd_bars)
-- }}} HDD

-- {{{ MUSIC
if not laptop then
  vicious.cache(vicious.widgets.mpd)
  widget_mpd = wibox.layout.fixed.horizontal()
  -- mpd icon
  widget_mpd_icon = mwidget_icon(" ▸ ")
  -- mpd text
  widget_mpd_text = wibox.widget.textbox()
  widget_mpd_text.fit = function(widget, width, height)
    local w, h = wibox.widget.textbox.fit(widget, width, height)
    return math.min(w, 300), h
  end
  vicious.register(widget_mpd_text, vicious.widgets.mpd,
    function (widget, args)
      if args["{state}"] == "Stop" then
        widget_mpd_icon:set_text(" ▹ ")
        return " - "
      elseif args["{state}"] == "Pause" then
        widget_mpd_icon:set_text(" ▹ ")
      else
        widget_mpd_icon:set_text(" ▸ ")
      end
      return args["{Artist}"].." - "..args["{Title}"].." "
  end, timeout_medium)
  -- mpd tooltip
  tooltip_mpd = awful.tooltip({ objects = { widget_mpd }, timeout = timeout_tooltip, timer_function = function()
    local info_mpd = vicious.widgets.mpd()
    local title = "music information"
    local tlen = string.len(title)+2
    local len = math.max(string.len(info_mpd["{Artist}"]), string.len(info_mpd["{Album}"]), string.len(info_mpd["{Title}"]), 10)
    local text
    text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
           " "..string.rep("-", tlen).." \n"
    if info_mpd["{state}"] == "Stop" then
      text = text.." Status <span color=\""..theme.fg_normal.."\">"..prettystring("stopped", len, " ").." </span>"
    else
      if info_mpd["{state}"] == "Play" then
        text = text.." Status <span color=\""..theme.fg_normal.."\">"..prettystring("playing" , len, " ").." </span>\n"
      else
        text = text.." Status <span color=\""..theme.fg_normal.."\">"..prettystring("paused", len, " ").." </span>\n"
      end
      text = text.." Artist <span color=\""..theme.fg_normal.."\">"..prettystring(info_mpd["{Artist}"], len, " ").." </span>\n"..
                   " Album  <span color=\""..theme.fg_normal.."\">"..prettystring(info_mpd["{Album}"], len, " ").." </span>\n"..
                   " Title  <span color=\""..theme.fg_normal.."\">"..prettystring(info_mpd["{Title}"], len, " ").." </span>"
    end
    return text
  end})
  -- put it together
  widget_mpd:add(widget_mpd_icon)
  widget_mpd:add(widget_mpd_text)
end
-- }}} MUSIC

-- {{{ VOLUME
vicious.cache(vicious.widgets.volume)
widget_vol = wibox.layout.fixed.horizontal()
-- vol icon
widget_vol_icon = wibox.widget.textbox()
widget_vol_icon:set_font("Anonymous Pro for Powerline 14")
-- vol bars
widget_vol_bar = awful.widget.progressbar()
widget_vol_bar:set_vertical(true)
widget_vol_bar:set_height(20)
widget_vol_bar:set_width(5)
widget_vol_bar:set_background_color(stats_bg)
widget_vol_bar:set_color(theme.bg_normal.."A0")
widget_vol_bar:set_border_color(stats_bg)
vicious.register(widget_vol_bar, vicious.widgets.volume,
  function(widget, args)
    if args[2] == "♫" then
      widget_vol_icon:set_text(args[2].." ")
      widget_vol_bar:set_color(theme.bg_normal.."A0")
    else
      widget_vol_icon:set_text(args[2].." ")
      widget_vol_bar:set_color(theme.bg_focus.."40")
    end
    return args[1]
  end,
timeout_medium, "Master")
-- vol tooltip
tooltip_vol = awful.tooltip({ objects = { widget_vol }, timeout = timeout_tooltip, timer_function = function()
  info_vol = vicious.widgets.volume(widget, "Master")
  local title = "volume information"
  local tlen = string.len(title)+2
  local text
  text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
         " "..string.rep("-", tlen).." \n"
  if info_vol[2] == "♫" then
    text = text.." state  <span color=\""..theme.fg_normal.."\">"..prettystring("on", 3, " ").." </span>\n"
  else
    text = text.." state  <span color=\""..theme.fg_normal.."\">"..prettystring("off", 3, " ").." </span>\n"
  end
  text = text.." volume <span color=\""..theme.fg_normal.."\">"..prettystring(info_vol[1], 3, " ").." </span> %"
  return text
end})
-- put it together
widget_vol:add(widget_vol_icon)
widget_vol:add(widget_vol_bar)
widget_vol:add(sep)
-- }}} VOLUME

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
  tooltip_bat = awful.tooltip({ objects = { widget_bat }, timeout = timeout_tooltip, timer_function = function()
    local info_bat = vicious.widgets.bat(widget, BAT)
    local title = "battery information"
    local tlen = string.len(title)+2
    local text
    text = " <span weight=\"bold\" color=\""..theme.fg_normal.."\">"..title.."</span> \n"..
           " "..string.rep("-", tlen).." \n"
    if info_bat[1] == "-" then
      text = text.." ⚫ status    <span color=\""..theme.fg_normal.."\">"..prettystring("discharging", 12, " ").." </span>\n"
    else
      text = text.." ⚫ status    <span color=\""..theme.fg_normal.."\">"..prettystring("charging", 12, " ").." </span>\n"
    end
    text = text.." ⚡ charge    <span color=\""..theme.fg_normal.."\">"..prettystring(info_bat[2], 11, " ").."% </span>\n"..
                 " ◴ time left <span color=\""..theme.fg_normal.."\">"..prettystring(info_bat[3], 12, " ").." </span>"
    return text
  end})
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
end
widget_stats:add(widget_stats_arrow)
widget_stats:add(widget_vol)
if laptop then
  widget_stats:add(widget_stats_arrow)
  widget_stats:add(widget_bat)
end
