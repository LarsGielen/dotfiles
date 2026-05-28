import QtQuick

import "../Theme"

// StatTile ─ a small "LABEL value" pair, e.g. for CPU / RAM read-outs.
//
//   Column { StatTile { label: "CPU"; value: "12%" }
//            StatTile { label: "RAM"; value: "3G"  } }
Row {
  id: root

  property string label: ""
  property string value: ""
  property color labelColor: Theme.subtext
  property color valueColor: Theme.text

  spacing: 6

  Text {
    anchors.verticalCenter: parent.verticalCenter
    text: root.label
    color: root.labelColor
    font.family: Theme.font
    font.pixelSize: Theme.fontSize - 3
  }

  Text {
    anchors.verticalCenter: parent.verticalCenter
    text: root.value
    color: root.valueColor
    font.family: Theme.font
    font.pixelSize: Theme.fontSize - 3
    font.bold: true
  }
}
