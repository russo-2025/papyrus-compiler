Scriptname Keyword Extends Form Hidden

; Sends this keyword as a story event to the story manager
Function SendStoryEvent(Location akLoc = None, ObjectReference akRef1 = None, ObjectReference akRef2 = None, int aiValue1 = 0, \
	int aiValue2 = 0) native

; Sends this keyword as a story event to the story manager and waits for it to be processed. Returns true if a quest was started.
bool Function SendStoryEventAndWait(Location akLoc = None, ObjectReference akRef1 = None, ObjectReference akRef2 = None, \
	int aiValue1 = 0, int aiValue2 = 0) native

; SKSE additions built 2015-05-24 00:46:48.937000 UTC
; return the keyword with the specified key
Keyword Function GetKeyword(string key) global native

; return the string value of the keyword
string Function GetString() native