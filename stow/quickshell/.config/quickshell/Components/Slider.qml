import QtQuick

import "../Theme"

// Slider ─ horizontal value slider with optional leading / trailing icons.
//
//   Slider { width: parent.width; value: 0.75
//            leadingIcon: 0xf027; trailingIcon: 0xf028
//            onMoved: (v) => audio.volume = v }
//
// `value` is the source of truth (range [from, to]); dragging or clicking
// the track updates it and emits `moved`.
Item {
  id: root

  property real from: 0
  property real to: 1
  property real value: 0.5

  property int leadingIcon: 0
  property int trailingIcon: 0

  property color fillColor: Theme.accent
  property color trackColor: Theme.surface2
  property real trackHeight: 6
  property real handleSize: 14

  signal moved(real value)

  readonly property real ratio: (to - from) === 0 ? 0
    : Math.max(0, Math.min(1, (value - from) / (to - from)))

  implicitWidth: 180
  implicitHeight: Math.max(handleSize, Theme.iconSize)

  Text {
    id: lead
    visible: root.leadingIcon !== 0
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    text: visible ? Theme.icon(root.leadingIcon) : ""
    color: Theme.subtext
    font.family: Theme.font
    font.pixelSize: Theme.iconSize
  }

  Text {
    id: trail
    visible: root.trailingIcon !== 0
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    text: visible ? Theme.icon(root.trailingIcon) : ""
    color: Theme.subtext
    font.family: Theme.font
    font.pixelSize: Theme.iconSize
  }

  Item {
    id: track
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: lead.visible ? lead.right : parent.left
    anchors.leftMargin: lead.visible ? 8 : 0
    anchors.right: trail.visible ? trail.left : parent.right
    anchors.rightMargin: trail.visible ? 8 : 0
    height: parent.height

    Rectangle {                                   // track background
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width
      height: root.trackHeight
      radius: height / 2
      color: root.trackColor
    }

    Rectangle {                                   // filled portion
      anchors.verticalCenter: parent.verticalCenter
      width: handle.x + handle.width / 2
      height: root.trackHeight
      radius: height / 2
      color: root.fillColor
    }

    Rectangle {                                   // handle
      id: handle
      y: (parent.height - height) / 2
      x: root.ratio * (track.width - width)
      width: root.handleSize
      height: root.handleSize
      radius: height / 2
      color: Theme.text
      border.width: 2
      border.color: root.fillColor
      scale: drag.pressed ? 1.15 : 1
      Behavior on scale { NumberAnimation { duration: 100 } }
    }

    MouseArea {
      id: drag
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      function setFromX(mx) {
        const span = track.width - handle.width
        if (span <= 0) return
        const t = Math.max(0, Math.min(1, (mx - handle.width / 2) / span))
        root.value = root.from + t * (root.to - root.from)
        root.moved(root.value)
      }
      onPressed: (e) => setFromX(e.x)
      onPositionChanged: (e) => { if (pressed) setFromX(e.x) }
    }
  }
}
