import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Widgets

// Bar entry point for the control center: the button toggles a dropdown that
// hosts the QuickSettings panel (slider + tile grid + detail drawer next to
// this file). Reusable bits live in qs.Widgets; device state in qs.Services.
IconButton {
    id: menuButton
    label: "\uf1de"                         // sliders-h
    onClicked: dropdown.toggle()

    Dropdown {
        id: dropdown
        anchorItem: menuButton
        contentWidth: 340
        radius: Theme.spacing * 2.2

        QuickSettings { Layout.fillWidth: true }
    }
}
