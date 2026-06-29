import QtQuick
import QtQuick.Layouts
import qs.Theme

// An Android-style quick-settings tile: a rounded card with an icon chip, a
// title/subtitle, and an optional expand chevron. Tapping the body emits
// `primary` (usually a toggle); tapping the chevron emits `expand`. When
// `active` it fills with the accent colour, like an enabled QS tile.
StyledRect {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool expandable: false
    property bool expanded: false
    signal primary()
    signal expand()

    radius: Theme.spacing * 1.6
    implicitHeight: 58
    color: root.active ? Theme.accent
         : mainArea.containsPress ? Theme.overlay
         : mainArea.containsMouse ? Theme.surfaceAlt
         : Theme.surface

    readonly property color fg:    root.active ? Theme.onAccent : Theme.text
    readonly property color fgDim: root.active ? Theme.onAccent : Theme.subtext

    // Whole-tile primary action sits underneath; the chevron overlays it.
    MouseArea {
        id: mainArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.primary()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing
        anchors.rightMargin: Theme.spacing
        spacing: Theme.spacing

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 34
            height: 34
            radius: width / 2
            color: root.active ? Qt.rgba(0, 0, 0, 0.13) : Theme.surfaceAlt

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: Theme.font.family
                font.pixelSize: Theme.font.size
                color: root.fg
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.size
                color: root.fg
            }

            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.subtitle
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                color: root.fgDim
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            visible: root.expandable
            text: "\uf078"                       // chevron-down
            rotation: root.expanded ? 180 : 0
            font.family: Theme.font.family
            font.pixelSize: Theme.font.sizeSmall
            color: root.fgDim
            Behavior on rotation { NumberAnimation { duration: Theme.animFast } }
        }
    }

    MouseArea {
        id: chevronArea
        visible: root.expandable
        enabled: root.expandable
        width: 40
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expand()
    }
}
