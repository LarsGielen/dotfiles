pragma Singleton
import Quickshell
import Quickshell.Bluetooth

// A thin facade over the built-in Bluetooth singleton, mirroring Audio.qml.
//
// Components depend on *your* stable surface (enabled / devices / toggle)
// rather than Bluez internals, so an upstream API change is fixed here once.
Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available:   adapter !== null
    readonly property bool enabled:     adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    // All known devices (paired or in range), most-relevant first.
    readonly property var devices: Bluetooth.devices.values
        .slice()
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired))

    function setEnabled(on: bool): void {
        if (adapter) adapter.enabled = on
    }
    function toggle(): void { setEnabled(!enabled) }

    function toggleDevice(dev): void {
        if (!dev) return
        if (dev.connected) dev.disconnect()
        else dev.connect()
    }
}
