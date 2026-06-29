pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Theme
import qs.Config
import qs.Services

// Per-screen, click-through overlay that stacks the active toasts. Set
// `position` to place the stack at any of the six screen anchors; the enter/
// exit slide direction follows from it. Lives outside the bar on purpose.
Scope {
    id: root

    enum Pos { TopRight, TopCenter, TopLeft, BottomRight, BottomCenter, BottomLeft }
    property int position: NotificationPopups.Pos.TopRight

    readonly property bool isBottom: position === NotificationPopups.Pos.BottomRight
                                  || position === NotificationPopups.Pos.BottomCenter
                                  || position === NotificationPopups.Pos.BottomLeft
    readonly property bool isLeft:   position === NotificationPopups.Pos.TopLeft
                                  || position === NotificationPopups.Pos.BottomLeft
    readonly property bool isRight:  position === NotificationPopups.Pos.TopRight
                                  || position === NotificationPopups.Pos.BottomRight
    readonly property bool isCenter: position === NotificationPopups.Pos.TopCenter
                                  || position === NotificationPopups.Pos.BottomCenter
    // Off-screen offset toasts slide in from / out to.
    readonly property real slideX: isLeft ? -30 : isRight ? 30 : 0

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: panel.modelData

            // Full-width strip pinned to the relevant edge; toasts align within.
            anchors.top: !root.isBottom
            anchors.bottom: root.isBottom
            anchors.left: true
            anchors.right: true
            margins.top: Theme.screenMarginTop
            margins.bottom: Theme.screenMarginBottom
            margins.left: Theme.screenMarginSide
            margins.right: Theme.screenMarginSide

            color: "transparent"
            exclusiveZone: 0
            implicitHeight: Math.max(1, list.contentHeight)

            // Only the toasts themselves are clickable; the rest passes through.
            mask: Region { item: list }

            ListView {
                id: list
                width: NotificationConfig.width
                height: parent.height
                spacing: NotificationConfig.gap
                interactive: false
                verticalLayoutDirection: root.isBottom ? ListView.BottomToTop : ListView.TopToBottom

                anchors.top: root.isBottom ? undefined : parent.top
                anchors.bottom: root.isBottom ? parent.bottom : undefined
                anchors.left: root.isLeft ? parent.left : undefined
                anchors.right: root.isRight ? parent.right : undefined
                anchors.horizontalCenter: root.isCenter ? parent.horizontalCenter : undefined

                model: Notifications.popups

                delegate: Notification {
                    required property var modelData
                    width: ListView.view.width
                    notif: modelData
                }

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: NotificationConfig.animIn; easing.type: Easing.OutCubic }
                        NumberAnimation { property: "scale"; from: 0.92; to: 1; duration: NotificationConfig.animIn; easing.type: Easing.OutCubic }
                        NumberAnimation { property: "x"; from: root.slideX; to: 0; duration: NotificationConfig.animIn; easing.type: Easing.OutCubic }
                    }
                }
                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; to: 0; duration: NotificationConfig.animOut; easing.type: Easing.InCubic }
                        NumberAnimation { property: "scale"; to: 0.92; duration: NotificationConfig.animOut; easing.type: Easing.InCubic }
                        NumberAnimation { property: "x"; to: root.slideX; duration: NotificationConfig.animOut; easing.type: Easing.InCubic }
                    }
                }
                displaced: Transition {
                    NumberAnimation { property: "y"; duration: NotificationConfig.animMove; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
