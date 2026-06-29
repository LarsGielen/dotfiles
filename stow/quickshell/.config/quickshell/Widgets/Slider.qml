import QtQuick
import qs.Theme

// A generic 0..1 horizontal slider. Emits `moved` while dragging; the owner
// decides what to do with the value (it does not mutate `value` itself, so it
// stays a pure view of whatever it is bound to).
Item {
    id: root

    property real value: 0          // current position, expressed in [from, to]
    property real from: 0
    property real to: 1
    signal moved(real value)

    implicitWidth: 140
    implicitHeight: 16

    readonly property real _frac: root.to > root.from
        ? Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from)))
        : 0

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: height / 2
        color: Theme.surfaceAlt

        Rectangle {
            id: fill
            height: parent.height
            radius: height / 2
            width: handle.x + handle.width / 2
            color: Theme.accent
        }
    }

    Rectangle {
        id: handle
        width: root.height
        height: root.height
        radius: height / 2
        y: (root.height - height) / 2
        x: root._frac * (track.width - width)
        color: Theme.text
        border.width: 2
        border.color: Theme.accent
        Behavior on x { enabled: !area.pressed; NumberAnimation { duration: Theme.animFast } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function commit(mx: real): void {
            const usable = root.width - handle.width
            const f = usable > 0 ? Math.max(0, Math.min(1, (mx - handle.width / 2) / usable)) : 0
            root.moved(root.from + f * (root.to - root.from))
        }

        onPressed: e => commit(e.x)
        onPositionChanged: e => { if (pressed) commit(e.x) }
    }
}
