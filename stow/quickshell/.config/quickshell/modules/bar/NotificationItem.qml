import QtQuick
import Quickshell.Services.Notifications

import "../../themes"
import "../../config"

// One notification as a card (Control Center). Toast is the floating variant.
Rectangle {
  id: root

  required property var notif
  property int pad: 12

  implicitHeight: content.implicitHeight + pad * 2
  radius: Appearance.barItemRadius
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
    font.family: Appearance.font
    font.pixelSize: Appearance.fontSize
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
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize - 3
      font.bold: true
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: root.notif.summary !== ""
      text: root.notif.summary
      color: Theme.text
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
      font.bold: true
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: root.notif.body !== ""
      text: root.notif.body
      color: Theme.subtext
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
      textFormat: Text.PlainText
      wrapMode: Text.WordWrap
      maximumLineCount: 4
      elide: Text.ElideRight
    }
  }
}
