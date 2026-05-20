hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -s b -- waybar")
    hl.exec_cmd("uwsm app -s b -- swaync")
    hl.exec_cmd("uwsm app -s b -- hyprpaper")
    hl.exec_cmd("uwsm app -s b -- hyprsunset")

    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme BreezeX-RosePine-Linux")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")

    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end)
