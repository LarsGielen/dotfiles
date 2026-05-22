import QtQuick
import Quickshell.Services.Pipewire

// Default sink volume. Click to mute, scroll to change.
Rectangle {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
  readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

  // Keep the sink's audio properties bound/live.
  PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

  implicitWidth: row.implicitWidth + Theme.padding * 2
  implicitHeight: Theme.itemHeight
  radius: Theme.itemRadius
  color: hover.containsMouse ? Theme.surface1 : Theme.surface0
  Behavior on color { ColorAnimation { duration: 120 } }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      // nf-fa volume off / down / up
      text: root.muted || root.volume === 0 ? Theme.icon(0xf026)
        : root.volume < 0.5 ? Theme.icon(0xf027) : Theme.icon(0xf028)
      color: root.muted ? Theme.overlay1 : Theme.accent
      font.family: Theme.font
      font.pixelSize: Theme.iconSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.muted ? "muted" : Math.round(root.volume * 100) + "%"
      color: Theme.text
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
    }
  }

  MouseArea {
    id: hover
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: if (root.sink && root.sink.audio) root.sink.audio.muted = !root.muted
    onWheel: (event) => {
      if (!root.sink || !root.sink.audio) return
      const step = 0.05
      const delta = event.angleDelta.y > 0 ? step : -step
      root.sink.audio.volume = Math.max(0, Math.min(1, root.volume + delta))
    }
  }
}
