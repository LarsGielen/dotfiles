pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.Theme
import qs.Config
import qs.Widgets

// One row in the notification center. Shares the toast's visual language
// (circular app badge, hover-to-expand body, action chips) but is persistent:
// no auto-hide timer — it lives until the notification is dismissed.
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

    function activate(): void {
        for (const a of root.actionList) {
            if (a.identifier === "default") { a.invoke(); root.notif.dismiss(); return }
        }
    }

    MouseArea {
        id: cardArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.hasDefault ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.hasDefault) root.activate()
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

            // Dismiss — faint until the row is hovered.
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

        // Non-default actions as chips (default lives on the row click).
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
