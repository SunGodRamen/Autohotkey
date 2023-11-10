#SingleInstance force

; AutoHotkey Array Functions Library by GeekDude
; Source: https://autohotkey.com/board/topic/102444-array-functions/

; ArrayLength(arr)
;    - Returns the length of a numerically indexed array by counting its elements.
;    - Note: This function counts all elements, which may differ from MaxIndex() if the array has gaps or non-standard indexing.
;    - Example: length := ArrayLength([1, 2, , 4]) ; length will be 3; Whereas: length := MaxIndex([1, 2, , 4]) ; length will be 4

; Array_Print(Array)
;    - Visualizes an array in text format.
;    - Handles sub-arrays and associative arrays.
;    - Example: Array_Print({"A":["Aardvark", "Antelope"], "B":"Bananas"})

; Array_Gui(Array)
;    - Displays array contents in a resizable GUI treeview.
;    - Handles circular references with an error message.
;    - Example: Array_Gui({"GeekDude":["Smart", "Charming", "Interesting"], "tidbit":"Weird"})

; Array_DeepClone(Array)
;    - Creates a deep clone of an array.
;    - Supports sub-arrays and circular references.
;    - Example: Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}, Array2 := Array_DeepClone(Array1)

; Array_IsCircle(Array)
;    - Checks if an array has circular references.
;    - Average execution time: 0.023 seconds.
;    - Returns 1 for circular references, 0 otherwise.
;    - Example: Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}, Array2 := Array_Copy(Array1)

; Return the count of non-empty elements in the array
ArrayLength(arr) {
    count := 0
    for _ in arr {
        count++
    }
    return count
}

Array_Print(Array) {
if Array_IsCircle(Array)
        return "Error: Circular refrence"
    For Key, Value in Array
    {
        If Key is not Number
            Output .= """" . Key . """:"
        Else
            Output .= Key . ":"
        
        If (IsObject(Value))
            Output .= "[" . Array_Print(Value) . "]"
        Else If Value is not number
            Output .= """" . Value . """"
        Else
            Output .= Value
        
        Output .= ", "
    }
    StringTrimRight, OutPut, OutPut, 2
    Return OutPut
}
 

 
Array_Gui(Array, Parent="") {
    static
    global GuiArrayTree, GuiArrayTreeX, GuiArrayTreeY
    if Array_IsCircle(Array)
    {
        MsgBox, 16, GuiArray, Error: Circular refrence
        return "Error: Circular refrence"
    }
    if !Parent
    {
        Gui, +HwndDefault
        Gui, GuiArray:New, +HwndGuiArray +LabelGuiArray +Resize
        Gui, Add, TreeView, vGuiArrayTree
        
        Parent := "P1"
        %Parent% := TV_Add("Array", 0, "+Expand")
        Array_Gui(Array, Parent)
        GuiControlGet, GuiArrayTree, Pos
        Gui, Show,, GuiArray
        Gui, %Default%:Default
        
        WinWaitActive, ahk_id%GuiArray%
        WinWaitClose, ahk_id%GuiArray%
        return
    }
    For Key, Value in Array
    {
        %Parent%C%A_Index% := TV_Add(Key, %Parent%)
        KeyParent := Parent "C" A_Index
        if (IsObject(Value))
            Array_Gui(Value, KeyParent)
        else
            %KeyParent%C1 := TV_Add(Value, %KeyParent%)
    }
    return
    
    GuiArrayClose:
    Gui, Destroy
    return
    
    GuiArraySize:
    if !(A_GuiWidth || A_GuiHeight) ; Minimized
        return
    GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX * 2) " h" A_GuiHeight - (GuiArrayTreeY * 2)
    return
}
 

Array_DeepClone(Array, Objs=0)
{
    if !Objs
        Objs := {}
    Obj := Array.Clone()
    Objs[&Array] := Obj ; Save this new array
    For Key, Val in Obj
        if (IsObject(Val)) ; If it is a subarray
            Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
            ? Objs[&Val] ; Then point it to the new array
            : Array_DeepClone(Val,Objs) ; Otherwise, clone this sub-array
    return Obj
}
 
 
Array_IsCircle(Obj, Objs=0)
{
    if !Objs
        Objs := {}
    For Key, Val in Obj
        if (IsObject(Val)&&(Objs[&Val]||Array_IsCircle(Val,(Objs,Objs[&Val]:=1))))
            return 1
    return 0
}