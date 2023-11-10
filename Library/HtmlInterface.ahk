; HtmlInterface Class:
; This class encapsulates the functionality of creating, managing, and interacting with HTML content within a GUI.
; The class allows customization of dimensions, positioning, and transparency. It includes events for navigation control
; and relies on specific HTML, CSS, and JS files provided in the directory.

; Note: must include the following objects in the calling class:
; no implementation needed
; global globalBrowser

; Define actions for when user interacts with a nav element
; class WB_events
; {
;     NavigateComplete2(wb, NewURL)
;     {
;         MsgBox, % "NavigateComplete2: " wb " " NewURL
;     }

;     BeforeNavigate2(wb, URL, Flags, TargetFrameName, PostData, Headers, Cancel)
;     {
;         MsgBox, % "BeforeNavigate2: " wb " " URL " " Flags " " TargetFrameName " " PostData " " Headers " " Cancel
;         Cancel := False
;     }
; }
; global myEvents = new WB_Events()

class HtmlInterface {
    Title := 
    GUIID :=
    Dim_X := 1600
    Dim_Y := 800
    Geo_X := 0
    Geo_Y := 0
    Trans := 160
    Shown := false
    WBEvents :=

    __New(title, pageDir, dim_x, dim_y, geo_x, geo_y, trans, ByRef globalBrowser, eventClassInstance) {
        ; Check if the pageDir path is valid
        if (!FileExist(pageDir . "\body.html")||!FileExist(pageDir . "\style.css")||!FileExist(pageDir . "\script.js")) {
            OutputDebug, Error, %pageDir% directory does not contain the required files. Please make sure the directory is correct.
            return, false
        }

        this.Title := title
        this.GUIID := 
        this.Dim_X := dim_x
        this.Dim_Y := dim_y
        this.Geo_X := geo_x
        this.Geo_Y := geo_y
        this.Trans := trans
        
        this.WBEvents := eventClassInstance ; Store the instance of the WB_events class

        ; Read HTML, CSS, and JS files
        FileRead, html, % pageDir . "\body.html"
        FileRead, css, % pageDir . "\style.css"
        FileRead, js, % pageDir . "\script.js"
        
        ; Combine HTML and CSS into a single HTML string
        html =
        (
        <!DOCTYPE html>
        <html>
            <style>
%css%
            </style>
            <head>
                <script>
%js%         
                </script>
            </head>
            <body>
%html%
            </body>
        </html>
        )

        Gui, New, , % this.Title ; Store the HWND in title
        Gui, -Caption
        Gui, Add, ActiveX, w%dim_x% h%dim_y% vglobalBrowser, Shell.Explorer

        globalBrowser.Navigate("about:blank")
        ComObjConnect(globalBrowser, this.WBEvents)
        globalBrowser.document.write(html)
        globalBrowser.document.close()
        this.GetWindowID()
    }

    GetWindowID(){
        title := this.Title
        Gui, Show
        WinGet, guiid, ID, %title%
        this.GUIID := guiid
        this.Hide()
    }

    Show() {
        guiid := this.GUIID    
        trans := this.Trans
        WinShow, ahk_id %guiid%
        WinSet, Transparent, %trans%, ahk_id %guiid%
        this.Shown := true
    }

    Hide() {
        guiid := this.GUIID      
        WinHide, ahk_id %guiid%
        this.Shown := false
    }

    Destroy() {
        guiid := this.GUIID
        WinClose, ahk_id guiid
    }
    
}