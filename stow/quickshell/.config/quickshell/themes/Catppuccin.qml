pragma Singleton

import Quickshell
import QtQuick

// Catppuccin Mocha. A palette is pure colour: clone this file, change the
// hexes, and point Theme.palette at it. See Theme.qml for what each role tints.
Singleton {
  // Neutrals (dark -> light)
  readonly property color crust:    "#11111b"
  readonly property color mantle:   "#181825"
  readonly property color base:     "#1e1e2e"
  readonly property color surface0: "#313244"
  readonly property color surface1: "#45475a"
  readonly property color surface2: "#585b70"
  readonly property color overlay0: "#6c7086"
  readonly property color overlay1: "#7f849c"
  readonly property color subtext:  "#a6adc8"
  readonly property color text:     "#cdd6f4"

  // Accents
  readonly property color blue:     "#89b4fa"
  readonly property color lavender: "#b4befe"
  readonly property color sapphire: "#74c7ec"
  readonly property color green:    "#a6e3a1"
  readonly property color teal:     "#94e2d5"
  readonly property color yellow:   "#f9e2af"
  readonly property color peach:    "#fab387"
  readonly property color red:      "#f38ba8"
  readonly property color mauve:    "#cba6f7"

  readonly property color accent: blue
}
