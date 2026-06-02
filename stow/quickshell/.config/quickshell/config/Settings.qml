pragma Singleton

import Quickshell
import QtQuick

// Behaviour and per-setup layout choices.
Singleton {
  // Notification toasts
  readonly property int toastTimeout: 6000      // ms before a toast auto-hides (0 = stay until dismissed)
  readonly property int toastMax:     5         // most toasts shown at once
}
