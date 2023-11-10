ShowToolTip(text) {
    ToolTip, %text%
    SetTimer, RemoveToolTip, 1500 ; Show tooltip for 1.5 seconds
}

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip