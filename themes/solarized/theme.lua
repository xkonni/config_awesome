------------------------------------------------
--  "Blue" awesome theme by xkonni            --
--    based on "Zenburn" By Adrian C. (anrxc) --
-----------------------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme                                           = {}
theme.wallpaper                                 = config .. "/themes/solarized/awesome-background.png"
-- }}} Main

-- {{{ Styles
theme.font                                      = "Anonymous Pro for Powerline 11"
-- }}} Styles

-- {{{ Colors
theme.fg_normal                                 = "#EEE8D5"
theme.fg_focus                                  = "#268BD2"
theme.fg_urgent                                 = "#268BD2"
theme.bg_normal                                 = "#3F3F3F"
theme.bg_focus                                  = "#1C1C1C"
theme.bg_urgent                                 = "#3F3F3F"
theme.bg_systray                                = theme.bg_focus
-- }}} Colors

-- {{{ Borders
theme.border_width                              = "1"
theme.border_normal                             = "#041015"
theme.border_focus                              = "#268bd2"
theme.border_marked                             = "#00ff00"
-- }}} Borders

-- {{{ Titlebars
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_bg_focus                         = theme.bg_focus
-- }}} Titlebars

-- {{{ Override
-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
-- theme.taglist_bg_focus = "#CC9393"
-- }}} Override

-- taglist
theme.taglist_fg_focus                          = "#268bd2"

-- tasklist
theme.tasklist_fg_focus                         = "#268bd2"

-- TODO seems unused
-- tooltip
theme.tooltip_fg_color                          = "#ff0000"
theme.tooltip_bg_color                          = "#00ff00"
-- }}} Override

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget                                 = "#AECF96"
--theme.fg_center_widget                          = "#88A175"
--theme.fg_end_widget                             = "#FF5656"
--theme.bg_widget                                 = "#494B4F"
--theme.border_widget                             = "#3F3F3F"
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
theme.taglist_squares_resize                    = "true"
-- }}} Taglist

-- {{{ Misc
theme.awesome_icon                              = config .. "/themes/solarized/awesome-icon.png"
theme.menu_submenu_icon                         = config .. "/themes/solarized/submenu.png"
theme.tasklist_floating_icon                    = config .. "/themes/solarized/tasklist/floatingw.png"
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
