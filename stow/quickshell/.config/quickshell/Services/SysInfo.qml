pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// CPU, GPU, memory and temperature, polled from /proc, sysfs and nvidia-smi.
// Usage and memory are 0..1 floats, temperatures are degrees Celsius. A value
// the machine can't report stays -1, which hides it from the bar pill.
Singleton {
    id: root

    property real cpu:     0    // 0..1
    property real memory:  0    // 0..1
    property real gpu:    -1    // 0..1
    property int cpuTemp: -1
    property int gpuTemp: -1

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
                root.cpu     = parseFloat(parts[0]) || 0
                root.memory  = parseFloat(parts[1]) || 0
                root.gpu     = parseFloat(parts[2])
                root.cpuTemp = parseInt(parts[3])
                root.gpuTemp = parseInt(parts[4])
            }
        }
    }

    // Prints "cpu mem gpu cpuTemp gpuTemp". The CPU sensor is k10temp (AMD) or
    // coretemp (Intel). The GPU is read from nvidia-smi when present, else from
    // the amdgpu sysfs files; either way a missing value prints -1.
    readonly property string script: [
        "read _ u n s i w q sq st rest < /proc/stat; t1=$((u+n+s+i+w+q+sq+st)); i1=$((i+w)); sleep 0.2",
        "read _ u n s i w q sq st rest < /proc/stat; t2=$((u+n+s+i+w+q+sq+st)); i2=$((i+w))",
        "cpu=$(awk -v t=$((t2-t1)) -v i=$((i2-i1)) 'BEGIN{ if(t>0) printf \"%.3f\",(t-i)/t; else print 0 }')",
        "mem=$(awk '/MemTotal/{tot=$2} /MemAvailable/{av=$2} END{ printf \"%.3f\",(tot-av)/tot }' /proc/meminfo)",
        "cpu_temp=-1; amd_temp=-1",
        "for hwmon in /sys/class/hwmon/hwmon*; do",
        "  case $(cat $hwmon/name) in",
        "    k10temp|coretemp) cpu_temp=$(($(cat $hwmon/temp1_input) / 1000)) ;;",
        "    amdgpu) amd_temp=$(($(cat $hwmon/temp1_input) / 1000)) ;;",
        "  esac",
        "done",
        "gpu=-1; gpu_temp=$amd_temp",
        "if command -v nvidia-smi >/dev/null; then",
        "  read -r usage gpu_temp <<EOF",
        "$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | head -n1 | tr -d ,)",
        "EOF",
        "  gpu=$(awk -v u=${usage:--100} 'BEGIN{ printf \"%.3f\",u/100 }')",
        "else",
        "  busy=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n1)",
        "  [ -n \"$busy\" ] && gpu=$(awk -v u=$busy 'BEGIN{ printf \"%.3f\",u/100 }')",
        "fi",
        "echo \"$cpu $mem $gpu $cpu_temp ${gpu_temp:--1}\""
    ].join("\n")
}
