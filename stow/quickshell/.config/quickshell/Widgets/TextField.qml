import QtQuick
import qs.Theme

// A themed single-line text input. Used for the launcher search box and the
// polkit password field. Set `echoMode` to TextInput.Password to mask input.
// Exposes the inner TextInput as `input` so callers can drive focus and forward
// navigation keys (Up/Down/Enter) to their list.
StyledRect {
    id: root

    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias input: input
    property string placeholder: ""

    signal accepted()

    radius: Theme.spacing
    color: Theme.surfaceAlt
    implicitHeight: input.implicitHeight + Theme.paddingV * 3
    implicitWidth: 240

    function clear() { input.text = "" }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingH
        anchors.rightMargin: Theme.paddingH
        verticalAlignment: TextInput.AlignVCenter
        clip: true

        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
        color: Theme.text
        selectionColor: Theme.accent
        selectedTextColor: Theme.onAccent
        selectByMouse: true

        onAccepted: root.accepted()

        // Placeholder shown while empty and not the source of a live edit.
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.placeholder
            visible: input.text.length === 0
            font: input.font
            color: Theme.subtext
        }
    }
}
