hl.on("hyprland.start", function()
    -- Provides org.freedesktop.secrets, so start it before apps that store credentials.
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    hl.exec_cmd("uwsm app -s b -- qs -d")
    hl.exec_cmd("uwsm app -s b -- hyprpaper")
    hl.exec_cmd("uwsm app -s b -- hyprsunset")

    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme BreezeX-RosePine-Linux")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")

    -- Vivaldi pre-load
    hl.exec_cmd("uwsm app -- vivaldi-stable --no-startup-window --profile-directory=\"Default\"")

    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end)
