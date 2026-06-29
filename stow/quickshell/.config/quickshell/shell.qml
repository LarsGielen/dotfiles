import Quickshell
import qs.Components.HorizontalBarMinimal
import qs.Components.Notifications

// Entry point. As you add components, load the always-on ones here.
// For on-demand surfaces (launcher, clipboard, OSD popups) wrap them in
// a LazyLoader so they cost nothing until the moment you open them —
// that's the main lever for keeping the shell lightweight.
ShellRoot {
    HorizontalBarMinimal {}

    // Toast pop-ups. Change `position` to any of TopRight/TopCenter/TopLeft/
    // BottomRight/BottomCenter/BottomLeft.
    NotificationPopups { position: NotificationPopups.Pos.TopRight }

    // Example of a lazily-loaded popup component (uncomment when built):
    // LazyLoader {
    //     id: launcher
    //     active: false              // flip to true via IPC / a keybind
    //     component: Launcher {}
    // }
}