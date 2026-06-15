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

  property bool _open: false

  function open() {
    if (_open) return
    _open = true
    root.visible = true
    closeAnim.stop()
    openAnim.start()
  }

  function close() {
    if (!_open) return
    _open = false
    openAnim.stop()
    closeAnim.start()
  }

  function toggle() { _open ? close() : open() }

  implicitWidth: contentWidth + pad * 2
  implicitHeight: layout.implicitHeight + pad * 2
  visible: false
  color: Theme.transparent

  readonly property var _anchorLayout: {
    if (!anchorItem || !root.screen) return { x: 0, origin: Item.Top }
    const itemX = anchorItem.mapToItem(null, 0, 0).x
    const centered = itemX + (anchorItem.width - root.implicitWidth) / 2
    const minLeft = root.screenMargin
    const maxLeft = root.screen.width - root.screenMargin - root.implicitWidth
    const clamped = Math.max(minLeft, Math.min(centered, maxLeft))
    const origin = clamped <= minLeft ? Item.TopLeft
                 : clamped >= maxLeft ? Item.TopRight
                 : Item.Top
    return { x: Math.round(clamped - itemX), origin }
  }

  anchor.item: anchorItem
  anchor.rect.y: anchorItem ? anchorItem.height + 5 : 0
  anchor.rect.x: _anchorLayout.x

  Rectangle {
    id: inner
    anchors.fill: parent
    color: Theme.base
    radius: root.radius
    border.width: 1
    border.color: Theme.surface0
    transformOrigin: root._anchorLayout.origin
    opacity: 0
    scale: 0.9

    Column {
      id: layout
      x: root.pad
      y: root.pad
      width: root.contentWidth
      spacing: root.gap
    }
  }

  ParallelAnimation {
    id: openAnim
    NumberAnimation { target: inner; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
    NumberAnimation { target: inner; property: "scale";   from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
  }

  SequentialAnimation {
    id: closeAnim
    ParallelAnimation {
      NumberAnimation { target: inner; property: "opacity"; to: 0; duration: 140; easing.type: Easing.InCubic }
      NumberAnimation { target: inner; property: "scale";   to: 0; duration: 140; easing.type: Easing.InCubic }
    }
    ScriptAction { script: { root.visible = false; grab.active = false } }
  }

  onVisibleChanged: {
    if (visible) grabTimer.restart()
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
