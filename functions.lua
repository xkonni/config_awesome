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

    widget_fg[w]:set_font("Anonymous Pro for Powerline 18")
    widget_fg[w]:set_markup("<span color=\"".. fg[w] .. "\">".. arrow[w] .."</span>")
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

function titlebar_enable(c)
  -- buttons for the titlebar
  local buttons = awful.util.table.join(
          awful.button({ }, 1, function()
              client.focus = c
              c:raise()
              awful.mouse.client.move(c)
          end),
          awful.button({ }, 3, function()
              client.focus = c
              c:raise()
              awful.mouse.client.resize(c)
          end)
          )

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(awful.titlebar.widget.iconwidget(c))
  left_layout:buttons(buttons)

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(awful.titlebar.widget.floatingbutton(c))
  right_layout:add(awful.titlebar.widget.maximizedbutton(c))
  right_layout:add(awful.titlebar.widget.stickybutton(c))
  right_layout:add(awful.titlebar.widget.ontopbutton(c))
  right_layout:add(awful.titlebar.widget.closebutton(c))

  -- The title goes in the middle
  local middle_layout = wibox.layout.flex.horizontal()
  local title = awful.titlebar.widget.titlewidget(c)
  title:set_align("center")
  middle_layout:add(title)
  middle_layout:buttons(buttons)

  -- Now bring it all together
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)
  layout:set_middle(middle_layout)

  awful.titlebar(c):set_widget(layout)
end

function titlebar_disable(c)
  awful.titlebar(c, {size=0})
end

function titlebar_toggle(c)
  _, size = c:titlebar_top()
  if size > 0 then
    titlebar_disable(c)
  else
    titlebar_enable(c)
  end
end

function resize(c)
  local n
  local border = 2*beautiful.border_width
  if awful.client.floating.get(c) then
    n = naughty.notify({title="resize floating", timeout=0})
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
    n = naughty.notify({title="resize foo tiling"})
    grabber = awful.keygrabber.run(
      function(mod, key, event)
        if event == "release" then return end

        if     key == 'h'       then awful.tag.incmwfact(-0.05)
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
    n = naughty.notify({title="move floating", timeout=0})
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

function set_volume(action)
  local text
  local icon
  local info_vol = vicious.widgets.volume(widget, "Master")
  local stats_grad = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#dc322f" }, { 0.5, "#808000" }, { 1, "#859900" }}}

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
    widget_vol_bar:set_color(stats_grad)
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
  notify_volume = naughty.notify({title="volume", text=text})
end
