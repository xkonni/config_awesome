local naughty = require("naughty")
local vicious = require("vicious")

functions = {}
function functions.set_volume(action)
  local text

  if (action == "toggle") then
    awful.util.spawn(functions.home .."/bin/set_volume toggle", false)
  elseif (action == "decrease") then
    awful.util.spawn(functions.home .."/bin/set_volume decrease", false)
  elseif (action == "increase") then
    awful.util.spawn(functions.home .."/bin/set_volume increase", false)
  end

  local info_vol = vicious.widgets.volume(widget, "Master")
  if ((info_vol[2] == "♫" and action ~= "toggle") or
      (info_vol[2] ~= "♫" and action == "toggle")) then
    --widget_vol_bar:set_color(stats_vol)
    text = "["..info_vol[1].."%] [on]"
  else
    --widget_vol_bar:set_color(beautiful.fg_normal .. "40")
    text = "["..info_vol[1].."%] [off]"
  end
  naughty.destroy(notify_volume)
  notify_volume = naughty.notify({screen=screen.count(), title="volume", text=text})
end

return functions
