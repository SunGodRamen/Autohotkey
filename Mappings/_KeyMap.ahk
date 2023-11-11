; KeyMap.ahk
#Persistent
#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk

; Assign windows to number hotkeys dynamically
; WIN + NUMPAD: ASSIGN
; NUMPAD: FOCUS
#Include, C:\Users\avons\Code\AutoHotkey\Mappings\GlobalMark.ahk

; Allows using the left and right Alt keys together to perform an Alt+Tab operation.
#Include, C:\Users\avons\Code\AutoHotkey\Mappings\AltTab.ahk

; Quit mapping: CTRL + ALT + WIN + SHIFT + Q
HYPER_Z := new Hotkey("^!#+z")
HYPER_Z.onEvent("Quit_Keymap")

Quit_Keymap() {
    ExitApp, 0
}