pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  // "none" | "wifi" | "ethernet"
  property string type: "none"
  property string ssid: ""

  readonly property int icon: {
    if (type === "wifi")     return 0xf1eb  // fa-wifi
    if (type === "ethernet") return 0xf796  // fa-ethernet
    return 0xf127                           // fa-chain-broken
  }

  Process {
    id: probe
    command: ["sh", "-c",
      "for d in /sys/class/net/*/; do " +
      "n=$(basename \"$d\"); [ \"$n\" = lo ] && continue; " +
      "[ \"$(cat \"$d/operstate\" 2>/dev/null)\" = up ] || continue; " +
      "if [ -d \"${d}wireless\" ]; then " +
      "  ssid=$(iw dev \"$n\" link 2>/dev/null | awk '/SSID:/{sub(/.*SSID: /,\"\"); print}'); " +
      "  echo \"wifi $ssid\"; exit 0; " +
      "fi; " +
      "echo ethernet; exit 0; " +
      "done; echo none"]
    stdout: SplitParser {
      onRead: data => {
        const parts = data.trim().split(" ")
        root.type = parts[0]
        root.ssid = parts.length > 1 ? parts.slice(1).join(" ") : ""
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
}
