pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Example of a service backed by a polled external command rather than
// a built-in Quickshell library. Exposes cpu and memory as 0..1 floats.
// Network status, brightness, weather, etc. follow the exact same shape.
Singleton {
    id: root

    property real cpu:    0   // 0..1
    property real memory: 0   // 0..1

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c", root.script]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                root.cpu    = parseFloat(parts[0]) || 0
                root.memory = parseFloat(parts[1]) || 0
            }
        }
    }

    // CPU over a short window + RAM from meminfo. Prints "cpu mem".
    readonly property string script:
        "read a b c d rest < /proc/stat; t1=$((a+b+c+d)); i1=$d; sleep 0.2; " +
        "read a b c d rest < /proc/stat; t2=$((a+b+c+d)); i2=$d; " +
        "cpu=$(awk -v t=$((t2-t1)) -v i=$((i2-i1)) 'BEGIN{ if(t>0) printf \"%.3f\",(t-i)/t; else print 0 }'); " +
        "mem=$(awk '/MemTotal/{tot=$2} /MemAvailable/{av=$2} END{ printf \"%.3f\",(tot-av)/tot }' /proc/meminfo); " +
        "echo \"$cpu $mem\""
}
