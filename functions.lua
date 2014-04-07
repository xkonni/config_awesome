local naughty = require("naughty")

functions = {}
function functions.init(args)
  beautiful       = args.beautiful
  functions.home  = args.home
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

return functions
