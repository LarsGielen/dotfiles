pragma Singleton

import Quickshell
import QtQuick

// Sizing/typography tokens shared by every widget.
Singleton {
  // Typography
  readonly property string font: "JetBrainsMono Nerd Font Propo"
  readonly property int fontSize: 13
  readonly property int iconSize: 15

  // Base geometry
  readonly property int topMargin: 10   // distance from top of screen to bar
  readonly property int sideMargin: 10  // distance from sides of screen to bar
  readonly property int radius: 14      // bar corner radius

  readonly property int itemHeight: 26  // height of widgets
  readonly property int itemRadius: 9   // bar widget corner radius
  readonly property int gap: 6          // gap between widgets
  readonly property int padding: 11     // horizontal padding inside a pill

  // Bar geometry
  readonly property int barTopMargin: topMargin   // distance from top of screen to bar
  readonly property int barSideMargin: sideMargin  // distance from sides of screen to bar
  readonly property int barRadius: radius      // bar corner radius

  readonly property int barItemHeight: itemHeight  // height of bar widgets
  readonly property int barItemRadius: itemRadius   // bar widget corner radius
  readonly property int barGap: gap          // gap between widgets
  readonly property int barPadding: padding     // horizontal padding inside a pill

  readonly property int barHeight: barItemHeight + barTopMargin  // visual height of the floating bar

  // Notifications toast geometry
  readonly property string toastEdge:    "bottom"  // "top" | "bottom"  (vertical edge)
  readonly property string toastSide:    "right"   // "left" | "right" | "center"
  readonly property int    toastWidth:    360       // width of a toast card
  readonly property int    toastMargin:   10        // gap from the screen edges
  readonly property int    toastSpacing:  8         // gap between stacked toasts
  readonly property int    toastRadius:   9         // toast card corner radius
  readonly property int    toastPadding:  12        // inner padding of a toast card
}
