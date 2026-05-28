import QtQuick

import "../Theme"

// Pill ─ the rounded "surface" container every bar widget is built on.
//
//   Pill { Text { text: "hi" } }                       // static label pill
//   Pill { interactive: true; onClicked: ...           // clickable
//          Text { text: "click" } }
//
// Children are centred automatically and the pill grows to fit them
// (plus `hPadding` on each side). Set `interactive` for hover feedback
// and the clicked / rightClicked / scrolled signals.
Rectangle {
  id: root

  property bool interactive: false
  property bool active: false
  readonly property bool hovered: mouse.containsMouse
  property real hPadding: Theme.padding

  property color baseColor:   Theme.surface0
  property color hoverColor:  Theme.surface1
  property color activeColor: Theme.accent

  signal clicked()
  signal rightClicked()
  signal scrolled(int delta)

  default property alias content: container.data

  implicitWidth: container.implicitWidth + hPadding * 2
  implicitHeight: Theme.itemHeight
  radius: Theme.itemRadius
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
