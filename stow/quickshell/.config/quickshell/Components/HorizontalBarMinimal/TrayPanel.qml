pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.Theme
import qs.Widgets

// The system-tray panel hosted by Tray's dropdown: one row per StatusNotifier
// item. Left click activates the item (raises/opens the app), right click
// expands its own DBus menu inline below the row — that menu is where Quit
// lives — and middle click sends the item's secondary action.
//
// Only one menu is expanded at a time, like the quick-settings drawer, so at
// most one remote menu is held open at once.
ColumnLayout {
    id: root
    spacing: Theme.spacing

    // The item whose menu drawer is open, null for none.
    property var openItem: null

    // Raised after an action that should dismiss the whole dropdown.
    signal closeRequested()

    readonly property var items: SystemTray.items.values

    // Don't reopen on a stale menu the next time the dropdown is shown.
    onVisibleChanged: if (!visible) root.openItem = null

    function _toggleMenu(item): void {
        root.openItem = root.openItem === item ? null : item;
    }

    // Left click opens the program; items flagged onlyMenu have no activate
    // action at all, so fall back to their menu rather than doing nothing.
    function _primary(item): void {
        if (item.onlyMenu) {
            if (item.hasMenu) root._toggleMenu(item);
            return;
        }
        item.activate();
        root.closeRequested();
    }

    Text {
        Layout.fillWidth: true
        text: "Tray"
        color: Theme.text
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeLarge
        font.bold: true
    }

    Text {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing
        Layout.bottomMargin: Theme.spacing
        visible: root.items.length === 0
        text: "Nothing in the tray"
        horizontalAlignment: Text.AlignHCenter
        color: Theme.subtext
        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
    }

    Repeater {
        model: SystemTray.items

        delegate: ColumnLayout {
            id: entry

            required property var modelData
            readonly property bool expanded: root.openItem === entry.modelData
            readonly property string name: entry.modelData.tooltipTitle
                                        || entry.modelData.title
                                        || entry.modelData.id
            // Items can name an icon your theme doesn't ship; fall back rather
            // than leaving a blank gap where it should have been.
            readonly property bool iconOk: icon.source !== "" && icon.status !== Image.Error

            Layout.fillWidth: true
            spacing: 2

            StyledRect {
                id: row

                Layout.fillWidth: true
                radius: Theme.spacing
                implicitHeight: Math.max(icon.implicitHeight, label.implicitHeight) + Theme.paddingV * 2
                color: area.containsPress ? Theme.overlay
                     : area.containsMouse ? Theme.surfaceAlt
                     : Theme.transparent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.paddingH
                    anchors.rightMargin: Theme.paddingH
                    spacing: Theme.spacing

                    IconImage {
                        id: icon
                        visible: entry.iconOk
                        source: entry.modelData.icon
                        implicitSize: Theme.font.sizeLarge
                        asynchronous: true
                    }

                    // Not every item ships an icon; keep the row aligned.
                    Text {
                        visible: !entry.iconOk
                        text: ""                     // cog
                        color: Theme.subtext
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeLarge
                    }

                    Text {
                        id: label
                        Layout.fillWidth: true
                        text: entry.name
                        elide: Text.ElideRight
                        color: entry.modelData.status === Status.NeedsAttention
                             ? Theme.accent : Theme.text
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.size
                    }

                    Text {
                        visible: entry.modelData.hasMenu
                        text: entry.expanded ? "" : ""   // chevron-down : chevron-right
                        color: Theme.subtext
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeSmall
                    }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            if (entry.modelData.hasMenu) root._toggleMenu(entry.modelData);
                        } else if (mouse.button === Qt.MiddleButton) {
                            entry.modelData.secondaryActivate();
                            root.closeRequested();
                        } else {
                            root._primary(entry.modelData);
                        }
                    }

                    // Volume/brightness applets expect wheel events on their icon.
                    onWheel: wheel => {
                        if (wheel.angleDelta.y !== 0)
                            entry.modelData.scroll(wheel.angleDelta.y, false);
                        if (wheel.angleDelta.x !== 0)
                            entry.modelData.scroll(wheel.angleDelta.x, true);
                    }
                }
            }

            // Menu drawer. Loaded only while open, so the item's menu isn't
            // held open on the far end for the lifetime of the bar.
            Loader {
                id: menuLoader

                // A Loader hangs onto the implicit height of the item it just
                // destroyed, which would leave the dropdown stuck at its
                // expanded size — drive the layout off the live item instead.
                Layout.preferredHeight: menuLoader.item ? menuLoader.item.implicitHeight : 0
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing * 1.5
                Layout.bottomMargin: entry.expanded ? Theme.spacing : 0
                active: entry.expanded
                source: "TrayMenu.qml"
                onLoaded: {
                    item.handle = entry.modelData.menu;
                    item.triggered.connect(() => {
                        root.openItem = null;
                        root.closeRequested();
                    });
                }
            }
        }
    }
}
