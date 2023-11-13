/*
	Class Hotkey
	Written by: Runar "RUNIE" Borge with help from A_AhkUser
	
	Usage: check out the example.
	
	Methods:
	__New(Key, Target [, Window, Type])		- create a new hotkey instance
	Key		- The key to bind
	Target	- Function referece, boundfunc or label name to run when Key is pressed
	Window	- *OPTIONAL* The window the hotkey should be related to
	Type		- *OPTIONAL* What context the hotkey has to the window (Active, Exist, NotActive, NotExist)
	
	Delete()		- Delete hotkey. Do this when you're done with the hotkey. It differs from Disable() since it releases the object the key is bound to.
	Enable()		- Enable hotkey
	Disable()		- Disable hotkey
	Toggle()		- Enable/Disable toggle
	
	Base object methods:
	Hotkey.GetKey(Key, Window [, Type])	- Parameters are the same as in __New() without the Target param.
	Hotkey.DeleteAll()		- Delete all hotkeys
	Hotkey.EnableAll()		- Enable all disabled hotkeys
	Hotkey.DisableAll()		- Disable all enabled hotkeys
*/

#Include, C:\Users\avons\Code\Autohotkey\Library\Logger.ahk
#Include, C:\Users\avons\Code\Autohotkey\Library\JSON.ahk
global hotkey_log := new Logger("DEBUG", "C:\Users\avons\Code\Autohotkey\Log\Hotkey.log")


; all methods return false on failure
Class Hotkey {
	static Keys := {} ; keep track of instances
	static KeyEnabled := {} ; keep track of state of hotkeys
	
	; create a new hotkey
	__New(Key, Target, Category := "", Window := false, Type := "Active") {
		hotkey_log.Message("INFO", "Instantiating key: " key)
		
		; check input
		if !StrLen(Window) {
			Window := false
		}
		if !StrLen(Key) {
			hotkey_log.Message("ERROR", "No key included")
			return false, ErrorLevel := 2
		}
		if !(Bind := IsLabel(Target) ? Target : this.CallFunc.Bind(this, Target)) {
			hotkey_log.Message("ERROR", "Couldnt bind function for " . this.Key)
			return false, ErrorLevel := 1
		}
		if !(Type ~= "im)^(Not)?(Active|Exist)$") {
			hotkey_log.Message("ERROR", "Type not recognized")
			return false, ErrorLevel := 4
		}
		
		; set values
		this.Key := Key
		this.Window := Window
		this.Type := Type
		this.Category := Category
		
		; enable if previously disabled
		if (Hotkey.KeyEnabled[Type, Window, Key] = false)
			this.Apply("On")
		
		; bind the key
		if !this.Apply(Bind) {
			hotkey_log.Message("ERROR", "Couldnt bind key")
			return false
		}
		
		this.Enabled := true ; set to enabled
		hotkey_log.Message("DEBUG", "Completed __New() instantiation with Key: " . this.Key . ", Window: " . this.Window . ", Type: " . this.Type)
		HotkeysObj_String := JSON.Dump(this.Keys, "", 4)
		FileDelete, C:\Users\avons\Code\Autohotkey\Resource\HotKeyObj.json
		FileAppend, %HotkeysObj_String%, C:\Users\avons\Code\Autohotkey\Resource\HotKeyObj.json
		return Hotkey.Keys[Type, Window, Key] := this
	}
	
	; 'delete' a hotkey. call this when you're done with a hotkey
	; this is superior to Disable() as it releases the function references
	Delete() {
		hotkey_log.Message("INFO", "Attempting to delete hotkey: " . this.Key)
		static JunkFunc := Func("WinActive")
		if this.Disable() {
			if this.Apply(JunkFunc) {
				hotkey_log.Message("DEBUG", "Deleted hotkey: " . this.Key)
				return true, Hotkey.Keys[this.Type, this.Window].Remove(this.Key)
			}
		}
		hotkey_log.Message("ERROR", "Failed to delete key")
		return false
	}
	
	; enable hotkey
	Enable() {
		hotkey_log.Message("INFO", "Enabling hotkey: " . this.Key)
		if this.Apply("On") {
			hotkey_log.Message("DEBUG", "Hotkey enabled: " . this.Key)
			return true, this.Enabled := true
		}
		hotkey_log.Message("ERROR", "Failed to enable key")
		return false
	}
	
	; disable hotkey
	Disable() {
		hotkey_log.Message("INFO", "Disabling hotkey: " . this.Key)
		if this.Apply("Off") {
			hotkey_log.Message("DEBUG", "Hotkey disabled: " . this.Key)
			return true, this.Enabled := false
		}
		hotkey_log.Message("ERROR", "Failed to disable key")
		return false
	}
	
	; toggle enabled/disabled
	Toggle() {
		hotkey_log.Message("INFO", "Toggling hotkey: " . this.Key)
		hotkey_log.Message("DEBUG", "Toggled hotkey: " . this.Key . " to " . (this.Enabled ? "Enabled" : "Disabled"))
		return this[this.Enabled ? "Disable" : "Enable"].Call(this)
	}
	
	; ===== CALLED VIA BASE OBJECT =====
	
	; enable all hotkeys
	EnableAll() {
		Hotkey.CallAll("Enable")
	}
	
	; disable all hotkeys
	DisableAll() {
		Hotkey.CallAll("Disable")
	}
	
	; delete all hotkeys
	DeleteAll() {
		Hotkey.CallAll("Delete")
	}
	
	; get a hotkey instance from it's properties
	GetKey(Key, Window := false, Type := "Active") {
		return Hotkey.Keys[Type, Window, Key]
	}
	
	; ===== PRIVATE =====
	
	Enabled[] {
		get {
			return Hotkey.KeyEnabled[this.Type, this.Window, this.Key]
		}
		
		set {
			return Hotkey.KeyEnabled[this.Type, this.Window, this.Key] := value
		}
	}
	
	CallFunc(Target) {
		hotkey_log.Message("INFO", "Hotkey: "  . this.Key . " Function triggered")
		Target.Call()
	}
	
	Apply(Label) {
		hotkey_log.Message("INFO", "Applying condition: " . this.Window . " to hotkey: " . this.Key)
		Hotkey, % "IfWin" this.Type, % this.Window ? this.Window : ""
		if (ErrorLevel) {
			hotkey_log.Message("ERROR", "Couldnt apply condition")
			return false
		}
		hotkey_log.Message("INFO", "Applying label: " . Label . " to hotkey: " . this.Key)
		Hotkey, % this.Key, % Label, UseErrorLevel
		if (ErrorLevel) {
			hotkey_log.Message("ERROR", "Couldnt apply label")
			return false
		}
		hotkey_log.Message("DEBUG", "Applied label: " . Label . " with result: " . (ErrorLevel ? "Error" : "Success"))
		return true
	}
	
	CallAll(Method) {
		Instances := []
		for Index, Type in Hotkey.Keys
			for Index, Window in Type
				for Index, Htk in Window
					Instances.Push(Htk)
		for Index, Instance in Instances
			Instance[Method].Call(Instance)
	}
}