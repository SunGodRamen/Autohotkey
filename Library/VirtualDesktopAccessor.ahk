/*
Virtual Desktop Control Library for AutoHotkey
This script provides an interface to the VirtualDesktopAccessor.dll, which allows manipulation and querying 
of Windows 10/11 Virtual Desktops directly from AutoHotkey. 

This script loads the VirtualDesktopAccessor.dll and retrieves function pointers for efficient 
function calls. The script's functions serve as wrappers to these DLL functions, making it easier 
to interact with virtual desktops directly from AHK scripts.

NOTE: For setting desktop names with UTF-8 characters, ensure the AHK script is saved with UTF-8 with BOM.
*/

; Path to the DLL, relative to the script
VDA_PATH := "C:\Users\avons\Code\AutoHotkey\DLL\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

global GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")

global IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
global IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
global GetWindowDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetWindowDesktopNumber", "Ptr")
global GetWindowDesktopIdProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetWindowDesktopId", "Ptr")

global GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")

global IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
global PinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinWindow", "Ptr")
global UnPinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinWindow", "Ptr")

global IsPinnedAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedApp", "Ptr")
global PinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinApp", "Ptr")
global UnPinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinApp", "Ptr")

global GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName", "Ptr")
global SetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName", "Ptr")
global GetDesktopIdByNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopIdByNumber", "Ptr")
global GetDesktopNumberByIdProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopNumberById", "Ptr")

global CreateDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "CreateDesktop", "Ptr")
global RemoveDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RemoveDesktop", "Ptr")

; On change listeners
RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")

GetDesktopCount() {
    global GetDesktopCountProc
    desktopCount := DllCall(GetDesktopCountProc, "Int")
    return desktopCount
}

GetCurrentDesktopNumber() {
    global GetCurrentDesktopNumberProc
    currentDesktop := DllCall(GetCurrentDesktopNumberProc, "Int")
    return currentDesktop
}

MoveCurrentWindowToDesktop(desktopNumber) {
    global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc
    WinGet, activeHwnd, ID, A
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", desktopNumber, "Int")
    DllCall(GoToDesktopNumberProc, "Int", desktopNumber)
}

GoToPrevDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is 0, go to last desktop
    if (current = 0) {
        MoveOrGotoDesktopNumber(last_desktop)
    } else {
        MoveOrGotoDesktopNumber(current - 1)
    }
    return
}

GoToNextDesktop() {
    global GetCurrentDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is last, go to first desktop
    if (current = last_desktop) {
        MoveOrGotoDesktopNumber(0)
    } else {
        MoveOrGotoDesktopNumber(current + 1)
    }
    return
}

GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    DllCall(GoToDesktopNumberProc, "Int", num, "Int")
    return
}

MoveOrGotoDesktopNumber(num) {
    ; If user is holding down Mouse left button, move the current window also
    if (GetKeyState("LButton")) {
        MoveCurrentWindowToDesktop(num)
    } else {
        GoToDesktopNumber(num)
    }
    return
}

GetDesktopName(num) {
    global GetDesktopNameProc
    utf8_buffer := ""
    utf8_buffer_len := VarSetCapacity(utf8_buffer, 1024, 0)
    ran := DllCall(GetDesktopNameProc, "Int", num, "Ptr", &utf8_buffer, "Ptr", utf8_buffer_len, "Int")
    name := StrGet(&utf8_buffer, 1024, "UTF-8")
    return name
}

SetDesktopName(num, name) {
    ; NOTICE! For UTF-8 to work AHK file must be saved with UTF-8 with BOM

    global SetDesktopNameProc
    VarSetCapacity(name_utf8, 1024, 0)
    StrPut(name, &name_utf8, "UTF-8")
    ran := DllCall(SetDesktopNameProc, "Int", num, "Ptr", &name_utf8, "Int")
    return ran
}

CreateDesktop() {
    global CreateDesktopProc
    ran := DllCall(CreateDesktopProc)
    return ran
}

RemoveDesktop(remove_desktop_number, fallback_desktop_number) {
    global RemoveDesktopProc
    ran := DllCall(RemoveDesktopProc, "Int", remove_desktop_number, "Int", fallback_desktop_number, "Int")
    return ran
}

IsWindowOnCurrentVirtualDesktop(hwnd) {
    global IsWindowOnCurrentVirtualDesktopProc
    result := DllCall(IsWindowOnCurrentVirtualDesktopProc, "Ptr", hwnd, "Int")
    return result
}

IsWindowOnDesktopNumber(hwnd, desktopNumber) {
    global IsWindowOnDesktopNumberProc
    result := DllCall(IsWindowOnDesktopNumberProc, "Ptr", hwnd, "Int", desktopNumber, "Int")
    return result
}

GetDesktopIdByNumber(number) {
    global GetDesktopIdByNumberProc
    VarSetCapacity(desktopId, 16, 0)
    success := DllCall(GetDesktopIdByNumberProc, "Int", number, "Ptr", &desktopId, "UInt")
    if (success) {
        return desktopId
    }
    return 0 ; Return 0 if the function fails
}

GetDesktopNumberById(desktopId) {
    global GetDesktopNumberByIdProc
    desktopNumber := DllCall(GetDesktopNumberByIdProc, "Ptr", &desktopId, "Int")
    return desktopNumber
}

GetWindowDesktopId(hwnd) {
    global GetWindowDesktopIdProc
    VarSetCapacity(desktopId, 16, 0)
    success := DllCall(GetWindowDesktopIdProc, "Ptr", hwnd, "Ptr", &desktopId, "UInt")
    if (success) {
        return desktopId
    }
    return 0 ; Return 0 if the function fails
}

GetWindowDesktopNumber(hwnd) {
    global GetWindowDesktopNumberProc
    desktopNumber := DllCall(GetWindowDesktopNumberProc, "Ptr", hwnd, "Int")
    return desktopNumber
}

IsPinnedWindow(hwnd) {
    global IsPinnedWindowProc
    pinned := DllCall(IsPinnedWindowProc, "Ptr", hwnd, "Int")
    return pinned
}

PinWindow(hwnd) {
    global PinWindowProc
    success := DllCall(PinWindowProc, "Ptr", hwnd, "Int")
    return success
}

UnPinWindow(hwnd) {
    global UnPinWindowProc
    success := DllCall(UnPinWindowProc, "Ptr", hwnd, "Int")
    return success
}

IsPinnedApp(hwnd) {
    global IsPinnedAppProc
    pinned := DllCall(IsPinnedAppProc, "Ptr", hwnd, "Int")
    return pinned
}

PinApp(hwnd) {
    global PinAppProc
    success := DllCall(PinAppProc, "Ptr", hwnd, "Int")
    return success
}

UnPinApp(hwnd) {
    global UnPinAppProc
    success := DllCall(UnPinAppProc, "Ptr", hwnd, "Int")
    return success
}

RegisterPostMessageHook(listenerHwnd, messageOffset) {
    global RegisterPostMessageHookProc
    success := DllCall(RegisterPostMessageHookProc, "Ptr", listenerHwnd, "UInt", messageOffset, "Int")
    return success
}

UnregisterPostMessageHook(listenerHwnd) {
    global UnregisterPostMessageHookProc
    success := DllCall(UnregisterPostMessageHookProc, "Ptr", listenerHwnd, "Int")
    return success
}

FreeLibrary() {
    DllCall("FreeLibrary", "Ptr", hVirtualDesktopAccessor)
}