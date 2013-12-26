local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
widgets = {}
widgets.grad = {
  type = "linear",
  from = { 0, 0 },
  to = { 0, 12 },
  stops = { { 0, "#dc322f" }, { 0.5, "#808000" }, { 1, "#859900" }}
}

local widget_sep = wibox.widget.base.empty_widget()
widget_sep.fit = function() return 3, 8 end

-- create an arrow as transition between fg and bg color
function widgets.arrow(arrow, fg, bg, sep)
  -- ⮃ ⮁ ⮂ ⮀
  local widget_arrow = wibox.layout.fixed.horizontal()
  local widget_fg = {}
  local widget_bg = {}
  if sep then
    widget_sep = wibox.widget.base.empty_widget()
    widget_sep.fit = function() return sep, 8 end
    widget_arrow:add(widget_sep)
  end
  for w = 1, #arrow do
    widget_fg[w] = wibox.widget.textbox()
    widget_bg[w] = wibox.widget.background()
    widget_fg[w]:set_markup("<span size=\"22000\" color=\"".. fg[w] .. "\">".. arrow[w] .."</span>")
    widget_bg[w]:set_bg(bg[w])
    widget_bg[w]:set_widget(widget_fg[w])
    widget_arrow:add(widget_bg[w])
  end
  if sep then widget_arrow:add(widget_sep) end
  return widget_arrow
end

-- create widget with a single, large symbol
function widgets.icon(symbol, valign)
  local widget_icon = wibox.widget.textbox()
  widget_icon.fit = function() return 25, 8 end
  widget_icon:set_font("Anonymous Pro for Powerline 14")
  widget_icon:set_align("center")
  if valign then
    widget_icon:set_valign(valign)
  end
  widget_icon:set_text(symbol)
  return widget_icon
end

-- color the background of a widget
--function widgets.bg(bg, widget)
--  local widget_bg = wibox.widget.background()
--  widget_bg:set_bg(bg)
--  widget_bg:set_widget(widget)
--  return widget_bg
--end

function widgets.text_vert(text)
  local widget_text = wibox.layout.align.vertical()
  local widget_texts = {}
  for i=1,3 do
    widget_texts[i] = wibox.widget.textbox()
    widget_texts[i]:set_font("Inconsolata for Powerline 7")
    widget_texts[i]:set_text(text:sub(i,i))
  end
  widget_text:set_first (widget_texts[1])
  widget_text:set_second(widget_texts[2])
  widget_text:set_third (widget_texts[3])
  return widget_text
end

function widgets.stats(args)
  local widget_stats = wibox.layout.fixed.horizontal()
  local widget_text = widgets.text_vert(args.text)
  local widget_info = widgets.info(args)

  widget_stats:add(widget_text)
  widget_stats:add(widget_sep)
  widget_stats:add(widget_info)
  return widget_stats
end

function widgets.info(args)
  vicious.cache(args.vicious_module)
  widget_info = wibox.layout.fixed.horizontal()
  for i=1,#args.id do
    local widget_info_align = wibox.layout.align.vertical()
    local widget_info_text = wibox.widget.textbox()
    widget_info_text:set_font("Inconsolata for Powerline 7")
    vicious.register(widget_info_text, args.vicious_module, function(widget, wargs)
      return args.string_pre[i] .. string.format("%05s", math.floor(wargs[args.id[i]])) .. args.string_post[i]
    end, args.timeout)
    -- graph
    local widget_info_graph = awful.widget.graph()
    widget_info_graph:set_width(30)
    widget_info_graph:set_height(15)
    widget_info_graph:set_background_color(args.bg)
    widget_info_graph:set_color(widgets.grad)
    widget_info_graph:set_border_color(args.border)
    vicious.register(widget_info_graph, args.vicious_module, function(widget, wargs)
      return wargs[args.id[i]]
    end, args.timeout)

    widget_info_align:set_first(widget_info_text)
    widget_info_align:set_second(widget_info_graph)
    widget_info:add(widget_info_align)
    widget_info:add(widget_sep)
  end

  return widget_info
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
--
--widget_cpu:add(widget_cpu_icon)
--widget_cpu:add(widget_cpu_text)
--widget_cpu:add(widget_cpu_graph)

widgets.textclock = awful.widget.textclock()

return widgets
