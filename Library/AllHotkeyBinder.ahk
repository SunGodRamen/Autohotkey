#SingleInstance force

#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk

; Class to bind all detectable keys to hotkeys that trigger the callback function
class AllHotkeyBinder {
    ; Constructor for the class
    __New(callback, pfx := "~*") {
        this.keys := {}
        this.Callback := callback
        this.Hotkeys := []
        
        ; Loop through all possible key codes
        Loop 512 {
            i := A_Index
            code := Format("{:x}", i)
            n := GetKeyName("sc" code)
            ; Skip if key name is not detected or already registered
            if (!n || this.keys.HasKey(n))
                continue
            this.keys[n] := code
            ; Bind the keydown event to the callback function using the Hotkey class
            this.RegisterHotkey(pfx, n, 1)
            ; Bind the keyup event to the callback function using the Hotkey class
            this.RegisterHotkey(pfx, n, 0)
        }
    }

    ; Helper function to register a hotkey
    RegisterHotkey(pfx, keyName, state) {
        ; Determine the event type (down or up)
        event := state ? "" : " up"
        ; Create a new Hotkey object
        hotkeyString := pfx . keyName . event
        hk := new Hotkey(hotkeyString)
        ; Bind the hotkey event to the KeyEvent method
        hk.onEvent(this.KeyEvent.Bind(this, this.keys[keyName], keyName, state))
        ; Store the hotkey object in the Hotkeys array for later reference
        this.Hotkeys.Push(hk)
    }

    ; Function called on key events, which in turn calls the passed callback function
    KeyEvent(code, name, state) {
        this.Callback.Call(code, name, state)
    }

    ; Destructor for the class to clean up hotkeys
    __Delete() {
        ; Loop through the stored Hotkey objects and delete them
        for index, hk in this.Hotkeys {
            hk.delete()
        }
    }
}
