import QtQuick
import Quickshell.Services.Pipewire

import "../Components"
import "../Theme"

Item {
  id: root
  implicitWidth: toggle.implicitWidth
  implicitHeight: toggle.implicitHeight

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource
  readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
  readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

  readonly property real step: 0.05  // scroll / snap increment

  PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] }

  function nodeName(n) {
    if (!n) return ""
    return n.description || n.nickname || n.name || "Unknown"
  }

  readonly property var sinkModel: Pipewire.nodes.values
    .filter(n => n.audio && n.isSink && !n.isStream)
    .map(n => ({ text: nodeName(n), value: n }))

  readonly property var sourceModel: Pipewire.nodes.values
    .filter(n => n.audio && !n.isSink && !n.isStream)
    .map(n => ({ text: nodeName(n), value: n }))

  readonly property int volIcon: {
    if (muted || volume <= 0) return 0xf026  // volume-off
    if (volume < 0.5)         return 0xf027  // volume-down
    return 0xf028                            // volume-up
  }

  function setVolume(v) { if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, v)) }

  IconButton {
    id: toggle
    icon: root.volIcon
    iconColor: root.muted ? Theme.red : Theme.subtext
    label: root.muted ? "Muted" : Math.round(root.volume * 100) + "%"
    active: panel.visible

    onClicked: panel.toggle()
    onRightClicked: if (root.sink && root.sink.audio) root.sink.audio.muted = !root.muted
    onScrolled: (delta) => root.setVolume((Math.round(root.volume / root.step) + delta) * root.step)
  }

  Dropdown {
    id: panel
    anchorItem: toggle

    Item {
      width: parent.width
      height: outLabel.implicitHeight
      Text {
        id: outLabel
        anchors.left: parent.left
        text: "Output"
        color: Theme.subtext
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 1
        font.bold: true
      }
      Text {
        anchors.right: parent.right
        text: root.muted ? "Muted" : Math.round(root.volume * 100) + "%"
        color: root.muted ? Theme.red : Theme.subtext
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 1
      }
    }

    Slider {
      width: parent.width
      from: 0
      to: 1
      value: root.volume
      leadingIcon: root.volIcon
      onMoved: (v) => root.setVolume(v)
    }

    Select {
      width: parent.width
      icon: 0xf028
      model: root.sinkModel
      current: root.sink
      placeholder: "No output device"
      onSelected: (value) => Pipewire.preferredDefaultAudioSink = value
    }

    Text {
      width: parent.width
      text: "Input"
      color: Theme.subtext
      font.family: Theme.font
      font.pixelSize: Theme.fontSize - 1
      font.bold: true
    }

    Select {
      width: parent.width
      icon: 0xf130 
      model: root.sourceModel
      current: root.source
      placeholder: "No input device"
      onSelected: (value) => Pipewire.preferredDefaultAudioSource = value
    }
  }
}
