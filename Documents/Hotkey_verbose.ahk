/*
Hotkey Library for Autohotkey  **For educational purposes only** 
refactors for clarity have broken the class

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
; Base class for creating hotkeys. Handles the instantiation of different types of hotkeys.
Class Hotkey extends _Hk {
    ; Constructor for creating a new hotkey instance.
    __New(_keyName, _enabled:=true) {
        local
        global _HotkeyIt, _Hotkey

        ; Try to instantiate a new hotkey, either for joystick or keyboard based on the key name.
        try {
            if (InStr(_keyName, "Joy"))
                return new _HotkeyIt(_keyName, _enabled, -2) ; Instantiate a joystick hotkey.
            else 
                return new _Hotkey(_keyName, _enabled, -2) ; Instantiate a keyboard hotkey.
        } catch _exception {
            ; If an error occurs, throw an exception with the message and extra info.
            throw Exception(_exception.message, -1, _exception.extra)
        }
    }
}

; Derived class for joystick button hotkeys.
Class _HotkeyIt extends __Hotkey__ {
    ; Retrieves or creates a new keypress handler for the joystick button.
    _getKeypressHandler() {
        local
        global _JoyButtonKeypressHandler

        ; Use an existing keypress handler if available, otherwise create a new one.
        _inst := IsObject(this._keypressHandler)
        ? this._keypressHandler
        : new _JoyButtonKeypressHandler(this.getKeyName(), this.call.bind(this))
        return this._keypressHandler := _inst
    }

    ; Cleans up the resources associated with the hotkey.
    _dispose() {
        local
        _r := base._dispose() ; Dispose base class resources.
        return _r, this._keypressHandler._dispose() ; Dispose the keypress handler.
    }

    ; Placeholder for a method to validate and normalize the key name.
    _validateAndNormalize(_keyName) {
        return {value: _keyName} ; Returns the key name as-is for now.
    }

    ; Placeholder for a destructor method.
    __Delete() {
        ; Potential cleanup code commented out.
    }
}

; Derived class for keyboard hotkeys.
Class _Hotkey extends __Hotkey__ {
    ; Retrieves or creates a new keypress handler for the keyboard hotkey.
    _getKeypressHandler() {
        return this._keypressHandler := IsObject(this._keypressHandler) 
                                       ? this._keypressHandler 
                                       : this.call.bind(this)
    }

    ; Cleans up the resources associated with the hotkey.
    _dispose() {
        local
        _r := base._dispose() ; Dispose base class resources.
        return _r, this._keypressHandler := "" ; Reset the keypress handler.
    }

    ; Placeholder for a method to validate and normalize the key name.
    _validateAndNormalize(_keyName) {
        return {value: _keyName} ; Returns the key name as-is for now.
    }

    ; Placeholder for a destructor method.
    __Delete() {
        ; Potential cleanup code commented out.
    }
}

; =====================
; Abstract base class for specific hotkey types.
Class __Hotkey__ extends _Hk {
    _oKeyName := "" ; Original key name.
    _enabled := false ; Enabled state of the hotkey.
    _keypressHandler := "" ; Function to call when the hotkey is pressed.

    ; Constructor for the hotkey class.
    __New(_keyName, _enabled:=true, _excpLevel:="") {
        local _that := ""
        ; Validate and initialize the key name.
        try {
            this._oKeyName := this._validateAndNormalize(_keyName)
        } catch _exception {
            throw Exception(_exception.message, _excpLevel, _exception.extra)
        }
        this.onEvent() ; Placeholder for an event setup method.
        ; Initiate the base class constructor with the normalized key name and a placeholder instance.
        base.__New(this.getKeyName(), this, _that), (_that && _that._dispose())
        ; Enable or disable the hotkey based on the _enabled flag.
        this[ (!this._enabled:=!_enabled) ? "enable" : "disable" ]()
    }

    ; Placeholder for a key name validation and normalization method.
    _validateAndNormalize(_keyName) {
        ; Implementation needed.
    }

    ; Placeholder for obtaining a keypress handler.
    _getKeypressHandler() {
        ; Implementation needed.
    }

    ; Applies the hotkey with given command and options.
    _apply(_cmd:="", _options:="") {
        local
        global Hotkey
        static _dummy := Func("StrLen").bind("") ; Default dummy function.
        ; Set the keypress handler.
        _keypressHandler := (_cmd = "") ? _dummy : this._getKeypressHandler()
        ; Add options.
        _options .= A_Space . _cmd . A_Space . "T1 B0"
        ; Apply criteria and set the hotkey.
        this._applyCriteria()
        Hotkey % this.getKeyName(), % _keypressHandler, % _options
        return true
    }

    ; Disables the hotkey and cleans up resources.
    _dispose() {
        this.disable(), this._apply(), this._enabled:="", this.onEvent() ; Placeholder for event cleanup method.
    }

    ; Deletes the hotkey instance.
    delete() {
        local _inst := this._remove()
        return _inst, (IsObject(_inst) && _inst._dispose())
    }

    ; Enables the hotkey if it's disabled.
    enable() {
        if (this._enabled = 0)
            return this._apply("On"), this._enabled:=1
        return -1 ; Returns -1 if already enabled.
    }

    ; Disables the hotkey if it's enabled.
    disable() {
        if (this._enabled = 1)
            return this._apply("Off"), this._enabled:=0
        return -1 ; Returns -1 if already disabled.
    }

    ; Toggles the enabled state of the hotkey.
    toggle() {
        return this[ (this.isEnabled()) ? "disable" : "enable" ]()
    }

    ; Gets the normalized key name.
    getKeyName() {
        return this._oKeyName.value
    }

    ; Checks if the hotkey is enabled.
    isEnabled() {
        return this._enabled
    }

    ; Invokes the keypress handler with provided parameters.
    call(_p*) {
        this.__event.call(this, _p*)
    }

    ; Placeholder for the event setup method.
    onEvent(_args*) {
        ; Implementation needed.
    }

    ; Inner class for managing callback chains.
    Class _Callbacks {
        chain := [] ; List to hold callbacks.

        ; Constructor to initialize callback chain.
        __New(_args*) {
            local
            if not (ObjCount(_args))
                return this
            ; Validate and add each callback to the chain.
            for _i, _fn in _args {
                if not (IsObject(_fn) || _args[_i]:=Func(_fn)) {
                    throw Exception("Invalid callback.", -1)
                }
            }
            for _i, _fn in _args
                this.chain.push(_fn)
        }

        ; Calls each function in the callback chain with provided arguments.
        call(_args*) {
            local
            for _, _fn in this.chain
                %_fn%(_args*)
        }

        ; attach a callback to an instance of an object (_inst). 
        ; The _callee is the name of the event method that should be called,
        ;  and _args* is variadic additional args
        _on(_inst, _callee, _args*) {
            ; This line declares local variables that will be used within the method.
            ;  _functor will store the callback function, _exception will capture any
            ;  exceptions that occur, _classPath will be an array containing the parts 
            ; of the class name, _className will be the actual class name, and _obj will
            ;  be the instance of the class.
            local _functor, _exception, _classPath, _className, _obj
            ; StrSplit splits the __Class property of the current object (this) by periods,
            ;  which is typical when working with namespaced classes. The removeAt(1) removes
            ;  the first element of the array, which is often the namespace or a parent class name,
            ;  and assigns it to _className
            _classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
            ; This line determines what _obj should be. If there are any elements left in _classPath
            ;  after the removal, it uses the remaining path to get a reference to a class or object;
            ;  otherwise, it uses _className as a reference to a class or object. 
            ; This is a dynamic operation that's dependent on the content of _classPath
            _obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
            ; Here, the script tries to instantiate a new object of the class referenced by _obj,
            ;  passing along any arguments from _args*. The new object is assigned to _functor.
            ;  This is where the actual binding of the event to the callback occurs.
            try _functor:=new _obj(_args*)
            ; If an exception occurs during the instantiation, it's caught and then thrown 
            ; again with more context, ensuring that the script doesn't fail silently.
            catch _exception {
                throw Exception(_exception.message, -1, _exception.extra)
            }
            ;Finally, this line modifies the passed instance _inst by setting a property on it.
            ;  The property's name is determined by concatenating "__" with the _callee name 
            ; after removing the "on" prefix from it. This property is then set to _functor, 
            ; effectively storing the callback within the instance.
            _inst["__" . LTrim(_callee, "on")] := _functor
            ; In summary, this segment is meant to dynamically bind a callback method to 
            ; an object instance when a particular event occurs. It does this through some 
            ; complex reflection-like behavior, where it is manipulating class names and 
            ; instances at runtime
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
		global _Context
		this._criteria := _Context.getDefaultCriteria()
		this._criterion22 := _Context._criterion22
		this._criterion3 := _hotkey
		_criteria := this._criteria
		if (_subContext:=_Context._instances[ _criteria* ]) {
			_inst := _subContext[_hotkey]
		} else (_subContext:=_Context._instances[ _criteria* ]:={})
		_subContext[_hotkey] := _instance
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

; Class to handle joystick button press events with timed checks.

Class _JoyButtonKeypressHandler extends ObjBindTimedMethod {
    _ITERATOR_CONSUMMATION_DELAY := 0.35 ; Delay after which button press is considered consumed.
    _ITERATOR_PERIOD := 65 ; The period of time (in ms) between checks for button state.
    _running := false ; Flag to indicate if the handler is currently processing an event.

    ; Constructor sets up the state function and initializes the base object.
    __New(_keyName, _args*) {
        this._keyStateFn := Func("GetKeyState").bind(this._keyName:=_keyName) ; Get the state of the joystick button.
        base.__New(this, "call", false, _args*) ; Call the parent class's constructor.
    }

    ; Called when the button state changes, or periodically by the timer.
    call(_callback:="", _state:=-1, _args*) {
        static STATE_PRESS := -1 ; Constant for button press state.
        static STATE_UP := 0 ; Constant for button up state.
        static STATE_DOWN := 1 ; Constant for button down state.

        if (_state = STATE_UP) {
            this.kill(), this.args.2 := STATE_PRESS ; Kill the timer and set the state to press.
        } else if (_state = STATE_DOWN) {
            if (this._running) ; If already running, exit to prevent buffering.
                Exit
            if not (this._getKeyState()) ; If the button is not pressed, update state and restart the timer.
                return "", this.restart(10), this.args.2 := STATE_UP
        } else {
            this.kill() ; Stop the timer.
            _fn := this.args.1, %_fn%(_state, _args*) ; Call the callback function with the new state.
            if (this._keyWait()) { ; Wait for the button to be released.
                return this.args.2 := STATE_DOWN, this.restart(this._ITERATOR_PERIOD) ; Set the state to down and restart the timer.
            } else return "", this.restart(10), this.args.2 := STATE_UP ; Otherwise, set the state to up and restart the timer.
        }
        this._running := true, %_callback%(_state, _args*), this._running := false ; Call the callback and update the running flag.
    }

    ; Waits for the joystick button to change state.
    _keyWait() {
        KeyWait % this._keyName, % "T" . this._ITERATOR_CONSUMMATION_DELAY ; Wait with the given delay.
        return ErrorLevel ; Return the result of the wait.
    }

    ; Gets the current state of the joystick button.
    _getKeyState() {
        return this._keyStateFn.call() ; Call the state function.
    }
}

; Class to handle timed method calls for objects.
Class ObjBindTimedMethod {
    _iterating := false ; Flag to indicate if the timer is running.

    ; Constructor binds a method to an object and sets up a timer.
    __New(_obj, _method, _rawBindMode:=false, _args*) {
        if not (IsObject(_obj)) {
            throw Exception("Parameter #1 invalid.", -1) ; Ensure the first parameter is an object.
        }
        this.fn := (_rawBindMode) ? ObjBindMethod(_obj, _method) : _obj[_method].bind(_obj) ; Bind the method.
        this.args := _args ; Store the arguments.
        this._lpTimerFunc := RegisterCallback("ObjBindTimedMethod.__TIMERPROC", "F", 4, &this) ; Register the timer callback.
        ObjAddRef(&this) ; Add a reference to the object to prevent garbage collection.
    }

    ; Callback function that the timer calls.
    __TIMERPROC(_uMsg, _idEvent, _dwTime) {
        this := Object(A_EventInfo), _fn := this.fn, %_fn%(this.args*) ; Call the bound function with the stored arguments.
    }

    ; Restarts the timer with a new interval.
    restart(_uElapse:=250) {
        this.kill(), this.start(_uElapse) ; Kill the existing timer and start a new one.
    }

    ; Starts the timer.
    start(_uElapse:=250) {
        this._iterating := DllCall("SetTimer", "Ptr", 0, "UInt", 0, "UInt", _uElapse, "Ptr", this._lpTimerFunc) ; Set the timer with the specified interval.
    }

    ; Kills the timer if it is running.
    kill() {
        (this._iterating && (DllCall("KillTimer", "Ptr", 0, "UInt", this._iterating), this._iterating:=false)) ; Stop the timer.
    }

    ; Destructor to clean up the object.
    __Delete() {
        ; Potential code for cleanup when the object is deleted.
    }

    ; Disposes of the object by freeing the timer and releasing the reference.
    _dispose() {
        if (this._lpTimerFunc) {
            this.kill() ; Stop the timer.
            DllCall("GlobalFree", "Ptr", this._lpTimerFunc, "Ptr") ; Free the timer function.
            ObjRelease(&this) ; Release the object reference.
        }
        this.fn := this.args := "" ; Clear the function and arguments.
    }
}
