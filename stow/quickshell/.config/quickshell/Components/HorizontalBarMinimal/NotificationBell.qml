import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Widgets
import qs.Services

// Bar entry point for the notification center: a bell button with an unread
// count badge that toggles a dropdown hosting NotificationCenter. Analog of
// Control.qml (which hosts QuickSettings). IconButton is a StyledRect with no
// overlay slot, so the badge floats over a wrapping Item — which is also what
// the bar and the dropdown anchor to.
Item {
    id: root

    implicitWidth: bell.implicitWidth
    implicitHeight: bell.implicitHeight

    IconButton {
        id: bell
        anchors.fill: parent
        label: Notifications.dnd ? "" : ""   // bell-slash : bell
        tint: Notifications.count > 0 ? Theme.accent : Theme.text
        onClicked: dropdown.toggle()
    }

    // Unread count badge, floating over the top-right corner.
    Rectangle {
        id: badge
        visible: Notifications.count > 0
        color: Theme.accent
        radius: height / 2
        height: countText.implicitHeight + 2
        width: Math.max(height, countText.implicitWidth + 6)
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: -width / 4
            topMargin: -height / 4
        }

        Text {
            id: countText
            anchors.centerIn: parent
            text: Notifications.count
            color: Theme.onAccent
            font.family: Theme.font.family
            font.pixelSize: Theme.font.sizeSmall
            font.bold: true
        }
    }

    Dropdown {
        id: dropdown
        anchorItem: root
        contentWidth: 360
        radius: Theme.spacing * 2.2

        NotificationCenter { Layout.fillWidth: true }
    }
}
