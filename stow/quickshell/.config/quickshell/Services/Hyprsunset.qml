pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Blue-light filter control over hyprsunset's IPC (`hyprctl hyprsunset ...`).
//
// hyprsunset already runs a time-based schedule from hyprsunset.conf; this is
// just a manual override — force the warm evening profile on, or reset to the
// neutral daytime values. "On" means the display temperature sits below the
// 6000K neutral point, so a scheduled warm shift reads as on here too.
//
// The warm target mirrors the evening block in hyprsunset.conf (temperature
// 3500, gamma 0.4). Note: hyprsunset 0.4.0's `identity` IPC command replies
// "ok" but doesn't actually reset anything, so turning off sets the neutral
// temperature/gamma explicitly instead.
Singleton {
    id: root

    readonly property int warmTemperature: 3500
    readonly property int warmGamma: 40          // percent (conf's gamma = 0.4)
    readonly property int neutralTemperature: 6000
    readonly property int neutralGamma: 100

    property int temperature: 6000               // last value read back from IPC
    readonly property bool enabled: temperature < 6000

    function refresh(): void { queryProc.running = true }

    function setEnabled(on: bool): void {
        const temp  = on ? root.warmTemperature : root.neutralTemperature
        const gamma = on ? root.warmGamma       : root.neutralGamma
        applyProc.command = ["sh", "-c",
            "hyprctl hyprsunset temperature " + temp
            + " && hyprctl hyprsunset gamma " + gamma]
        applyProc.running = true
    }
    function toggle(): void { root.setEnabled(!root.enabled) }

    Component.onCompleted: root.refresh()

    Process {
        id: queryProc
        command: ["hyprctl", "hyprsunset", "temperature"]
        stdout: StdioCollector {
            onStreamFinished: {
                const n = parseInt(text.trim())
                if (!isNaN(n)) root.temperature = n
            }
        }
    }

    // Re-read the real state after applying, so the tile reflects what
    // hyprsunset actually did rather than what we asked for.
    Process {
        id: applyProc
        onExited: root.refresh()
    }
}
