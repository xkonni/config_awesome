------------------------------------------------
--  "Blue" awesome theme by xkonni            --
--    based on "Zenburn" By Adrian C. (anrxc) --
-----------------------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme                                           = {}
theme.wallpaper_cmd                             = { "" }
-- }}} Main

-- {{{ Styles
theme.font                                      = "Anonymous Pro for Powerline 11"
-- }}} Styles

-- {{{ Colors
theme.fg_normal                                 = "#DCDCCC"
theme.fg_focus                                  = "#F0DFAF"
theme.fg_urgent                                 = "#CC9393"
theme.bg_normal                                 = "#3F3F3F"
theme.bg_focus                                  = "#1E2320"
theme.bg_urgent                                 = "#3F3F3F"
-- }}} Colors

-- {{{ Borders
theme.border_width                              = "1"
theme.border_normal                             = "#041015"
theme.border_focus                              = "#268bd2"
theme.border_marked                             = "#00ff00"
-- }}} Borders

-- {{{ Titlebars
theme.titlebar_bg_focus                         = "#3F3F3F"
theme.titlebar_bg_normal                        = "#3F3F3F"
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
theme.tasklist_left                             = home .."/.config/awesome/themes/black-blue/tasklist/tasklist_left.png"
theme.tasklist_center_left                      = home .."/.config/awesome/themes/black-blue/tasklist/tasklist_center_left.png"
theme.tasklist_center                           = home .."/.config/awesome/themes/black-blue/tasklist/tasklist_center.png"
theme.tasklist_center_right                     = home .."/.config/awesome/themes/black-blue/tasklist/tasklist_center_right.png"
theme.tasklist_right                            = home .."/.config/awesome/themes/black-blue/tasklist/tasklist_right.png"
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
theme.taglist_squares_sel                       = home .."/.config/awesome/themes/black-blue/taglist/squarefz.png"
theme.taglist_squares_unsel                     = home .."/.config/awesome/themes/black-blue/taglist/squarez.png"
theme.taglist_squares_resize                    = "true"
-- }}} Taglist

-- {{{ Misc
theme.awesome_icon                              = home .."/.config/awesome/themes/black-blue/awesome-icon.png"
theme.menu_submenu_icon                         = home .."/.config/awesome/themes/black-blue/submenu.png"
theme.tasklist_floating_icon                    = home .."/.config/awesome/themes/black-blue/tasklist/floatingw.png"
-- }}} Misc

-- {{{ Layout
theme.layout_tile                               = home .."/.config/awesome/themes/black-blue/layouts/tile.png"
theme.layout_tileleft                           = home .."/.config/awesome/themes/black-blue/layouts/tileleft.png"
theme.layout_tilebottom                         = home .."/.config/awesome/themes/black-blue/layouts/tilebottom.png"
theme.layout_tiletop                            = home .."/.config/awesome/themes/black-blue/layouts/tiletop.png"
theme.layout_fairv                              = home .."/.config/awesome/themes/black-blue/layouts/fairv.png"
theme.layout_fairh                              = home .."/.config/awesome/themes/black-blue/layouts/fairh.png"
theme.layout_spiral                             = home .."/.config/awesome/themes/black-blue/layouts/spiral.png"
theme.layout_dwindle                            = home .."/.config/awesome/themes/black-blue/layouts/dwindle.png"
theme.layout_max                                = home .."/.config/awesome/themes/black-blue/layouts/max.png"
theme.layout_fullscreen                         = home .."/.config/awesome/themes/black-blue/layouts/fullscreen.png"
theme.layout_magnifier                          = home .."/.config/awesome/themes/black-blue/layouts/magnifier.png"
theme.layout_floating                           = home .."/.config/awesome/themes/black-blue/layouts/floating.png"
-- }}} Layout

-- {{{ Titlebar
theme.titlebar_close_button_focus               = home .."/.config/awesome/themes/black-blue/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = home .."/.config/awesome/themes/black-blue/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active        = home .."/.config/awesome/themes/black-blue/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = home .."/.config/awesome/themes/black-blue/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = home .."/.config/awesome/themes/black-blue/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = home .."/.config/awesome/themes/black-blue/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active       = home .."/.config/awesome/themes/black-blue/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = home .."/.config/awesome/themes/black-blue/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = home .."/.config/awesome/themes/black-blue/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = home .."/.config/awesome/themes/black-blue/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active     = home .."/.config/awesome/themes/black-blue/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = home .."/.config/awesome/themes/black-blue/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = home .."/.config/awesome/themes/black-blue/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = home .."/.config/awesome/themes/black-blue/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = home .."/.config/awesome/themes/black-blue/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = home .."/.config/awesome/themes/black-blue/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = home .."/.config/awesome/themes/black-blue/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = home .."/.config/awesome/themes/black-blue/titlebar/maximized_normal_inactive.png"
-- }}} Titlebar
-- }}} Icons

return theme
