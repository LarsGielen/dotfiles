import QtQuick
import Quickshell
import Quickshell.Hyprland

import "../themes"
import "../config"

PopupWindow {
  id: root

  property Item anchorItem
  property int contentWidth: 500
  property int pad: Appearance.margin
  property int gap: Appearance.gap
  property int radius: Appearance.radius
  property int screenMargin: Appearance.margin

  default property alias content: layout.data

  function open()   { root.visible = true }
  function close()  { root.visible = false }
  function toggle() { root.visible = !root.visible }

  implicitWidth: contentWidth + pad * 2
  implicitHeight: layout.implicitHeight + pad * 2
  visible: false
  color: Theme.transparent

  anchor.item: anchorItem
  anchor.rect.y: anchorItem ? anchorItem.height + 5 : 0
  anchor.rect.x: {
    if (!anchorItem || !root.screen) return 0
    const itemX = anchorItem.mapToItem(null, 0, 0).x
    const centered = itemX + (anchorItem.width - root.implicitWidth) / 2
    const minLeft = root.screenMargin
    const maxLeft = root.screen.width - root.screenMargin - root.implicitWidth
    const clamped = Math.max(minLeft, Math.min(centered, maxLeft))
    return Math.round(clamped - itemX)
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.base
    radius: root.radius
    border.width: 1
    border.color: Theme.surface0

    Column {
      id: layout
      x: root.pad 
      y: root.pad
      width: root.contentWidth 
      spacing: root.gap
    }
  }

  onVisibleChanged: {
    if (visible) grabTimer.restart()
    else grab.active = false
  }

  Timer {
    id: grabTimer
    interval: 10
    onTriggered: grab.active = true
  }

  HyprlandFocusGrab {
    id: grab
    windows: [root]
    onCleared: root.close()
  }
}
