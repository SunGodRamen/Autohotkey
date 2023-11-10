; KeyMap.ahk
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; Quit mapping: CTRL + ALT + WIN + SHIFT + Q
#Include, C:\Users\avons\Code\AutoHotkey\Mappings\ExitMapping.ahk

; Allows using the left and right Alt keys together to perform an Alt+Tab operation.
#Include, C:\Users\avons\Code\AutoHotkey\Mappings\AltTab.ahk

; Contains functions to cycle through application windows, update the current window index,
; and handle window activation.
#Include, C:\Users\avons\Code\AutoHotkey\Mappings\AppFocus.ahk

; Assign windows to number hotkeys dynamically
; CTRL + ALT + SHIFT + (NUMBER): ASSIGN
; CTRL + ALT + (NUMBER): FOCUS
Run, C:\Users\avons\Code\AutoHotkey\Mappings\GlobalMark.ahk

; Launch window spy and copy window information
#Include, C:\Users\avons\Code\AutoHotkey\Mappings\WinSpy.ahk
