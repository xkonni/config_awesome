-- Define a tag table which hold all screen tags.
tags = {}

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
  --awful.layout.suit.floating
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  --awful.layout.suit.fair,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.spiral,
  --awful.layout.suit.spiral.dwindle,
  --awful.layout.suit.max,
  --awful.layout.suit.max.fullscreen,
  --awful.layout.suit.magnifier,
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" }, s, layouts[1])
end
