#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk

 hk0 := new Hotkey("a")
 hk0.onEvent("myFunc")

 myFunc() {
    MsgBox, test
 }