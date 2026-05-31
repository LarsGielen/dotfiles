import QtQuick
import Quickshell.Services.Notifications

import "../Theme"

// NotificationItem ─ one notification rendered as a card: an urgency-coloured
// stripe, app name, summary and body, with a hover-to-reveal dismiss button.
//
//   NotificationItem { notif: someNotification }
Rectangle {
  id: root

  required property var notif
  property int pad: 12

  implicitHeight: content.implicitHeight + pad * 2
  radius: Theme.itemRadius
  color: Theme.mantle
  border.width: 1
  border.color: Theme.surface0
  clip: true

  readonly property color accent:
      notif.urgency === NotificationUrgency.Critical ? Theme.red :
      notif.urgency === NotificationUrgency.Low      ? Theme.overlay0 :
                                                       Theme.accent

  Rectangle {
    id: stripe
    width: 3
    radius: 2
    color: root.accent
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
      margins: root.pad
    }
  }

  Text {
    id: dismiss
    text: "✕"
    color: dismissArea.containsMouse ? Theme.red : Theme.overlay1
    font.family: Theme.font
    font.pixelSize: Theme.fontSize
    anchors {
      top: parent.top
      right: parent.right
      margins: root.pad
    }

    MouseArea {
      id: dismissArea
      anchors.fill: parent
      anchors.margins: -6
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.notif.dismiss()
    }
  }

  Column {
    id: content
    spacing: 3
    anchors {
      left: stripe.right
      leftMargin: 10
      right: dismiss.left
      rightMargin: 8
      top: parent.top
      topMargin: root.pad
    }

    Text {
      width: parent.width
      visible: root.notif.appName !== ""
      text: root.notif.appName
      color: root.accent
      font.family: Theme.font
      font.pixelSize: Theme.fontSize - 3
      font.bold: true
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: root.notif.summary !== ""
      text: root.notif.summary
      color: Theme.text
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
      font.bold: true
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: root.notif.body !== ""
      text: root.notif.body
      color: Theme.subtext
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
      textFormat: Text.PlainText
      wrapMode: Text.WordWrap
      maximumLineCount: 4
      elide: Text.ElideRight
    }
  }
}
