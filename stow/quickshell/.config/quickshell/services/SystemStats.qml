pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Polls /proc, hwmon and nvidia-smi; a Singleton so the probes run once for
// the whole shell however many monitors mount ResourceMonitor.
Singleton {
  id: root

  // CPU
  property real cpuUsage: 0    // %
  property real cpuTemp:  0    // °C  (AMD k10temp / Tctl)
  // GPU (NVIDIA)
  property real gpuUsage:  0   // %
  property real gpuTemp:   0   // °C
  property real vramUsed:  0   // GiB
  property real vramTotal: 0   // GiB
  // Memory
  property real ramUsed:  0    // GiB
  property real ramTotal: 0    // GiB

  readonly property string cpuUsageText: Math.round(cpuUsage) + "%"
  readonly property string gpuUsageText: Math.round(gpuUsage) + "%"
  readonly property string cpuTempText:  Math.round(cpuTemp) + "°"
  readonly property string gpuTempText:  Math.round(gpuTemp) + "°"
  readonly property string ramText:      ramUsed.toFixed(1) + "G"
  readonly property string vramText:     vramUsed.toFixed(1) + "G"

  // CPU usage from the delta between /proc/stat samples.
  property real _prevTotal: 0
  property real _prevIdle:  0

  Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]
    stdout: SplitParser {
      onRead: data => {
        const t = data.trim().split(/\s+/).slice(1).map(Number)
        const total = t.reduce((a, b) => a + b, 0)
        const idle = t[3]
        const dTotal = total - root._prevTotal
        const dIdle = idle - root._prevIdle
        if (dTotal > 0)
          root.cpuUsage = (dTotal - dIdle) / dTotal * 100
        root._prevTotal = total
        root._prevIdle = idle
      }
    }
  }

  // RAM + CPU temperature in one probe.
  Process {
    id: hostProc
    command: ["sh", "-c",
      "m=$(awk '/^MemTotal/{t=$2}/^MemAvailable/{a=$2}END{print t,a}' /proc/meminfo); " +
      "c=0; for h in /sys/class/hwmon/hwmon*; do " +
      "[ \"$(cat $h/name 2>/dev/null)\" = k10temp ] || continue; " +
      "for l in $h/temp*_label; do " +
      "[ \"$(cat $l 2>/dev/null)\" = Tctl ] && { c=$(cat \"${l%_label}_input\"); break; }; " +
      "done; [ \"$c\" != 0 ] && break; done; echo $m $c"]
    stdout: SplitParser {
      onRead: data => {
        const p = data.trim().split(/\s+/).map(Number)
        if (p.length < 3) return
        root.ramTotal = p[0] / 1048576
        root.ramUsed = (p[0] - p[1]) / 1048576
        root.cpuTemp = p[2] / 1000
      }
    }
  }

  // GPU usage/temp/VRAM from nvidia-smi.
  Process {
    id: gpuProc
    command: ["nvidia-smi",
      "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total",
      "--format=csv,noheader,nounits"]
    stdout: SplitParser {
      onRead: data => {
        const p = data.trim().split(",").map(s => parseFloat(s))
        if (p.length < 4) return
        root.gpuUsage = p[0]
        root.gpuTemp = p[1]
        root.vramUsed = p[2] / 1024
        root.vramTotal = p[3] / 1024
      }
    }
  }

  // CPU usage needs frequent sampling; the rest drifts slowly.
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: cpuProc.running = true
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: { hostProc.running = true; gpuProc.running = true }
  }
}
