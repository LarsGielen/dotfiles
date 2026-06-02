import QtQuick

import "../themes"
import "../config"

// A small "label value" pair, e.g. CPU/RAM read-outs.
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
    font.family: Appearance.font
    font.pixelSize: Appearance.fontSize - 3
  }

  Text {
    anchors.verticalCenter: parent.verticalCenter
    text: root.value
    color: root.valueColor
    font.family: Appearance.font
    font.pixelSize: Appearance.fontSize - 3
    font.bold: true
  }
}
