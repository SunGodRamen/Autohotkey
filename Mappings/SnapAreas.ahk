#Persistent
global snap_zone_repo := "C:\Users\avons\Code\Autohotkey\Resource\snap_areas.txt"
global snap_zones := []
#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk
#Include, C:\Users\avons\Code\Autohotkey\Library\JSON.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Util\Tooltip.ahk

#Include, C:\Users\avons\Code\Autohotkey\config.ahk

; Create hotkeys
Loop, 10 {
    ; Create zone
    hotkeySet := new Hotkey(snap_set_prefix A_Index - 1)
    hotkeySet.onEvent(Func("SnapZoneFromWindow").Bind(A_Index - 1))
    ; Snap to zone
    hotkeySnap := new Hotkey(snap_window_prefix A_Index - 1)
    hotkeySnap.onEvent(Func("SnapWindowToZone").Bind(A_Index - 1))
}

; Use active window location and dimensions to record a new snap zone associated with the hotkey number
SnapZoneFromWindow(number) {
    LoadSnapZones()
    WinGetPos, x, y, w, h, A ; Get the position and dimensions of the active window
    snap_zones.InsertAt(number, { "x": x, "y": y, "w": w, "h": h })
    SaveSnapZones()
    ShowToolTip("Snap zone " number " set for (x:" x " y:" y ") (w:" w " h:" h ")", 3000)
}

; Snap active window to previously recorded position
SnapWindowToZone(number) {
    LoadSnapZones()
    zone := snap_zones[number]
    if (zone) {
        ; Move and resize the active window to the recorded position and dimensions
        WinMove, A,, % zone.x, % zone.y, % zone.w, % zone.h
    } else {
        ShowToolTip("No snap zone set for " number, 1500)
    }
}

; Function to load snap zones from file
LoadSnapZones() {
    global snap_zones
    if (FileExist(snap_zone_repo)) {
        FileRead, snap_zones_content, %snap_zone_repo%
        snap_zones := JSON.Load(snap_zones_content)
    } else {
        snap_zones := []
    }
}

; Function to save snap zones to a file
SaveSnapZones() {
    FileDelete, %snap_zone_repo%
    snap_zone_data := JSON.Dump(snap_zones)
    FileAppend, %snap_zone_data%, %snap_zone_repo%
}
