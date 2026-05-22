pragma Singleton

import Quickshell
import QtQuick

// Central place for all colors, sizing and fonts.
// Palette: Catppuccin Mocha (matches the rest of the dotfiles).
Singleton {
  id: root

  // --- Palette -------------------------------------------------------------
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

  // --- Typography ----------------------------------------------------------
  readonly property string font: "JetBrainsMono Nerd Font Propo"
  readonly property int fontSize: 13
  readonly property int iconSize: 15

  // Render a Nerd Font glyph from its codepoint, e.g. Theme.icon(0xf017).
  // Kept ASCII-only here so the source never depends on raw glyph bytes.
  // fromCodePoint (not fromCharCode) so high-plane v3 icons like 0xf035b work.
  function icon(code) { return String.fromCodePoint(code); }

  // --- Metrics -------------------------------------------------------------
  readonly property int barHeight: 36   // visual height of the floating bar
  readonly property int margin: 5       // gap around the floating bar
  readonly property int radius: 14      // bar corner radius
  readonly property int itemHeight: 26  // height of pill widgets
  readonly property int itemRadius: 9   // pill corner radius
  readonly property int gap: 6          // gap between widgets
  readonly property int padding: 11     // horizontal padding inside a pill
}
