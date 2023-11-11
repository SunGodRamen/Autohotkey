#Persistent
global snap_zone_repo := "C:\Users\avons\Code\Autohotkey\Resource\snap_areas.txt"
global snap_zones := {}

#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk
#Include, C:\Users\avons\Code\Autohotkey\Library\JSON.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Util\Tooltip.ahk

#Include, C:\Users\avons\Code\Autohotkey\config.ahk

; Create hotkeys
; Create zone
Loop, 10 {
    hotkeyAssign := new Hotkey(snap_set_prefix A_Index - 1)
    hotkeyAssign.onEvent(Func("SnapZoneFromWindow").Bind(A_Index - 1))
}

; Snap to zone
Loop, 10 {
    hotkeyAssign := new Hotkey(snap_window_prefix A_Index - 1)
    hotkeyFocus.onEvent(Func("SnapWindowToZone").Bind(A_Index - 1))
}

; Use active window location and dimensions to record a new snap zone associated with the hotkey number
SnapZoneFromWindow(number) {
    ; ShowToolTip("SnapZoneFromWindow")
    global snap_zones
    WinGetPos, x, y, w, h, A ; Get the position and dimensions of the active window
    snap_zones[number] := { "x": x, "y": y, "w": w, "h": h }
    SaveSnapZones()
    ; ShowToolTip("Snap zone " number " set for the active window.")
}

; Snap active window to previously recorded position
SnapWindowToZone(number) {
    ShowToolTip("SnapWindowToZone")
    global snap_zones
    LoadSnapZones()
    zone := snap_zones[number]
    if (zone) {
        ; Move and resize the active window to the recorded position and dimensions
        WinMove, A,, % zone.x, % zone.y, % zone.w, % zone.h
    } else {
        ShowToolTip("No snap zone set for " number)
    }
}

; Function to load snap zones from file
LoadSnapZones() {
    ShowToolTip("LoadSnapZones")
    global snap_zone_repo
    global snap_zones
    if (FileExist(snap_zone_repo)) {
        FileRead, snap_zones_content, %filePath%
        snap_zones := JSON.Load(snap_zones_content)
        ShowToolTip("Snap zones loaded from file.")
    } else {
        snap_zones := {}
    }
}

; Function to save snap zones to a file
SaveSnapZones() {
    ; ShowToolTip("SaveSnapZones")
    global snap_zone_repo
    global snap_zones
    FileDelete, %snap_zone_repo%
    snap_zone_data := JSON.Dump(snap_zones)
    FileAppend, %snap_zone_data%, %snap_zone_repo%
    ; ShowToolTip("Snap zones saved to file.")
}
