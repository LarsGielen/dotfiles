import QtQuick

import "../Theme"

// Select ─ an inline expanding dropdown selector.
//
//   Select {
//     width: parent.width
//     icon: 0xf028
//     model: [{ text: "Speakers", value: nodeA },
//             { text: "HDMI",     value: nodeB }]
//     current: someValue
//     onSelected: (value) => doThing(value)
//   }
//
// Shows the current selection as a header row; clicking it expands the
// option list beneath. Picking an option collapses the list and emits
// `selected`. `model` is an array of { text, value } pairs; `value` may
// be any type and is matched against `current` by identity.
Item {
  id: root

  property int icon: 0
  property var model: []
  property var current: undefined
  property string placeholder: "—"

  property bool expanded: false

  signal selected(var value)

  readonly property string currentText: {
    for (let i = 0; i < model.length; i++)
      if (model[i].value === current) return model[i].text
    return placeholder
  }

  implicitWidth: 200
  implicitHeight: col.implicitHeight

  Column {
    id: col
    width: parent.width
    spacing: 4

    // Header ─ shows the current selection, toggles the option list.
    Rectangle {
      width: parent.width
      height: Theme.itemHeight + 8
      radius: Theme.itemRadius
      color: headerMouse.containsMouse ? Theme.surface1 : Theme.surface0
      Behavior on color { ColorAnimation { duration: 120 } }

      Text {
        id: headerIcon
        visible: root.icon !== 0
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon !== 0 ? Theme.icon(root.icon) : ""
        color: Theme.subtext
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
      }

      Text {
        anchors.left: headerIcon.visible ? headerIcon.right : parent.left
        anchors.leftMargin: headerIcon.visible ? 8 : 10
        anchors.right: chevron.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.currentText
        elide: Text.ElideRight
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
      }

      Text {
        id: chevron
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: Theme.icon(root.expanded ? 0xf077 : 0xf078)  // chevron up / down
        color: Theme.subtext
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
      }

      MouseArea {
        id: headerMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
      }
    }

    // Option list ─ excluded from layout (and height) while collapsed.
    Column {
      width: parent.width
      spacing: 2
      visible: root.expanded

      Repeater {
        model: root.model

        delegate: Rectangle {
          id: opt
          required property var modelData

          readonly property bool isCurrent: modelData.value === root.current

          width: parent.width
          height: Theme.itemHeight
          radius: Theme.itemRadius
          color: optMouse.containsMouse ? Theme.surface1 : Theme.transparent
          Behavior on color { ColorAnimation { duration: 120 } }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: root.icon !== 0 ? 36 : 10
            anchors.right: tick.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: opt.modelData.text
            elide: Text.ElideRight
            color: opt.isCurrent ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
          }

          Text {
            id: tick
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: opt.isCurrent
            text: Theme.icon(0xf00c)  // check
            color: Theme.accent
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
          }

          MouseArea {
            id: optMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.selected(opt.modelData.value)
              root.expanded = false
            }
          }
        }
      }
    }
  }
}
