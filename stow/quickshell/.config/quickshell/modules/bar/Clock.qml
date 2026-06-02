import QtQuick
import Quickshell

import "../../themes"
import "../../config"

Rectangle {
  id: root
  implicitWidth: row.implicitWidth + Appearance.barPadding * 2
  implicitHeight: Appearance.barItemHeight
  radius: Appearance.barItemRadius
  color: Theme.surface0

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 8

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Theme.icon(0xf017)   // nf-fa-clock_o
      color: Theme.accent
      font.family: Appearance.font
      font.pixelSize: Appearance.iconSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Qt.formatDateTime(clock.date, "HH:mm")
      color: Theme.text
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
      font.bold: true
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Qt.formatDateTime(clock.date, "ddd d MMM")
      color: Theme.subtext
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
    }
  }
}
