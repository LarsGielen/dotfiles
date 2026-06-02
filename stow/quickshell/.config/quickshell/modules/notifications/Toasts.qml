import QtQuick
import Quickshell

import "../../themes"
import "../../config"
import "../../services"

// Per-screen overlay for the floating toast stack. Position comes from Appearance.toast*.
Variants {
  model: Quickshell.screens

  PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    visible: Notifications.popups.length > 0
    color: Theme.transparent
    exclusiveZone: 0  // float over things, never reserve space

    // Cover the screen but only let the cards catch the mouse.
    anchors { top: true; bottom: true; left: true; right: true }
    mask: Region { item: stack }

    readonly property bool atTop:    Appearance.toastEdge === "top"
    readonly property bool atLeft:   Appearance.toastSide === "left"
    readonly property bool atRight:  Appearance.toastSide === "right"

    Column {
      id: stack
      width: Appearance.toastWidth
      spacing: Appearance.toastSpacing

      // Vertical: leave room for the bar when anchored at the top.
      anchors.top:    win.atTop    ? parent.top    : undefined
      anchors.bottom: !win.atTop   ? parent.bottom : undefined
      anchors.topMargin:    Appearance.barHeight + Appearance.toastMargin
      anchors.bottomMargin: Appearance.toastMargin

      anchors.left:             win.atLeft  ? parent.left  : undefined
      anchors.right:            win.atRight ? parent.right : undefined
      anchors.horizontalCenter: (!win.atLeft && !win.atRight) ? parent.horizontalCenter : undefined
      anchors.leftMargin:  Appearance.toastMargin
      anchors.rightMargin: Appearance.toastMargin

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
