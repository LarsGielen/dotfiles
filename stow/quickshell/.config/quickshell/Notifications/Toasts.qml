import QtQuick
import Quickshell

import "../Theme"
import "../Services"

// Toasts ─ the on-screen pop-up layer. A transparent, click-through overlay per
// screen whose input region is masked to just the toast stack, so only the
// cards themselves catch the mouse. Position is driven entirely by the
// Theme.toast* settings, so moving the stack is a one-line change in Theme.qml.
Variants {
  model: Quickshell.screens

  PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    visible: Notifications.popups.length > 0
    color: Theme.transparent
    exclusiveZone: 0  // float over things, never reserve space

    // Cover the whole screen; the mask below limits clicks to the cards.
    anchors { top: true; bottom: true; left: true; right: true }
    mask: Region { item: stack }

    readonly property bool atTop:    Theme.toastEdge === "top"
    readonly property bool atLeft:   Theme.toastSide === "left"
    readonly property bool atRight:  Theme.toastSide === "right"

    Column {
      id: stack
      width: Theme.toastWidth
      spacing: Theme.toastSpacing

      // Vertical placement (leave room for the bar when anchored at the top).
      anchors.top:    win.atTop    ? parent.top    : undefined
      anchors.bottom: !win.atTop   ? parent.bottom : undefined
      anchors.topMargin:    Theme.barHeight + Theme.toastMargin
      anchors.bottomMargin: Theme.toastMargin

      // Horizontal placement.
      anchors.left:             win.atLeft  ? parent.left  : undefined
      anchors.right:            win.atRight ? parent.right : undefined
      anchors.horizontalCenter: (!win.atLeft && !win.atRight) ? parent.horizontalCenter : undefined
      anchors.leftMargin:  Theme.toastMargin
      anchors.rightMargin: Theme.toastMargin

      Repeater {
        model: Notifications.popups

        delegate: Toast {
          required property var modelData
          width: stack.width
          notif: modelData
        }
      }
    }
  }
}
