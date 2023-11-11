#Persistent
#Include, C:\Users\avons\Code\AutoHotkey\Library\Hotkey.ahk
#Include, C:\Users\avons\Code\Autohotkey\config.ahk

global leaderKeyActive := false
leaderKeyTimeout := 1500

; Set the leader key (CapsLock in this case)
LeaderKey := new Hotkey(leader_key)
LeaderKey.onEvent("StartListenTimer").bind(leaderKeyTimeout)

StartListenTimer(timeout) {
    leaderKeyActive := true
    ; You can set a timer to reset the leader key mode after a certain period
    SetTimer, ResetLeaderKey, %timeout%
    return
}

; Define actions for keys following the leader key
#If (leaderKeyActive)

    a::
        MsgBox, Action A triggered!
        ResetLeaderKeyMode()
        return

    b::
        MsgBox, Action B triggered!
        ResetLeaderKeyMode()
        return

#If ; End conditional hotkeys

; Function to reset the leader key mode
ResetLeaderKey:
    leaderKeyActive := false
    SetTimer, ResetLeaderKey, Off
    return

; Helper function to reset the leader key mode
ResetLeaderKeyMode() {
    leaderKeyActive := false
    SetTimer, ResetLeaderKey, Off
}

