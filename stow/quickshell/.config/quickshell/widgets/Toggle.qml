import QtQuick

import "../themes"
import "../config"

// Compact on/off switch.
Item {
  id: root

  property bool checked: false
  property color onColor: Theme.accent
  property color offColor: Theme.surface2

  signal toggled(bool checked)

  implicitWidth: 40
  implicitHeight: 22

  Rectangle {
    anchors.fill: parent
    radius: height / 2
    color: root.checked ? root.onColor : root.offColor
    Behavior on color { ColorAnimation { duration: 140 } }

    Rectangle {
      id: knob
      width: parent.height - 6
      height: width
      y: 3
      x: root.checked ? parent.width - width - 3 : 3
      radius: height / 2
      color: Theme.base
      Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      root.checked = !root.checked
      root.toggled(root.checked)
    }
  }
}
