import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import "../../widgets"
import "../../themes"
import "../../config"

Item {
  id: root
  implicitWidth: toggle.implicitWidth
  implicitHeight: toggle.implicitHeight

  visible: SystemTray.items.values.length > 0

  IconButton {
    id: toggle
    itemHeight: Appearance.barItemHeight
    itemRadius: Appearance.barItemRadius
    hPadding: Appearance.barPadding
    icon: panel.visible ? 0xf077 : 0xf078
    active: panel.visible
    onClicked: panel.toggle()
  }

  Dropdown {
    id: panel
    anchorItem: toggle
    contentWidth: 220

    Text {
      width: parent.width
      text: "System Tray"
      color: Theme.subtext
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
      font.bold: true
    }

    Column {
      width: parent.width
      spacing: 4

      Repeater {
        model: SystemTray.items

        delegate: Rectangle {
          id: entry
          required property var modelData

          width: parent.width
          height: Appearance.barItemHeight + 6
          radius: Appearance.barItemRadius
          color: itemMouse.containsMouse ? Theme.surface0 : Theme.transparent
          Behavior on color { ColorAnimation { duration: 120 } }

          IconImage {
            id: trayIcon
            anchors.left: parent.left
            anchors.leftMargin: Appearance.barPadding
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: Appearance.iconSize + 2
            source: entry.modelData.icon
          }

          Text {
            anchors.left: trayIcon.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: Appearance.barPadding
            anchors.verticalCenter: parent.verticalCenter
            text: entry.modelData.tooltipTitle || entry.modelData.title || entry.modelData.id
            color: Theme.text
            font.family: Appearance.font
            font.pixelSize: Appearance.fontSize
            elide: Text.ElideRight
          }

          MouseArea {
            id: itemMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (event) => {
              if (event.button === Qt.LeftButton) {
                entry.modelData.activate()
              }
            }
          }
        }
      }
    }
  }
}
