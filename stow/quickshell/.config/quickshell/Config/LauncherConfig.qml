pragma Singleton
import Quickshell
import QtQuick

// App-launcher configuration. Kept out of the global Theme so the launcher can
// be tuned in isolation, following the NotificationConfig convention.
Singleton {
    id: root

    // Desktop entries to hide from the launcher, matched by `id` — the .desktop
    // filename without its extension (e.g. /usr/share/applications/bssh.desktop
    // -> "bssh"). Find an id with:  ls /usr/share/applications | sed 's/\.desktop$//'
    property var hidden: [
        // Avahi network browsers
        "avahi-discover",     // Avahi Zeroconf Browser
        "bssh",               // Avahi SSH Server Browser
        "bvnc",               // Avahi VNC Server Browser

        // Hardware / video test utilities
        "lstopo",             // Hardware Locality lstopo
        "qv4l2",              // Qt V4L2 test Utility
        "qvidcap",            // Qt V4L2 video capture utility

        // Infra / DE cruft not meant to be launched by name
        "uuctl",              // uwsm systemd unit control helper
        "xfce4-about",        // About Xfce (not the active DE)

        // Secondary dialogs (main app kept)
        "blueman-adapters",   // duplicate of Bluetooth Manager
        "thunar-bulk-rename"  // Thunar sub-tool, invoked from the file manager
    ]

    // Terminal emulator used to run terminal apps (custom entries with
    // `terminal: true`, and any desktop entry marked Terminal=true, which
    // Quickshell's execute() otherwise ignores). argv form; the program to run
    // is appended after it, so kitty launches `kitty <program> <args...>`.
    property var terminal: ["kitty"]

    // Your own launcher entries, shown alongside the desktop apps. Each is:
    //   name:    text shown in the list (required)
    //   exec:    argv array to run (required), e.g. ["python", "/path/app.py"]
    //   terminal: true for CLI / shell / TUI apps so they open in `terminal`
    //   icon:    freedesktop icon name (optional), e.g. "utilities-terminal"
    //   comment: subtitle shown under the name (optional)
    property var extra: [
        // { name: "Example TUI", exec: ["python", "/home/lars/scripts/tui.py"],
        //   terminal: true, icon: "utilities-terminal", comment: "A shell app" },
    ]
}
