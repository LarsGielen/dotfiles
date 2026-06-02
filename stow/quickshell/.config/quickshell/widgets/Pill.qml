import QtQuick

import "../themes"
import "../config"

// Rounded surface container that grows to fit its centred children.
Rectangle {
  id: root

  property bool interactive: false
  property bool active: false
  readonly property bool hovered: mouse.containsMouse

  property int  itemHeight: Appearance.itemHeight
  property int  itemRadius: Appearance.itemRadius
  property real hPadding:   Appearance.padding

  property color baseColor:   Theme.surface0
  property color hoverColor:  Theme.surface1
  property color activeColor: Theme.accent

  signal clicked()
  signal rightClicked()
  signal scrolled(int delta)

  default property alias content: container.data

  implicitWidth: container.implicitWidth + hPadding * 2
  implicitHeight: itemHeight
  radius: itemRadius
  color: active ? activeColor : (interactive && hovered ? hoverColor : baseColor)
  Behavior on color { ColorAnimation { duration: 120 } }

  Item {
    id: container
    anchors.centerIn: parent
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    enabled: root.interactive
    hoverEnabled: root.interactive
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: (e) => e.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    onWheel: (e) => root.scrolled(e.angleDelta.y > 0 ? 1 : -1)
  }
}
