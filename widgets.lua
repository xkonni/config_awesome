local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local vicious = require("vicious")
widgets = {}

widgets.grad = {
  type = "linear",
  from = { 0, 0 }, to = { 0, 12 },
  stops = { { 0, "#dc322f" }, { 0.5, "#808000" }, { 1, "#859900" }}
}

function widgets.init(args)
  widgets.fg      = args.fg       or "#ffffff"
  widgets.bg      = args.bg       or "#000000"
  widgets.focus   = args.focus    or "#ff0000"
  widgets.border  = args.border   or "#0000ff"
  widgets.timeout = widgets.timeout  or 5
end

function widgets.background(args)
  widget_bg = wibox.widget.background()
  widget_bg:set_bg(args.bg)
  widget_bg:set_widget(args.widget)
  return widget_bg
end

-- create a separator
-- e.g. an arrow as transition between fg and bg color
-- args = {[sep_left=px], [sep_right=px], [symbol{}, [fg], [bg]]}
-- ⮃ ⮁ ⮂ ⮀
function widgets.sep(args)
  widget_sep = wibox.layout.fixed.horizontal()

  local sep_left = args.sep_left or 3
  widget_sep_left = wibox.widget.base.empty_widget()
  widget_sep_left.fit = function() return sep_left, 15 end

  local sep_right = args.sep_right or 3
  widget_sep_right = wibox.widget.base.empty_widget()
  widget_sep_right.fit = function() return sep_right, 15 end

  -- left spacing
  if args.sep_left then
    widget_sep:add(widget_sep_left)
  end

  if args.symbol then
    local fg = args.fg or widgets.focus
    local bg = args.bg or widgets.bg
    widget_fg = wibox.widget.textbox()
    widget_bg = wibox.widget.background()
    widget_fg:set_markup("<span size=\"22000\" color=\"".. fg .. "\">".. args.symbol .."</span>")
    widget_bg:set_bg(bg)
    widget_bg:set_widget(widget_fg)
    widget_sep:add(widget_bg)
  end

  -- right spacing
  if args.sep_right then
    widget_sep_right:add(widget_sep_right)
  end

  return widget_sep
end

-- create widget with a single, large symbol
function widgets.icon(symbol, valign)
  widget_icon = wibox.widget.textbox()
  widget_icon.fit = function() return 25, 8 end
  widget_icon:set_font("Anonymous Pro for Powerline 14")
  widget_icon:set_align("center")
  if valign then
    widget_icon:set_valign(valign)
  end
  widget_icon:set_text(symbol)
  return widget_icon
end

function widgets.text_vert(args)
  widget_text = wibox.layout.align.vertical()
  local widget_texts = {}
  for i=1,3 do
    widget_texts[i] = wibox.widget.textbox()
    widget_texts[i]:set_font("Inconsolata for Powerline 7")
    widget_texts[i]:set_markup("<span weight=\"bold\" color=\"" .. args.color .. "\">" .. args.text:sub(i,i) .. "</span>")
  end
  widget_text:set_first (widget_texts[1])
  widget_text:set_second(widget_texts[2])
  widget_text:set_third (widget_texts[3])
  return widget_text
end

function widgets.stats(args)
  widget_stats = wibox.layout.fixed.horizontal()
  local widget_text = widgets.text_vert({text=args.text, color=widgets.focus})
  local widget_info = widgets.info(args)

  widget_stats:add(widget_text)
  widget_stats:add(widgets.sep({sep_left=5}))
  widget_stats:add(widget_info)
  return widget_stats
end

function widgets.info(args)
  local string_post = args.string_post or ""
  local string_pre = args.string_pre or ""
  local id = args.id or 1
  widget_info = wibox.layout.fixed.horizontal()
    local widget_info_align = wibox.layout.align.vertical()
    -- textbox
    local widget_info_text = wibox.widget.textbox()
    widget_info_text:set_font("Inconsolata for Powerline 7")
    vicious.register(widget_info_text, args.vicious_module, function(widget, wargs)
      return string.format("%07s", string_pre .. " " .. math.floor(wargs[id])) .. string_post
    end, widgets.timeout)
    -- graph
    local widget_info_graph = awful.widget.graph()
    widget_info_graph:set_width(20)
    widget_info_graph:set_height(15)
    widget_info_graph:set_background_color(widgets.bg)
    widget_info_graph:set_color(widgets.grad)
    widget_info_graph:set_border_color(widgets.border)
    vicious.register(widget_info_graph, args.vicious_module, function(widget, wargs)
      return wargs[id]
    end, widgets.timeout)

    widget_info_align:set_first(widget_info_text)
    widget_info_align:set_second(widget_info_graph)
    widget_info:add(widget_info_align)
    widget_info:add(widgets.sep({sep_left=5}))

  return widget_info
end

-- preconfigured widgets
function widgets.bat(bat)
  vicious.cache(vicious.widgets.bat)
  local widget_bat = wibox.layout.fixed.horizontal()
  local widget_bat_text = widgets.text_vert({text="BAT", color=widgets.focus})
  local widget_bat_info_align = wibox.layout.align.vertical()

  -- textbox
  local widget_bat_info_text = wibox.widget.textbox()
  widget_bat_info_text:set_font("Inconsolata for Powerline 7")
  vicious.register(widget_bat_info_text, vicious.widgets.bat, function(widget, wargs)
    return string.format("%10s", wargs[1] .. wargs[2] .. "% " .. wargs[3])
  end, widgets.timeout, bat)

  -- progressbar
  local widget_bat_info_bar = awful.widget.progressbar()
  widget_bat_info_bar:set_height(6)
  widget_bat_info_bar:set_width(15)
  widget_bat_info_bar:set_background_color(widgets.bg)
  widget_bat_info_bar:set_color(widgets.fg)
  widget_bat_info_bar:set_border_color(widgets.border)
  widget_bat_info_bar:set_ticks(true)
  widget_bat_info_bar:set_ticks_gap(1)
  widget_bat_info_bar:set_ticks_size(2)
  vicious.register(widget_bat_info_bar, vicious.widgets.bat, "$2", widgets.timeout, bat)

  widget_bat_info_align:set_first (widget_bat_info_text)
  widget_bat_info_align:set_second (widget_bat_info_bar)

  widget_bat:add(widget_bat_text)
  widget_bat:add(widgets.sep({sep_left=5}))
  widget_bat:add(widget_bat_info_align)
  return widget_bat
end

function widgets.cpu()
  vicious.cache(vicious.widgets.cpu)
  widget_cpu = widgets.stats({
    text = "CPU",
    vicious_module = vicious.widgets.cpu,
    string_pre = "",
    string_post = "%"
  })
  return widget_cpu
end

function widgets.mem()
  vicious.cache(vicious.widgets.mem)
  widget_mem = widgets.stats({
    text = "MEM",
    vicious_module = vicious.widgets.mem,
    --id = 1,
    string_pre = "",
    string_post = "%"
  })
  return widget_mem
end

function widgets.net(interface)
  vicious.cache(vicious.widgets.net)
  widget_net = wibox.layout.fixed.horizontal()
  widget_net_text = widgets.text_vert({text="NET", color=widgets.focus})
  widget_net_up = widgets.info({
    vicious_module = vicious.widgets.net,
    id = "{" .. interface .. " up_kb}",
    string_pre = "↑",
    string_post = "kb"
  })
  widget_net_down = widgets.info({
    vicious_module = vicious.widgets.net,
    id = "{" .. interface .. " down_kb}",
    string_pre = "↓",
    string_post = "kb"
  })

  widget_net:add(widget_net_text)
  widget_net:add(widget_net_up)
  widget_net:add(widget_net_down)
  return widget_net
end

function widgets.mpd()
  vicious.cache(vicious.widgets.mpd)
  local widget_mpd = wibox.layout.fixed.horizontal()
  local widget_mpd_text = widgets.text_vert({text="MPD", color=widgets.focus})
  local widget_mpd_info = wibox.layout.align.vertical()

  local widget_mpd_infos = {}
  local strings = {
    {icon="★ ", id="{Artist}"},
    {icon="⚫ ", id="{Album}"},
    {icon="♫ ", id="{Title}"}
  }
  for i =1,3 do
    widget_mpd_infos[i] = wibox.widget.textbox()
    widget_mpd_infos[i]:set_font("Inconsolata for Powerline 7")

    vicious.register(widget_mpd_infos[i], vicious.widgets.mpd, function (widget, wargs)
      if wargs["{state}"] == "Stop" then
        if i == 2 then
          return " - "
        else
          return ""
        end
      else
        return "<span size=\"medium\">" .. strings[i].icon .. "</span>".. string.format("%15s", wargs[strings[i].id])
      end
    end, widgets.timeout)
  end

  widget_mpd_info:set_first (widget_mpd_infos[1])
  widget_mpd_info:set_second(widget_mpd_infos[2])
  widget_mpd_info:set_third (widget_mpd_infos[3])
  widget_mpd:add(widget_mpd_text)
  widget_mpd:add(widgets.sep({sep_left=5}))
  widget_mpd:add(widget_mpd_info)
  return widget_mpd
end

function widgets.msg_update(args)
  if (args.action == 'reset') then
    widgets.msg_count = 0
    widget_msg_info_icon:set_markup("<span color=\"" .. widgets.fg .. "\">✉ </span>")
    widget_msg_info_text:set_text("")
  else
    widgets.msg_count = widgets.msg_count + 1
    widget_msg_info_icon:set_markup("<span color=\"#859900\">✉ </span>")
    widget_msg_info_text:set_text(widgets.msg_count)
    if (args.active ~= 1) then
      naughty.notify({screen=screen.count(), timeout=args.timeout, title=args.title, text=args.text})
    end
  end
end

function widgets.msg()
  widgets.msg_count = 0
  local widget_msg = wibox.layout.fixed.horizontal()
  local widget_msg_text = widgets.text_vert({text="MSG", color=widgets.focus})
  local widget_msg_info = wibox.layout.align.vertical()
  widget_msg_info_icon = wibox.widget.textbox()
  widget_msg_info_icon:set_font("Inconsolata for Powerline 7")
  widget_msg_info_icon:set_markup("<span color=\"" .. widgets.fg .. "\">✉ </span>")
  widget_msg_info_text = wibox.widget.textbox()
  widget_msg_info_text:set_font("Inconsolata for Powerline 7")
  widget_msg_info_text:set_text("")

  widget_msg_info:set_first(widget_msg_info_icon)
  widget_msg_info:set_second(widget_msg_info_text)

  widget_msg:add(widget_msg_text)
  widget_msg:add(widgets.sep({sep_left=5}))
  widget_msg:add(widget_msg_info)
  return widget_msg
end

function widgets.vol_update(args)
  widget_vol_bar:set_value(args.volume)
  if args.status == 1 then
    widget_vol_bar:set_color(widgets.fg)
  else
    widget_vol_bar:set_color(widgets.fg .. "40")
  end
end

function widgets.vol()
  vicious.cache(vicious.widgets.volume)
  local widget_vol = wibox.layout.fixed.horizontal()
  local widget_vol_text = widgets.text_vert({text="VOL", color=widgets.focus})
  widget_vol_bar = awful.widget.progressbar()

  -- progressbar
  widget_vol_bar:set_vertical(true)
  widget_vol_bar:set_height(15)
  widget_vol_bar:set_width(6)
  widget_vol_bar:set_background_color(widgets.bg)
  widget_vol_bar:set_color(widgets.fg)
  widget_vol_bar:set_border_color(widgets.border)
  widget_vol_bar:set_ticks(true)
  widget_vol_bar:set_ticks_gap(1)
  widget_vol_bar:set_ticks_size(2)
  vicious.register(widget_vol_bar, vicious.widgets.volume,
    function(widget, wargs)
      if wargs[2] == "♫" then
        widget_vol_bar:set_color(widgets.fg)
      else
        widget_vol_bar:set_color(widgets.fg .. "40")
      end
      return wargs[1]
    end,
  widgets.timeout, "Master")

  widget_vol:add(widget_vol_text)
  widget_vol:add(widgets.sep({sep_left=5}))
  widget_vol:add(widget_vol_bar)
  return widget_vol
end

--tooltip_cpu = awful.tooltip({ objects = { widget_cpu }, timeout = timeout_tooltip, timer_function = function()
--  info_cpu = vicious.widgets.cpu()
--  local title = "cpu usage"
--  local tlen = string.len(title)
--  local text
--  text = " <span weight=\"bold\" color=\""..beautiful.fg_normal.."\">"..title.."</span> \n"..
--         " <span weight=\"bold\">"..string.rep("-", tlen).."</span> \n"
--  for core = 2, #info_cpu do
--    text = text.." ◈ core"..(core-1).." <span color=\""..beautiful.fg_normal.."\">"..info_cpu[core].."</span> % "
--    if core < #info_cpu then
--      text = text.."\n"
--    end
--  end
--  return text
--end})

widgets.textclock = awful.widget.textclock()

return widgets
