local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
widgets = {}

widgets.grad = {
  type = "linear",
  from = { 0, 0 }, to = { 0, 12 },
  stops = { { 0, "#dc322f" }, { 0.5, "#808000" }, { 1, "#859900" }}
}

-- create a separator
-- e.g. an arrow as transition between fg and bg color
-- args = {[sep_left=px], [sep_right=px], [symbol{}, fg{}, bg{}, size{}]}
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
    local widget_fg = {}
    local widget_bg = {}
    for w = 1, #args.symbol do
      widget_fg[w] = wibox.widget.textbox()
      widget_bg[w] = wibox.widget.background()
      widget_fg[w]:set_markup("<span size=\"".. args.size[w] .."\" color=\"".. args.fg[w] .. "\">".. args.symbol[w] .."</span>")
      widget_bg[w]:set_bg(args.bg[w])
      widget_bg[w]:set_widget(widget_fg[w])
      widget_sep:add(widget_bg[w])
    end
  end

  -- right spacing
  if args.sep_right then
    widget_sep_right:add(widget_sep_right)
  end

  return widget_sep
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
  widget_stats:add(widgets.sep({sep_left=3}))
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
      return string.format("%06s", args.string_pre[i] .. " " .. math.floor(wargs[args.id[i]])) .. args.string_post[i]
    end, args.timeout)
    -- graph
    local widget_info_graph = awful.widget.graph()
    widget_info_graph:set_width(20)
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

    widget_info:add(widgets.sep({sep_left=3}))
  end

  return widget_info
end

-- preconfigured widgets
function widgets.mpd(args)
  vicious.cache(vicious.widgets.mpd)
  local widget_mpd = wibox.layout.fixed.horizontal()
  local widget_mpd_text = widgets.text_vert("MPD")
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
        return "<span size=\"small\">" .. strings[i].icon .. "</span>".. string.format("%20s", wargs[strings[i].id])
      end
    end, args.timeout)
  end

  widget_mpd_info:set_first (widget_mpd_infos[1])
  widget_mpd_info:set_second(widget_mpd_infos[2])
  widget_mpd_info:set_third (widget_mpd_infos[3])
  widget_mpd:add(widget_mpd_text)
  widget_mpd:add(widgets.sep({sep_left=3}))
  widget_mpd:add(widget_mpd_info)
  return widget_mpd
end

function widgets.vol(args)
  local widget_vol = wibox.layout.fixed.horizontal()
  local widget_vol_text = widgets.text_vert("VOL")
  local widget_vol_bar = awful.widget.progressbar()

  widget_vol_bar:set_vertical(true)
  widget_vol_bar:set_height(15)
  widget_vol_bar:set_width(5)
  widget_vol_bar:set_background_color(args.bg)
  widget_vol_bar:set_color(stats_vol)
  widget_vol_bar:set_border_color(args.border)
  vicious.register(widget_vol_bar, vicious.widgets.volume,
    function(widget, wargs)
      if wargs[2] == "♫" then
        widget_vol_bar:set_color(args.fg)
        icon = "♫ "
      else
        widget_vol_bar:set_color(args.fg .. "40")
        icon = " ♯ "
      end
      return wargs[1]
    end,
  args.timeout, "Master")

  widget_vol:add(widget_vol_text)
  widget_vol:add(widgets.sep({sep_left=3}))
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
