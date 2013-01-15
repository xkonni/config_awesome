-- Create a laucher widget and a main menu
myusermenu = {
   { "reconfigure", awesome.restart },
   { "logout", awesome.quit },
   { "login user", "dm-tool switch-to-greeter" },
 }
myappmenu = {
   { "terminal", terminal }
 }
mylogoutmenu = {
   { "suspend", "systemctl suspend"},
   { "hibernate", "systemctl hibernate"},
   { "reboot", "systemctl reboot"},
   { "shutdown", "systemctl shutdown"}
}

mymainmenu = awful.menu({ items = {
                                    { "user", myusermenu },
                                    { "app", myappmenu },
                                    { "system", mylogoutmenu }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
