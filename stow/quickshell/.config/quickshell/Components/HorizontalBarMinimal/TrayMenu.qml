pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Theme
import qs.Widgets

// One level of a tray item's DBus menu, drawn inline with the shell's own
// styling instead of a platform popup. Submenus expand in place beneath their
// parent entry — same idiom as the quick-settings detail drawer, one open at a
// time.
//
// QsMenuOpener holds the remote menu open for as long as it exists, so this is
// only ever instantiated while the menu is actually on screen. Nested levels
// load by URL because a QML file can't reference its own type.
ColumnLayout {
    id: root

    // QsMenuHandle: SystemTrayItem.menu at the top level, a QsMenuEntry with
    // children below that.
    property var handle: null

    // Bubbles up from any depth so the dropdown can close after a click.
    signal triggered()

    // The entry whose submenu is expanded, null for none.
    property var openSub: null

    spacing: 2

    QsMenuOpener {
        id: opener
        menu: root.handle
    }

    Repeater {
        model: opener.children

        delegate: ColumnLayout {
            id: entry

            required property var modelData
            readonly property bool expanded: root.openSub === entry.modelData

            Layout.fillWidth: true
            spacing: 2

            Rectangle {
                visible: entry.modelData.isSeparator
                Layout.fillWidth: true
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                implicitHeight: 1
                color: Theme.surfaceAlt
            }

            StyledRect {
                id: row

                visible: !entry.modelData.isSeparator
                enabled: entry.modelData.enabled
                opacity: entry.modelData.enabled ? 1 : 0.45
                Layout.fillWidth: true
                radius: Theme.spacing
                implicitHeight: label.implicitHeight + Theme.paddingV * 2
                color: area.containsPress ? Theme.overlay
                     : area.containsMouse ? Theme.surfaceAlt
                     : Theme.transparent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.paddingH
                    anchors.rightMargin: Theme.paddingH
                    spacing: Theme.spacing

                    // Check mark / radio dot, only for entries that carry one.
                    Text {
                        visible: entry.modelData.buttonType !== QsMenuButtonType.None
                        text: entry.modelData.checkState === Qt.Unchecked ? ""
                            : entry.modelData.buttonType === QsMenuButtonType.RadioButton ? ""   // circle
                            : ""                                                                 // check
                        color: Theme.accent
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeSmall
                    }

                    IconImage {
                        // Menus routinely name symbolic icons the theme lacks;
                        // drop the slot entirely rather than indent past a gap.
                        visible: source !== "" && status !== Image.Error
                        source: entry.modelData.icon
                        implicitSize: Theme.font.size
                        asynchronous: true
                    }

                    Text {
                        id: label
                        Layout.fillWidth: true
                        text: entry.modelData.text
                        elide: Text.ElideRight
                        color: Theme.text
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.size
                    }

                    Text {
                        visible: entry.modelData.hasChildren
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
                    onClicked: {
                        if (entry.modelData.hasChildren) {
                            root.openSub = entry.expanded ? null : entry.modelData;
                        } else {
                            // Emitted *to* the entry: this is what activates it.
                            entry.modelData.triggered();
                            root.triggered();
                        }
                    }
                }
            }

            Loader {
                id: submenu

                // See TrayPanel: the Loader's own implicit height survives the
                // item it loaded, so the collapse wouldn't shrink anything.
                Layout.preferredHeight: submenu.item ? submenu.item.implicitHeight : 0
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing * 1.5
                active: entry.expanded
                source: "TrayMenu.qml"
                onLoaded: {
                    item.handle = entry.modelData;
                    item.triggered.connect(root.triggered);
                }
            }
        }
    }
}
