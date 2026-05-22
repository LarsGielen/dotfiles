import QtQuick
import Quickshell.Services.UPower

// Battery indicator. Hidden entirely on machines without a laptop battery.
Rectangle {
  id: root

  readonly property var dev: UPower.displayDevice
  readonly property bool present: dev && dev.isLaptopBattery
  readonly property int percent: present ? Math.round(dev.percentage) : 0
  readonly property bool charging: present
    && (dev.state === UPowerDeviceState.Charging
        || dev.state === UPowerDeviceState.FullyCharged)

  function batIcon() {
    if (charging) return Theme.icon(0xf0e7)         // bolt
    if (percent >= 90) return Theme.icon(0xf240)    // battery-full
    if (percent >= 65) return Theme.icon(0xf241)
    if (percent >= 40) return Theme.icon(0xf242) 
    if (percent >= 15) return Theme.icon(0xf243)
    return Theme.icon(0xf244)                        // battery-empty
  }

  visible: present
  implicitWidth: visible ? row.implicitWidth + Theme.padding * 2 : 0
  implicitHeight: Theme.itemHeight
  radius: Theme.itemRadius
  color: Theme.surface0

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.batIcon()
      color: root.percent <= 15 && !root.charging ? Theme.red : root.charging ? Theme.green : Theme.accent
      font.family: Theme.font
      font.pixelSize: Theme.iconSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.percent + "%"
      color: Theme.text
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
    }
  }
}
