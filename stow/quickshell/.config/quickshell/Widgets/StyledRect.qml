import QtQuick
import qs.Theme

// The base building block. A Rectangle that already knows the theme.
// Everything that needs a rounded, coloured surface extends this.
Rectangle {
    color: Theme.surface
    radius: height / 2

    // Free smooth colour transitions on theme change for every descendant.
    Behavior on color { ColorAnimation { duration: Theme.animFast } }
}
