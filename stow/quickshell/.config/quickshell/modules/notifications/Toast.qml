import QtQuick
import Quickshell
import Quickshell.Services.Notifications

import "../../themes"
import "../../config"
import "../../services"

// One notification as a floating pop-up; expands on the chevron. NotificationItem
// is the static Control Center variant. Clicking opens the default action, or
// falls back to the file manager at a path found in the text.
Rectangle {
  id: root

  required property var notif
  property int pad: Appearance.toastPadding
  property bool expanded: false
  readonly property bool hovered: cardArea.containsMouse

  radius: Appearance.toastRadius
  color: cardArea.containsMouse ? Theme.base : Theme.mantle
  border.width: 1
  border.color: Theme.surface0
  clip: true
  Behavior on color { ColorAnimation { duration: 120 } }

  implicitHeight: content.implicitHeight + pad * 2
  Behavior on implicitHeight { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  opacity: 0
  Component.onCompleted: opacity = 1
  Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  readonly property color accent:
      notif.urgency === NotificationUrgency.Critical ? Theme.red :
      notif.urgency === NotificationUrgency.Low      ? Theme.overlay0 :
                                                       Theme.accent

  readonly property var actionList: notif.actions
  readonly property bool hasDefault: {
    for (const a of actionList) if (a.identifier === "default") return true
    return false
  }
  // file path / file:// URI found in the text, if any
  readonly property string filePath: {
    const text = (notif.body || "") + "\n" + (notif.summary || "")
    let m = text.match(/file:\/\/(\/[^\s'"]+)/)
    if (m) return decodeURIComponent(m[1])
    m = text.match(/(\/[^\s'"<>]+\/[^\s'"<>]+)/)
    if (m) return m[1]
    return ""
  }
  readonly property bool clickable: hasDefault || filePath !== ""

  function activate() {
    for (const a of actionList) {
      if (a.identifier === "default") { a.invoke(); notif.dismiss(); return }
    }
    if (filePath !== "") {
      const dir = filePath.replace(/\/[^\/]*$/, "")
      Quickshell.execDetached(["xdg-open", dir !== "" ? dir : filePath])
      notif.dismiss()
    }
  }

  // Pause the auto-hide countdown while hovered or expanded; restart on leave.
  Timer {
    running: Settings.toastTimeout > 0 && !root.hovered && !root.expanded
    interval: Notifications.popupRemaining(root.notif)
    repeat: false
    onTriggered: Notifications.removePopup(root.notif)
  }
  onHoveredChanged: if (!hovered) Notifications.touchPopup(notif)
  onExpandedChanged: if (!expanded) Notifications.touchPopup(notif)

  MouseArea {
    id: cardArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: if (root.clickable) root.activate(); else root.expanded = !root.expanded
  }

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

  Rectangle {
    id: thumb
    visible: root.notif.image !== ""
    width: visible ? (root.expanded ? 56 : 36) : 0
    height: width
    radius: 8
    clip: true
    color: Theme.surface0
    anchors {
      left: stripe.right
      leftMargin: visible ? 10 : 0
      top: parent.top
      topMargin: root.pad
    }
    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Image {
      anchors.fill: parent
      source: root.notif.image
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
    }
  }

  Text {
    id: chevron
    text: root.expanded ? Theme.icon(0xf077) : Theme.icon(0xf078)  // up / down
    color: chevronArea.containsMouse ? Theme.text : Theme.overlay1
    font.family: Appearance.font
    font.pixelSize: Appearance.fontSize - 2
    anchors {
      top: parent.top
      right: dismiss.left
      rightMargin: 10
      topMargin: root.pad
    }
    MouseArea {
      id: chevronArea
      anchors.fill: parent
      anchors.margins: -6
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.expanded = !root.expanded
    }
  }

  Text {
    id: dismiss
    text: "✕"
    visible: root.hovered || dismissArea.containsMouse
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
    spacing: 4
    anchors {
      left: thumb.visible ? thumb.right : stripe.right
      leftMargin: 10
      right: chevron.left
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
      maximumLineCount: root.expanded ? 3 : 1
      wrapMode: Text.WordWrap
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
      maximumLineCount: root.expanded ? 12 : 1
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: root.clickable && !root.expanded
      text: root.hasDefault ? "↵ Click to open"
                            : "↵ Click to open in file manager"
      color: Theme.overlay0
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize - 3
      elide: Text.ElideRight
    }

    // Action buttons (expanded); default action lives on the card click, so it's excluded.
    Flow {
      width: parent.width
      spacing: 6
      visible: root.expanded
      topPadding: 4

      Repeater {
        model: root.expanded
               ? root.actionList.filter(a => a.identifier !== "default" && a.text !== "")
               : []

        delegate: Rectangle {
          required property var modelData
          height: 24
          width: actionLabel.implicitWidth + 18
          radius: Appearance.toastRadius - 2
          color: actionBtn.containsMouse ? Theme.surface1 : Theme.surface0
          Behavior on color { ColorAnimation { duration: 120 } }

          Text {
            id: actionLabel
            anchors.centerIn: parent
            text: modelData.text
            color: Theme.text
            font.family: Appearance.font
            font.pixelSize: Appearance.fontSize - 2
          }

          MouseArea {
            id: actionBtn
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { modelData.invoke(); root.notif.dismiss() }
          }
        }
      }
    }
  }
}
