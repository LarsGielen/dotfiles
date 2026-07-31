import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.Theme
import qs.Widgets

// Bar entry point for the system tray: a chevron that toggles a dropdown
// listing every StatusNotifier item (TrayPanel next to this file). Same shape
// as Control.qml / NotificationBell.qml.
//
// The bar hides this button when nothing is registered — it reads hasItems
// rather than this item's own `visible`, which would feed back through the
// parent's visibility.
IconButton {
    id: trayButton

    readonly property bool hasItems: SystemTray.items.values.length > 0

    label: ""                        // chevron-down
    onClicked: dropdown.toggle()

    Dropdown {
        id: dropdown
        anchorItem: trayButton
        contentWidth: 260
        radius: Theme.spacing * 2.2

        TrayPanel {
            Layout.fillWidth: true
            onCloseRequested: dropdown.close()
        }
    }
}
