import QtQuick
import Quickshell
import Quickshell.Services.Notifications

import "../Theme"
import "../Services"

// Toast ─ one notification rendered as a floating pop-up. It starts collapsed
// (app name + summary + one line of body) and expands on the chevron to reveal
// the full body, an image and any action buttons. Clicking the card "opens" the
// notification: it invokes the notification's default action if it has one, and
// otherwise falls back to opening the folder of a file path found in the text
// (so a finished download opens the file manager at the right place).
//
//   Toast { notif: someNotification }
Rectangle {
  id: root

  required property var notif
  property int pad: 12
  property bool expanded: false
  readonly property bool hovered: cardArea.containsMouse

  radius: Theme.itemRadius
  color: cardArea.containsMouse ? Theme.base : Theme.mantle
  border.width: 1
  border.color: Theme.surface0
  clip: true
  Behavior on color { ColorAnimation { duration: 120 } }

  implicitHeight: content.implicitHeight + pad * 2
  Behavior on implicitHeight { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  // Entrance fade-in.
  opacity: 0
  Component.onCompleted: opacity = 1
  Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  readonly property color accent:
      notif.urgency === NotificationUrgency.Critical ? Theme.red :
      notif.urgency === NotificationUrgency.Low      ? Theme.overlay0 :
                                                       Theme.accent

  // ── "Open" target detection ───────────────────────────────────────────────
  readonly property var actionList: notif.actions
  readonly property bool hasDefault: {
    for (const a of actionList) if (a.identifier === "default") return true
    return false
  }
  // A file path / file:// URI mentioned in the notification, if any.
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

  // Pause the auto-hide countdown while hovered or expanded; restart it on leave.
  Timer {
    running: Theme.toastTimeout > 0 && !root.hovered && !root.expanded
    interval: Notifications.popupRemaining(root.notif)
    repeat: false
    onTriggered: Notifications.removePopup(root.notif)
  }
  onHoveredChanged: if (!hovered) Notifications.touchPopup(notif)
  onExpandedChanged: if (!expanded) Notifications.touchPopup(notif)

  // Click anywhere on the card (except the buttons, which sit on top) to open it.
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

  // Optional thumbnail (notification image), shown small while collapsed.
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

  // Expand / collapse chevron.
  Text {
    id: chevron
    text: root.expanded ? Theme.icon(0xf077) : Theme.icon(0xf078)  // up / down
    color: chevronArea.containsMouse ? Theme.text : Theme.overlay1
    font.family: Theme.font
    font.pixelSize: Theme.fontSize - 2
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

  // Dismiss (hover-revealed).
  Text {
    id: dismiss
    text: "✕"
    visible: root.hovered || dismissArea.containsMouse
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
      maximumLineCount: root.expanded ? 3 : 1
      wrapMode: Text.WordWrap
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
      maximumLineCount: root.expanded ? 12 : 1
      elide: Text.ElideRight
    }

    // Hint that the card is clickable, only while collapsed.
    Text {
      width: parent.width
      visible: root.clickable && !root.expanded
      text: root.hasDefault ? "↵ Click to open"
                            : "↵ Click to open in file manager"
      color: Theme.overlay0
      font.family: Theme.font
      font.pixelSize: Theme.fontSize - 3
      elide: Text.ElideRight
    }

    // Action buttons (expanded only). The default action is handled by clicking
    // the card itself, so it's excluded here.
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
          radius: Theme.itemRadius - 2
          color: actionBtn.containsMouse ? Theme.surface1 : Theme.surface0
          Behavior on color { ColorAnimation { duration: 120 } }

          Text {
            id: actionLabel
            anchors.centerIn: parent
            text: modelData.text
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
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
