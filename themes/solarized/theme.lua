------------------------------------------------
--  "solarized" awesome theme by konni        --
--    based on "Zenburn" By Adrian C. (anrxc) --
------------------------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
config                                          = awful.util.getdir("config")
theme                                           = {}
theme.wallpaper                                 = config .. "/themes/solarized/awesome-background.png"
theme.bat_icon                                  = config .. "/themes/solarized/widgets/bat.png"
theme.cpu_icon                                  = config .. "/themes/solarized/widgets/cpu.png"
theme.mem_icon                                  = config .. "/themes/solarized/widgets/mem.png"
theme.mpd_icon                                  = config .. "/themes/solarized/widgets/mpd.png"
theme.msg_icon                                  = config .. "/themes/solarized/widgets/msg.png"
theme.net_icon                                  = config .. "/themes/solarized/widgets/net.png"
theme.vol_icon                                  = config .. "/themes/solarized/widgets/vol.png"
-- }}} Main

-- {{{ Styles
theme.font                                      = "Inconsolata for Powerline 10"
-- }}} Styles

-- {{{ Colors
theme.fg_normal                                 = "#EEE8D5"
theme.fg_focus                                  = "#268BD2"
theme.fg_urgent                                 = "#268BD2"
theme.fg_minimize                               = "#8A8A8A"

theme.bg_normal                                 = "#3F3F3F"
theme.bg_focus                                  = "#1C1C1C"
theme.bg_urgent                                 = "#3F3F3F"
theme.bg_minimize                               = theme.bg_normal
theme.bg_systray                                = theme.bg_normal
-- }}} Colors

-- {{{ Borders
theme.border_width                              = "1"
theme.border_normal                             = "#041015"
theme.border_focus                              = "#268bd2"
theme.border_marked                             = "#00ff00"
-- }}} Borders


-- {{{ Titlebars
--theme.titlebar_bg_focus  = "#3F3F3F"
--theme.titlebar_bg_normal = "#3F3F3F"
theme.titlebar_close_button                     = "true"
-- }}}

-- {{{ Override
-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- tasklist_[bg|fg]_[focus|urgent]
-- taglist_[bg|fg]_[focus|urgent|occupied]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
-- theme.taglist_bg_focus = "#CC9393"

-- taglist
theme.taglist_bg_focus                          = theme.bg_normal
theme.taglist_squares                           = "true"

-- tasklist
theme.tasklist_bg_focus                         = theme.bg_normal

-- gaps
theme.useless_gap_width = 6
-- }}} Override

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget                                 = "#494B4F"
-- }}} Widgets

-- {{{ Mouse finder
theme.mouse_finder_color                        = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}} Mouse finder

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height                               = "15"
theme.menu_width                                = "100"
-- }}} Menu

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel                       = config .. "/themes/solarized/taglist/squarefz.png"
theme.taglist_squares_unsel                     = config .. "/themes/solarized/taglist/squarez.png"
-- }}} Taglist

-- {{{ Misc
theme.awesome_icon                              = config .. "/themes/solarized/awesome-icon.png"
theme.menu_submenu_icon                         = config .. "/themes/solarized/submenu.png"
-- }}} Misc

-- {{{ Layout
theme.layout_tile                               = config .. "/themes/solarized/layouts/tile.png"
theme.layout_tileleft                           = config .. "/themes/solarized/layouts/tileleft.png"
theme.layout_tilebottom                         = config .. "/themes/solarized/layouts/tilebottom.png"
theme.layout_tiletop                            = config .. "/themes/solarized/layouts/tiletop.png"
theme.layout_fairv                              = config .. "/themes/solarized/layouts/fairv.png"
theme.layout_fairh                              = config .. "/themes/solarized/layouts/fairh.png"
theme.layout_spiral                             = config .. "/themes/solarized/layouts/spiral.png"
theme.layout_dwindle                            = config .. "/themes/solarized/layouts/dwindle.png"
theme.layout_max                                = config .. "/themes/solarized/layouts/max.png"
theme.layout_fullscreen                         = config .. "/themes/solarized/layouts/fullscreen.png"
theme.layout_magnifier                          = config .. "/themes/solarized/layouts/magnifier.png"
theme.layout_floating                           = config .. "/themes/solarized/layouts/floating.png"
-- lain
theme.layout_cascade                            = config .. "/themes/solarized/layouts/cascade.png"
--theme.layout_cascadetile                        = config .. "/themes/solarized/layouts/cascadetile.png"
theme.layout_centerfair                         = config .. "/themes/solarized/layouts/centerfair.png"
theme.layout_centerwork                         = config .. "/themes/solarized/layouts/centerwork.png"
theme.layout_termfair                           = config .. "/themes/solarized/layouts/termfair.png"
theme.layout_uselessfair                        = config .. "/themes/solarized/layouts/uselessfair.png"
theme.layout_uselesspiral                       = config .. "/themes/solarized/layouts/uselesspiral.png"
theme.layout_uselesstile                        = config .. "/themes/solarized/layouts/uselesstile.png"
theme.layout_uselesstileleft                    = config .. "/themes/solarized/layouts/uselesstileleft.png"
theme.layout_uselesstiletop                    = config .. "/themes/solarized/layouts/uselesstiletop.png"
theme.layout_uselesstilebottom                    = config .. "/themes/solarized/layouts/uselesstilebottom.png"
-- }}} Layout

-- {{{ Titlebar
theme.titlebar_close_button_focus               = config .. "/themes/solarized/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = config .. "/themes/solarized/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active        = config .. "/themes/solarized/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = config .. "/themes/solarized/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = config .. "/themes/solarized/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = config .. "/themes/solarized/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active       = config .. "/themes/solarized/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = config .. "/themes/solarized/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = config .. "/themes/solarized/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = config .. "/themes/solarized/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active     = config .. "/themes/solarized/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = config .. "/themes/solarized/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = config .. "/themes/solarized/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = config .. "/themes/solarized/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = config .. "/themes/solarized/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = config .. "/themes/solarized/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = config .. "/themes/solarized/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = config .. "/themes/solarized/titlebar/maximized_normal_inactive.png"
-- }}} Titlebar
-- }}} Icons

return theme
