import QtQuick
import Quickshell.Io

import "../Theme"

Rectangle {
  id: root

  property string iface: ""
  property string state: ""
  readonly property bool wifi: iface.startsWith("wl")
  readonly property bool connected: state === "up"

  implicitWidth: row.implicitWidth + Theme.padding * 2
  implicitHeight: Theme.itemHeight
  radius: Theme.itemRadius
  color: Theme.surface0

  Process {
    id: probe
    command: ["sh", "-c",
      "i=$(ip route get 1.1.1.1 2>/dev/null | sed -n 's/.* dev \\([^ ]*\\).*/\\1/p' | head -1); " +
      "if [ -z \"$i\" ]; then echo 'none down'; else echo \"$i $(cat /sys/class/net/$i/operstate 2>/dev/null)\"; fi"]
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = text.trim().split(/\s+/)
        root.iface = parts[0] || ""
        root.state = parts[1] || ""
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: probe.running = true
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      // nf-fa unlink / wifi  ·  nf-md ethernet (v3 codepoint)
      text: !root.connected ? Theme.icon(0xf127)
        : root.wifi ? Theme.icon(0xf1eb) : Theme.icon(0xf0200)
      color: root.connected ? Theme.accent : Theme.red
      font.family: Theme.font
      font.pixelSize: Theme.iconSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: !root.connected ? "off" : root.wifi ? "Wi-Fi" : "Wired"
      color: Theme.text
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
    }
  }
}
