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
            Timer { id: reserveOffTimer; interval: Theme.animNormal; onTriggered: panel.reserveOn = false }

            mask: panel.barIn ? clickRegion : emptyRegion
            Region { id: clickRegion; item: reveal }
            Region { id: emptyRegion }

            component BarItem: Item {
                id: cell
                property real drive: 1
                anchors.verticalCenter: parent.verticalCenter
                enabled: panel.barIn
                opacity: Math.min(1, drive * 2)
                transform: Scale {
                    origin.x: cell.width / 2
                    origin.y: cell.height / 2
                    xScale: cell.drive
                    yScale: cell.drive
                }

                NumberAnimation {
                    id: popAnim
                    target: cell
                    property: "drive"
                    easing.overshoot: 2
                }
                Connections {
                    target: panel
                    function onBarInChanged() {
                        popAnim.stop();
                        if (panel.barIn) {
                            popAnim.from = 0;
                            popAnim.to = 1;
                            popAnim.duration = Theme.animNormal * 1.5;
                            popAnim.easing.type = Easing.OutBack;
                        } else {
                            popAnim.from = cell.drive;
                            popAnim.to = 0;
                            popAnim.duration = Theme.animNormal * 1.5;
                            popAnim.easing.type = Easing.InBack;
                        }
                        popAnim.restart();
                    }
                }
            }

            Item {
                id: reveal
                anchors.fill: parent

                BarItem {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.screenMarginSide
                    implicitWidth: workspaces.implicitWidth
                    implicitHeight: workspaces.implicitHeight

                    Workspaces {
                        id: workspaces
                        anchors.fill: parent
                        screen: panel.screen
                        display: Workspaces.Display.AllScreens
                        perMonitor: true
                    }
                }

                BarItem {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.screenMarginSide + control.width + Theme.spacing + notificationBell.width + Theme.spacing
                    implicitWidth: clock.implicitWidth
                    implicitHeight: clock.implicitHeight
                    Clock { id: clock; anchors.fill: parent }
                }

                BarItem {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.screenMarginSide + control.width + Theme.spacing
                    implicitWidth: notificationBell.implicitWidth
                    implicitHeight: notificationBell.implicitHeight
                    NotificationBell { id: notificationBell; anchors.fill: parent }
                }

                BarItem {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.screenMarginSide
                    implicitWidth: control.implicitWidth
                    implicitHeight: control.implicitHeight
                    Control { id: control; anchors.fill: parent }
                }
            }
        }
    }
}