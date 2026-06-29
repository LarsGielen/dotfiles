import QtQuick
import QtQuick.Layouts
import qs.Theme

// A single selectable row: label on the left, a check mark when selected.
// Used by Select for the entries of any dropdown list.
StyledRect {
    id: root

    property alias label: labelText.text
    property bool selected: false
    signal clicked()

    radius: Theme.spacing
    implicitWidth:  row.implicitWidth + Theme.paddingH * 2
    implicitHeight: labelText.implicitHeight + Theme.paddingV * 2
    color: area.containsPress ? Theme.overlay
         : area.containsMouse ? Theme.surfaceAlt
         : Theme.transparent

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingH
        anchors.rightMargin: Theme.paddingH
        spacing: Theme.spacing

        Text {
            id: labelText
            Layout.fillWidth: true
            elide: Text.ElideRight
            font.family: Theme.font.family
            font.pixelSize: Theme.font.size
            color: root.selected ? Theme.accent : Theme.text
        }

        Text {
            text: "\uf00c"                       // check
            visible: root.selected
            font.family: Theme.font.family
            font.pixelSize: Theme.font.sizeSmall
            color: Theme.accent
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
