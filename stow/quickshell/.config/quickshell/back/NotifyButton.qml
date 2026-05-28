import QtQuick
import Quickshell.Io

import "../Theme"

Rectangle {
  id: root
  implicitWidth: Theme.itemHeight + 6
  implicitHeight: Theme.itemHeight
  radius: Theme.itemRadius
  color: hover.containsMouse ? Theme.surface1 : Theme.surface0
  Behavior on color { ColorAnimation { duration: 120 } }

  Text {
    anchors.centerIn: parent
    text: Theme.icon(0xf0f3)
    color: Theme.accent
    font.family: Theme.font
    font.pixelSize: Theme.iconSize
  }

  Process { id: toggle; command: ["swaync-client", "-t", "-sw"] }

  MouseArea {
    id: hover
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: toggle.running = true
  }
}
