#Include, C:\Users\avons\Code\AutoHotkey\Library\ArrayPlus.ahk
#Include, C:\Users\avons\Code\AutoHotkey\Library\JSON.ahk
/*
Hotkey Library for Autohotkey

 1. INCLUDE THE Hotkey CLASS:
    Before utilizing the Hotkey class, ensure that you include the file containing the class:

 2. BASIC USAGE:
    To assign a function to a specific key/button press:
 hk0 := new Hotkey("Joy4")
 hk0.onEvent("myFunc")

 3. USING CONDITIONS AND GROUPS:
    You can set groups and specific conditions for hotkeys:
    - Set a hotkey group:
 Hotkey.setGroup("testGroup")
    - Set a condition like the window should be active for the hotkey to work:
 Hotkey.IfWinActive("ahk_class Notepad")
    - Assign functions/methods to hotkeys under specific conditions:
 hk := new Hotkey("a")
 hk.onEvent(ObjBindMethod(instance, "method"))

 4. USING MULTIPLE CONDITIONS:
    You can set multiple conditions and functions/methods for the same hotkey:
 hk := new Hotkey("a", false)
 hk.onEvent("myFunc", ObjBindMethod(instance, "method"))

 5. EXCEPTIONS FOR CONDITIONS:
    Use `InTheEventNot` to provide exceptions to conditions:
 Hotkey.InTheEventNot("check")
 	hk2 := new Hotkey("Joy3")
   hk2.onEvent(ObjBindMethod(instance, "method2"), "myOtherFunc")

 6. TOGGLE HOTKEYS:
    Use keyboard shortcuts to enable or disable hotkeys:
 Hotkey.enableAll()                   ; Enable all hotkeys
 Hotkey.disableAll()                  ; Disable all hotkeys

 7. CONTROL INDIVIDUAL HOTKEYS:
 hk.disable()               ; Disable the hotkey
 hk.enable()                ; Enable the hotkey
 hk.toggle()                ; Toggle the hotkey on/off
 hk.getCriteria())          ; Get hotkey criteria
 hk.getKeyName()            ; Get hotkey name
 hk.isEnabled()             ; Get hotkey enabled state
 hk.delete()                ; Delete the hotkey
 hk := ""                   ; Clear the variable

 8. CUSTOM CLASSES AND FUNCTIONS:
    You can bind hotkey events to methods of your custom class or standalone functions:
    Class myClass: Contains `method` and `method2` to display tooltips
    myFunc and myOtherFunc: Standalone functions that display tooltips
*/

Class Hotkey extends _Hk {
	__New(_keyName, _enabled:=true) {
		local
		FileAppend, Entered Hotkey.__New`n, C:\Users\avons\Code\AutoHotkey\Test\HotkeyDebug.log
		global _HotkeyIt, _Hotkey
		try {
			if (InStr(_keyName, "Joy"))
				return new _HotkeyIt(_keyName, _enabled, -2)
			else return new _Hotkey(_keyName, _enabled, -2)
		} catch _exception {
			MsgBox, _exception.message
			throw Exception(_exception.message, -1, _exception.extra)
		}
		FileAppend, Exit Hotkey.__New`n, C:\Users\avons\Code\AutoHotkey\Test\HotkeyDebug.log
	}
}
Class _HotkeyIt extends __Hotkey__ {
	_getKeypressHandler() {
		local
		global _JoyButtonKeypressHandler
		_inst := IsObject(this._keypressHandler)
		? this._keypressHandler
		: new _JoyButtonKeypressHandler(this.getKeyName(), this.call.bind(this))
	return this._keypressHandler:=_inst
	}
	_dispose() {
	local
		_r := base._dispose()
	return _r, this._keypressHandler._dispose()
	}
	_validateAndNormalize(_keyName) { ; todo
	return {value: _keyName}
	}
	__Delete() {
		; WinActivate, ahk_class Notepad
		; WinWaitActive, ahk_class Notepad
		; ControlSend,, % "{Text}" . A_ThisFunc "," this.getKeyName() "`r`n", A
	}
}
; =======================================
Class _Hotkey extends __Hotkey__ {
	_getKeypressHandler() {
		FileAppend, Entering _Hotkey._getKeypressHandler`n, HotkeyDebug.log
		; Check if the _keypressHandler has already been set and is an object.
		if (IsObject(this._keypressHandler)) {
			; If it's already an object, log or display its information.
			handlerInfo := "Existing keypress handler: " (this._keypressHandler.Name ? this._keypressHandler.Name : "Anonymous")
			MsgBox, %handlerInfo%
			handlerObj := JSON.Dump(this._keypressHandler)
			MsgBox, %handlerObj%

			FileAppend, _Hotkey._getKeypressHandler name: %handlerInfo% object: %handlerObj% `n, HotkeyDebug.log
		} else {
			; If it's not set, bind the call method and log or display that information.
			this._keypressHandler := this.call.bind(this)
			FileAppend, Setting new keypress handler to bound 'call' method.`n, HotkeyDebug.log
		}
		FileAppend, Exiting _Hotkey._Keypresshandler`n, HotkeyDebug.log
		; Return the _keypressHandler.
		return this._keypressHandler
	}

	_dispose() {
	local
		_r := base._dispose()
	return _r, this._keypressHandler := ""
	}
	_validateAndNormalize(_keyName) { ; todo
	return {value: _keyName}
	}
	__Delete() {
		WinActivate, ahk_class Notepad
		WinWaitActive, ahk_class Notepad
		ControlSend,, % "{Text}" . A_ThisFunc "," this.getKeyName() "`r`n", A
	}
}
; =====================
Class __Hotkey__ extends _Hk {
	_oKeyName := ""
	_enabled := false
	_keypressHandler := ""
	__New(_keyName, _enabled:=true, _excpLevel:="") {
		local
		FileAppend, Entering __Hotkey__.__New`n, HotkeyDebug.log
		_that := ""
		try this._oKeyName := this._validateAndNormalize(_keyName)
		catch _exception {
			throw Exception(_exception.message, _excpLevel, _exception.extra)
		; return
		}
		this.onEvent()
		; base.__New(this.getKeyName(), this, _that), (_that && _that.delete()) ; +++
		base.__New(this.getKeyName(), this, _that), (_that && _that._dispose()) ; +++
		this[ (!this._enabled:=!_enabled) ? "enable" : "disable" ]()
		FileAppend, Exiting __Hotkey__.__New`n, HotkeyDebug.log
	}
	_validateAndNormalize(_keyName) {
	}
	_getKeypressHandler() {
	}
	
	_apply(_cmd:="", _options:="") {
		local 
		global Hotkey
		static _dummy := Func("StrLen").bind("") ; A dummy function for demonstration.
		FileAppend, Entering __Hotkey__._apply`n, HotkeyDebug.log
		
		; Determine whether to use the dummy handler or get the actual keypress handler.
		_keypressHandler := (_cmd = "") ? _dummy : this._getKeypressHandler()
		
		; Append additional options for the Hotkey command.
		_options .= A_Space . _cmd . A_Space . "T1 B0"
		
		; Debugging: Display the command and options before applying the hotkey.
		FileAppend, Applying hotkey with command:  %_cmd% `nOptions:  %_options% `n, HotkeyDebug.log
		
		; Apply any criteria set for the hotkey.
		this._applyCriteria()
		
		; Set up or modify the hotkey with the given handler and options.
		Hotkey % this.getKeyName(), % _keypressHandler, % _options
		
		; Re-apply criteria after setting up the hotkey (if necessary).
		Hotkey._applyCriteria() ; This line seems to indicate a class method, but it's not typical AHK syntax.
		
		; Debugging: Confirm that the hotkey setup has been attempted.
		keyname := this.getKeyName()
		FileAppend, Hotkey setup attempted for key:  %keyname% `n, HotkeyDebug.log
		
		return true
	}


	_dispose() {
	this.disable(), this._apply(), this._enabled:="", this.onEvent()
	}
	delete() {
		local
		_inst := this._remove()
	return _inst, (IsObject(_inst) && this._dispose())
	}
	enable() {
	if (this._enabled = 0)
		return this._apply("On"), this._enabled:=1
	return -1
	}
	disable() {
	if (this._enabled = 1)
		return this._apply("Off"), this._enabled:=0
	return -1
	}
	toggle() {
	return this[ (this.isEnabled()) ? "disable" : "enable" ]()
	}
	getKeyName() {
	return this._oKeyName.value
	}
	isEnabled() {
	return this._enabled
	}

	call(_p*) {
		FileAppend, Entering __Hotkey__.call`n, HotkeyDebug.log
		; Check if the __event property has been set to a function/method
		if (IsObject(this.__event)) {
			; If it's a function, display or log its name
			functionName := this.__event.Name ? this.__event.Name : "Anonymous"
			FileAppend, Event handler name:  %functionName% `n, HotkeyDebug.log
			; If it's a bound function, you may be able to extract more info depending on its properties
			if (functionName = "Anonymous" && this.__event.hasOwnProperty("Target")) {
				boundTargetName := this.__event.Target.Name ? this.__event.Target.Name : "Anonymous Target"
				FileAppend, Bound function target name:  %boundTargetName% `n, HotkeyDebug.log
			}
		} else {
			; If __event is not set to an object, log or display a warning
			FileAppend, __event is not set to a function/method.`n, HotkeyDebug.log
		}

		args_string := Array_Print(_p)
		args_len := _p.MaxIndex()
		MsgBox, % args_len " args passed to __Hotkey__.call: " args_string 
		FileAppend, %args_len% Arguments passed to __Hotkey__.call: %args_string%`n, HotkeyDebug.log

		; Continue with the existing functionality
		this.__event.call(this, _p*)
	}

	__event := ""
	onEvent(_args*) {
		FileAppend, Entering __Hotkey__.onEvent`n, HotkeyDebug.log
		; Retrieve the function's name or object definition.
		functionName := _args[1].hasOwnProperty("Bind") ? "BoundFunc" : _args[1].Name
		; Display the name of the function passed to onEvent.
		args_string := Array_Print(_args)
		args_len := _args.MaxIndex()
		MsgBox, % args_len " args passed to __Hotkey__.onEvent: " args_string 

		
		; If the function is a bound function, you can display more information.
		if (functionName = "BoundFunc") {
			boundFuncInfo := "Bound Function:`n"
			for key, value in _args[1] {
				boundFuncInfo .= key ": " value "`n"
			}
			FileAppend, boundFuncInfo:  %boundFuncInfo% `n, HotkeyDebug.log
		}
		
		; You can also log the function details to a file for analysis.
		FileAppend, Arguments passed to __Hotkey__.onEvent: %args_string%`n, HotkeyDebug.log
		
		; Call the original _Callbacks._on method with the provided arguments.
		return this._Callbacks._on(this, StrSplit(A_ThisFunc, ".").pop(), _args*)
	}

	Class _Callbacks {
		chain := []
		__New(_args*) {
			local
			if not (ObjCount(_args))
				return this
			for _i, _fn in _args {
				if not (IsObject(_fn) || _args[_i]:=Func(_fn)) {
					throw Exception("Invalid callback.", -1)
				; return
				}
			}
			for _i, _fn in _args
				this.chain.push(_fn)
		}

		call(_args*) {
			local 
			FileAppend, Entering _Callbacks.call`n, HotkeyDebug.log
			; Iterate over each function in the chain
			for index, _fn in this.chain {
				; Get the name of the function, if available
				functionName := IsObject(_fn) ? (_fn.Name ? _fn.Name : "Anonymous") : "Not an object"
				
				; Debugging: Display a message box with the function name and index
				FileAppend, Calling function  %index% :  %functionName% `n, HotkeyDebug.log

				; If _fn is an object and is a bound function, display more details
				if IsObject(_fn) && _fn.IsBoundFunc {
					; Get the target object's class name if possible
					targetClassName := _fn.Target.__Class ? _fn.Target.__Class : "Unknown Class"
					FileAppend, Bound function's target class:  %targetClassName% `n, HotkeyDebug.log
				}

				; Execute the function with the arguments
				try {
					%_fn%(_args*)
				} catch e {
					; If there's an error, show a message box with the error details
		            MsgBox, 16, "Error in callback", "An error occurred in callback #" index ":`nFunction: " functionName "`nError: " e.message
					; Throw, Exception(e.message)
				}
			}
		}

		_on(_inst, _callee, _args*) {
			local _functor, _exception, _classPath, _className, _obj
			FileAppend, Entering _Callbacks._on with _callee:  %_callee% `n, HotkeyDebug.log

			_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
			__class := this.__Class
			FileAppend, Class Path:  %__class% `nClass Name:  %_className% `n, HotkeyDebug.log

			_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
			FileAppend, % "Object reference: " (_classPath.count() > 0 ? "Namespaced" : "Direct") "`n", HotkeyDebug.log

			try {
				_functor := new _obj(_args*)
				FileAppend, % "Functor created successfully.`n", HotkeyDebug.log
			} catch _exception {
				FileAppend, % "Exception caught: " _exception.message "`n", HotkeyDebug.log
				throw Exception(_exception.message, -1, _exception.extra)
			}

			; Assuming that _callee is expected to be in the format "onEventName"
			; and the corresponding property to be "__EventName"
			propName := "__" . LTrim(_callee, "on")
			_inst[propName] := _functor
			FileAppend, % "Bound " propName " to functor.`nExiting _Callbacks._on`n", HotkeyDebug.log
		}

	}
}
Class _Hk extends _Context {
	InTheEvent(_param:="") {
		base._If(_param, false, true, -2)
	}
	InTheEventNot(_param:="") {
		base._If(_param, true, true, -2)
	}
	IfWinActive(_param:="") {
		base._IfWinX("WinActive", _param, false, -3)
	}
	IfWinNotActive(_param:="") {
		base._IfWinX("WinActive", _param, true, -3)
	}
	IfWinExist(_param:="") {
		base._IfWinX("WinExist", _param, false, -3)
	}
	IfWinNotExist(_param:="") {
		base._IfWinX("WinExist", _param, true, -3)
	}
	deleteAll(_group:="", _excpLevel:=-2, _exitReason_:="", _exitCode_:="") {
	static _ := OnExit(ObjBindMethod(Hotkey, "deleteAll", "", -2), -1)
		local base, _r := base._callAll("delete", _group, _excpLevel)
	return (A_ExitReason) ? 0 : _r
	}
	enableAll(_group:="") {
	return base._callAll("enable", _group, -2)
	}
	disableAll(_group:="") {
	return base._callAll("disable", _group, -2)
	}
}
Class _Context {
	static _instances := {}
	static _criteria := [ _Context.setGroup(A_Now), "If", Func("StrLen") ]
	static _criterion22 := ""
	_criterion3 := ""
	__New(_hotkey, _instance, ByRef _inst:="") {
		local
		FileAppend, Entering _Context.__New`n, HotkeyDebug.log
		global _Context
		this._criteria := _Context.getDefaultCriteria()
		this._criterion22 := _Context._criterion22
		this._criterion3 := _hotkey
		_criteria := this._criteria
		if (_subContext:=_Context._instances[ _criteria* ]) {
			_inst := _subContext[_hotkey]
		} else (_subContext:=_Context._instances[ _criteria* ]:={})
		_subContext[_hotkey] := _instance
		FileAppend, Exiting _Context.__New`n, HotkeyDebug.log
	}
	_remove() {
		local
		global _Context
		_subContext := _Context._instances[ this._criteria* ], _hotkey := this._criterion3
		if (_subContext.hasKey(_hotkey)) {
			_inst := _subContext[_hotkey]
		return _inst, _subContext.delete(_hotkey)
		}
		return -1
	}
	_callAll(_method, _group:="", _excpLevel:=-1) {
		local
		global _Context
		_count := 0

		if (StrLen(_group)) {
			if not (_Context._instances.hasKey(_group)) {
				throw Exception("The group does not exist.", _excpLevel, _group)
			; return
			}
			for _ifSubCmd, _subLevel in _Context._instances[_group] {
				for _param, _array in _subLevel {
					_enum := _array.clone()._newEnum()
					if (_enum.next(_hotkey, _obj)) {
						_obj._applyCriteria()
						Loop {
							_fn := _obj[_method], _r := _fn.call(_obj)
							ErrorLevel += !_count += (_r <> 0)
						} Until !(_enum[_hotkey, _obj])
					}
				}
			}
		} else {
			for _group, _root in _Context._instances {
				for _ifSubCmd, _subLevel in _root {
					for _param, _array in _subLevel {
						_enum := _array.clone()._newEnum()
						if (_enum.next(_hotkey, _obj)) {
							_obj._applyCriteria()
							Loop {
								_fn := _obj[_method], _r := _fn.call(_obj)
								ErrorLevel += !_count += (_r <> 0)
							} Until !(_enum[_hotkey, _obj])
						}
					}
				}
			}
		}
		_Context._applyCriteria()
	return _count
	}

	_applyCriteria() {
		local
		_fn := this._criterion22
		Hotkey, If, % _fn
	}
	getCriteria() {
	return [ this._criteria* ]
	}
	getDefaultCriteria() {
		local
		global _Context
	return [_Context._criteria*]
	}
	setGroup(_group:="") {
		local
		global _Context
		static _lastFoundGroup := ""
		if not (StrLen(_group))
			return _lastFoundGroup
		else {
		if not (_Context._instances.hasKey(_group))
			_Context._instances[_group] := {}
			_Context._criteria.1 := _lastFoundGroup := _group
		}
	return _group
	}

	_If(_param, _isNotVariant, _passHotkey, _excpLevel:="") {
		local
		global _Context
		if (_param <> "") {
			if not (IsObject(_param) || _param:=Func(_param)) {
				throw Exception("Parameter #1 invalid.", _excpLevel)
			; return
			}
			_params := [ this, _param, !_isNotVariant ], (!_passHotkey && _params.push(""))
			_uChecker := this.__upstreamChecker__.bind(_params*)
		} else _uChecker := ""
		_lastSetting := _Context._criterion22
		try {
			_Context._criterion22 := _uChecker, _Context._applyCriteria(_uChecker)
		} catch _exception {
			_Context._criterion22 := _lastSetting
			throw Exception(_exception.message, _excpLevel, _exception.extra)
		; return
		}
		_Context._criteria.2 := "InTheEvent" . ((_isNotVariant) ? "Not" : "")
		_Context._criteria.3 := _param
	}
	_IfWinX(_ifSubCmdVariant, _param, _isNotVariant, _excpLevel) {
		local
		global _Context
		_Context._If(Func(_ifSubCmdVariant).bind(_param:=(_param = "") ? "A" : _param), _isNotVariant, false, _excpLevel) ; +++
		_Context._criteria.2 := "IfWin" . ((_isNotVariant) ? "Not" : "") . LTrim(_ifSubCmdVariant, "IfWin")
		_Context._criteria.3 := _param
	}
		__upstreamChecker__(_fn, _boolean, _paramOrHotkey, _hotkeyOrSuperfluous:="") {
			if (!!%_fn%(_paramOrHotkey) <> _boolean)
				Exit
		return true
		}
}
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Class _JoyButtonKeypressHandler extends ObjBindTimedMethod {
	_ITERATOR_CONSUMMATION_DELAY := 0.35
	_ITERATOR_PERIOD := 65
	_running := false
	__New(_keyName, _args*) {
		this._keyStateFn := Func("GetKeyState").bind(this._keyName:=_keyName)
		base.__New(this, "call", false, _args*)
	}
	call(_callback:="", _state:=-1, _args*) {
		static STATE_PRESS := -1
		static STATE_UP := 0
		static STATE_DOWN := 1
		local
		if (_state = STATE_UP) {
			this.kill(), this.args.2 := STATE_PRESS
		} else if (_state = STATE_DOWN) {
			if (this._running) ; prevent buffering
				Exit
			if not (this._getKeyState())
				return "", this.restart(10), this.args.2 := STATE_UP
		} else {
			this.kill()
			_fn := this.args.1, %_fn%(_state, _args*)
			if (this._keyWait()) {
				return this.args.2 := STATE_DOWN, this.restart(this._ITERATOR_PERIOD)
			} else return "", this.restart(10), this.args.2 := STATE_UP
		}
		this._running := true, %_callback%(_state, _args*), this._running := false
	}
		_keyWait() {
			KeyWait % this._keyName, % "T" . this._ITERATOR_CONSUMMATION_DELAY
		return ErrorLevel
		}
		_getKeyState() {
		return this._keyStateFn.call()
		}
}
Class ObjBindTimedMethod {
	_iterating := false
    __New(_obj, _method, _rawBindMode:=false, _args*) {
		local
        if not (IsObject(_obj)) {
			throw Exception("Parameter #1 invalid.", -1)
		; return
		}
		this.fn := (_rawBindMode) ? ObjBindMethod(_obj, _method) : _obj[_method].bind(_obj)
		this.args := _args
		this._lpTimerFunc := RegisterCallback("ObjBindTimedMethod.__TIMERPROC", "F", 4, &this)
		ObjAddRef(&this)
    }
		__TIMERPROC(_uMsg, _idEvent, _dwTime) { ; https://msdn.microsoft.com/en-us/windows/desktop/ms644907
			local
			_hwnd := this
			this := Object(A_EventInfo), _fn := this.fn, %_fn%(this.args*) ; see for example https://www.autohotkey.com/boards/viewtopic.php?p=41220#profile235243
		}
	restart(_uElapse:=250) {
	this.kill(), this.start(_uElapse)
	}
	start(_uElapse:=250) {
	this._iterating := DllCall("SetTimer", "Ptr", 0, "UInt", 0, "UInt", _uElapse, "Ptr", this._lpTimerFunc)
	}
	kill() {
	(this._iterating && (DllCall("KillTimer", "Ptr", 0, "UInt", this._iterating), this._iterating:=false))
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}
	_dispose() {
		if (this._lpTimerFunc) {
			this.kill()
			DllCall("GlobalFree", "Ptr", this._lpTimerFunc, "Ptr")
			ObjRelease(&this)
		}
		this.fn := this.args := ""
	}
}