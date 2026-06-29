import QtQuick
import Quickshell
import qs.Widgets

Pill {
    id: root
    label: Qt.formatDateTime(clock.date, "HH:mm")
    
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}