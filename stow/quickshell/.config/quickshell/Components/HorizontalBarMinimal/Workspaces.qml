pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Theme
import qs.Widgets

Item {
    id: root

    enum Display { AllScreens, FocusedScreen, PrimaryScreen }

    property ShellScreen screen
    property int display: Workspaces.Display.AllScreens
    property bool perMonitor: false
    property string mainMonitor: ""

    readonly property HyprlandMonitor monitor: root.screen ? Hyprland.monitorFor(root.screen) : null

    readonly property bool isShown: {
        switch (root.display) {
            case Workspaces.Display.FocusedScreen: return !!root.monitor && root.monitor === Hyprland.focusedMonitor;
            case Workspaces.Display.PrimaryScreen: return !!root.monitor && (root.mainMonitor !== "" ? root.monitor.name === root.mainMonitor : root.monitor.id === 0);
            default: return true;
        }
    }

    readonly property var model: {
        const all = Hyprland.workspaces.values;
        return (root.perMonitor && root.monitor) ? all.filter(w => w.monitor === root.monitor) : all;
    }

    visible: root.isShown
    implicitWidth: root.isShown ? loader.implicitWidth : 0
    implicitHeight: loader.implicitHeight

    // accessors handed to whichever picker is active
    function _label(ws): string { return ws.name; }
    function _selected(ws): bool { return !!root.monitor && ws === root.monitor.activeWorkspace; }
    function _filled(ws): bool { return (ws?.toplevels?.values?.length ?? 0) > 0; }
    function _alert(ws): bool { return ws?.urgent ?? false; }
    function _select(ws): void { Hyprland.dispatch("hl.dsp.focus({workspace=" + ws.id + "})"); }

    Loader {
        id: loader
        sourceComponent: liquidPicker
    }

    Component {
        id: liquidPicker
        LiquidPicker {
            model: root.model
            labelOf: ws => root._label(ws)
            isSelected: ws => root._selected(ws)
            isAlert: ws => root._alert(ws)
            onActivated: ws => root._select(ws)
        }
    }
}