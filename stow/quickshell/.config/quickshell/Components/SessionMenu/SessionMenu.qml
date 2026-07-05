pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Config
import qs.Services
import qs.Widgets

// Logout / power menu. A row of large action tiles hosted in the shared modal
// Overlay. Triggered via `qs ipc call session toggle`.
Overlay {
    id: overlay
    ipcTarget: "session"

    onOpened: { menu.selected = 0; menu.forceActiveFocus() }

    readonly property var actions: [
        { icon: "", label: "Lock",     act: () => Session.lock() },
        { icon: "", label: "Logout",   act: () => Session.logout() },
        { icon: "", label: "Suspend",  act: () => Session.suspend() },
        { icon: "", label: "Reboot",   act: () => Session.reboot() },
        { icon: "", label: "Shutdown", act: () => Session.shutdown() }
    ]

    function trigger(i) {
        overlay.actions[i].act()
        overlay.close()
    }

    StyledRect {
        id: menu
        color: Theme.surface
        radius: OverlayConfig.radius
        border.width: 1
        border.color: Theme.surfaceAlt

        implicitWidth: row.implicitWidth + Theme.paddingH * 2
        implicitHeight: row.implicitHeight + Theme.paddingH * 2

        property int selected: 0

        Keys.onLeftPressed:  selected = Math.max(0, selected - 1)
        Keys.onRightPressed: selected = Math.min(overlay.actions.length - 1, selected + 1)
        Keys.onReturnPressed: overlay.trigger(selected)
        Keys.onEnterPressed:  overlay.trigger(selected)

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Theme.spacing

            Repeater {
                model: overlay.actions

                StyledRect {
                    id: tile
                    required property int index
                    required property var modelData

                    readonly property bool active: menu.selected === index || area.containsMouse

                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 96
                    radius: Theme.spacing
                    color: area.containsPress ? Theme.overlay
                         : tile.active ? Theme.surfaceAlt
                         : Theme.transparent
                    border.width: menu.selected === index ? 1 : 0
                    border.color: Theme.accent

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacing

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: tile.modelData.icon
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.sizeLarge * 1.6
                            color: tile.active ? Theme.accent : Theme.text
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: tile.modelData.label
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.sizeSmall
                            color: Theme.subtext
                        }
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: menu.selected = tile.index
                        onClicked: overlay.trigger(tile.index)
                    }
                }
            }
        }
    }
}
