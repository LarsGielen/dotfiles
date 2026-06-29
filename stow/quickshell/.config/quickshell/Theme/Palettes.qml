pragma Singleton
import Quickshell

Singleton {
    id: root

    readonly property var gruvbox: ({
        surface:    "#3c3836",
        surfaceAlt: "#504945",
        overlay:    "#665c54",
        text:       "#ebdbb2",
        subtext:    "#a89984",
        accent:     "#fabd2f",
        onAccent:   "#282828",
        red:        "#fb4934",
        green:      "#b8bb26",
        yellow:     "#fabd2f",
        blue:       "#83a598",
        magenta:    "#d3869b",
        cyan:       "#8ec07c"
    })

    readonly property var catppuccin: ({
        surface:    "#313244",
        surfaceAlt: "#45475a",
        overlay:    "#585b70",
        text:       "#cdd6f4",
        subtext:    "#a6adc8",
        accent:     "#cba6f7",
        onAccent:   "#1e1e2e",
        red:        "#f38ba8",
        green:      "#a6e3a1",
        yellow:     "#f9e2af",
        blue:       "#89b4fa",
        magenta:    "#f5c2e7",
        cyan:       "#94e2d5"
    })

    // Lookup table so Theme can resolve a palette from a string name.
    readonly property var byName: ({
        gruvbox: gruvbox,
        catppuccin: catppuccin
    })
}