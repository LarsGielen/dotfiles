import QtQuick

import "../../widgets"
import "../../themes"
import "../../config"

Item {
  id: root
  implicitWidth: toggle.implicitWidth
  implicitHeight: toggle.implicitHeight

  property bool wifi: true
  property bool bluetooth: false
  property bool dnd: false
  property real volume: 0.75
  property real mic: 0.4

  IconButton {
    id: toggle
    itemHeight: Appearance.barItemHeight
    itemRadius: Appearance.barItemRadius
    hPadding: Appearance.barPadding
    icon: 0xf015
    active: panel.visible
    onClicked: panel.toggle()
  }

  Dropdown {
    id: panel
    anchorItem: toggle

    Text {
      width: parent.width
      text: "Control Center"
      color: Theme.subtext
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
      font.bold: true
    }

    NotificationList {
      width: parent.width
    }
  }
}
