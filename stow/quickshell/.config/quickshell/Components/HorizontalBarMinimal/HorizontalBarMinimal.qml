pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme

Scope {
    id: root
 
    property bool revealed: true

    IpcHandler {
        target: "bar"
        function show(): void { root.revealed = true }
        function hide(): void { root.revealed = false }
        function toggle(): void { root.revealed = !root.revealed }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            id: panel
            screen: panel.modelData

            anchors { top: true; left: true; right: true }
            margins.top: Theme.screenMarginTop
            property int _contentHeight: Math.max(clock.implicitHeight, control.implicitHeight || 0, notificationBell.implicitHeight || 0, workspaces.implicitHeight || 0)
            implicitHeight: _contentHeight + Theme.paddingV * 2
            color: "transparent"

            property bool reserveOn: true
            property bool barIn: true

            readonly property int reservedHeight: implicitHeight
            readonly property int hiddenY: -(panel.height + Theme.ScreenMarginTop)

            exclusiveZone: panel.reserveOn ? reservedHeight : 0

            Connections {
                target: root
                function onRevealedChanged() {
                    if (root.revealed) {
                        panel.reserveOn = true;
                        barInTimer.restart();
                    } else {
                        panel.barIn = false;
                        reserveOffTimer.restart();
                    }
                }
            }
            Timer { id: barInTimer; interval: 130; onTriggered: panel.barIn = true }
            Timer { id: reserveOffTimer; interval: Math.round(Theme.animNormal * 0.5); onTriggered: panel.reserveOn = false }

            mask: panel.barIn ? clickRegion : emptyRegion
            Region { id: clickRegion; item: reveal }
            Region { id: emptyRegion }

            Item {
                id: reveal
                anchors.fill: parent
                enabled: panel.barIn

                opacity: panel.barIn ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

                transform: Translate {
                    y: panel.barIn ? 0 : panel.hiddenY
                    Behavior on y {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: root.revealed ? Easing.OutBack : Easing.InBack
                            easing.overshoot: 1.3
                        }
                    }
                }

                Workspaces {
                    id: workspaces
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.screenMarginSide
                    anchors.verticalCenter: parent.verticalCenter

                    screen: panel.screen
                    display: Workspaces.Display.AllScreens
                    perMonitor: true
                }

                Clock {
                    id: clock
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.screenMarginSide + control.width + Theme.spacing + notificationBell.width + Theme.spacing
                    anchors.verticalCenter: parent.verticalCenter
                }

                NotificationBell {
                    id: notificationBell
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.screenMarginSide + control.width + Theme.spacing
                    anchors.verticalCenter: parent.verticalCenter
                }

                Control {
                    id: control
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.screenMarginSide
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}