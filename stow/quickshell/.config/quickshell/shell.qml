import Quickshell
import qs.Components.HorizontalBarMinimal
import qs.Components.Notifications
import qs.Components.SessionMenu
import qs.Components.Launcher
import qs.Components.Polkit

// Entry point. As you add components, load the always-on ones here.
ShellRoot {
    HorizontalBarMinimal {}

    // Toast pop-ups. Change `position` to any of TopRight/TopCenter/TopLeft/
    // BottomRight/BottomCenter/BottomLeft.
    NotificationPopups { position: NotificationPopups.Pos.TopRight }

    // Modal surfaces. Their windows stay unmapped until opened, so they're
    // idle until triggered. Position is configured in Config/OverlayConfig.qml.
    SessionMenu {}   // qs ipc call session toggle
    Launcher {}      // qs ipc call launcher toggle
    PolkitPrompt {}  // auto-opens on any GUI privilege escalation
}