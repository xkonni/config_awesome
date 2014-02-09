local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local vicious = require("vicious")

-- attributes & variables
widgets = {}
widgets.grad = {
  type = "linear",
  from = { 0, 0 }, to = { 0, 12 },
  stops = { { 0, "#dc322f" }, { 0.5, "#808000" }, { 1, "#859900" }}
}

-- local helper functions
local function _textbox(args)
  local widget = wibox.widget.textbox()
  widget:set_font("Inconsolata for Powerline 7")

  if args then
    local text = "<span "
    if args.color then text = text .. "color=\"" .. args.color .. "\"" end
    if args.weight then text = text .. "weight=\"" .. args.weight .. "\"" end
    text = text .. ">"
    if args.text then text = text .. args.text end
    text = text .. "</span>"
    widget:set_markup(text)
  end

  return widget
end

local function _text_vertical(args)
  widget = wibox.layout.align.vertical()
  widget:set_first (_textbox({color=args.color, weight=bold, text=args.text:sub(1,1)}))
  widget:set_second(_textbox({color=args.color, weight=bold, text=args.text:sub(2,2)}))
  widget:set_third (_textbox({color=args.color, weight=bold, text=args.text:sub(3,3)}))
  return widget
end

local function _info(args)
  local string_post = args.string_post or ""
  local string_pre = args.string_pre or ""
  local id = args.id or 1
  widget_info = wibox.layout.fixed.horizontal()
    local widget_info_align = wibox.layout.align.vertical()
    -- textbox
    local widget_info_text = _textbox()
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

local function _stats(args)
  widget_stats = wibox.layout.fixed.horizontal()
  local widget_text = _text_vertical({text=args.text, color=widgets.focus})
  local widget_info = _info(args)

  widget_stats:add(widget_text)
  widget_stats:add(widgets.sep({sep_left=5}))
  widget_stats:add(widget_info)
  return widget_stats
end
-- end

-- public functions
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
  local widget_sep = wibox.layout.fixed.horizontal()

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
-- end

-- preconfigured widgets
function widgets.bat(bat)
  vicious.cache(vicious.widgets.bat)
  local widget_bat = wibox.layout.fixed.horizontal()
  local widget_bat_text = _text_vertical({text="BAT", color=widgets.focus})
  local widget_bat_info_align = wibox.layout.align.vertical()

  -- textbox
  local widget_bat_info_text = _textbox()
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
  widget_cpu = _stats({
    text = "CPU",
    vicious_module = vicious.widgets.cpu,
    string_pre = "",
    string_post = "%"
  })
  return widget_cpu
end

function widgets.mem()
  vicious.cache(vicious.widgets.mem)
  widget_mem = _stats({
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
  widget_net_text = _text_vertical({text="NET", color=widgets.focus})
  widget_net_up = _info({
    vicious_module = vicious.widgets.net,
    id = "{" .. interface .. " up_kb}",
    string_pre = "↑",
    string_post = "kb"
  })
  widget_net_down = _info({
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
  local widget = wibox.layout.fixed.horizontal()
  local widget_text = _text_vertical({text="MPD", color=widgets.focus})
  local widget_info = wibox.layout.align.vertical()

  local widget_artist = _textbox()
  local widget_title  = _textbox()
  vicious.register(widget_title, vicious.widgets.mpd, function (widget, wargs)
    if wargs["{state}"] == "Stop" then
      widget_artist:set_text("")
      return " - "
    else

      widget_artist:set_text("★ " .. wargs["{Artist}"] .. " ⚫ " .. wargs["{Album}"])
      return "♫ " .. wargs["{Title}"]
    end
  end, widgets.timeout)
  widget_info:set_first (widget_artist)
  widget_info:set_second(widget_title)

  widget:add(widget_text)
  widget:add(widgets.sep({sep_left=5}))
  widget:add(widget_info)
  return widget
end

function widgets.msg()
  msg = {}
  msg.count = 0

  msg.title = _text_vertical({text="MSG", color=widgets.focus})
  msg.info = wibox.layout.align.vertical()
  msg.icon = _textbox({color=widgets.fg, text="✉ "})
  msg.text = _textbox()
  msg.info:set_first(msg.icon)
  msg.info:set_second(msg.text)

  msg.widget = wibox.layout.fixed.horizontal()

  function msg.update(args)
    if (args.action == 'reset') then
      msg.count = 0
      msg.icon:set_markup("<span color=\"" .. widgets.fg .. "\">✉ </span>")
      msg.text:set_text("")
    else
      msg.count = msg.count + 1
      msg.icon:set_markup("<span color=\"#859900\">✉ </span>")
      msg.text:set_text(msg.count)
      if (args.active ~= 1) then
        naughty.notify({screen=screen.count(), timeout=args.timeout, title=args.title, text=args.text})
      end
    end
  end

  msg.widget:add(msg.title)
  msg.widget:add(widgets.sep({sep_left=5}))
  msg.widget:add(msg.info)
  return msg
end

function widgets.vol()
  vol = {}
  vol.level = 0

  vol.title = _text_vertical({text="VOL", color=widgets.focus})
  vol.widget = wibox.layout.fixed.horizontal()
  vol.bar = awful.widget.progressbar()
  vol.notify = nil

  function vol.increase()
    awful.util.spawn(functions.home .."/bin/set_volume increase", false)
    naughty.destroy(vol.notify)
    local info_vol = vicious.widgets.volume(widget, "Master")
    local text
    if info_vol[2] == "♫" then
      text = "["..info_vol[1].."%] [on]"
    else
      text = "["..info_vol[1].."%] [off]"
    end

    vol.bar:set_value(info_vol[1]/100)
    vol.notify = naughty.notify({screen=screen.count(), title="volume", text=text})
  end

  function vol.decrease()
    awful.util.spawn(functions.home .."/bin/set_volume decrease", false)
    naughty.destroy(vol.notify)
    local info_vol = vicious.widgets.volume(widget, "Master")
    local text

    if info_vol[2] == "♫" then
      text = "["..info_vol[1].."%] [on]"
    else
      text = "["..info_vol[1].."%] [off]"
    end

    vol.bar:set_value(info_vol[1]/100)
    vol.notify = naughty.notify({screen=screen.count(), title="volume", text=text})
  end

  function vol.toggle()
    awful.util.spawn(functions.home .."/bin/set_volume toggle", false)
    naughty.destroy(vol.notify)
    local info_vol = vicious.widgets.volume(widget, "Master")
    local text
    if info_vol[2] ~= "♫" then
      text = "["..info_vol[1].."%] [on]"
      vol.bar:set_color(widgets.fg)
    else
      text = "["..info_vol[1].."%] [off]"
      vol.bar:set_color(widgets.fg .. "40")
    end

    vol.notify = naughty.notify({screen=screen.count(), title="volume", text=text})
  end

  vicious.cache(vicious.widgets.volume)
  widget:buttons(
    awful.util.table.join(
      awful.button({ }, 1, function() vol.toggle() end),
      awful.button({ }, 4, function() vol.increase() end),
      awful.button({ }, 5, function() vol.decrease() end)
  ))

  -- progressbar
  vol.bar:set_vertical(true)
  vol.bar:set_height(15)
  vol.bar:set_width(6)
  vol.bar:set_background_color(widgets.bg)
  vol.bar:set_color(widgets.fg)
  vol.bar:set_border_color(widgets.border)
  vol.bar:set_ticks(true)
  vol.bar:set_ticks_gap(1)
  vol.bar:set_ticks_size(2)
  vicious.register(vol.bar, vicious.widgets.volume,
    function(widget, wargs)
      if wargs[2] == "♫" then
        vol.bar:set_color(widgets.fg)
      else
        vol.bar:set_color(widgets.fg .. "40")
      end
      return wargs[1]
    end,
  widgets.timeout, "Master")

  vol.widget:add(vol.title)
  vol.widget:add(widgets.sep({sep_left=5}))
  vol.widget:add(vol.bar)
  return vol
end
-- end

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
