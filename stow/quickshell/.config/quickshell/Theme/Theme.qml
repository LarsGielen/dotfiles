pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root

  // Palette
  readonly property color transparent: "transparent"

  readonly property color base:     "#1e1e2e"
  readonly property color mantle:   "#181825"
  readonly property color crust:    "#11111b"
  readonly property color surface0: "#313244"
  readonly property color surface1: "#45475a"
  readonly property color surface2: "#585b70"
  readonly property color overlay0: "#6c7086"
  readonly property color overlay1: "#7f849c"
  readonly property color text:     "#cdd6f4"
  readonly property color subtext:  "#a6adc8"

  readonly property color blue:     "#89b4fa"
  readonly property color lavender: "#b4befe"
  readonly property color sapphire: "#74c7ec"
  readonly property color green:    "#a6e3a1"
  readonly property color teal:     "#94e2d5"
  readonly property color yellow:   "#f9e2af"
  readonly property color peach:    "#fab387"
  readonly property color red:      "#f38ba8"
  readonly property color mauve:    "#cba6f7"

  readonly property color accent:   blue

  // Typography
  readonly property string font: "JetBrainsMono Nerd Font Propo"
  readonly property int fontSize: 13
  readonly property int iconSize: 15

  function icon(code) { return String.fromCodePoint(code); }

  // Metrics
  readonly property int topMargin: 10   // distance from top of screen to bar
  readonly property int sideMargin: 10  // distance from sides of screen to bar
  readonly property int radius: 14      // bar corner radius

  readonly property int itemHeight: 26  // height of bar widgets
  readonly property int itemRadius: 9   // bar widget corner radius
  readonly property int gap: 6          // gap between widgets
  readonly property int padding: 11     // horizontal padding inside a pill

  readonly property int barHeight: itemHeight + topMargin  // visual height of the floating bar

  // Notification toasts (the pop-ups that appear on new notifications).
  // Change these to move the stack around the screen.
  readonly property string toastEdge:   "bottom"    // "top" | "bottom"  (vertical edge)
  readonly property string toastSide:   "right"  // "left" | "right" | "center"
  readonly property int    toastWidth:   360     // width of a toast card
  readonly property int    toastMargin:  10      // gap from the screen edges
  readonly property int    toastSpacing: 8       // gap between stacked toasts
  readonly property int    toastTimeout: 6000    // ms before a toast auto-hides (0 = stay until dismissed)
  readonly property int    toastMax:     5       // most toasts shown at once
}
