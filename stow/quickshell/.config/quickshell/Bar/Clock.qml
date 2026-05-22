import QtQuick
import Quickshell

// Centered clock: bold time with a lighter date beside it.
Rectangle {
  id: root
  implicitWidth: row.implicitWidth + Theme.padding * 2
  implicitHeight: Theme.itemHeight
  radius: Theme.itemRadius
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
      font.family: Theme.font
      font.pixelSize: Theme.iconSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Qt.formatDateTime(clock.date, "HH:mm")
      color: Theme.text
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
      font.bold: true
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Qt.formatDateTime(clock.date, "ddd d MMM")
      color: Theme.subtext
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
    }
  }
}
