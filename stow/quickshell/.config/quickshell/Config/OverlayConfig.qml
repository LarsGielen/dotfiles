pragma Singleton
import Quickshell
import QtQuick
import qs.Theme

// Shared config for the modal surfaces (launcher, session menu, auth prompt).
// Kept out of the global Theme so the overlays can be positioned/tuned in
// isolation, while still inheriting Theme's spacing/timing. Change `position`
// to move all three surfaces to the top, middle or bottom of the screen.
Singleton {
    id: root

    enum Pos { TopCenter, Center, BottomCenter }

    // The one knob the user is expected to flip.
    property int position: OverlayConfig.Pos.Center

    // Background scrim behind the modal.
    property color dimColor: "#000000"
    property real  dimOpacity: 0.45

    // Distance from the anchored screen edge for TopCenter / BottomCenter.
    property int edgeMargin: 80

    // Reveal / dismiss animation.
    property int  animOpen: Theme.animNormal
    property int  animClose: Theme.animNormal
    property real overshoot: 1.2
    // How far (px) content slides in from the anchored edge on open.
    property int  slideDistance: 40

    // Default content sizing.
    property int radius: Theme.spacing * 2
    property int width: 520
}
