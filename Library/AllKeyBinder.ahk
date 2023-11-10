#SingleInstance force

; Class to bind all detectable keys to hotkeys that trigger the callback function
class AllKeyBinder {
    ; Constructor for the class
    __New(callback, pfx := "~*") {
        keys := {}
        this.Callback := callback
        ; Loop through all possible key codes
        Loop 512 {
            i := A_Index
            code := Format("{:x}", i)
            n := GetKeyName("sc" code)
            ; Skip if key name is not detected or already registered
            if (!n || keys.HasKey(n))
                continue
            keys[n] := code
            ; Bind the keydown event to the callback function
            fn := this.KeyEvent.Bind(this, i, n, 1)
            hotkey, % pfx n, % fn, On
            ; Bind the keyup event to the callback function
            fn := this.KeyEvent.Bind(this, i, n, 0)
            hotkey, % pfx n " up", % fn, On
        }
    }

    ; Function called on key events, which in turn calls the passed callback function
    KeyEvent(code, name, state) {
        this.Callback.Call(code, name, state)
    }
}