import qs.Services
import qs.Widgets

Pill {
    // nf-md battery / battery-charging glyphs
    label: (Battery.charging ? "󰂄" : "󰁹") + " " + Battery.percent + "%"
}
