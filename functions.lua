-- create an arrow as transition between fg and bg color
function mwidget_arrow(fg, bg, direction)
  local widget_bg = wibox.widget.background()
  local widget_fg = wibox.widget.textbox()

  local arrow="|"
  if direction == "cleft"   then arrow = "⮃" end
  if direction == "cright"  then arrow = "⮁" end
  if direction == "left"   then arrow = "⮂" end
  if direction == "right"  then arrow = "⮀" end

  widget_fg:set_font("Anonymous Pro for Powerline 18")
  widget_fg:set_markup("<span color=\"".. fg .. "\">".. arrow .."</span>")
  widget_bg:set_bg(bg)

  widget_bg:set_widget(widget_fg)
  return widget_bg
end

function mwidget_icon(symbol)
  local mwidget_icon = wibox.widget.textbox()
  mwidget_icon:set_font("Anonymous Pro for Powerline 14")
  mwidget_icon:set_text(symbol)
  return mwidget_icon
end

-- color the background of a widget
function mwidget_bg(bg, widget)
  local widget_bg = wibox.widget.background()
  widget_bg:set_bg(bg)
  widget_bg:set_widget(widget)
  return widget_bg
end

-- return a string with fixed length
-- cut off at the end of filled with
-- whitespaces at the beginning
function prettystring(str, length, fill, center)
  if string.len(str) > length then
    str=string.sub(str, 1, length-1).."…"
  elseif fill then
    local num=length-string.len(str)
    if center then
      local left = math.floor(num/2)
      local right = num-left
      str = string.rep(fill, left)..str..string.rep(fill, right)
    else
      str = string.rep(fill, num)..str
    end
  end
  return str
end

-- test if window floats
function floats(c)
  local ret = false
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
    ret = true
  end
  return ret
end

function titlebar_enable(c)
  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(awful.titlebar.widget.iconwidget(c))

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(awful.titlebar.widget.floatingbutton(c))
  right_layout:add(awful.titlebar.widget.maximizedbutton(c))
  right_layout:add(awful.titlebar.widget.stickybutton(c))
  right_layout:add(awful.titlebar.widget.ontopbutton(c))
  right_layout:add(awful.titlebar.widget.closebutton(c))

  -- The title goes in the middle
  local title = awful.titlebar.widget.titlewidget(c)
  title:buttons(awful.util.table.join(
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
          ))

  -- Now bring it all together
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)
  layout:set_middle(title)

  awful.titlebar(c):set_widget(layout)
end

function titlebar_disable(c)
  awful.titlebar(c, {size=0})
end

function set_volume(action)
  local text
  local icon
  local info_vol = vicious.widgets.volume(widget, "Master")

  if (action == "toggle") then
    if info_vol[2] == "♫" then info_vol[2] = "♩"
    else info_vol[2] = "♫" end
    awful.util.spawn(home .."/bin/notify_volume toggle")
  elseif (action == "decrease") then
    awful.util.spawn(home .."/bin/notify_volume decrease")
  elseif (action == "increase") then
    awful.util.spawn(home .."/bin/notify_volume increase")
  end

  if info_vol[2] == "♫" then
    widget_vol_bar:set_color(theme.bg_normal.."A0")
    text = "["..info_vol[1].."%] [on]"
    icon = "♫ "
  else
    widget_vol_bar:set_color(theme.bg_focus.."40")
    text = "["..info_vol[1].."%] [off]"
    icon = " ♯ "
  end

  widget_vol_icon:set_text(icon)
  widget_vol_bar:set_value(info_vol[1]/100)
  naughty.destroy(notify_volume)
  notify_volume = naughty.notify({title="volume", text=text})
end
