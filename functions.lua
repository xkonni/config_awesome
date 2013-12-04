-- create an arrow as transition between fg and bg color
function mwidget_arrow(arrow, fg, bg, sep)
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

    widget_fg[w]:set_markup("<span size=\"18000\" color=\"".. fg[w] .. "\">".. arrow[w] .."</span>")
    widget_bg[w]:set_bg(bg[w])
    widget_bg[w]:set_widget(widget_fg[w])
    widget_arrow:add(widget_bg[w])
  end
  if sep then widget_arrow:add(widget_sep) end
  return widget_arrow
end

function mwidget_icon(symbol, valign)
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
function mwidget_bg(bg, widget)
  local widget_bg = wibox.widget.background()
  widget_bg:set_bg(bg)
  widget_bg:set_widget(widget)
  return widget_bg
end

-- return a string with fixed length
-- cut off at the end or filled with some character at the beginning
function formatstring(str, length)
  if string.len(str) > length then
    str=string.sub(str, 1, length-1)..string.len(str).."…"
  else
    local num=length-string.len(str)
    str = string.rep(" ", num)..str
  end
  return str
end

function resize(c)
  local n
  local border = 2*beautiful.border_width
  if awful.client.floating.get(c) then
    n = naughty.notify({screen=mouse.screen, title="resize floating", timeout=0})
    grabber = awful.keygrabber.run(
      function(mod, key, event)
        if event == "release" then return end

        local g = c:geometry()
        local w = screen[c.screen].workarea
        m = 100
        local step = {}
        local step_max = {
          w.x + w.width - (g.x + g.width) - border,
          w.y + w.height - (g.y + g.height) - border,
          g.width - 4*m,
          g.height - 2*m
        }
        for i=1, 2 do
          if step_max[i] > m then
            step[i] = m
          else
            step[i] = step_max[i]
          end
        end

        if     key == 'h'       then awful.client.moveresize(0, 0, -m, 0, c)
        elseif key == 'j'       then awful.client.moveresize(0, 0, 0, step[2], c)
        elseif key == 'k'       then awful.client.moveresize(0, 0, 0, -m, c)
        elseif key == 'l'       then awful.client.moveresize(0, 0, step[1], 0, c)
        elseif key == 'H'       then awful.client.moveresize(0, 0, -step_max[3], 0, c)
        elseif key == 'J'       then awful.client.moveresize(0, 0, 0, step_max[2], c)
        elseif key == 'K'       then awful.client.moveresize(0, 0, 0, -step_max[4], c)
        elseif key == 'L'       then awful.client.moveresize(0, 0, step_max[1], 0, c)
        elseif key == 'Shift_L' then return
        else                         awful.keygrabber.stop(grabber)
                                     naughty.destroy(n)
        end
      end)
  else
    n = naughty.notify({screen=mouse.screen, title="resize tiling"})
    grabber = awful.keygrabber.run(
      function(mod, key, event)
        if event == "release" then return end

        if     key == 'h'       then awful.tag.incmwfact(-0.05)
        elseif key == 'j'       then awful.client.incwfact(0.05)
        elseif key == 'k'       then awful.client.incwfact(-0.05)
        elseif key == 'l'       then awful.tag.incmwfact(0.05)
        else                         awful.keygrabber.stop(grabber)
                                     naughty.destroy(n)
        end
      end)
    end
end

function move(c)
  local n
  local border = 2*beautiful.border_width
  if awful.client.floating.get(c) then
    n = naughty.notify({screen=mouse.screen, title="move floating", timeout=0})
    grabber = awful.keygrabber.run(
      function(mod, key, event)
        if event == "release" then return end

        local g = c:geometry()
        local w = screen[c.screen].workarea
        m = 100
        local step = {}
        local step_max = {
          g.x - w.x,
          g.y - w.y,
          w.x + w.width - (g.x + g.width) - border,
          w.y + w.height - (g.y + g.height) - border
        }

        for i=1, #step_max do
          if step_max[i] > m then
            step[i] = m
          else
            step[i] = step_max[i]
          end
        end

        if     key == 'h'       then awful.client.moveresize(-step[1], 0, 0, 0, c)
        elseif key == 'j'       then awful.client.moveresize(0, step[4], 0, 0, c)
        elseif key == 'k'       then awful.client.moveresize(0, -step[2], 0, 0, c)
        elseif key == 'l'       then awful.client.moveresize(step[3], 0, 0, 0, c)
        elseif key == 'H'       then awful.client.moveresize(-step_max[1], 0, 0, 0, c)
        elseif key == 'J'       then awful.client.moveresize(0, step_max[4], 0, 0, c)
        elseif key == 'K'       then awful.client.moveresize(0, -step_max[2], 0, 0, c)
        elseif key == 'L'       then awful.client.moveresize(step_max[3], 0, 0, 0, c)
        elseif key == 'Shift_L' then return
        else                         awful.keygrabber.stop(grabber)
                                     naughty.destroy(n)
        end
      end)
    end
end

function message(args)
  if (args.action == 'reset') then
    messages.count = 0
    widget_msg_text:set_text("-")
  else
    messages.count = messages.count + 1
    messages[messages.count] = {}
    messages[messages.count].name = args.title
    messages[messages.count].text = args.text
    widget_msg_text:set_markup("<span color=\"#859900\">".. messages.count .."</span>")
    if (args.active ~= 1) then
      naughty.notify({screen=screen.count(), timeout=args.timeout, title=args.title, text=args.text})
    end
  end
end

function set_volume(action)
  local text
  local icon
  local info_vol = vicious.widgets.volume(widget, "Master")
  local stats_vol = { type = "linear", from = { 0, 0 }, to = { 0, 18 }, stops = { { 0, "#859900" }, { 0.5, "#566600" }, { 1, "#426600" }}}

  if (action == "toggle") then
    if info_vol[2] == "♫" then info_vol[2] = "♩"
    else info_vol[2] = "♫" end
    awful.util.spawn(home .."/bin/set_volume toggle")
  elseif (action == "decrease") then
    awful.util.spawn(home .."/bin/set_volume decrease")
  elseif (action == "increase") then
    awful.util.spawn(home .."/bin/set_volume increase")
  end

  if info_vol[2] == "♫" then
    widget_vol_bar:set_color(stats_vol)
    text = "["..info_vol[1].."%] [on]"
    icon = "♫ "
  else
    widget_vol_bar:set_color(beautiful.fg_normal .. "40")
    text = "["..info_vol[1].."%] [off]"
    icon = " ♯ "
  end

  widget_vol_icon:set_text(icon)
  widget_vol_bar:set_value(info_vol[1]/100)
  naughty.destroy(notify_volume)
  notify_volume = naughty.notify({screen=screen.count(), title="volume", text=text})
end
