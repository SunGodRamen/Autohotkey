#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#Include, C:\Users\avons\Code\AutoHotkey\Modules\WindowMark\MarkWindow.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Util\Tooltip.ahk

; Function to focus on the window assigned to a number
FocusWindowByNumber(number) {
    hwnd := windowMapping[number]
    if (hwnd) {
        if !WinExist("ahk_id " hwnd) {  ; Check if the window exists
            ShowToolTip("Window assigned to number " number " does not exist.")
            return
        }
        WinActivate, ahk_id %hwnd% ; Activate the window with the stored handle
    } else {
        AssignWindowToNumber(number)
    }
}