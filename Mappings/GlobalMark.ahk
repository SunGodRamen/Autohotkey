#Persistent
; Object to store window handles assigned to numbers
global windowMapping := {}

#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Util\Tooltip.ahk
#Include, C:\Users\avons\Code\Autohotkey\Library\VirtualDesktopAccessor.ahk
#Include, C:\Users\avons\Code\Autohotkey\config.ahk

; Create hotkeys
; Mark Window
Loop, 10 {
    hotkeyAssign := new Hotkey(mark_window_prefix A_Index - 1)
    hotkeyAssign.onEvent(Func("AssignWindowToNumber").Bind(A_Index - 1))
}

; Focus Mark
Loop, 10 {
    hotkeyFocus := new Hotkey(mark_focus_prefix A_Index - 1)
    hotkeyFocus.onEvent(Func("FocusWindowByNumber").Bind(A_Index - 1))
}

; Function to assign the current active window to a number
AssignWindowToNumber(number) {
    WinGet, activeHwnd, ID, A ; Get the hwnd (handle) of the active window
    if (activeHwnd) {
        windowMapping[number] := activeHwnd ; Assign the handle to the chosen number
        ; CaptureWindow(activeHwnd, screenshotDir, number)
        ShowToolTip("Window " activeHwnd " assigned to number " number)
    }
}

; Function to focus on the window assigned to a number
FocusWindowByNumber(number) {
    hwnd := windowMapping[number]
    if (hwnd) {
        if !WinExist("ahk_id " hwnd) {  ; Check if the window exists
            ; Get the current virtual desktop number
            currentDesktop := GetCurrentDesktopNumber()

            ; Get the virtual desktop number for the window
            windowDesktop := GetWindowDesktopNumber(hwnd)

            if (windowDesktop = -1) {
                ShowToolTip("Window assigned to number " number " does not exist.")
                return
            } else {
                GoToDesktopNumber(windowDesktop)
            }
        }

        ; Activate the window with the stored handle
        WinActivate, ahk_id %hwnd%
    } else {
        AssignWindowToNumber(number)
    }
}


