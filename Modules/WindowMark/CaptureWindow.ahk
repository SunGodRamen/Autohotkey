#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

#Include, C:\Users\avons\Code\AutoHotkey\Library\Gdip_All.ahk

CaptureWindow(hwnd, screenshotDir, filename) {
    WinActivate, ahk_id %hwnd%  ; Make sure the window is active
    Sleep, 150  ; Wait a bit for the window to respond

    ; Send Alt + PrintScreen
    Send, {Alt down}
    Send, {PrintScreen}
    Send, {Alt up}
    Sleep, 300  ; Wait a bit longer for the clipboard to receive the image

    ; Save the image from the clipboard
    screenshotPath := screenshotDir . "\" . filename . ".png"
    
    IfNotExist, %screenshotDir%
        FileCreateDir, %screenshotDir%

    SaveClipboardImage(screenshotPath)
}

SaveClipboardImage(filePath) {
    pToken := Gdip_Startup()
    pBitmap := Gdip_CreateBitmapFromClipboard()
    if !pBitmap {
        MsgBox, Could not create bitmap from clipboard.
        return
    }

    Gdip_SaveBitmapToFile(pBitmap, filePath)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
}
