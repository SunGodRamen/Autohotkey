; AltTab.ahk
SendMode, Input
#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk

Lalt_Ralt := new Hotkey("LAlt & RAlt")
Lalt_Ralt.onEvent("Send_AltTab")

Send_AltTab() {
    Send, {Alt Down}{Tab}
    return
}

Lalt_up := new Hotkey("LAlt up")
Lalt_up.onEvent("Send_AltUp")

Send_AltUp() {
    Send, {Alt Up}
    return
}
