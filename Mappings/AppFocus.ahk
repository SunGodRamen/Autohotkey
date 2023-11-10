; AppFocus.ahk
#SingleInstance, Force
#Persistent

; Global arrays to track the windows for each application
global appWindows := []

; Global indices to track the current window for each application
global currentWindowIndex := 1

; Global variables to track the last hotkey press time and app
global lastHotkeyTime := 0
global lastHotkeyApp := ""
global timeoutMultiplier := 10

; Hotkey for Chrome
^!c::
    CycleAppWindows("chrome.exe", "ahk_exe chrome.exe", "chrome")
return

; Hotkey for VS Code
^!v::
    CycleAppWindows("C:\\Users\\avons\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe", "ahk_exe Code.exe", "vscode")
return

; Hotkey for Windows Terminal
^!t::
    CycleAppWindows("wt.exe", "ahk_exe WindowsTerminal.exe", "terminal")
return

CycleAppWindows(exeName, ahkQuery, appName) {
    ; Check if a different hotkey was pressed or if the timeout was reached
    if (appName != lastHotkeyApp || A_TickCount - lastHotkeyTime > (appWindows.Length() * timeoutMultiplier * 1000)) {
        ; Clear the appWindows array
        appWindows := []
        ; Get all application windows and sort by Z-order
        appWindows := GetAppWindows(ahkQuery)
        currentWindowIndex := 1 ; Start from 1
    }

    lastHotkeyApp := appName  ; Update the last hotkey app
    lastHotkeyTime := A_TickCount  ; Update the last time the hotkey was pressed

    ; If no application windows, launch the application
    if (appWindows.Length() = 0) {
        Run, %exeName%
    } else {
        ; Activate the window at the current index
        thisHwnd := appWindows[currentWindowIndex]
        WinActivate, ahk_id %thisHwnd%

        ; Move to next window for next press, and wrap if needed
        if (currentWindowIndex = appWindows.Length()) {
            currentWindowIndex := 1 ; Reset to the first window
        } else {
            currentWindowIndex++
        }
    }
}

GetAppWindows(ahk_query) {
    WinGet, allWindows, List, %ahk_query%

    windows := []

    ; First add non-minimized windows in z-order
    Loop, % allWindows {
        hwnd := allWindows%A_Index%
        if !WinMinimized(hwnd) {
            windows.Push(hwnd)
        }
    }

    ; Then add minimized windows
    Loop, % allWindows {
        hwnd := allWindows%A_Index%
        if WinMinimized(hwnd) {
            windows.Push(hwnd)
        }
    }

    return windows
}

WinMinimized(hwnd) {
    WinGet, winMinimized, MinMax, ahk_id %hwnd%
    return winMinimized = -1
}
