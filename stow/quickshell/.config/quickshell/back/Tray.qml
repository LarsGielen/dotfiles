import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import "../Theme"

Row {
  id: root
  spacing: 10
  visible: SystemTray.items.values.length > 0

  Repeater {
    model: SystemTray.items

    delegate: Item {
      id: entry
      required property var modelData
      implicitWidth: Theme.iconSize + 4
      implicitHeight: Theme.itemHeight

      IconImage {
        anchors.centerIn: parent
        implicitSize: Theme.iconSize + 2
        source: entry.modelData.icon
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => {
          if (event.button === Qt.LeftButton) {
            if (entry.modelData.onlyMenu) menu.open()
            else entry.modelData.activate()
          } else if (event.button === Qt.MiddleButton) {
            entry.modelData.secondaryActivate()
          } else {
            menu.open()
          }
        }
      }

      QsMenuAnchor {
        id: menu
        menu: entry.modelData.menu
        anchor.item: entry
        anchor.edges: Edges.Bottom
      }
    }
  }
}
