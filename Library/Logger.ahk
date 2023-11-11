class Logger {
    LogLevels := { "ERROR": 1, "WARN": 2, "INFO": 3, "DEBUG": 4 }
    
    LogLevel := LogLevels.ERROR
    LogFile := 
    
    __New(logLevel, logFile) {
        ; Set the log level
        this.LogFile := logFile
        this.SetLogLevel(logLevel)
    }

    ValidateLogLevel(level) {
        if (level in "ERROR","WARN","INFO","DEBUG")
            return true
        if (RegExMatch(level,"^\d+$"))
            return true
        return false
    }

    ConvertLogLevel(level) {
        if (level in "ERROR","WARN","INFO","DEBUG")
            return this.LogLevels[level]
        return level
    }

    SetLogLevel(level) {
        if (level = "") {
            EnvGet, envLogLevel, AHK_LOG_LEVEL
            if (envLogLevel = "") {
                this.LogLevel := LogLevels.ERROR
            } else {
                this.LogLevel := envLogLevel
            }
        } else {
            if (!this.ValidateLogLevel(level)) {
                this.InternalError("Invalid log level provided: " . level)
                ExitApp
            }
            this.LogLevel := this.ConvertLogLevel(level)
        }
        level := this.LogLevel
        this.CreateEntry("INFO", "Log level set to: " . level)
    }

    InternalError(errorMsg) {
        if (errorMsg = "")
            return
        this.CreateEntry("ERROR", "Logger Internal Error: " . errorMsg)
    }
    
    ; Generalized log function
    Message(msg_log_level, msg) {
        current_log_level := this.LogLevel
        if (msg_log_level < current_log_level){
            this.CreateEntry(msg_log_level, msg)
        }
    }

    ; Actual log function that uses OutputDebugString
    CreateEntry(level, msg) {

        ; Get current timestamp
        FormatTime, currentTime,, yyyy-MM-dd HH:mm:ss
        
        ; Construct the log message with timestamp
        debug_log := currentTime . " " . "[" . level . "] - " . msg

        OutputDebug, %debug_log%
        
        log_file := this.LogFile
        if (log_file = "") {
            OutputDebug, "No Log File Specified"
            return
        }

        ; Log to file
        FileAppend, %debug_log%`n, %log_file%
    }

    ; Log the application exit
    ExitLog(exception, ExitCode) {
        errorMsg := "Script exited with error: " . exception . " and exit code: " . ExitCode
        this.CreateEntry("ERROR", errorMsg)
        return
    }

}
