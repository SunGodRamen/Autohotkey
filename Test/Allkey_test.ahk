#SingleInstance force

#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk

recorderKeyName := "Insert"

; Class to bind all detectable keys to hotkeys that trigger the callback function
class AllHotkeyBinder {
    ; Constructor for the class
    __New(pfx := "~*") {
        this.keys := {}
        this.Hotkeys := []
        this.recorderKeyHeld := false
        this.recordedKeys := []

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

    ; Function called on key events, store keys while space is held
    KeyEvent(code, name, state) {
        if (name = "Space" && state = 1) { ; Spacebar pressed
            this.recorderKeyHeld := true
            this.recordedKeys := [] ; Initialize the list of recorded keys
        } else if (name = "Space" && state = 0) { ; Spacebar released
            this.recorderKeyHeld := false
            if (this.recordedKeys.MaxIndex() = "") { ; If no keys were recorded
                Send, {Space} ; Send space
            } else {
                for key, value in this.recordedKeys {
                    OutputDebug, %value%
                }
            }
            this.recordedKeys := [] ; Clear the recorded keys
        } else if (this.recorderKeyHeld && state = 1) { ; Key pressed while space is held
            this.recordedKeys.Push(name) ; Record the key name
        } else {
            ; Handle other key events when space is not held
            if (state = 1) { ; Key pressed and space not held
                Send, {%name% down} ; Send the key down event
            } else if (state = 0) { ; Key released and space not held
                Send, {%name% up} ; Send the key up event
            }
        }
    }

    ; Destructor for the class to clean up hotkeys
    __Delete() {
        ; Loop through the stored Hotkey objects and delete them
        for index, hk in this.Hotkeys {
            hk.delete()
        }
    }
}

allHotkeyBinder := new AllHotkeyBinder("*")