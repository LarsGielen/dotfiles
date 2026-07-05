import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Widgets

// One result row in the launcher: app icon, name and description. Modeled on
// MenuItem's selectable-row styling.
StyledRect {
    id: root

    required property var entry
    property bool selected: false
    signal activated()

    radius: Theme.spacing
    implicitHeight: rowLayout.implicitHeight + Theme.paddingV * 2
    color: area.containsPress ? Theme.overlay
         : (root.selected || area.containsMouse) ? Theme.surfaceAlt
         : Theme.transparent

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingH
        anchors.rightMargin: Theme.paddingH
        spacing: Theme.spacing

        Image {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            sourceSize.width: 32
            sourceSize.height: 32
            fillMode: Image.PreserveAspectFit
            visible: source != ""
            source: root.entry && root.entry.icon ? Quickshell.iconPath(root.entry.icon, true) : ""
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.entry ? root.entry.name : ""
                font.family: Theme.font.family
                font.pixelSize: Theme.font.size
                color: root.selected ? Theme.accent : Theme.text
            }

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                visible: text.length > 0
                text: root.entry && root.entry.comment ? root.entry.comment : ""
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                color: Theme.subtext
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
