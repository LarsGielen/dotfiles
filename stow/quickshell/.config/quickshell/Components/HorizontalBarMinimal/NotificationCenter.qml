pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Widgets
import qs.Services

// The notification-center panel hosted by NotificationBell's dropdown: a header
// (title + Do Not Disturb toggle + clear-all) above a height-capped, scrollable
// list of every tracked notification, newest first.
ColumnLayout {
    id: root
    spacing: Theme.spacing

    // Cap before the list scrolls instead of growing the dropdown unbounded.
    readonly property int maxListHeight: 420

    // Newest first: the server appends, so reverse a copy for display.
    readonly property var entries: Notifications.list.values.slice().reverse()

    // --- header ---
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing

        Text {
            Layout.fillWidth: true
            text: "Notifications"
            color: Theme.text
            font.family: Theme.font.family
            font.pixelSize: Theme.font.sizeLarge
            font.bold: true
        }

        // Do Not Disturb — accent tint while active.
        IconButton {
            implicitWidth: implicitHeight
            label: ""                       // moon
            tint: Notifications.dnd ? Theme.accent : Theme.subtext
            normalColor: Theme.transparent
            hoverColor: Theme.surfaceAlt
            onClicked: Notifications.toggleDnd()
        }

        IconButton {
            visible: Notifications.count > 0
            label: "Clear all"
            tint: Theme.subtext
            normalColor: Theme.transparent
            hoverColor: Theme.surfaceAlt
            onClicked: Notifications.dismissAll()
        }
    }

    // --- empty state ---
    Text {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing
        Layout.bottomMargin: Theme.spacing
        visible: Notifications.count === 0
        text: "No notifications"
        horizontalAlignment: Text.AlignHCenter
        color: Theme.subtext
        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
    }

    // --- list ---
    Flickable {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(listColumn.implicitHeight, root.maxListHeight)
        visible: Notifications.count > 0
        clip: true
        contentWidth: width
        contentHeight: listColumn.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: listColumn
            width: parent.width
            spacing: Theme.spacing

            Repeater {
                model: root.entries
                delegate: NotificationEntry {
                    required property var modelData
                    Layout.fillWidth: true
                    notif: modelData
                }
            }
        }
    }
}
