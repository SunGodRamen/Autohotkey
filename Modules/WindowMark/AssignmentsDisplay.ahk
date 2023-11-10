#Include, C:\Users\avons\Code\AutoHotkey\Library\Gdip_All.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Library\HtmlInterface.ahk

global globalBrowser

class WB_events
{}

global myEvents = new WB_Events()

; Start GDI+
if !pToken := Gdip_Startup() {
    MsgBox, Could not start GDI+.
    ExitApp
}

; Path to the screenshots directory and thumbnail directory
screenshotDir := "C:\Users\avons\Code\AutoHotkey\Modules\WindowMark\temp"
pageDir := screenshotDir "\page"
thumbnailDir := pageDir "\thumbnails"

; Ensure the thumbnail directory exists
FileCreateDir, %thumbnailDir%

; Start HTML string
html := ""

; Add thumbnail images and filenames to the HTML
Loop, Files, % screenshotDir "\*.png"
{
    ; Create a bitmap from the image file
    pBitmap := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
    ; Create a thumbnail
    pThumbnail := CreateThumbnail(pBitmap, 96, 96)
    ; Save the thumbnail as a new file in the thumbnail directory
    thumbFileName := A_Index . ".png" ; Use index for unique thumbnail filenames
    thumbPath := thumbnailDir . "\" . thumbFileName
    Gdip_SaveBitmapToFile(pThumbnail, thumbPath)
    
    ; Extract filename without extension
    fileNameWithoutExt := StrSplit(A_LoopFileName, ".")[1]

    ; Add an image tag for the thumbnail to the HTML string, including the filename without extension as a label
    ; html .= "<div style='display: inline-block; text-align: center; margin: 10px;'>"
    html .= "<img src='file:///" thumbPath "' alt='" A_LoopFileName "' style='margin-bottom: 5px;'>"
    html .= "<div style='color: white;'>" fileNameWithoutExt "</div>"
    ; html .= "</div>"

    ; Cleanup GDI+ objects
    Gdip_DisposeImage(pBitmap)
    Gdip_DisposeImage(pThumbnail)
}

; Specify the HTML file path where you want to save
htmlFilePath := pageDir . "\body.html"

; Delete the file if it already exists to avoid appending to old content
FileDelete, %htmlFilePath%

; Save the HTML content to the file
FileAppend, %html%, %htmlFilePath%

; Use the HtmlInterface class to display the thumbnails
htmlGui := new HtmlInterface("Thumbnail Viewer", pageDir, 900, 300, 250, 89, 100, globalBrowser, myEvents)
htmlGui.Show() ; Show the GUI

; Shut down GDI+ when the GUI is closed
OnExit, ExitSub
return

ExitSub:
    Gdip_Shutdown(pToken)
    htmlGui.Destroy()
    ExitApp
