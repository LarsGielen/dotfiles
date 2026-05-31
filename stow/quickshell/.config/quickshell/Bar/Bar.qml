import QtQuick
import Quickshell

import "../Theme"

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
        anchors.topMargin: Theme.topMargin
        anchors.leftMargin: Theme.sideMargin
        anchors.rightMargin: Theme.sideMargin
        anchors.bottomMargin: 0

        color: Theme.transparent
        border.width: 0
        radius: Theme.radius

        // Left
        Row {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: Theme.gap

          Workspaces { screenName: panel.modelData.name } 
        }

        // Center
        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          spacing: Theme.gap  

          Clock {}
        }

        // Right
        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Theme.gap

          ResourceMonitor {}
          Tray {}
          Audio {}
          ControlCenter {}
        }
      }
    }
  }
}
