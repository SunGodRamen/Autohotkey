ShowToolTip(text, delay) {
    ToolTip, %text%
    SetTimer, RemoveToolTip, %delay%
}

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip