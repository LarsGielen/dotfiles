pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Widgets
import qs.Services

// The control-center panel: a media-style volume slider on top, a grid of
// quick-settings tiles, and a single detail drawer that slides open beneath
// the grid to show the active tile's list (output devices / bluetooth).
ColumnLayout {
    id: root
    spacing: Theme.spacing

    // "" | "audio" | "bluetooth" | "vpn" — which tile's drawer is open (one at a time).
    property string openSection: ""
    function _toggle(s: string): void { root.openSection = root.openSection === s ? "" : s }

    // --- volume ---
    StyledRect {
        Layout.fillWidth: true
        radius: Theme.spacing * 1.6
        implicitHeight: 50
        color: Theme.surface

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing
            anchors.rightMargin: Theme.paddingH
            spacing: Theme.spacing

            IconButton {
                // Square so the differing glyph widths don't resize it on mute.
                implicitWidth: implicitHeight
                label: Audio.muted ? "\uf026" : "\uf028"   // volume-off : volume-up
                tint: Audio.muted ? Theme.error : Theme.text
                normalColor: Theme.transparent
                hoverColor: Theme.surfaceAlt
                onClicked: Audio.toggleMute()
            }

            Slider {
                Layout.fillWidth: true
                value: Audio.volume
                opacity: Audio.muted ? 0.5 : 1
                onMoved: v => Audio.setVolume(v)
            }

            Text {
                Layout.preferredWidth: 34
                horizontalAlignment: Text.AlignRight
                text: Math.round(Audio.volume * 100) + "%"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                color: Theme.subtext
            }
        }
    }

    // --- tiles ---
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: Theme.spacing
        rowSpacing: Theme.spacing

        Tile {
            Layout.fillWidth: true
            icon: "\uf028"                                    // volume-up
            title: "Output"
            subtitle: Audio.sink?.description ?? Audio.sink?.nickname ?? "No output"
            expandable: true
            expanded: root.openSection === "audio"
            onPrimary: root._toggle("audio")
            onExpand: root._toggle("audio")
        }

        Tile {
            Layout.fillWidth: true
            icon: "\uf293"                                    // bluetooth
            title: "Bluetooth"
            subtitle: !Bluetooth.available ? "Unavailable"
                    : !Bluetooth.enabled  ? "Off"
                    : (Bluetooth.devices.filter(d => d.connected)[0]?.name ?? "On")
            active: Bluetooth.enabled
            expandable: Bluetooth.available && Bluetooth.enabled
            expanded: root.openSection === "bluetooth"
            onPrimary: Bluetooth.toggle()
            onExpand: root._toggle("bluetooth")
        }

        Tile {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            icon: ""                                    // shield
            title: "VPN"
            subtitle: !Vpn.profiles.length ? "No profiles"
                    : Vpn.busy               ? "Connecting…"
                    : Vpn.connected          ? Vpn.activeProfile
                    : "Off"
            active: Vpn.connected
            expandable: Vpn.profiles.length > 0
            expanded: root.openSection === "vpn"
            onPrimary: Vpn.toggle()
            onExpand: root._toggle("vpn")
        }
    }

    // --- detail drawer (shared, one open at a time) ---
    // Height snaps to its content; the Dropdown window animates around it, so
    // the reveal is one smooth resize rather than two competing animations.
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.openSection === "" ? 0 : drawer.implicitHeight
        opacity: root.openSection === "" ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        ColumnLayout {
            id: drawer
            width: parent.width
            spacing: 2

            Repeater {
                model: root.openSection === "audio"     ? Audio.sinks
                     : root.openSection === "bluetooth" ? Bluetooth.devices
                     : root.openSection === "vpn"       ? Vpn.profiles
                     : []

                delegate: MenuItem {
                    required property var modelData
                    Layout.fillWidth: true
                    label: root.openSection === "audio"
                        ? (modelData.description || modelData.nickname || modelData.name)
                        : root.openSection === "bluetooth"
                        ? (modelData.name || modelData.deviceName || modelData.address)
                        : modelData
                    selected: root.openSection === "audio"
                        ? (modelData === Audio.sink)
                        : root.openSection === "bluetooth"
                        ? modelData.connected
                        : modelData === Vpn.activeProfile
                    onClicked: {
                        if (root.openSection === "audio") Audio.setSink(modelData)
                        else if (root.openSection === "bluetooth") Bluetooth.toggleDevice(modelData)
                        else if (modelData === Vpn.activeProfile) Vpn.disconnect()
                        else Vpn.connect(modelData)
                    }
                }
            }
        }
    }
}
