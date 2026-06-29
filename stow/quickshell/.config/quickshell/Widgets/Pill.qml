import QtQuick
import QtQuick.Layouts
import qs.Theme

StyledRect {
    id: root

    property alias label: labelText.text
    property color tint: Theme.text

    implicitWidth:  row.implicitWidth + Theme.paddingH * 2
    implicitHeight: row.implicitHeight + Theme.paddingV * 2
    color: Theme.surface

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing / 2

        Text {
            id: labelText
            font.family: Theme.font.family
            font.pixelSize: Theme.font.size
            color: Theme.text
            visible: text.length > 0
        }
    }
}
