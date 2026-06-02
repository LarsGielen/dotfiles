import QtQuick
import Quickshell

import "../../themes"
import "../../config"

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

      implicitHeight: Appearance.barHeight

      Rectangle {
        id: bar
        anchors.fill: parent
        anchors.topMargin: Appearance.barTopMargin
        anchors.leftMargin: Appearance.barSideMargin
        anchors.rightMargin: Appearance.barSideMargin
        anchors.bottomMargin: 0

        color: Theme.transparent

        Row {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: Appearance.barGap

          Workspaces { screenName: panel.modelData.name }
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          spacing: Appearance.barGap  

          Clock {}
        }

        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Appearance.barGap

          ResourceMonitor {}
          Tray {}
          Audio {}
          ControlCenter {}
        }
      }
    }
  }
}
