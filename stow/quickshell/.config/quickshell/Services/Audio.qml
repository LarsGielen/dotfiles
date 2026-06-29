pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

// A thin facade over the built-in Pipewire singleton.
//
// Why wrap it? Components depend on *your* stable surface
// (volume / muted / setVolume) instead of Pipewire's internals.
// If the upstream API shifts, you fix it here once. (For services
// that are already clean, it's fine to use the built-in directly and
// skip the wrapper — don't wrap for the sake of wrapping.)
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted:  sink?.audio?.muted ?? false

    // Every selectable output device (real sinks, not application streams).
    readonly property var sinks: Pipewire.nodes.values
        .filter(n => n.isSink && !n.isStream && n.audio)

    function setVolume(v: real): void {
        if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, v))
    }
    function toggleMute(): void {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted
    }
    function setSink(node: PwNode): void {
        if (node) Pipewire.preferredDefaultAudioSink = node
    }

    // Pipewire only keeps a node's properties live while it's tracked.
    // Without this, volume/muted won't update reactively. Track every sink
    // so the picker and the active-device slider both stay in sync.
    PwObjectTracker { objects: root.sinks }
}
