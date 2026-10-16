pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Battery state read straight from sysfs, so no upower daemon is needed.
// BAT0 is the kernel's name for the first battery; `present` stays false on
// machines without one, which hides the bar pill.
Singleton {
    id: root

    readonly property string batteryDir: "/sys/class/power_supply/BAT0"

    property bool present: false
    property int percent: 0
    property bool charging: false

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c",
            "cd " + root.batteryDir + " 2>/dev/null && echo \"$(cat capacity) $(cat status)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                root.present = parts.length === 2
                if (!root.present) return
                root.percent = parseInt(parts[0])
                root.charging = parts[1] === "Charging"
            }
        }
    }
}
