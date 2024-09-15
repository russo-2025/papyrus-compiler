Scriptname Debug Hidden

; Note that these functions will do nothing in release console builds

; COC functionality
Function CenterOnCell(string asCellname) native global

; COC functionality
float Function CenterOnCellAndWait(string asCellname) native global

; player.moveto functionality
float Function PlayerMoveToAndWait(string asDestRef) native global

; Closes the specified user log
Function CloseUserLog(string asLogName) native global

; Outputs the string to a named debug channel (useful on the Xenon currently)
Function DebugChannelNotify(string channel, string message) native global

; Dumps all alias fill information for the quest to the AliasDump log in Logs/Script/
Function DumpAliasData(Quest akQuest) native global

; Returns the config name
string Function GetConfigName() native global

; Returns the platform name
string Function GetPlatformName() native global

; Returns the version number string
string Function GetVersionNumber() native global

; Displays an in-game message box
Function MessageBox(string asMessageBoxText) native global

; Displays an in-game notification
Function Notification(string asNotificationText) native global

; Opens a user log - fails if the log is already open
bool Function OpenUserLog(string asLogName) native global

; Quits the game
Function QuitGame() native global

; Toggles Foot IK on/off
Function SetFootIK(bool abFootIK) native global

; TGM functionality
Function SetGodMode(bool abGodMode) native global

; Forcibly sends an animation event to a reference's behavior graph
; used to bypass actor limitation on the ObjectReference version
Function SendAnimationEvent(ObjectReference arRef, string asEventName) native global

; Start profiing a specific script - setting doesn't persist across saves
; Will do nothing on release console builds, and if the Papyrus:bEnableProfiling ini setting is off
Function StartScriptProfiling(string asScriptName) native global

; Start profiling the calling stack - setting doesn't persist across saves
; Will do nothing on release console builds, and if the Papyrus:bEnableProfiling ini setting is off
Function StartStackProfiling() native global

; Stop profiling a specific script - setting doesn't persist across saves
; Will do nothing on release console builds, and if the Papyrus:bEnableProfiling ini setting is off
Function StopScriptProfiling(string asScriptName) native global

; Stop profiling the calling stack - setting doesn't persist across saves
; Will do nothing on release console builds, and if the Papyrus:bEnableProfiling ini setting is off
Function StopStackProfiling() native global

; Takes a screenshot (Xenon only)
Function TakeScreenshot(string asFilename) native global

; ToggleAI
Function ToggleAI() native global

; TCL functionality
Function ToggleCollisions() native global

; Toggles menus on/off
Function ToggleMenus() native global

; Outputs the string to the log
; Severity is one of the following:
; 0 - Info
; 1 - Warning
; 2 - Error
Function Trace(string asTextToPrint, int aiSeverity = 0) native global

; Outputs the current stack to the log
Function TraceStack(string asTextToPrint = "Tracing stack on request", int aiSeverity = 0) native global

; Outputs the string to a user log - fails if the log hasn't been opened
bool Function TraceUser(string asUserLog, string asTextToPrint, int aiSeverity = 0) native global

;Suppressable Trace
Function TraceConditional(string TextToPrint, bool ShowTrace) Global
{As Trace() but takes a second parameter bool ShowTrace (which if false suppresses the message). Used to turn off and on traces that might be otherwise annoying.}
;jduval
	if ShowTrace
		trace(TextToPrint)
	EndIf
EndFunction

Function TraceAndBox(string asTextToPrint, int aiSeverity = 0) global
{A convenience function to both throw a message box AND write to the trace log, since message boxes sometimes stack in weird ways and won't show up reliably.}
	;SJML
	MessageBox(asTextToPrint)
	Trace(asTextToPrint, aiSeverity)
EndFunction

; Used to add a tripod to a reference (non-release builds only)
Function ShowRefPosition(ObjectReference arRef) native global

;Prints out the players position to the database (non-release PC and Xenon builds only)
Function DBSendPlayerPosition() native global
