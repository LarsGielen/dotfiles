import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string cpuUsage: "0"
  property real prevTotal: 0
  property real prevIdle: 0

  Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]

    stdout: SplitParser {
      onRead: data => {
        const cpuTimes = data.trim().split(/\s+/).slice(1).map(Number)
        const total = cpuTimes.reduce((a, b) => a + b, 0)
        const idle = cpuTimes[3]

        const dTotal = total - root.prevTotal
        const dIdle = idle - root.prevIdle
        if (dTotal > 0)
          root.cpuUsage = ((dTotal - dIdle) / dTotal * 100).toFixed(2)

        root.prevTotal = total
        root.prevIdle = idle
      }
    }
  } 

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: cpuProc.running = true
  }
}