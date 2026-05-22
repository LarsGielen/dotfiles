import QtQuick
import Quickshell

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData
      screen: modelData

      color: Theme.transparent

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: Theme.barHeight

      Rectangle {
        id: bar
        anchors.fill: parent
        anchors.topMargin: Theme.margin
        anchors.leftMargin: Theme.margin
        anchors.rightMargin: Theme.margin
        anchors.bottomMargin: 0

        color: Theme.transparent
        border.width: 0

        // Left
        Row {
          anchors.left: parent.left
          anchors.leftMargin: Theme.padding
          anchors.verticalCenter: parent.verticalCenter
          spacing: Theme.gap

          Workspaces { screenName: panel.modelData.name }
        }

        // Center
        Clock {
          anchors.centerIn: parent
        }

        // Right
        Row {
          anchors.right: parent.right
          anchors.rightMargin: Theme.padding
          anchors.verticalCenter: parent.verticalCenter
          spacing: Theme.gap

          Tray {}
          Volume {}
          Network {}
          Battery {}
          NotifyButton {}
        }
      }
    }
  }
}
