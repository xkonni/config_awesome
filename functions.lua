local naughty = require("naughty")
local wibox   = require("wibox")
local awful   = require("awful")

functions = {}
function functions.init(args)
  beautiful = args.beautiful
end

function functions.textbox(args)
  local widget = wibox.widget.textbox()
  widget:set_font("Inconsolata for Powerline 9")

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

function functions.move(c)
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

function functions.swaptags(dir)
  dir = dir or 1

  -- screen
  scr1 = mouse.screen
  if dir == 1 then
    if scr1 < screen.count() then
      scr2 = scr1+1
    else
      scr2 = 1
    end
  else
    if scr1 > 1 then
      scr2 = scr1-1
    else
      scr2 = screen.count()
    end
  end

  -- current tags
  tag1 = awful.tag.selected(scr1)
  tag2 = awful.tag.selected(scr2)
  -- current names
  name1 = tag1.name
  name2 = tag2.name

  -- swap tags
  awful.tag.swap(tag1,tag2)
  -- swap names
  tag1.name = name2
  tag2.name = name1
  -- view tags
  awful.tag.viewonly(tag1)
  awful.tag.viewonly(tag2)
end

function functions.quit()
  awful.util.spawn("xfce4-session-logout -lf")
end

return functions
