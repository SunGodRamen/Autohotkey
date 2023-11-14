#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Util\Tooltip.ahk

class LeaderKey {
    active := false
    hotkeyObject := null
    timerMethod := null

    ; Constructor
    __New(hotkey_string, timeout := 1500) {
        this.hotkey_string := hotkey_string
        this.hotkeyObject := new Hotkey(hotkey_string)
        this.hotkeyObject.__event := ObjBindMethod(this, "HotkeyEvent")
        this.timerMethod := new ObjBindTimedMethod(this, "Reset")
        this.timeout := timeout
    }

    ; Method that handles the hotkey event
    HotkeyEvent() {
        ; If the leader key is not active, start the timer.
        if (!this.active) {
            this.active := true
            ; Start the timer with the bound method
            this.timerMethod.start(this.timeout)
            ShowToolTip(this.hotkey_string, this.timeout)
        }
    }

    ; Reset the leader key mode
    Reset() {
        this.active := false
        ; To turn off the timer, we must pass the same object as before
        this.timerMethod.kill()
    }

    ; Method to check if the leader key is active
    IsActive() {
        active := this.active
        return active
    }
}
