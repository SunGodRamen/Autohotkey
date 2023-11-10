
; Object to store window handles assigned to numbers
global windowMapping := {}
global screenshotDir := "C:\Users\avons\Code\AutoHotkey\Modules\WindowMark\temp"

#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Modules\WindowMark\MarkWindow.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Modules\WindowMark\FocusMark.ahk

; List all files in the screenshotDir
Loop, Files, % screenshotDir "\*.png", F
{
    ; Extract the index number from the filename
    fileNameIndex := RegExReplace(A_LoopFileName, "\D", "")
    
    ; Check if the index is represented in windowMapping
    if !windowMapping.HasKey(fileNameIndex) {
        ; If the index is not found in windowMapping, delete the file
        filePath := screenshotDir . "\" . fileNameIndex . ".png"
        FileDelete, %filePath%
        if ErrorLevel {  ; Check if there was an error during deletion
            MsgBox, An error occurred while trying to remove the file: %filePath%
        }
    }
}

; Create hotkeys
; Mark Window
Loop, 10 {
    hotkeyAssign := new Hotkey("^!+" A_Index - 1)
    hotkeyAssign.onEvent(Func("AssignWindowToNumber").Bind(A_Index - 1))
}

; Focus Mark
Loop, 10 {
    hotkeyFocus := new Hotkey("^!" A_Index - 1)
    hotkeyFocus.onEvent(Func("FocusWindowByNumber").Bind(A_Index - 1))
}
