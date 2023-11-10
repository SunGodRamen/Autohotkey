#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; Hotkey to toggle Window Spy
^!w::
    ; The "ahk_exe AutoHotkey.exe" is not necessary here, as we can uniquely identify Window Spy by its class and title
    If WinExist("ahk_class AutoHotkeyGUI", "Window Spy")
    {
        WinClose
    }
    else
    {
        Run, "C:\Program Files\AutoHotkey\WindowSpy.ahk"  ; Adjust the path if necessary
    }
return

; Hotkey to copy focused window information to clipboard
^!+w::
    WinGetTitle, title, A  ; Gets the title of the active window
    WinGetClass, class, A  ; Gets the class of the active window
    WinGet, processPath, ProcessPath, A  ; Gets the path of the process of the active window
    WinGetPos, X, Y, Width, Height, A  ; Gets the position and size of the active window

    ; Format the window information
    clipboard = 
    (Join`r`n
Title: %title%
Class: %class%
Executable Path: %processPath%
Position: X: %X% Y: %Y%
Size: Width: %Width% Height: %Height%
    )
return