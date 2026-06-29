pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.Theme

StyledRect {
    id: root

    property var model: []
    property var labelOf:    (item) => ""
    property var isSelected: (item) => false
    property var isAlert:    (item) => false
    signal activated(var item)

    property Item activeItem: null

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    color: Theme.surface

    Rectangle {
        id: blob
        visible: root.activeItem !== null
        z: 0
        width: 0
        radius: height / 2
        color: Theme.accent
        anchors.verticalCenter: row.verticalCenter
        height: row.implicitHeight - Theme.paddingV * 2
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing / 2

        onXChanged: if (root.activeItem) root._snapBlob()
        onYChanged: if (root.activeItem) root._snapBlob()

        Repeater {
            model: root.model

            delegate: StyledRect {
                id: it
                required property var modelData

                readonly property bool selected: root.isSelected(it.modelData)
                readonly property bool alert: root.isAlert(it.modelData)

                implicitHeight: labelText.implicitHeight + Theme.paddingV * 2
                implicitWidth: labelText.implicitWidth + Theme.paddingH * 2

                color: Theme.transparent

                Text {
                    anchors.centerIn: parent
                    id: labelText
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.size
                    visible: text.length > 0
                    text: root.labelOf(it.modelData)
                    color: it.selected ? Theme.onAccent
                         : it.alert ? Theme.warning
                         : ma.containsMouse ? Theme.text
                         : Theme.subtext
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activated(it.modelData)
                }

                onSelectedChanged: if (it.selected) root.activeItem = it
                Component.onCompleted: if (it.selected) root.activeItem = it
            }
        }
    }

    onActiveItemChanged: Qt.callLater(root._moveBlob)

    function _snapBlob(): void {
        if (!root.activeItem) return; 
        liquid.stop();
        blob.x = row.x + root.activeItem.x + Theme.paddingH / 2;
        blob.width = root.activeItem.width - Theme.paddingH;
        blob.y = row.y + root.activeItem.y;
        // blob.height = root.activeItem.height;
    }

    function _moveBlob(): void {
        if (!root.activeItem) return;

        const targetX = row.x + root.activeItem.x + Theme.paddingH / 2;
        const tw = root.activeItem.width - Theme.paddingH;
        blob.y = row.y + root.activeItem.y;
        // blob.height = root.activeItem.height;

        if (blob.width === 0) {
            blob.x = targetX;
            blob.width = tw;
            return;
        }

        const spanLeft = Math.min(blob.x, targetX);
        const spanRight = Math.max(blob.x + blob.width, targetX + tw);
        liquid.spanX = spanLeft;
        liquid.spanW = spanRight - spanLeft;
        liquid.finalX = targetX;
        liquid.finalW = tw;
        liquid.restart();
    }

    SequentialAnimation {
        id: liquid
        property real spanX
        property real spanW
        property real finalX
        property real finalW
        readonly property int halfDur: Math.round(Theme.animNormal * 0.5)

        ParallelAnimation {
            NumberAnimation { target: blob; property: "x";     to: liquid.spanX; duration: liquid.halfDur; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
            NumberAnimation { target: blob; property: "width"; to: liquid.spanW; duration: liquid.halfDur; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
        }
        ParallelAnimation {
            NumberAnimation { target: blob; property: "x";     to: liquid.finalX; duration: liquid.halfDur; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
            NumberAnimation { target: blob; property: "width"; to: liquid.finalW; duration: liquid.halfDur; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
        }
    }
}