import QtQuick
import qs.Theme

// One icon + usage + temperature group of the SysStats pill. The usage and
// temperature texts are sized for their widest value so the pill keeps a
// constant width, and left-aligned so the number stays next to its icon.
Row {
    id: root

    property string icon
    property real usage
    property int temperature: -1

    spacing: Theme.spacing / 2

    // "max" is as wide as "99%", so a full load doesn't need a wider slot.
    readonly property string usageLabel: {
        const percent = Math.round(usage * 100)
        return percent >= 100 ? "max" : percent + "%"
    }

    function temperatureColor(celsius: int): color {
        if (celsius >= 90) return Theme.error
        if (celsius >= 80) return Theme.warning
        return Theme.subtext
    }

    TextMetrics {
        id: usageWidest
        text: "99%"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
    }

    TextMetrics {
        id: temperatureWidest
        text: "99°"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeSmall
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeLarge
        color: Theme.accent
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: usageWidest.advanceWidth
        text: root.usageLabel
        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
        color: Theme.text
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.temperature >= 0
        width: temperatureWidest.advanceWidth
        text: root.temperature + "°"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeSmall
        color: root.temperatureColor(root.temperature)
    }
}
