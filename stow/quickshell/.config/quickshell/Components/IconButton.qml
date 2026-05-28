import QtQuick

import "../Theme"

// IconButton ─ a Pill carrying a Nerd-Font icon and/or a text label.
//
//   IconButton { icon: 0xf1eb; label: "Wi-Fi"; onClicked: ... }
//   IconButton { icon: 0xf013; hPadding: 8 }            // icon-only, tight
//   IconButton { icon: 0xf186; label: "DND"; active: dnd }   // toggled look
//
// `active` swaps to the accent background with dark fg, so the same button
// doubles as a toggle. Inherits clicked / rightClicked / scrolled from Pill.
Pill {
  id: root
  interactive: true

  property int icon: 0
  property string label: ""
  property color iconColor: Theme.subtext
  property color labelColor: Theme.text

  Row {
    spacing: (root.icon !== 0 && root.label !== "") ? 6 : 0

    Text {
      anchors.verticalCenter: parent.verticalCenter
      visible: root.icon !== 0
      text: root.icon !== 0 ? Theme.icon(root.icon) : ""
      color: root.active ? Theme.base : root.iconColor
      font.family: Theme.font
      font.pixelSize: Theme.iconSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      visible: root.label !== ""
      text: root.label
      color: root.active ? Theme.base : root.labelColor
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
    }
  }
}
