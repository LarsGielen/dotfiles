import QtQuick
import Quickshell.Hyprland

import "../Theme"

Rectangle {
  id: root
  property string screenName: ""

  implicitWidth: row.implicitWidth + Theme.padding * 2
  implicitHeight: Theme.itemHeight
  radius: Theme.itemRadius
  color: Theme.surface0

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: Hyprland.workspaces.values
        .filter(w => w.monitor && (root.screenName === "" || w.monitor.name === root.screenName))
        .sort((a, b) => a.id - b.id)

      delegate: Item {
        id: ws
        required property var modelData
        readonly property bool active: 
          modelData.monitor 
          && modelData.monitor.activeWorkspace 
          && modelData.monitor.activeWorkspace.id === modelData.id

        implicitWidth: (active ? 22 : 10) + 8
        implicitHeight: Theme.itemHeight
        Behavior on implicitWidth { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Rectangle {
          anchors.centerIn: parent
          width: ws.active ? 22 : 10
          height: 10
          radius: 5
          color: ws.active ? Theme.accent
            : ws.modelData.urgent ? Theme.red
            : hover.containsMouse ? Theme.overlay1
            : Theme.surface2
          Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
          Behavior on color { ColorAnimation { duration: 140 } }
        }

        MouseArea {
          id: hover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: Hyprland.dispatch("hl.dsp.focus({workspace=" + ws.modelData.id + "})")
        }
      }
    }
  }

  function cycle(dir) {
    const list = Hyprland.workspaces.values
      .filter(w => w.monitor && (root.screenName === "" || w.monitor.name === root.screenName))
      .sort((a, b) => a.id - b.id);
    if (list.length === 0) return;
    const mon = list[0].monitor;
    const activeId = mon && mon.activeWorkspace ? mon.activeWorkspace.id : list[0].id;
    let idx = list.findIndex(w => w.id === activeId);
    if (idx < 0) idx = 0;
    const next = list[(idx + dir + list.length) % list.length];
    Hyprland.dispatch("hl.dsp.focus({workspace=" + next.id + "})");
  }

  WheelHandler {
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: (event) => root.cycle(event.angleDelta.y < 0 ? -1 : 1)
  }
}
