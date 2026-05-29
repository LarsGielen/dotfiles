pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

import "../Theme"

// Notifications ─ the freedesktop notification server, exposed as a singleton so
// any UI can read the live list. Incoming notifications are retained (tracked)
// until explicitly dismissed, rather than auto-expiring off the bus.
//
//   model:   Notifications.list      // ObjectModel<Notification>
//   count:   Notifications.count
//   clear:   Notifications.dismissAll()
//
// On top of the persistent list it keeps a separate, transient `popups` list:
// the notifications that should currently float on screen as toasts. A toast
// leaves `popups` when it times out (the notification stays in the list for the
// Control Center) or when the underlying notification is dismissed/closed.
//
//   toasts:  Notifications.popups     // array<Notification>
Singleton {
  id: root

  readonly property var list: server.trackedNotifications
  readonly property int count: server.trackedNotifications.values.length

  // Notifications currently shown as on-screen toasts.
  property var popups: []
  // id -> epoch-ms at which the toast should disappear. Kept separate from the
  // notification so a toast that gets re-created (the popups list changing
  // rebuilds the delegates) resumes its original countdown instead of restarting.
  property var expiry: ({})

  function dismissAll() {
    // Dismissing mutates the model, so iterate over a copy.
    for (const n of server.trackedNotifications.values.slice())
      n.dismiss()
  }

  // Drop every toast from the screen without dismissing the notifications.
  function clearPopups() {
    for (const n of popups.slice()) removePopup(n)
  }

  function pushPopup(n) {
    touchPopup(n)
    let next = popups.slice()
    next.push(n)
    // Cap the stack; oldest toasts fall off first (they stay in the list).
    if (next.length > Theme.toastMax) next = next.slice(next.length - Theme.toastMax)
    popups = next
  }

  function removePopup(n) {
    const e = expiry
    delete e[n.id]
    expiry = e
    popups = popups.filter(x => x !== n)
  }

  // (Re)start a toast's countdown, e.g. on arrival or when the mouse leaves it.
  function touchPopup(n) {
    if (Theme.toastTimeout <= 0) return
    expiry = Object.assign({}, expiry, { [n.id]: Date.now() + Theme.toastTimeout })
  }

  // Milliseconds left before this toast should auto-hide (>=1 to keep timers valid).
  function popupRemaining(n) {
    if (Theme.toastTimeout <= 0) return 0
    return Math.max(1, (expiry[n.id] || 0) - Date.now())
  }

  NotificationServer {
    id: server
    keepOnReload: true

    // Advertise the capabilities our UI actually renders.
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true
    actionsSupported: true

    onNotification: n => {
      n.tracked = true
      root.pushPopup(n)
      // When the notification is dismissed/closed from anywhere, pull its toast.
      n.closed.connect(() => root.removePopup(n))
    }
  }
}
