import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.Theme

PopupWindow {
    id: root

    property Item anchorItem
    property int contentWidth: 500
    property int pad: Theme.paddingH
    property int gap: Theme.spacing
    property int radius: height / 2
    property int screenMargin: Theme.screenMarginSide
    property int screenMarginTop: Theme.screenMarginTop

    default property alias content: layout.data

    property bool _open: false

    function open() {
        if (_open) return
        _open = true
        root.visible = true
        closeAnim.stop()
        openAnim.start()
    }

    function close() {
        if (!_open) return
        _open = false
        openAnim.stop()
        closeAnim.start()
    }

    function toggle() { _open ? close() : open() }

    // Fixed width so growing content (a long device name) can't shove the
    // popup sideways. Height tracks the content but animates, so the window
    // resizes in one smooth pass instead of jittering per frame.
    implicitWidth: contentWidth + pad * 2
    implicitHeight: layout.implicitHeight + pad * 2
    Behavior on implicitHeight { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
    grabFocus: true
    visible: false
    color: Theme.transparent

    onVisibleChanged: if (!visible) _open = false

    readonly property var _anchorLayout: {
        if (!anchorItem || !root.screen) return { x: 0, origin: Item.Top }
        const itemX = anchorItem.mapToItem(null, 0, 0).x
        const centered = itemX + (anchorItem.width - root.implicitWidth) / 2
        const minLeft = root.screenMargin
        const maxLeft = root.screen.width - root.screenMargin - root.implicitWidth
        const clamped = Math.max(minLeft, Math.min(centered, maxLeft))
        const origin = clamped <= minLeft ? Item.TopLeft
                    : clamped >= maxLeft ? Item.TopRight
                    : Item.Top
        return { x: Math.round(clamped - itemX), origin }
    }

    anchor.item: anchorItem
    anchor.adjustment: PopupAdjustment.All
    anchor.rect.y: anchorItem ? anchorItem.height + root.screenMarginTop : 0
    anchor.rect.x: _anchorLayout.x

    Rectangle {
        id: inner
        anchors.fill: parent
        color: Theme.surface
        radius: root.radius
        border.width: 1
        border.color: Theme.surfaceAlt
        transformOrigin: root._anchorLayout.origin
        opacity: 0
        scale: 0.9
        clip: true

        // Pinned to the top so the content keeps its natural height while the
        // window animates around it — the extra rows are revealed by clipping,
        // never squashed.
        ColumnLayout {
        id: layout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.pad
        spacing: root.gap
        }
    }

    ParallelAnimation {
        id: openAnim
        NumberAnimation { target: inner; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { target: inner; property: "scale";   from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
        NumberAnimation { target: inner; property: "opacity"; to: 0; duration: 140; easing.type: Easing.InCubic }
        NumberAnimation { target: inner; property: "scale";   to: 0; duration: 140; easing.type: Easing.InCubic }
        }
        ScriptAction { script: { root.visible = false } }
    }
}