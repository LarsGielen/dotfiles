pragma Singleton
import Quickshell
import QtQuick
import qs.Theme

// Toast-specific tuning. Kept out of the global Theme so notifications can be
// tweaked in isolation, while still inheriting Theme's spacing/timing.
Singleton {
    id: root

    // Behavior (notification-specific)
    property int  timeout: 5000     // ms before auto-hide; <=0 disables auto-hide
    property int  max: 5            // max simultaneous toasts before oldest drops

    // Layout — derive from Theme where it makes sense; only toast-specific sizes are literals
    property int  width: 360
    property int  radius: Theme.spacing * 2
    property int  padding: Theme.paddingH
    property int  gap: Theme.spacing
    property int  iconSize: 40
    property int  bodyLinesCollapsed: 2
    property int  bodyLinesExpanded: 8

    // Animation — reuse Theme durations
    property int  animIn: Theme.animNormal
    property int  animOut: Theme.animFast
    property int  animMove: Theme.animNormal
}
