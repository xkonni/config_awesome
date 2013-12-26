local naughty = require("naughty")
local vicious = require("vicious")

functions = {}
function functions.init(args)
  functions.home = args.home
end

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
    text = "["..info_vol[1].."%] [on]"
    info_vol[2] = 1
  else
    text = "["..info_vol[1].."%] [off]"
    info_vol[2] = 0
  end
  naughty.destroy(notify_volume)
  notify_volume = naughty.notify({screen=screen.count(), title="volume", text=text})
  return {volume=info_vol[1]/100, status=info_vol[2]}
end

return functions
