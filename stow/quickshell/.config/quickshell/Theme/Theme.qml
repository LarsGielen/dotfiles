pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string palette: Palettes.name
    readonly property var c: Palettes.colors

    readonly property color base:        c.base
    readonly property color mantle:      c.mantle
    readonly property color surface:     c.surface
    readonly property color surfaceAlt:  c.surfaceAlt
    readonly property color overlay:     c.overlay
    readonly property color border:      c.border
    readonly property color text:        c.text
    readonly property color subtext:     c.subtext
    readonly property color accent:      c.accent
    readonly property color onAccent:    c.onAccent
    readonly property color error:       c.brightRed
    readonly property color success:     c.brightGreen
    readonly property color warning:     c.brightYellow
    readonly property color transparent: "transparent"

    readonly property int screenMarginSide: 10
    readonly property int screenMarginTop: 10
    readonly property int screenMarginBottom: 10

    readonly property int spacing: 8
    readonly property int paddingH: 12
    readonly property int paddingV: 5

    readonly property int animFast: 120
    readonly property int animNormal: 220

    readonly property QtObject font: QtObject {
        readonly property string family: "JetBrainsMono Nerd Font"
        readonly property int sizeSmall: 11
        readonly property int size: 13
        readonly property int sizeLarge: 16
    }
}
