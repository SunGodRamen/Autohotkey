
SetFormat, Integer, Hex
Gui +ToolWindow -SysMenu +AlwaysOnTop
Gui, Font, s14 Bold, Arial
Gui, Add, Text, w200 h33 vKeyInfo +Border, {Key Info}
Gui, Show,, % "// Key Info //////////"
Loop 9
  OnMessage( 255+A_Index, "ScanCode" ) ; 0x100 to 0x108
Return

ScanCode( wParam, lParam ) {
    sc := (((lParam >> 16) & 0xFF) + 0xF000)
    keyName := GetKeyName("sc" sc)
    
    ; Display both scancode and key name in the GUI
    GuiControl,, KeyInfo, SC%sc% - %keyName%
    
    ; Optionally, you can copy the information to the clipboard
    Clipboard := sc
}

; Quit mapping: CTRL + ALT + WIN + SHIFT + Q
CTRL_ALT_K := new Hotkey("^!k")
CTRL_ALT_K.onEvent("Quit_KeySpy")

Quit_KeySpy() {
    ExitApp, 0
}
