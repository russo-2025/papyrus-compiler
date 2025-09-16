ScriptName OSANative


; █████╗  ██████╗████████╗ ██████╗ ██████╗
; ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
; ███████║██║        ██║   ██║   ██║██████╔╝
; ██╔══██║██║        ██║   ██║   ██║██╔══██╗
; ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝


Int Function GetSex(ActorBase Base) Global Native
Race Function GetRace(ActorBase Base) Global Native
VoiceType Function GetVoiceType(ActorBase Base) Global Native
ActorBase Function GetLeveledActorBase(Actor Act) Global Native

; Get all loaded actors
; [CenterRef] ObjectReference as the origin for the search. (Optional)
; [Radius]    Radius to search for loaded actors. (Optional)
Actor[] Function GetActors(ObjectReference CenterRef = None, Float Radius = 0.0) Global Native

; For player only; set position without hitbox updating
Function SetPositionEx(Actor Act, Float X, Float Y, Float Z) Global Native

; Works on all NPCs that have a placed ref in the world
; Will not work on npcs spawned by script or 'placeatme'
; Most likely will not work on leveledlist npcs like bandits
; Returns the first one it finds
Actor Function GetActorFromBase(ActorBase Act) Global Native

; For example, give this an actor and the 'Spouse' AT and it will return their spouse's actorbase
; Returns none if the actor does not have that AT
; Works with all ATs
; returns an array because sometimes there may be multiple i.e. multiple kids or orcs having multiple spouses
ActorBase[] Function LookupRelationshipPartners(Actor FirstActor, AssociationType RelationshipType) Global Native

actor[] Function SortActorsByDistance(ObjectReference from, actor[] actors) Global Native
actor[] Function RemoveActorsWithGender(actor[] actors, int gender) Global Native

form[] Function GetEquippedAmmo(actor act) Global Native


;  ██████╗ █████╗ ███╗   ███╗███████╗██████╗  █████╗
; ██╔════╝██╔══██╗████╗ ████║██╔════╝██╔══██╗██╔══██╗
; ██║     ███████║██╔████╔██║█████╗  ██████╔╝███████║
; ██║     ██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██║
; ╚██████╗██║  ██║██║ ╚═╝ ██║███████╗██║  ██║██║  ██║
;  ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝


; Is FreeCam enabled
Bool Function IsFreeCam() Global Native

; Enable/Disable FreeCam
Function EnableFreeCam(Bool StopTime = False) Global Native
Function DisableFreeCam() Global Native

; Set FreeCam speed (default: 10.0)
Function SetFreeCamSpeed(Float Speed = 10.0) Global Native

; Set FOV
Function SetFOV(Float Value, Bool FirstPerson = False) Global Native

; Get camera coordinates
; Coordinates are relative to users screen right now, not recomended.
Float[] Function GetCameraPos() Global Native
Function SetCameraPos(Float X, Float Y, Float Z) Global Native


; ██████╗  █████╗ ████████╗ █████╗ ██████╗  █████╗ ███████╗███████╗
; ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
; ██║  ██║███████║   ██║   ███████║██████╔╝███████║███████╗█████╗
; ██║  ██║██╔══██║   ██║   ██╔══██║██╔══██╗██╔══██║╚════██║██╔══╝
; ██████╔╝██║  ██║   ██║   ██║  ██║██████╔╝██║  ██║███████║███████╗
; ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝


; Build the json database
Function BuildDB() Global Native


; ███████╗ █████╗  ██████╗███████╗
; ██╔════╝██╔══██╗██╔════╝██╔════╝
; █████╗  ███████║██║     █████╗
; ██╔══╝  ██╔══██║██║     ██╔══╝
; ██║     ██║  ██║╚██████╗███████╗
; ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝


Bool Function SetFace(Actor Act, Int Mode, Int ID, Int Value) Global Native
Int Function GetFace(Actor Act, Int Mode, Int ID) Global Native

; Does not reset Expression
Bool Function ResetFace(Actor Act) Global
	Return SetFace(Act, -1, 0, 0)
EndFunction

; Set Phoneme/Modifier
Bool Function SetFacePhoneme(Actor Act, Int ID, Int Value) Global
	Return SetFace(Act, 0, ID, Value)
EndFunction
Bool Function SetFaceModifier(Actor Act, Int ID, Int Value) Global
	Return SetFace(Act, 1, ID, Value)
EndFunction

; Get Phoneme/Modifier/Expression
Int Function GetFacePhoneme(Actor Act, Int ID) Global
	Return GetFace(Act, 0, ID)
EndFunction
Int Function GetFaceModifier(Actor Act, Int ID) Global
	Return GetFace(Act, 1, ID)
EndFunction
Int Function GetFaceExpression(Actor Act) Global
	Return GetFace(Act, 2, 0)
EndFunction

; Get Expression ID
Int Function GetFaceExpressionID(Actor Act) Global
	Return GetFace(Act, 3, 0)
EndFunction


;  ██████╗ ██████╗      ██╗███████╗ ██████╗████████╗
; ██╔═══██╗██╔══██╗     ██║██╔════╝██╔════╝╚══██╔══╝
; ██║   ██║██████╔╝     ██║█████╗  ██║        ██║
; ██║   ██║██╔══██╗██   ██║██╔══╝  ██║        ██║
; ╚██████╔╝██████╔╝╚█████╔╝███████╗╚██████╗   ██║
;  ╚═════╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝


Int Function GetFormID(Form FormRef) Global Native
Float Function GetWeight(Form FormRef) Global Native
String Function GetName(Form FormRef) Global Native
String Function GetDisplayName(ObjectReference ObjectRef) Global Native

; Find the nearest beds
; [CenterRef] ObjectReference as the origin for the search.
; [Radius]    Radius to search for beds.
; [SameFloor] Setting a value above 0 will set the tolerance threshold for the bed's height.
; Returns an array of beds from closest to farthest
ObjectReference[] Function FindBed(ObjectReference CenterRef, Float Radius = 1000.0, Float SameFloor = 0.0) Global Native

Float[] Function GetCoords(ObjectReference ObjectRef) Global Native

; Untested
Float Function GetScaleFactor(ObjectReference ObjectRef) Global Native

ObjectReference	Function GetLocationMarker(location loc) Global Native

form[] Function RemoveFormsBelowValue(form[] forms, int goldvalue) Global Native

; ██╗   ██╗████████╗██╗██╗
; ██║   ██║╚══██╔══╝██║██║
; ██║   ██║   ██║   ██║██║
; ██║   ██║   ██║   ██║██║
; ╚██████╔╝   ██║   ██║███████╗
;  ╚═════╝    ╚═╝   ╚═╝╚══════╝

Function ToggleCombat(bool a_enable) Global Native

Bool Function DetectionActive() Global Native

; Print text to console. Supports passing a translation key
Function PrintConsole(String a_str) Global Native

Int Function RandomInt(Int Min = 0, Int Max = 100) Global Native
Float Function RandomFloat(Float Min = 0.0, Float Max = 1.0) Global Native

; Send any event with no arguments
; Quests with "Run once" can never fire oninit again after install. until now.
Function SendEvent(Form FormRef, String Evnt) Global Native

; Experimental
;Form Function NewObject(String Classname) Global Native
;Function DeleteObject(Form FormRef) Global Native

; Mutex system
; See also: OUtils.lock() for a wrapper with while-loop lock
Bool Function TryLock(String a_lock) Global Native
{Returns true if nothing has claimed the given string, and claims the string. Returns false if the string is already claimed}
Function Unlock(String a_lock) Global Native
{Unclaims the given string}

; Experimental
String Function Translate(String a_key) Global Native
Function SetLocale(String a_locale = "") Global Native
