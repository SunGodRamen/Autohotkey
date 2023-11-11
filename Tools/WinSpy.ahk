; Hotkey to copy focused window information to clipboard
SPACEBAR := new Hotkey("Space")
SPACEBAR.onEvent("CopyWinInfo")

CopyWinInfo() {
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
    ExitApp, 0
}