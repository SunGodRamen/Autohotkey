#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include, C:\Users\avons\Code\Autohotkey\Test\Util\Validation.ahk

; Hotkey.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk

; Setup
global testKey_1 := "F1"
global testKey_2 := "F2"
global testKey_3 := "F3"
global testKey_4 := "F4"
global testKey_5 := "F5"
global testKey_6 := "F6"

global isTriggered := false

; Define a function for the test
TestFunction() {
    isTriggered := true
}

; Create the hotkey and bind the event
hk0 := new Hotkey(testKey_1)
hk0.onEvent("TestFunction")

MsgBox, Press %testKey_1% to validate.

; Verify that the function was triggered by the hotkey
AssertTrue(isTriggered, "Basic Usage: The hotkey should trigger the function.")

; Cleanup
hk0 := ""

; =================================================================

; Setup
global groupTriggered := false
Hotkey.setGroup("testGroup")
Hotkey.IfWinActive("ahk_class Notepad")
; Test
hk1 := new Hotkey(testKey_2)
hk1.onEvent("GroupTestFunction")

; Define a function for the test
GroupTestFunction() {
    groupTriggered := true
    ; Attempt to close Notepad
    WinClose, ahk_class Notepad

    return
}


Run, C:\Windows\Notepad.exe
WinWait, ahk_exe Notepad.exe

MsgBox, Focus on Notepad and press %testKey_2% to validate.

; Verify
AssertTrue(groupTriggered, "Conditions and Groups: The hotkey should trigger the function only if Notepad is active.")

; Cleanup
hk1 := ""

; ==============================================================

hk2 := new Hotkey(testKey_3)
hk3 := new Hotkey(testKey_4)

; Test
Hotkey.enableAll()
; Simulate condition and verify all hotkeys are enabled
AssertTrue(testKey_3.isEnabled(), "Toggle Hotkeys: All hotkeys should be enabled.")

Hotkey.disableAll()
; Simulate condition and verify all hotkeys are disabled
AssertFalse(testKey_1.isEnabled(), "Toggle Hotkeys: All hotkeys should be disabled.")

hk2 := ""
hk3 := ""

; ==============================================================

; Setup
hk4 := new Hotkey(testKey_5)

; Test Enable/Disable
hk4.disable()
AssertFalse(hk4.isEnabled(), "Control Individual Hotkeys: The hotkey should be disabled.")

hk4.enable()
AssertTrue(hk4.isEnabled(), "Control Individual Hotkeys: The hotkey should be enabled.")

; Test Toggle
hk4.toggle()
AssertFalse(hk4.isEnabled(), "Control Individual Hotkeys: The hotkey should be toggled off.")

; Test Getters
AssertEqual(hk4.getKeyName(), testKey_5, "Control Individual Hotkeys: The getKeyName should return the name of the key.")

hk4.IfWinActive("ahk_class Notepad")
AssertEqual(hk4.getCriteria(), "", "Control Individual Hotkeys: The getCriteria should return the set criteria.")

; Cleanup
hk4 := ""

; ==============================================================


hk5 := new Hotkey(testKey_6)
hk5.delete()

AssertEqual(hk5.getKeyName(), "", "Delete Hotkeys: The getKeyName should not return a deleted keyname.")


ExitApp, 0