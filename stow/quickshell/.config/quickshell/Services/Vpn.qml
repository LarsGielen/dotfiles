pragma Singleton
import Quickshell
import Quickshell.Io

// wg-quick tunnel control (ProtonVPN or any WireGuard provider). Profiles are
// plain wg-quick .conf files in /etc/wireguard — install-protonvpn.sh makes
// that directory group-readable (wheel) so profile *names* can be listed
// without a privilege prompt, while the files themselves stay root-only, so
// private keys are never read by the session. Bringing a tunnel up/down still
// needs root; those two run through pkexec and surface via the shared
// PolkitPrompt (Components/Polkit), same as every other privileged call here.
Singleton {
    id: root

    readonly property string configDir: "/etc/wireguard"

    property var profiles: []           // config names (no .conf), alphabetical
    property string activeProfile: ""   // "" when no known tunnel is up
    readonly property bool connected: activeProfile !== ""
    property string selectedProfile: "" // profile the next connect() targets
    property bool busy: false           // an up/down/switch is in flight
    property string _pendingTarget: ""  // queued "up" target once a switch's "down" finishes

    function refresh(): void {
        listProc.running = true
        statusProc.running = true
    }

    function select(name: string): void { root.selectedProfile = name }

    function connect(name: string): void {
        const target = name || root.selectedProfile || root.profiles[0] || ""
        if (!target || root.busy || target === root.activeProfile) return
        root.busy = true
        root.selectedProfile = target
        if (root.activeProfile) {
            root._pendingTarget = target
            downProc.command = ["pkexec", "/usr/bin/wg-quick", "down", root.activeProfile]
            downProc.running = true
        } else {
            upProc.command = ["pkexec", "/usr/bin/wg-quick", "up", target]
            upProc.running = true
        }
    }

    function disconnect(): void {
        if (!root.activeProfile || root.busy) return
        root.busy = true
        downProc.command = ["pkexec", "/usr/bin/wg-quick", "down", root.activeProfile]
        downProc.running = true
    }

    function toggle(): void {
        if (root.connected) root.disconnect()
        else root.connect(root.selectedProfile)
    }

    Component.onCompleted: root.refresh()

    // Directory listing only — never reads file contents, so it needs no
    // privilege beyond the group-read access install-protonvpn.sh grants.
    Process {
        id: listProc
        command: ["sh", "-c",
            "ls -1 " + root.configDir + " 2>/dev/null | grep '\\.conf$' | sed 's/\\.conf$//' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.profiles = text.trim().length ? text.trim().split("\n") : []
                if (!root.selectedProfile && root.profiles.length) root.selectedProfile = root.profiles[0]
            }
        }
    }

    // `wg show interfaces` only needs to read interface *names*, unlike
    // `wg show` (which also prints keys and requires root).
    Process {
        id: statusProc
        command: ["wg", "show", "interfaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                const names = text.trim().length ? text.trim().split(/\s+/) : []
                root.activeProfile = names.find(n => root.profiles.includes(n)) ?? ""
                if (root.activeProfile) root.selectedProfile = root.activeProfile
            }
        }
    }

    Process {
        id: downProc
        onExited: (exitCode) => {
            root.refresh()
            const target = root._pendingTarget
            root._pendingTarget = ""
            if (target && exitCode === 0) {
                upProc.command = ["pkexec", "/usr/bin/wg-quick", "up", target]
                upProc.running = true
            } else {
                root.busy = false
            }
        }
    }

    Process {
        id: upProc
        onExited: {
            root.busy = false
            root.refresh()
        }
    }
}
