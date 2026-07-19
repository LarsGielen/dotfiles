pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// wg-quick tunnel control (ProtonVPN or any WireGuard provider) with a
// firewall kill switch. Profiles are plain wg-quick .conf files in
// /etc/wireguard — install-protonvpn.sh makes that directory group-readable
// (wheel) so profile *names* can be listed without a privilege prompt, while
// the files themselves stay root-only, so private keys are never read by the
// session. Bringing a tunnel up/down still needs root; those two (plus the
// kill switch they carry) run through pkexec and surface via the shared
// PolkitPrompt (Components/Polkit), same as every other privileged call here.
//
// Kill switch: connecting first loads a standalone nftables table
// (inet vpn_killswitch, hooked on output) that drops all outbound traffic
// except loopback, the tunnel interface, and the UDP handshake to the VPN
// server itself — only *then* does it bring the tunnel up, so there's no
// unprotected window. Disconnecting brings the tunnel down first, then
// removes that table. Because the table is only ever removed by *this* down
// path, an interface that disappears any other way (crash, an external
// `wg-quick down`, ...) leaves the block in place — traffic stays fenced in
// until you reconnect, rather than silently falling back to the clear.
// To lift it by hand: `sudo nft delete table inet vpn_killswitch`.
//
// Caveat: this assumes the profile's AllowedIPs routes everything through
// the tunnel (ProtonVPN's default). A deliberately split-tunneled config
// would have its non-tunneled traffic blocked too, since the switch can't
// tell "not meant to go through the VPN" apart from "leaking".
Singleton {
    id: root

    readonly property string configDir: "/etc/wireguard"

    property var profiles: []           // config names (no .conf), alphabetical
    property string activeProfile: ""   // "" when no known tunnel is up
    readonly property bool connected: activeProfile !== ""
    property string selectedProfile: "" // profile the next connect() targets
    property bool busy: false           // an up/down/switch is in flight
    property string _pendingTarget: ""   // queued "up" target once a switch's "down" finishes
    property bool _manualTeardown: false // true while our own disconnect()/down is in flight

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
            root._manualTeardown = true
            downProc.command = ["pkexec", "sh", "-c", root._downScript, "vpn-disconnect", root.activeProfile]
            downProc.running = true
        } else {
            upProc.command = ["pkexec", "sh", "-c", root._upScript, "vpn-connect", target]
            upProc.running = true
        }
    }

    function disconnect(): void {
        if (!root.activeProfile || root.busy) return
        root.busy = true
        root._manualTeardown = true
        downProc.command = ["pkexec", "sh", "-c", root._downScript, "vpn-disconnect", root.activeProfile]
        downProc.running = true
    }

    function toggle(): void {
        if (root.connected) root.disconnect()
        else root.connect(root.selectedProfile)
    }

    Component.onCompleted: root.refresh()

    // --- kill switch scripts, run as root via pkexec; profile name arrives as $1 ---

    readonly property string _upScript:
        "set -e\n" +
        "NAME=\"$1\"\n" +
        "CONF=\"/etc/wireguard/$NAME.conf\"\n" +
        "EP=$(grep -m1 '^Endpoint' \"$CONF\" | sed 's/^[^=]*=[[:space:]]*//')\n" +
        "case \"$EP\" in *\\[*) echo 'vpn-killswitch: bracketed IPv6 endpoints are not supported' >&2; exit 1 ;; esac\n" +
        "EP_HOST=${EP%:*}\n" +
        "EP_PORT=${EP##*:}\n" +
        "[ -n \"$EP_HOST\" ] && [ -n \"$EP_PORT\" ] || { echo 'vpn-killswitch: could not parse Endpoint from config' >&2; exit 1; }\n" +
        "nft delete table inet vpn_killswitch 2>/dev/null || true\n" +
        "nft -f - <<NFTEOF\n" +
        "table inet vpn_killswitch {\n" +
        "  chain output {\n" +
        "    type filter hook output priority 0; policy accept;\n" +
        "    oif \"lo\" accept\n" +
        "    oifname \"$NAME\" accept\n" +
        "    ip daddr $EP_HOST udp dport $EP_PORT accept\n" +
        "    counter drop\n" +
        "  }\n" +
        "}\n" +
        "NFTEOF\n" +
        "wg-quick up \"$NAME\" || { nft delete table inet vpn_killswitch 2>/dev/null; exit 1; }\n"

    readonly property string _downScript:
        "set -e\n" +
        "NAME=\"$1\"\n" +
        "wg-quick down \"$NAME\"\n" +
        "nft delete table inet vpn_killswitch 2>/dev/null || true\n"

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
            root._manualTeardown = false
            root.refresh()
            const target = root._pendingTarget
            root._pendingTarget = ""
            if (target && exitCode === 0) {
                upProc.command = ["pkexec", "sh", "-c", root._upScript, "vpn-connect", target]
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

    // Event-driven, not polled: blocks on a netlink socket and only wakes on
    // an actual link change. Purely informational — the kill switch above is
    // what stops the leak, independent of whether this ever fires (a stale
    // tunnel that never tears down its interface stays fenced in too, just
    // silently, since there's no link event to react to).
    Process {
        running: true
        command: ["ip", "-o", "monitor", "link"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (!root.activeProfile || root._manualTeardown) return
                if (!line.startsWith("Deleted")) return
                if (!line.includes(root.activeProfile + ":")) return
                const dropped = root.activeProfile
                root.activeProfile = ""
                Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "VPN",
                    "VPN disconnected unexpectedly",
                    dropped + " dropped without being told to. The kill switch is blocking network traffic until you reconnect."])
            }
        }
    }
}
