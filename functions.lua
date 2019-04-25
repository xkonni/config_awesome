local naughty = require("naughty")
local wibox   = require("wibox")
local awful   = require("awful")
-- local gears   = require("gears")

functions = {}
function functions.init(args)
  theme = args.theme
end

function functions.textbox(args)
  local widget = wibox.widget.textbox()

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

function functions.resize(c)
  local n
  local border = 2*theme.border_width
  if awful.client.floating.get(c) then
    n = naughty.notify({screen=mouse.screen, title="resize floating", timeout=0})
    grabber = awful.keygrabber.run(
      function(mod, key, event)
        if event == "release" then return end

        local g = c:geometry()
        local w = screen[c.screen].workarea
        local m = 100
        local min = 100
        local step_max = {
          x0 = g.x - w.x,
          x1 = w.x + w.width - (g.x + g.width + border),
          y0 = g.y - w.y,
          y1 = w.y + w.height - (g.y + g.height + border)
        }
        local step_min = {
          w = g.width - min,
          h = g.height - min
        }
        local step_inc = {
          x0 = (m < step_max.x0) and m or step_max.x0,
          x1 = (m < step_max.x1) and m or step_max.x1,
          y0 = (m < step_max.y0) and m or step_max.y0,
          y1 = (m < step_max.y1) and m or step_max.y1
        }
        local step_dec = {
          x = (m < step_min.w) and m or step_min.w,
          y = (m < step_min.h) and m or step_min.h
        }

        if     key == 'h'       then awful.client.moveresize(-step_inc.x0, 0, step_inc.x0, 0, c)
        elseif key == 'j'       then awful.client.moveresize(0, 0, 0, step_inc.y1, c)
        elseif key == 'k'       then awful.client.moveresize(0, -step_inc.y0, 0, step_inc.y0, c)
        elseif key == 'l'       then awful.client.moveresize(0, 0, step_inc.x1, 0, c)
        elseif key == 'H'       then awful.client.moveresize(step_dec.x, 0, -step_dec.x, 0, c)
        elseif key == 'J'       then awful.client.moveresize(0, 0, 0, -step_dec.y, c)
        elseif key == 'K'       then awful.client.moveresize(0, step_dec.y, 0, -step_dec.y, c)
        elseif key == 'L'       then awful.client.moveresize(0, 0, -step_dec.x, 0, c)
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

function functions.move(c)
  local n
  local border = 2*theme.border_width
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

function functions.swaptags()
  if screen.count() <= 2 then
    return
  end

  -- screen
  scr1 = mouse.screen.index
  scr2 = scr1 + 1
  if scr2 > screen.count() then
    scr2 = 1
  end

  -- current tags
  tag1 = awful.tag.selected(scr1)
  tag2 = awful.tag.selected(scr2)
  -- current names
  name1 = tag1.name
  name2 = tag2.name

  -- swap tags
  if tag1 and tag2 then
    -- awful.tag.swap(tag1, tag2)
    tag1:swap(tag2)
    -- swap names
    tag1.name = name2
    tag2.name = name1
    -- view tags
    awful.tag.viewonly(tag1)
    awful.tag.viewonly(tag2)
  else
    naughty.notify({screen=mouse.screen, title="tag is nil"})
  end
end

function functions.quit()
  awful.util.spawn("lxsession-logout")
end

return functions
