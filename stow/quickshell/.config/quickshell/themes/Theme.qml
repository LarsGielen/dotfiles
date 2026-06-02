pragma Singleton

import Quickshell
import QtQuick

// Active colour tokens used across the whole shell. Swap themes by pointing
// `palette` at another file in this directory. Each token notes what it tints.
Singleton {
  readonly property var palette: Catppuccin  // the palette this theme uses

  readonly property color transparent: "transparent"  // bar/popup backgrounds

  readonly property color base:     palette.base      // main background (bar pills, popups)
  readonly property color mantle:   palette.mantle    // notification card background
  readonly property color crust:    palette.crust     // darkest background
  readonly property color surface0: palette.surface0  // widget background
  readonly property color surface1: palette.surface1  // hovered widget background
  readonly property color surface2: palette.surface2  // tracks, inactive dots
  readonly property color overlay0: palette.overlay0  // muted/empty-state text
  readonly property color overlay1: palette.overlay1  // dim icons, secondary glyphs
  readonly property color text:     palette.text      // primary text
  readonly property color subtext:  palette.subtext   // labels, secondary text

  readonly property color blue:     palette.blue      // named accents, used per-widget
  readonly property color lavender: palette.lavender
  readonly property color sapphire: palette.sapphire
  readonly property color green:    palette.green
  readonly property color teal:     palette.teal
  readonly property color yellow:   palette.yellow
  readonly property color peach:    palette.peach
  readonly property color red:      palette.red       // errors, critical, dismiss
  readonly property color mauve:    palette.mauve

  readonly property color accent:   palette.accent    // primary highlight (active, fills)

  function icon(code) { return String.fromCodePoint(code); }  // codepoint -> glyph
}
