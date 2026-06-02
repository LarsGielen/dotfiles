import QtQuick

import "../themes"
import "../config"

// Inline expanding selector. `model` is an array of { text, value } pairs;
// `value` is matched against `current` by identity.
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

    Rectangle {
      width: parent.width
      height: Appearance.itemHeight + 8
      radius: Appearance.itemRadius
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
        font.family: Appearance.font
        font.pixelSize: Appearance.iconSize
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
        font.family: Appearance.font
        font.pixelSize: Appearance.fontSize
      }

      Text {
        id: chevron
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: Theme.icon(root.expanded ? 0xf077 : 0xf078)  // chevron up / down
        color: Theme.subtext
        font.family: Appearance.font
        font.pixelSize: Appearance.fontSize - 2
      }

      MouseArea {
        id: headerMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
      }
    }

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
          height: Appearance.itemHeight
          radius: Appearance.itemRadius
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
            font.family: Appearance.font
            font.pixelSize: Appearance.fontSize
          }

          Text {
            id: tick
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: opt.isCurrent
            text: Theme.icon(0xf00c)  // check
            color: Theme.accent
            font.family: Appearance.font
            font.pixelSize: Appearance.fontSize - 2
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
