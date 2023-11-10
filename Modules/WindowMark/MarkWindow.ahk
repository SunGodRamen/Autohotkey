#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#Include, C:\Users\avons\Code\AutoHotkey\Modules\WindowMark\CaptureWindow.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Util\Tooltip.ahk

; Function to assign the current active window to a number
AssignWindowToNumber(number) {
    WinGet, activeHwnd, ID, A ; Get the hwnd (handle) of the active window
    if (activeHwnd) {
        windowMapping[number] := activeHwnd ; Assign the handle to the chosen number
        CaptureWindow(activeHwnd, screenshotDir, number)
        ShowToolTip("Window " activeHwnd " assigned to number " number)
    }
}