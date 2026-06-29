pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import qs.Config

// freedesktop notification daemon. `list` is the persistent set (kept until
// dismissed) — it backs a future Control-Center overview; `popups` is the
// transient subset currently floating as toasts.
Singleton {
    id: root

    readonly property var list: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    property var popups: []
    // id -> epoch-ms deadline, kept off the notification object so a re-created
    // toast resumes its countdown instead of restarting.
    property var expiry: ({})

    function dismissAll(): void {
        // Dismissing mutates the model, so iterate over a copy.
        for (const n of list.values.slice()) n.dismiss()
    }

    // Clear toasts without dismissing the underlying notifications.
    function clearPopups(): void {
        for (const n of popups.slice()) removePopup(n)
    }

    function pushPopup(n): void {
        touchPopup(n)
        let next = popups.slice()
        next.push(n)
        // Cap the stack; oldest toasts fall off first (they stay in `list`).
        if (next.length > NotificationConfig.max)
            next = next.slice(next.length - NotificationConfig.max)
        popups = next
    }

    function removePopup(n): void {
        const e = expiry
        delete e[n.id]
        expiry = e
        popups = popups.filter(x => x !== n)
    }

    // (Re)start a toast's countdown.
    function touchPopup(n): void {
        if (NotificationConfig.timeout <= 0) return
        expiry = Object.assign({}, expiry, { [n.id]: Date.now() + NotificationConfig.timeout })
    }

    // Ms left before auto-hide (>=1 to keep timers/animations valid).
    function popupRemaining(n): int {
        if (NotificationConfig.timeout <= 0) return 0
        return Math.max(1, (expiry[n.id] || 0) - Date.now())
    }

    NotificationServer {
        id: server
        keepOnReload: true

        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true

        onNotification: n => {
            n.tracked = true
            root.pushPopup(n)
            // When closed/dismissed from anywhere, pull its toast.
            n.closed.connect(() => root.removePopup(n))
        }
    }
}
