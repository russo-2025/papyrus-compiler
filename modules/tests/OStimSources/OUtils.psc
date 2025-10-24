ScriptName OUtils

OSexIntegrationMain Function GetOStim() Global
	quest q = game.GetFormFromFile(0x000801, "Ostim.esp") as quest
	return (q as OSexIntegrationMain)
EndFunction

Function Console(String In) Global
	MiscUtil.PrintConsole("OStim: " + In)
EndFunction

int Function GetTimeOfDay() global ; 0 - day | 1 - morning/dusk | 2 - Night
	float hour = GetCurrentHourOfDay()

	if (hour < 4) || (hour > 20 ) ; 8:01 to 3:59. night
		return 2
	elseif ((hour >= 18) && (hour <= 20))  || ((hour >= 4) && (hour <= 6)) ; morning/dusk
		return 1
	Else
		return 0
	endif
		
EndFunction

float Function GetCurrentHourOfDay() global
 
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	Return Time
 
EndFunction

Function RegisterForOUpdate(form f) Global
	(game.GetFormFromFile(0x000D67, "Ostim.esp") as OStimUpdaterScript).AddFormToDatabase(f)
EndFunction

Function ForceOUpdate() Global
	(game.GetFormFromFile(0x000D67, "OStim.esp") as OStimUpdaterScript).DoUpdate()
EndFunction


function StoreNPCDataFloat(actor npc, string keys, Float num) Global
	StorageUtil.SetFloatValue(npc as form, keys, num)
	;console("Set value " + num + " for key " + keys)
EndFunction

Float function GetNPCDataFloat(actor npc, string keys) Global
	return StorageUtil.GetFloatValue(npc, keys, -1.0)
EndFunction

function StoreNPCDataInt(actor npc, string keys, int num) Global
	StorageUtil.SetIntValue(npc as form, keys, num)
	;console("Set value " + num + " for key " + keys)
EndFunction

Int function GetNPCDataInt(actor npc, string keys) Global
	return StorageUtil.GetIntValue(npc, keys, -1)
EndFunction

function StoreNPCDataBool(actor npc, string keys, bool value) Global
	int store 
	if value 
		store = 1
	else 
		store = 0
	endif
	StoreNPCDataInt(npc, keys, store)
	;console("Set value " + store + " for key " + keys)
EndFunction

Bool function GetNPCDataBool(actor npc, string keys) Global
	int value = GetNPCDataInt(npc, keys)
	bool ret = (value == 1)
	;console("got value " + value + " for key " + keys)
	return ret
EndFunction

Bool Function IntArrayContainsValue(Int[] Arr, Int Val) Global
	return Arr.Find(Val) != -1
EndFunction

Bool Function StringArrayContainsValue(String[] Arr, String Val) Global
	return ( PapyrusUtil.CountString(Arr, Val) > 0)
EndFunction

bool Function StringContains(string str, string contains) Global
	return (StringUtil.Find(str, contains) != -1)
EndFunction

bool Function IsModLoaded(string ESPFile) Global
	return (Game.GetModByName(ESPFile) != 255)
Endfunction

float[] Function GetNodeLocation(actor act, string node) Global
	float[] ret = new float[3]
	NetImmerse.GetNodeWorldPosition(act, node, ret, false)
	return ret
EndFunction

int Function GetFloatMin(float[] arr) Global 
	int min = 0
	int i = 1 
	int l = arr.Length 
	while i < l 
		if arr[i] < arr[min]
			min = i 
		endif  
		i += 1 
	endwhile 

	return min 
EndFunction

int Function GetFloatMax(float[] arr) Global 
	int max = 0
	int i = 1 
	int l = arr.Length 
	while i < l 
		if arr[i] > arr[max]
			max = i 
		endif  
		i += 1 
	endwhile 

	return max
EndFunction

float Function ThreeDeeDistance(float[] pointSet1, float[] pointSet2) Global
	return math.sqrt( ((pointset2[0] - pointSet1[0]) * (pointset2[0] - pointSet1[0])) +  ((pointset2[1] - pointSet1[1]) * (pointset2[1] - pointSet1[1])) + ((pointset2[2] - pointSet1[2]) * (pointset2[2] - pointSet1[2])))
EndFunction

Function DisplayTextBanner(String Txt) Global
	UI.InvokeString("HUD Menu", "_root.HUDMovieBaseInstance.QuestUpdateBaseInstance.ShowNotification", Txt)
EndFunction

Function DisplayToastText(String Txt, float lengthOfTime) Global
	outils.Lock("mtx_toast")

	int handle =  UICallback.Create("HUD Menu", "_root.HUDMovieBaseInstance.ShowTutorialHintText")
	UICallback.PushString(handle, txt)
	UICallback.PushBool(handle, true)

	UICallback.Send(handle)

	Utility.wait(lengthOfTime)

	handle =  UICallback.Create("HUD Menu", "_root.HUDMovieBaseInstance.ShowTutorialHintText")
	UICallback.PushString(handle, txt)
	UICallback.PushBool(handle, false)

	UICallback.Send(handle)

	Utility.Wait(1.0)
	osanative.Unlock("mtx_toast")
EndFunction

Function HideTutorialText() Global
	int handle =  UICallback.Create("HUD Menu", "_root.HUDMovieBaseInstance.ShowTutorialHintText")
	UICallback.PushString(handle, "txt")
	UICallback.PushBool(handle, false)

	UICallback.Send(handle)

EndFunction

string Function KeycodeToKey(int keycode) Global
	int data = JValue.readFromFile("data/Interface/scanCodes/scancode.json")
	return JMap.GetStr(data, keycode)
endfunction 

int Function KeyToKeycode(string p_key) Global
	int data = JValue.readFromFile("data/Interface/scanCodes/scancode.json")
	int loc = jarray.findstr(jmap.allValues(data), p_key)
	return jmap.getnthkey(data, loc) as int
endfunction 

string Function GetButtontag(int keycode) Global
	string ret = "[" + KeycodeToKey(keycode) + "]"

	if keycode == 54
		ret = "R-" + ret 
	elseif keycode == 42
		ret = "L-" + ret 
	elseif keycode == 203
		ret = "Left-Arrow"
	elseif keycode == 205
		ret = "Right-Arrow"
	endif 

	return ret
endfunction 

bool Function IsChild(actor act) Global
	; Normally, we can just use act.ischild() to see if an actor is a child.
	; However, some mods unset this flag.
	; Note: OSA will automatically fail start scenes with child actors, so you don't have to use this to filter actors beforehand

	if act.IsChild()
		return true
	else 
		Race ActorRace  = OSANative.GetRace(OSANative.GetLeveledActorBase(act))
		string RaceName = OSANative.GetName(act) + MiscUtil.GetRaceEditorID(ActorRace)
		return StringContains(RaceName, "Child")
	endif
EndFunction 



Actor[] Function BaseArrToActorArr(ActorBase[] base) Global
	int l = base.Length
	int i = 0

	Actor[] ret = PapyrusUtil.ActorArray(l, filler = none)
	
	while i < l
		ret[i] = OSANative.GetActorFromBase(base[i])

		i += 1
	endwhile

	return ret
EndFunction

actor Function GetNPC(int id, string source = "skyrim.esm") Global
	actor ret = game.GetFormFromFile(id, source) as actor 
	if !ret
		console("----------------- Error getting npc " + id + source)
	endif 

	return ret 
EndFunction

; Cached natives
; After running once, the value is cached. Once cached a function will return in less than 1 ms instead of a full frame.
; However, note that the cached data is stored in the skse co-save which is sensitive to bloat. Be cautious about calling these on hundreds of
; NPCs.



; Normally, since this value can change dynamically, we would not want to cache this
; However, there is no way to get the 'original scale' of an actor after it has been changed without calling setscale(1.0) on them first
; (setscale is relative to the original scale while getscale always returns the true value, making it more confusing)
; This serves as a workaround, as long as nobody calls this (the first time) after setscale has been used!
;float Function GetScaleCached(actor in) Global
;	float cached = StorageUtil.GetFloatValue(in, "ostim_cache_scale",  missing = -2.0)
;	if cached != -2
;		return cached
;	else 
;		cached = (in.GetScale())
;		StorageUtil.SetFloatValue(in, "ostim_cache_scale",  cached)
;		return cached
;	endif 
;EndFunction

float Function GetOriginalScale(objectreference obj) Global
	return obj.GetScale() / OSANative.GetScaleFactor(obj)
EndFunction

Float Function TrigAngleZ(Float GameAngleZ) Global
	If (GameAngleZ < 90)
		 Return (90 - GameAngleZ)
	EndIf
 	Return (450 - GameAngleZ)
EndFunction

int[] Function BoolArrToIntArr(bool[] arr) Global 
	int l = arr.length
	int[] ret = PapyrusUtil.IntArray(l)
	int i = 0 
	while i < l 
		ret[i] = arr[i] as int

		i += 1
	endwhile

	return ret
EndFunction

form[] Function ObjRefArrToFormArr(objectreference[] arr) Global 
	int l = arr.length
	form[] ret = PapyrusUtil.FormArray(l)
	int i = 0 
	while i < l 
		ret[i] = arr[i] as form

		i += 1
	endwhile

	return ret
EndFunction

ObjectReference[] Function FormArrToObjRefArr(form[] arr) Global 
	int l = arr.length
	ObjectReference[] ret = PapyrusUtil.ObjRefArray(l)
	int i = 0 
	while i < l 
		ret[i] = arr[i] as ObjectReference

		i += 1
	endwhile

	return ret
EndFunction

Bool Function ChanceRoll(Int Chance) Global ; input 60: 60% of returning true
	return ( (OSANative.RandomInt(0, 99) ) < Chance)
EndFunction

string function FormatToDecimalPlace(float num, int DecimalPlacesToShow) Global
	string[] numString = StringUtil.Split(num as string, ".")
	numString[1] = StringUtil.Substring(numString[1], 0, DecimalPlacesToShow)

	return PapyrusUtil.StringJoin(numString, ".")
EndFunction

; in honor of this disaster: qz.com/646467/how-one-programmer-broke-the-internet-by-deleting-a-tiny-piece-of-code/
; a papyrus version
string function PadString(string str, int to, int side = 0, string char = " ") Global
	{fill the string with specified chars until it hits the specified length}
	int amount = to - stringutil.GetLength(str)

	if amount < 1
		return str 
	endif 

	string[] padding = PapyrusUtil.StringArray(amount, filler = char)

	if side == 0 ; right 
		string[] temp = PapyrusUtil.StringArray(1, str)

		padding = PapyrusUtil.MergeStringArray(temp, padding)
	elseif side == 1 ;left 
		padding = PapyrusUtil.PushString(padding, str)
	elseif side == 2 ; center
		string[] leftPad = PapyrusUtil.StringArray(amount/2, filler = char)
		string[] rightPad = PapyrusUtil.StringArray(amount - leftPad.Length , filler = char)

		padding = PapyrusUtil.PushString(leftpad, str)
		padding = PapyrusUtil.MergeStringArray(padding, rightpad)
	endif 

	return PapyrusUtil.StringJoin(padding, "")
EndFunction

form Function GetFormFromFile(int aiFormID, string asFilename) global
	{GetFormFromFile wrapper with error checking}
	form a = game.GetFormFromFile(aiFormID,  asFilename)

	if !a 
		debug.MessageBox("Error trying to get form: " + aiFormID + " from " + asFilename)
	endif 

	return a
endfunction 

bool Function MenuOpen() global
	return (Utility.IsInMenuMode() || UI.IsMenuOpen("console")) || UI.IsMenuOpen("Crafting Menu") || UI.IsMenuOpen("Dialogue Menu")
EndFunction

actor[] Function FilterToPlayerFollowers(actor[] acts) Global
	;faction followerfaction = Game.GetFormFromFile(0x05C84E, "Skyrim.esm") as faction

	int i = 0
	int l = acts.Length
	while i < l 
		if !acts[i].isplayerteammate()
			acts[i] = none
		endif 

		i += 1
	endwhile

	return PapyrusUtil.RemoveActor(acts, none)
EndFunction

bool Function IsInFirstPerson() global
	int cstate = game.GetCameraState()
	return (cstate == 0) ;|| ((cstate == 9))
EndFunction

Bool Function AppearsFemale(Actor Act) Global
	{gender based / looks like a woman but can have a penis}
	Return OSANative.GetSex(OSANative.GetLeveledActorBase(act)) == 1
EndFunction

Function SetSkyUIWidgetsVisible(bool visible) Global
	float val
	if visible
		val = 100.0
	else 
		val = 0.0
	endif 

	UI.SetNumber("HUD Menu", "_root.WidgetContainer._alpha", val)
EndFunction

Bool Function IsNaked(Actor NPC) global 
	Return (!(NPC.GetWornForm(0x00000004) as Bool))
EndFunction

Function SetUIVisible(bool visible) Global
	UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", visible)
EndFunction

bool Function IsUIVisible() Global
	return UI.GetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible")
endfunction 

objectreference Function GetBlankObject() Global
	return game.GetPlayer().PlaceAtMe((Quest.GetQuest("0SA") as _oOmni).OBlankStatic) as ObjectReference
EndFunction

Actor[] Function ShuffleActorArray(Actor[] arr) Global
    
    int i = arr.length
    int j ; an index

    actor temp
    While (i > 0)
        i -= 1
        j = osanative.RandomInt(0, i)

        temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp 

    EndWhile
    return arr
EndFunction

Function Lock(string mutex_key, float spinlockRate = 0.1) Global
	while !osanative.TryLock(mutex_key)
		utility.waitmenumode(spinlockRate)
	endwhile
EndFunction

string[] Function BlowjobClasses() Global
	string[] ret = new String[5]
	ret[0] = "BJ"
	ret[1] = "ApPJ"
	ret[2] = "HhPJ"
	ret[3] = "HhBJ"
	ret[4] = "VBJ"

	return ret
endfunction 

string[] Function HandjobClasses() Global
	string[] ret = new String[4]
	ret[0] = "ApHJ"
	ret[1] = "HJ"
	ret[2] = "VHJ"
	ret[3] = "DHJ"

	return ret
endfunction 

string[] Function CunnilingusClasses() Global
	string[] ret = new String[3]
	ret[0] = "VJ"
	ret[1] = "VBJ"
	ret[2] = "VHJ"

	return ret
endfunction 

string[] Function VagPlayClasses() Global
	string[] ret = new String[3]
	ret[0] = "Pf1"
	ret[1] = "Pf2"
	ret[2] = "Cr"

	return PapyrusUtil.MergeStringArray(ret, CunnilingusClasses())
endfunction 


string[] Function StringArray(string one = "", string two = "", string three = "", string four = "", string five = "", string six = "", string seven = "", string eight = "", string nine = "", string ten = "") Global
	if one == ""
		return PapyrusUtil.StringArray(0)
	elseif two == ""
		return PapyrusUtil.StringArray(1, one)
	elseif three == ""
		string[] ret = PapyrusUtil.StringArray(2)
		ret[0] = one 
		ret[1] = two 

		return ret 
	elseif four == ""
		string[] ret = PapyrusUtil.StringArray(3)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three

		return ret 
	elseif five == ""
		string[] ret = PapyrusUtil.StringArray(4)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 

		return ret 
	elseif six == ""
		string[] ret = PapyrusUtil.StringArray(5)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 
		ret[4] = five

		return ret 
	elseif seven == ""
		string[] ret = PapyrusUtil.StringArray(6)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 
		ret[4] = five
		ret[5] = six 

	elseif seven == ""
		string[] ret = PapyrusUtil.StringArray(6)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 
		ret[4] = five
		ret[5] = six 

		return ret 

	elseif eight == ""
		string[] ret = PapyrusUtil.StringArray(7)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 
		ret[4] = five
		ret[5] = six 
		ret[6] = seven

		return ret  
	elseif nine == ""
		string[] ret = PapyrusUtil.StringArray(8)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 
		ret[4] = five
		ret[5] = six 
		ret[6] = seven
		ret[7] = eight

		return ret  
	elseif ten == ""
		string[] ret = PapyrusUtil.StringArray(9)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 
		ret[4] = five
		ret[5] = six 
		ret[6] = seven
		ret[7] = eight
		ret[8] = nine

		return ret  
	else
		string[] ret = PapyrusUtil.StringArray(10)
		ret[0] = one 
		ret[1] = two 
		ret[2] = three
		ret[3] = four 
		ret[4] = five
		ret[5] = six 
		ret[6] = seven
		ret[7] = eight
		ret[8] = nine
		ret[9] = ten

		return ret 
	endif

EndFunction