#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey_debug.ahk
; #Include, C:\Users\avons\Code\AutoHotkey\Util\Tooltip.ahk

class LeaderKey {
    active := false
    timeout := 1500
    hotkeyObject := null
    timerMethod := null  ; This will hold our ObjBindTimedMethod object

    ; Constructor
    __New(hotkey) {
        ; this.hotkeyObject := new Hotkey(hotkey_string)
        this.hotkeyObject := hotkey
        this.hotkeyObject.__event := ObjBindMethod(this, "HotkeyEvent")
        this.timerMethod := new ObjBindTimedMethod(this, "Reset")
    }


    ; Method that handles the hotkey event
    HotkeyEvent() {
        ; If the leader key is not active, start the timer.
        if (!this.active) {
            this.active := true
            ; ShowToolTip("Leader Key Active", 2000)
            ; Start the timer using the ObjBindTimedMethod object
            this.timerMethod.start(this.timeout)
        } else {
            ; If the leader key was already active, handle the second key press here.
            ; Reset the leader key after handling.
            this.Reset()
        }
    }

    ; Reset the leader key mode
    Reset() {
        this.active := false
        ; ShowToolTip("Leader Key Inactive", 2000)
        ; Stop the timer as we're resetting the leader key
        this.timerMethod.kill()
    }

    ; Method to check if the leader key is active
    IsActive() {
        return this.active
    }
}
hk_leader := new Hotkey("LShift")
leaderKey := new LeaderKey(hk_leader)
; hk_test := new Hotkey("RShift")
; hk_test.onEvent("test_leaderkey")

test_leaderkey() {
    active := leaderKey.IsActive()
    if (active) {
        MsgBox, Leader Active
    } else {
        Msgbox, Leader Inactive
    }
}