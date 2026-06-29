import QtQuick
import Quickshell

import qs.Theme

StyledRect {
    id: root

    property alias label: label.text
    property color tint: Theme.text
    signal clicked()

    property color normalColor: Theme.surface
    property color hoverColor: Theme.surfaceAlt
    property color pressColor: Theme.overlay

    implicitWidth: label.implicitWidth + Theme.paddingH * 2
    implicitHeight: label.implicitHeight + Theme.paddingV * 2
    
    color: area.containsPress ? root.pressColor
         : area.containsMouse ? root.hoverColor
         : root.normalColor

    Text {
        id: label
        anchors.centerIn: parent
        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
        color: root.tint
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}