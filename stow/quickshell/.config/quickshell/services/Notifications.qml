pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

import "../config"

// freedesktop notification server. `list` is the persistent set (kept until
// dismissed); `popups` is the transient subset currently floating as toasts.
Singleton {
  id: root

  readonly property var list: server.trackedNotifications
  readonly property int count: server.trackedNotifications.values.length

  property var popups: []
  // id -> epoch-ms deadline, kept off the notification so a re-created toast
  // resumes its countdown instead of restarting.
  property var expiry: ({})

  function dismissAll() {
    // Dismissing mutates the model, so iterate over a copy.
    for (const n of server.trackedNotifications.values.slice())
      n.dismiss()
  }

  // Clear toasts without dismissing the notifications.
  function clearPopups() {
    for (const n of popups.slice()) removePopup(n)
  }

  function pushPopup(n) {
    touchPopup(n)
    let next = popups.slice()
    next.push(n)
    // Cap the stack; oldest toasts fall off first (they stay in the list).
    if (next.length > Settings.toastMax) next = next.slice(next.length - Settings.toastMax)
    popups = next
  }

  function removePopup(n) {
    const e = expiry
    delete e[n.id]
    expiry = e
    popups = popups.filter(x => x !== n)
  }

  // (Re)start a toast's countdown.
  function touchPopup(n) {
    if (Settings.toastTimeout <= 0) return
    expiry = Object.assign({}, expiry, { [n.id]: Date.now() + Settings.toastTimeout })
  }

  // Ms left before auto-hide (>=1 to keep timers valid).
  function popupRemaining(n) {
    if (Settings.toastTimeout <= 0) return 0
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
      // When the notification is dismissed/closed from anywhere, pull its toast.
      n.closed.connect(() => root.removePopup(n))
    }
  }
}
