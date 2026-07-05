pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Theme
import qs.Config

// Reusable full-screen modal. Hosts arbitrary `content`, dims the background,
// grabs the keyboard, closes on click-away or Escape, and reveals its content
// centered on the focused monitor with a scale/opacity/slide animation. The
// vertical placement (top / middle / bottom center) follows `position`, which
// defaults to the shared OverlayConfig knob but can be overridden per surface.
//
// Consumers drop their UI in as the default child and drive it via open() /
// close() / toggle(), or expose it over IPC by setting `ipcTarget`.
Scope {
    id: root

    default property alias content: card.data
    property int position: OverlayConfig.position
    property string ipcTarget: ""

    // True from the moment open() is called until the close animation ends.
    property bool _open: false

    signal opened()
    signal closed()

    function open() {
        if (_open) return
        _open = true
        win.visible = true
        closeAnim.stop()
        openAnim.start()
        focusScope.forceActiveFocus()
        root.opened()
    }

    function close() {
        if (!_open) return
        _open = false
        openAnim.stop()
        closeAnim.start()
        root.closed()
    }

    function toggle() { _open ? close() : open() }

    // Optional IPC surface, only instantiated when a target name is given.
    Loader {
        active: root.ipcTarget !== ""
        sourceComponent: IpcHandler {
            target: root.ipcTarget
            function show(): void { root.open() }
            function hide(): void { root.close() }
            function toggle(): void { root.toggle() }
        }
    }

    // Pick the ShellScreen matching Hyprland's focused monitor so the modal
    // always lands where the user is looking.
    readonly property var _targetScreen: {
        const mon = Hyprland.focusedMonitor
        const screens = Quickshell.screens
        if (mon)
            for (let i = 0; i < screens.length; i++)
                if (screens[i].name === mon.name) return screens[i]
        return screens.length ? screens[0] : null
    }

    PanelWindow {
        id: win
        screen: root._targetScreen
        visible: false

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        // Stable namespace so Hyprland can target this surface with a blur
        // layer_rule (see hypr .../windowrules.lua).
        WlrLayershell.namespace: "quickshell-overlay"

        // Span the whole output, ignoring the bar's exclusive zone, so the
        // scrim/blur also covers the space reserved by the bar.
        exclusionMode: ExclusionMode.Ignore

        // Grab all keyboard input while open so typing lands in the modal.
        WlrLayershell.keyboardFocus: root._open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        FocusScope {
            id: focusScope
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.close()

            // Dim scrim.
            Rectangle {
                anchors.fill: parent
                color: OverlayConfig.dimColor
                opacity: root._open ? OverlayConfig.dimOpacity : 0
                Behavior on opacity { NumberAnimation { duration: OverlayConfig.animOpen; easing.type: Easing.OutCubic } }
            }

            // Click-away. Sits under the content, above the scrim.
            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            // Off-screen slide offset the content enters from / exits to.
            readonly property int slideFrom: root.position === OverlayConfig.Pos.BottomCenter
                                             ? OverlayConfig.slideDistance
                                             : root.position === OverlayConfig.Pos.TopCenter
                                               ? -OverlayConfig.slideDistance
                                               : 0

            Item {
                id: card
                width: childrenRect.width
                height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter

                y: {
                    switch (root.position) {
                    case OverlayConfig.Pos.TopCenter:    return OverlayConfig.edgeMargin
                    case OverlayConfig.Pos.BottomCenter: return focusScope.height - height - OverlayConfig.edgeMargin
                    default:                             return (focusScope.height - height) / 2
                    }
                }

                opacity: 0
                scale: 0.9
                transform: Translate { id: slide; y: 0 }
            }

            ParallelAnimation {
                id: openAnim
                NumberAnimation { target: card;  property: "opacity"; from: 0; to: 1; duration: OverlayConfig.animOpen; easing.type: Easing.OutCubic }
                NumberAnimation { target: card;  property: "scale";   from: 0.9; to: 1; duration: OverlayConfig.animOpen; easing.type: Easing.OutBack; easing.overshoot: OverlayConfig.overshoot }
                NumberAnimation { target: slide; property: "y"; from: focusScope.slideFrom; to: 0; duration: OverlayConfig.animOpen; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: closeAnim
                ParallelAnimation {
                    NumberAnimation { target: card;  property: "opacity"; to: 0; duration: OverlayConfig.animClose; easing.type: Easing.InCubic }
                    NumberAnimation { target: card;  property: "scale";   to: 0.9; duration: OverlayConfig.animClose; easing.type: Easing.InCubic }
                    NumberAnimation { target: slide; property: "y"; to: focusScope.slideFrom; duration: OverlayConfig.animClose; easing.type: Easing.InCubic }
                }
                ScriptAction { script: win.visible = false }
            }
        }
    }
}
