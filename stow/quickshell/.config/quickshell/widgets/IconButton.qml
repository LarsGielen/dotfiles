import QtQuick

import "../themes"
import "../config"

// A Pill carrying a Nerd-Font icon and/or label; `active` gives a toggled look.
Pill {
  id: root
  interactive: true

  property int icon: 0
  property string label: ""
  property color iconColor: Theme.subtext
  property color labelColor: Theme.text
  property bool labelOnHover: false

  readonly property bool labelVisible: root.label !== "" && (!root.labelOnHover || root.hovered)

  Row {
    spacing: (root.icon !== 0 && root.labelVisible) ? 6 : 0

    Text {
      anchors.verticalCenter: parent.verticalCenter
      visible: root.icon !== 0
      text: root.icon !== 0 ? Theme.icon(root.icon) : ""
      color: root.active ? Theme.base : root.iconColor
      font.family: Appearance.font
      font.pixelSize: Appearance.iconSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: root.labelVisible ? implicitWidth : 0
      clip: true
      opacity: root.labelVisible ? 1 : 0
      text: root.label
      color: root.active ? Theme.base : root.labelColor
      font.family: Appearance.font
      font.pixelSize: Appearance.fontSize
      Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }
  }
}
