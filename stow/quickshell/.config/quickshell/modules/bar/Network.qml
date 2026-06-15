import QtQuick

import "../../widgets"
import "../../services"
import "../../themes"
import "../../config"

Item {
  id: root
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string netType: NetworkStatus.type

  readonly property string label: {
    if (netType === "wifi")     return NetworkStatus.ssid || "WiFi"
    if (netType === "ethernet") return "Ethernet"
    return "No network"
  }

  IconButton {
    id: button
    itemHeight: Appearance.barItemHeight
    itemRadius: Appearance.barItemRadius
    hPadding: Appearance.barPadding
    icon: NetworkStatus.icon
    iconColor: netType === "none" ? Theme.red : Theme.subtext
    label: root.label
    labelOnHover: true
  }
}
