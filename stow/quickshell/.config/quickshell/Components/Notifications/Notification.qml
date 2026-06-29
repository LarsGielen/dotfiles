pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.Theme
import qs.Config
import qs.Services
import qs.Widgets

// A single notification toast. Modern, minimal card: circular app badge,
// hover-to-expand body, action chips, and a thin countdown bar that depletes
// as the auto-hide timer runs. Clicking the card invokes the linked default
// action (or opens a file path found in the text) when there is one.
StyledRect {
    id: root

    required property var notif

    readonly property bool hovered: cardArea.containsMouse
    readonly property bool expanded: hovered

    radius: NotificationConfig.radius
    color: root.hovered ? Theme.surfaceAlt : Theme.surface
    border.width: 1
    border.color: Theme.overlay
    clip: true

    implicitWidth: NotificationConfig.width
    implicitHeight: content.implicitHeight + NotificationConfig.padding * 2
    Behavior on implicitHeight { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

    readonly property color urgencyColor:
        notif.urgency === NotificationUrgency.Critical ? Theme.error
      : notif.urgency === NotificationUrgency.Low      ? Theme.subtext
      :                                                  Theme.accent

    readonly property var actionList: notif.actions
    readonly property bool hasDefault: {
        for (const a of root.actionList) if (a.identifier === "default") return true
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
    readonly property bool clickable: root.hasDefault || root.filePath !== ""

    function activate(): void {
        for (const a of root.actionList) {
            if (a.identifier === "default") { a.invoke(); root.notif.dismiss(); return }
        }
        if (root.filePath !== "") {
            const dir = root.filePath.replace(/\/[^\/]*$/, "")
            Quickshell.execDetached(["xdg-open", dir !== "" ? dir : root.filePath])
            root.notif.dismiss()
        }
    }

    // Auto-hide; paused while hovered. Leaving refreshes the deadline so the
    // countdown (and the progress bar below) restart from full.
    Timer {
        running: NotificationConfig.timeout > 0 && !root.hovered
        interval: Notifications.popupRemaining(root.notif)
        repeat: false
        onTriggered: Notifications.removePopup(root.notif)
    }
    onHoveredChanged: if (!root.hovered) Notifications.touchPopup(root.notif)

    MouseArea {
        id: cardArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.clickable) root.activate()
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: NotificationConfig.padding
        }
        spacing: Theme.spacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing

            // Circular app badge: image -> resolved app icon -> tinted initial.
            Rectangle {
                id: badge
                Layout.alignment: Qt.AlignTop
                width: NotificationConfig.iconSize
                height: NotificationConfig.iconSize
                radius: width / 2
                color: root.urgencyColor
                clip: true

                readonly property string src: {
                    if (root.notif.image !== "") return root.notif.image
                    if (root.notif.appIcon !== "") return Quickshell.iconPath(root.notif.appIcon, true)
                    return ""
                }

                Image {
                    anchors.fill: parent
                    visible: badge.src !== ""
                    source: badge.src
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                }
                Text {
                    anchors.centerIn: parent
                    visible: badge.src === ""
                    text: (root.notif.appName || root.notif.summary || "?").charAt(0).toUpperCase()
                    color: Theme.surface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeLarge
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    visible: root.notif.appName !== ""
                    text: root.notif.appName
                    color: root.urgencyColor
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall
                    font.bold: true
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    visible: root.notif.summary !== ""
                    text: root.notif.summary
                    color: Theme.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.size
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: root.expanded ? 2 : 1
                    wrapMode: Text.WordWrap
                }
            }

            // Dismiss — faint until the card is hovered.
            IconButton {
                Layout.alignment: Qt.AlignTop
                implicitWidth: implicitHeight
                label: "✕"
                tint: Theme.subtext
                normalColor: Theme.transparent
                hoverColor: Theme.overlay
                pressColor: Theme.overlay
                opacity: root.hovered ? 1 : 0.35
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                onClicked: root.notif.dismiss()
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.notif.body !== ""
            text: root.notif.body
            color: Theme.subtext
            font.family: Theme.font.family
            font.pixelSize: Theme.font.size
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
            maximumLineCount: root.expanded ? NotificationConfig.bodyLinesExpanded
                                            : NotificationConfig.bodyLinesCollapsed
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: root.clickable && !root.expanded
            text: root.hasDefault ? "↵ click to open" : "↵ click to open in file manager"
            color: Theme.overlay
            font.family: Theme.font.family
            font.pixelSize: Theme.font.sizeSmall
            elide: Text.ElideRight
        }

        // Non-default actions as chips (default lives on the card click).
        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacing / 2
            visible: root.expanded && actions.count > 0

            Repeater {
                id: actions
                model: root.expanded
                       ? root.actionList.filter(a => a.identifier !== "default" && a.text !== "")
                       : []

                delegate: IconButton {
                    required property var modelData
                    label: modelData.text
                    tint: Theme.text
                    normalColor: Theme.surface
                    hoverColor: Theme.overlay
                    onClicked: { modelData.invoke(); root.notif.dismiss() }
                }
            }
        }
    }
}
