import QtQuick
import qs.Services
import qs.Theme
import qs.Widgets

// CPU, GPU and memory usage with temperatures. The GPU group hides itself on
// machines that report no GPU.
Pill {
    id: root

    // The Pill's own label is unused: each stat styles its icon, value and
    // temperature separately. The height follows a normal text line rather
    // than the larger icons, so this pill matches its neighbours.
    implicitWidth: content.implicitWidth + Theme.paddingH * 2
    implicitHeight: lineMetrics.height + Theme.paddingV * 2

    TextMetrics {
        id: lineMetrics
        text: "0"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacing * 1.5

        // nf-md cpu / expansion-card / memory glyphs
        SysStat { icon: "󰻠"; usage: SysInfo.cpu; temperature: SysInfo.cpuTemp }
        SysStat {
            visible: SysInfo.gpu >= 0
            icon: "󰢮"
            usage: SysInfo.gpu
            temperature: SysInfo.gpuTemp
        }
        SysStat { icon: "󰍛"; usage: SysInfo.memory }
    }
}
