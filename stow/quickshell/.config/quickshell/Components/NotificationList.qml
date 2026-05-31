import QtQuick

import "../Theme"
import "../Services"

// NotificationList ─ the Control Center's notification section: a header with a
// "Clear all" action over a fixed-height, scrolling list of NotificationItem
// cards (with an empty-state line). Reads everything from the Notifications
// singleton.
//
// The list area is a FIXED height on purpose: dismissing or receiving a
// notification then scrolls the list internally instead of resizing the popup.
// Resizing a mapped xdg-popup leaves ghost surfaces on Hyprland (hyprwm/
// Hyprland#6682), which is what made the panel appear to render twice.
//
//   NotificationList { width: parent.width }
Column {
  id: root
  spacing: Theme.gap

  property int listHeight: 280

  // Header: title + count, with a Clear all action on the right.
  Item {
    width: parent.width
    height: 20

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: Notifications.count > 0 ? "Notifications (" + Notifications.count + ")"
                                    : "Notifications"
      color: Theme.subtext
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
      font.bold: true
    }

    Text {
      id: clearAll
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      visible: Notifications.count > 0
      text: "Clear all"
      color: clearArea.containsMouse ? Theme.red : Theme.overlay1
      font.family: Theme.font
      font.pixelSize: Theme.fontSize - 2

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

  // Fixed-height area so the popup never resizes as notifications come and go.
  Item {
    width: parent.width
    height: root.listHeight

    ListView {
      id: listView
      anchors.fill: parent
      spacing: Theme.gap
      clip: true
      // Only grab drags when there's actually something to scroll.
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
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
    }
  }
}
