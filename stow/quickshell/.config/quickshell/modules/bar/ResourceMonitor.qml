import QtQuick

import "../../widgets"
import "../../services"
import "../../themes"
import "../../config"

Row {
  id: root
  spacing: detail.visible ? Appearance.barGap : 0

  property bool expanded: false

  Rectangle {
    id: detail
    height: Appearance.barItemHeight
    radius: Appearance.barItemRadius
    color: Theme.surface0
    clip: true

    width: root.expanded ? inner.implicitWidth + Appearance.barPadding * 2 : 0
    opacity: root.expanded ? 1 : 0
    visible: width > 1

    Behavior on width   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Row {
      id: inner
      anchors.right: parent.right
      anchors.rightMargin: Appearance.barPadding
      anchors.verticalCenter: parent.verticalCenter
      spacing: 13

      StatTile {
        label: Theme.icon(0xf2c9)
        labelColor: Theme.blue
        value: SystemStats.cpuTempText
      }

      StatTile {
        label: Theme.icon(0xf2c9)
        labelColor: Theme.green
        value: SystemStats.gpuTempText
      }

      StatTile {
        label: "RAM"
        value: SystemStats.ramText
      }

      StatTile {
        label: "VRAM"
        labelColor: Theme.green
        value: SystemStats.vramText
      }
    }
  }

  Pill {
    id: toggle
    interactive: true
    itemHeight: Appearance.barItemHeight
    itemRadius: Appearance.barItemRadius
    hPadding: Appearance.barPadding
    active: root.expanded
    onClicked: root.expanded = !root.expanded

    Row {
      spacing: 7

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Theme.icon(0xf2db)  // microchip
        color: toggle.active ? Theme.base : Theme.subtext
        font.family: Appearance.font
        font.pixelSize: Appearance.iconSize
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: SystemStats.cpuUsageText
        color: toggle.active ? Theme.base : Theme.blue
        font.family: Appearance.font
        font.pixelSize: Appearance.fontSize
        font.bold: true
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "·"
        color: toggle.active ? Theme.base : Theme.overlay1
        font.family: Appearance.font
        font.pixelSize: Appearance.fontSize
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: SystemStats.gpuUsageText
        color: toggle.active ? Theme.base : Theme.green
        font.family: Appearance.font
        font.pixelSize: Appearance.fontSize
        font.bold: true
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Theme.icon(0xf053)  // chevron-left
        color: toggle.active ? Theme.base : Theme.subtext
        font.family: Appearance.font
        font.pixelSize: Appearance.fontSize - 2
        rotation: root.expanded ? 180 : 0
        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      }
    }
  }
}
