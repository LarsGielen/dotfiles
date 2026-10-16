import QtQuick
import Quickshell
import qs.Theme
import qs.Widgets

// Shows the time; hovering peeks the date, left click pins it, right click
// unpins it. The date slides out to the left of the time.
Pill {
    id: root

    property bool dateShown: false

    // 0 = time only, 1 = date fully revealed.
    property real reveal: area.containsMouse || root.dateShown ? 1 : 0
    Behavior on reveal {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    // The Pill's own label is unused: the date needs to animate in separately
    // from the time, which a single text can't do.
    implicitWidth: content.implicitWidth + Theme.paddingH * 2
    implicitHeight: content.implicitHeight + Theme.paddingV * 2

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: content
        anchors.centerIn: parent

        Item {
            width: (dateText.implicitWidth + Theme.spacing) * root.reveal
            height: timeText.implicitHeight
            opacity: root.reveal
            clip: true

            Text {
                id: dateText
                text: Qt.formatDateTime(clock.date, "ddd d MMM")
                font: timeText.font
                color: Theme.text
            }
        }

        Text {
            id: timeText
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.family: Theme.font.family
            font.pixelSize: Theme.font.size
            color: Theme.text
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => root.dateShown = mouse.button === Qt.LeftButton && !root.dateShown
    }
}
