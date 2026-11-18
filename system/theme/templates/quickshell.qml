// {{banner}}
pragma Singleton
import Quickshell

Singleton {
    id: root

    readonly property string name: "{{name}}"
    readonly property string label: "{{label}}"

    readonly property var colors: ({
        base: "{{base}}",
        mantle: "{{mantle}}",
        surface: "{{surface}}",
        surfaceAlt: "{{surfaceAlt}}",
        overlay: "{{overlay}}",
        border: "{{border}}",
        text: "{{text}}",
        subtext: "{{subtext}}",
        accent: "{{accent}}",
        onAccent: "{{onAccent}}",
        black: "{{black}}",
        red: "{{red}}",
        green: "{{green}}",
        yellow: "{{yellow}}",
        blue: "{{blue}}",
        magenta: "{{magenta}}",
        cyan: "{{cyan}}",
        white: "{{white}}",
        brightBlack: "{{brightBlack}}",
        brightRed: "{{brightRed}}",
        brightGreen: "{{brightGreen}}",
        brightYellow: "{{brightYellow}}",
        brightBlue: "{{brightBlue}}",
        brightMagenta: "{{brightMagenta}}",
        brightCyan: "{{brightCyan}}",
        brightWhite: "{{brightWhite}}"
    })
}
