pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Config
import qs.Widgets

// Application launcher hosted in the shared modal Overlay. Filters the
// freedesktop application index by name/description and launches the chosen
// entry. Triggered via `qs ipc call launcher toggle`.
Overlay {
    id: overlay
    ipcTarget: "launcher"

    property string query: ""
    property int selected: 0

    // Build a normalized, searchable list: visible desktop entries (minus the
    // configured blocklist) plus the user's custom entries, filtered by query.
    readonly property var results: {
        const q = overlay.query.trim().toLowerCase()
        const items = []

        const apps = DesktopEntries.applications ? DesktopEntries.applications.values : []
        for (let i = 0; i < apps.length; i++) {
            const e = apps[i]
            if (LauncherConfig.hidden.includes(e.id)) continue
            const kw = e.keywords ? e.keywords.join(" ") : ""
            items.push({
                name: e.name || "",
                icon: e.icon || "",
                comment: e.comment || "",
                hay: ((e.name || "") + " " + (e.genericName || "") + " " + (e.comment || "") + " " + kw).toLowerCase(),
                entry: e,
                custom: null
            })
        }

        const extra = LauncherConfig.extra || []
        for (let i = 0; i < extra.length; i++) {
            const x = extra[i]
            items.push({
                name: x.name || "",
                icon: x.icon || "",
                comment: x.comment || "",
                hay: ((x.name || "") + " " + (x.comment || "")).toLowerCase(),
                entry: null,
                custom: x
            })
        }

        let list = q === "" ? items : items.filter(it => it.hay.includes(q))
        list.sort((a, b) => a.name.localeCompare(b.name))
        return list
    }

    onResultsChanged: selected = 0
    onOpened: {
        overlay.query = ""
        overlay.selected = 0
        search.clear()
        search.input.forceActiveFocus()
    }

    function move(delta) {
        const n = overlay.results.length
        if (n === 0) return
        overlay.selected = Math.max(0, Math.min(n - 1, overlay.selected + delta))
        list.positionViewAtIndex(overlay.selected, ListView.Contain)
    }

    // Launch a normalized result. Terminal apps (custom `terminal: true`, or a
    // desktop entry with Terminal=true, which execute() ignores) are wrapped in
    // the configured terminal emulator.
    function launch(item) {
        if (!item) return
        if (item.entry) {
            if (item.entry.runInTerminal)
                Quickshell.execDetached(LauncherConfig.terminal.concat(item.entry.command))
            else
                item.entry.execute()
        } else if (item.custom) {
            const x = item.custom
            Quickshell.execDetached(x.terminal ? LauncherConfig.terminal.concat(x.exec) : x.exec)
        }
        overlay.close()
    }

    function launchSelected() {
        const r = overlay.results
        if (overlay.selected >= 0 && overlay.selected < r.length)
            overlay.launch(r[overlay.selected])
    }

    StyledRect {
        color: Theme.surface
        radius: OverlayConfig.radius
        border.width: 1
        border.color: Theme.surfaceAlt
        implicitWidth: OverlayConfig.width
        implicitHeight: column.implicitHeight + Theme.paddingH * 2

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: Theme.paddingH
            spacing: Theme.spacing

            TextField {
                id: search
                Layout.fillWidth: true
                placeholder: "Search applications…"
                onTextChanged: overlay.query = text
                onAccepted: overlay.launchSelected()

                // Vertical arrows aren't used by a single-line input, so they
                // bubble up here to drive list selection.
                Keys.onUpPressed: overlay.move(-1)
                Keys.onDownPressed: overlay.move(1)
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 400)
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: overlay.selected

                model: overlay.results
                delegate: AppEntry {
                    required property int index
                    required property var modelData
                    width: ListView.view.width
                    entry: modelData
                    selected: index === overlay.selected
                    onActivated: {
                        overlay.selected = index
                        overlay.launchSelected()
                    }
                }
            }
        }
    }
}
