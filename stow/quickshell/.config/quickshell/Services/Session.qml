pragma Singleton
import Quickshell

// Power / session actions. Thin facade over execDetached, mirroring the other
// Services singletons. Commands are plain properties so they can be retargeted
// (e.g. swap the locker) without touching the menu UI.
Singleton {
    id: root

    property var lockCmd:     ["loginctl", "lock-session"]
    property var logoutCmd:   ["uwsm", "stop"]
    property var suspendCmd:  ["systemctl", "suspend"]
    property var rebootCmd:   ["systemctl", "reboot"]
    property var shutdownCmd: ["systemctl", "poweroff"]

    function lock()     { Quickshell.execDetached(root.lockCmd) }
    function logout()   { Quickshell.execDetached(root.logoutCmd) }
    function suspend()  { Quickshell.execDetached(root.suspendCmd) }
    function reboot()   { Quickshell.execDetached(root.rebootCmd) }
    function shutdown() { Quickshell.execDetached(root.shutdownCmd) }
}
