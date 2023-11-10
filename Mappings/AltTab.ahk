; AltTab.ahk

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

LAlt & RAlt::
    Send, {Alt Down}{Tab}
return

LAlt up::
    Send, {Alt Up}
return
