import QtQuick

import "../../themes"
import "../../config"
import "../../services"

Column {
  id: root
  spacing: Appearance.barGap

  property int listHeight: 280

  Item {
    width: parent.width
    height: 20

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: Notifications.count > 0 ? "Notifications (" + Notifications.count + ")"
                                    : "Notifications"
      color: Theme.subtext
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
      font.bold: true
    }

    Text {
      id: clearAll
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      visible: Notifications.count > 0
      text: "Clear all"
      color: clearArea.containsMouse ? Theme.red : Theme.overlay1
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize - 2

      MouseArea {
        id: clearArea
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifications.dismissAll()
      }
    }
  }

  // Fixed height: resizing a mapped xdg-popup leaves ghost surfaces on Hyprland (hyprwm/Hyprland#6682).
  Item {
    width: parent.width
    height: root.listHeight

    ListView {
      id: listView
      anchors.fill: parent
      spacing: Appearance.barGap
      clip: true
      interactive: contentHeight > height
      model: Notifications.list

      delegate: NotificationItem {
        required property var modelData
        width: listView.width
        notif: modelData
      }
    }

    Text {
      anchors.centerIn: parent
      visible: Notifications.count === 0
      text: "No notifications"
      color: Theme.overlay0
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
    }
  }
}
