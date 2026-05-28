pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

// Notifications ─ the freedesktop notification server, exposed as a singleton so
// any UI can read the live list. Incoming notifications are retained (tracked)
// until explicitly dismissed, rather than auto-expiring off the bus.
//
//   model:   Notifications.list      // ObjectModel<Notification>
//   count:   Notifications.count
//   clear:   Notifications.dismissAll()
Singleton {
  id: root

  readonly property var list: server.trackedNotifications
  readonly property int count: server.trackedNotifications.values.length

  function dismissAll() {
    // Dismissing mutates the model, so iterate over a copy.
    for (const n of server.trackedNotifications.values.slice())
      n.dismiss()
  }

  NotificationServer {
    id: server
    keepOnReload: true

    // Advertise the capabilities our UI actually renders.
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true
    actionsSupported: true

    onNotification: n => n.tracked = true
  }
}
