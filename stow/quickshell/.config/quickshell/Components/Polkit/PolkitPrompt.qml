pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import qs.Theme
import qs.Config
import qs.Widgets

// System polkit authentication agent. Instantiating PolkitAgent registers it
// over D-Bus, so this prompt appears automatically whenever a GUI action needs
// privilege escalation (e.g. `pkexec`). Reuses the shared modal Overlay.
Scope {
    id: root

    PolkitAgent {
        id: agent
        onAuthenticationRequestStarted: overlay.open()
    }

    Overlay {
        id: overlay
        readonly property var flow: agent.flow

        onOpened: { field.clear(); field.input.forceActiveFocus() }
        // Closing without a completed flow (Escape / click-away) cancels the
        // pending request so the requesting app isn't left hanging.
        onClosed: if (agent.flow && !agent.flow.isCompleted) agent.flow.cancelAuthenticationRequest()

        function submit() {
            if (overlay.flow) overlay.flow.submit(field.text)
        }

        Connections {
            target: overlay.flow
            function onAuthenticationSucceeded() { overlay.close() }
            function onAuthenticationFailed() { field.clear(); field.input.forceActiveFocus() }
            function onAuthenticationRequestCancelled() { overlay.close() }
        }

        StyledRect {
            color: Theme.surface
            radius: OverlayConfig.radius
            border.width: 1
            border.color: Theme.surfaceAlt
            implicitWidth: 420
            implicitHeight: column.implicitHeight + Theme.paddingH * 2

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: Theme.paddingH
                spacing: Theme.spacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing

                    Text {
                        text: String.fromCharCode(0xf023) // lock
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeLarge
                        color: Theme.accent
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Authentication required"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeLarge
                        color: Theme.text
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    wrapMode: Text.WordWrap
                    text: overlay.flow && overlay.flow.message ? overlay.flow.message : ""
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.size
                    color: Theme.subtext
                }

                TextField {
                    id: field
                    Layout.fillWidth: true
                    echoMode: overlay.flow && overlay.flow.responseVisible ? TextInput.Normal : TextInput.Password
                    placeholder: overlay.flow && overlay.flow.inputPrompt ? overlay.flow.inputPrompt : "Password"
                    onAccepted: overlay.submit()
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    wrapMode: Text.WordWrap
                    text: overlay.flow && overlay.flow.supplementaryMessage ? overlay.flow.supplementaryMessage : ""
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall
                    color: overlay.flow && overlay.flow.supplementaryIsError ? Theme.error : Theme.subtext
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spacing
                    spacing: Theme.spacing

                    Item { Layout.fillWidth: true }

                    IconButton {
                        label: "Cancel"
                        onClicked: overlay.close()
                    }
                    IconButton {
                        label: "Authenticate"
                        normalColor: Theme.accent
                        hoverColor: Theme.accent
                        tint: Theme.onAccent
                        onClicked: overlay.submit()
                    }
                }
            }
        }
    }
}
