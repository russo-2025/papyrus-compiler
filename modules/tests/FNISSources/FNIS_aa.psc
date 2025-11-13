Scriptname FNIS_aa Hidden

; =============================================================================
; bool FNIS_aa.SetAnimGroup(actor ac, string animGroup, int base, int number, string mod, bool debugOutput = false)
; bool FNIS_aa.SetAnimGroupEX(actor ac, string animGroup, int base, int number, string mod, bool debugOutput = false, bool skipForce3D = false)
; =============================================================================
; This function activates new custom versions for a group of alternate animations 
; by defining the appropriate animation variables, e.g "FNISaa_mtidle"
; It also sets an animgroup specific (e.g. "FNISaa_mtidle_crc") and an overall
; variables ("FNISaa_crc") with crc values needed for base adjustment on start. 
;
; "number" is between 0 and 9, which determines the number of the animations
; selected for this specific mod. It will always change the number for all anims
; of a group "animGroup" according to Alternate_Animations.txt. E.g. changing the
; number for the group "_1hmidle", will select 1hm_idle.hkx and sneak1hm_idle.hkx
;
; "base" is goup, mod, and installation specific value which will be added to
; "number" and reflect animations of another mod which come first in load order
;
; NOTE: the function GetGroupBaseValue to determine the base value can be VERY
; time consuming. If you intend to frequently set AA animation variables, it is
; recommended to calculate the base values only once OnInit and OnPlayerLoadGame
;
; This example will activate the animation fsm3_mt_idle.hkx for the player
; int myModID = FNIS_aa.GetAAmodID("fsm", "FNIS Sexy Move")	; "fsm" for FNIS Sexy Move
; int myBase = FNIS_aa.GetGroupBaseValue(myModID, FNIS_aa._mtidle(), "FNIS Sexy Move")
; bool result = FNIS_aa.SetAnimGroup(Game.GetPlayer(), "_mtidle", myBase, 3, "FNIS Sexy Move")
;
; @param actor			- actor
;		 animGroup		- name of the animgroup to be modified (e.g. "_mtidle")
;		 base			- load, mod and animgroup specific base value
;						  (see GetGroupBaseValue()
;		 number			- mod specific animation number (0 to 9)
;		 mod			- (full)full mod name (for error message and debug)
;		 debugOutput	- true to add debug output to logfile
;		 skipForce3D	- true (for trying) to set the animation variables without forcing 3rdp camera first.
;			Note: necessary if current cam state is unknown, but you want to avoid 3rdp change. You have to set once more when the user changes to 3rdp.  
; @return bool 			- false, if AnimVar could not be set

bool Function SetAnimGroup(actor ac, string animGroup, int base, int number, string mod, bool debugOutput = false) global
	return SetAnimGroupEX(ac, animGroup, base, number, mod, debugOutput, false)
endFunction

bool Function SetAnimGroupEX(actor ac, string animGroup, int base, int number, string mod, bool debugOutput = false, bool skipForce3D = false) global
	string skipText = ""
	if ( base >= 0 ) && ( number >= 0 ) && ( number <= 9 ) && ( ac != none )
		if ( ac == Game.GetPlayer() )
			if skipForce3D
				skipText = " skipforce3d: true"
			else
				Game.ForceThirdPerson()
			endif
		elseif !ac.is3dloaded()
			if debugOutput
				Debug.Trace("FNIS aa SetAnimGroup mod: " + mod + " actor: " + (ac.GetBaseObject() as ActorBase) + " not loaded.")
			endif
 			return false
		endif
		if debugOutput
			Debug.Trace("FNIS aa SetAnimGroup mod: " + mod + " actor: " + (ac.GetBaseObject() as ActorBase) + " group: " + animGroup + " base: " + base + " number: " + number + skipText)
		endif

		int value = base
		if ( base > 0 )
			value += number
		endif
		ac.SetAnimationVariableInt("FNISaa" + animGroup, value)
		
		int crc = FNIS_aa2.GetAAnumber(2)
		ac.SetAnimationVariableInt("FNISaa_crc", crc)
		ac.SetAnimationVariableInt("FNISaa" + animGroup + "_crc", crc)
		return true
	endif
	Debug.Trace("FNIS aa SetAnimGroup ERROR mod: " + mod + " actor: " + (ac.GetBaseObject() as ActorBase) + " group: " + animGroup + " base: " + base + " number: " + number + skipText)
	return false
endFunction



; =============================================================================
; int FNIS_aa.GetAAmodID(string myAAprefix, string mod, bool debugOutput = false)
; =============================================================================
; Function returns the AAmodID. myAAprefix is a 3 character abbreviation of
; the mod using the FNIS Alternate Animation functionality.
; This function can be timeconsuming. If you intend to frequently set the
; AA animation variables, it is recommended to calculate the AA prefix of your 
; mod only once OnInit and OnPlayerLoadGame
; Because this function can be lengthy, and the ID can change after each load,
; it is recommended to read the ID only once OnInit and OnPlayerLoadGame
; Note: the prefix strings are patched by the FNIS generator (instead of mm0 ..)
; @param myAAprefix		- 3 character AA prefix
;		 mod			- (full)full mod name (for error message and debug)
;		 debugOutput	- true to add debug output to logfile
; @return int 			- >=0 ID (for this load run only)
;						  -1 myAAprefix not defined (not included by generator)

int Function GetAAmodID(string myAAprefix, string mod, bool debugOutput = false) global
	int i = 0
	string[] AAPrefix

	int nMods = FNIS_aa2.GetAANumber(0)
	AAPrefix = FNIS_aa2.GetAAprefixList(nMods, mod)
	while ( i < nMods )
		if ( AAPrefix[i] == myAAprefix )
			if debugOutput
				Debug.Trace("FNIS aa GetAAmodID mod: " + mod + " prefix: " + myAAprefix + " modID:" + i)
			endif
			return i
		endif
		i += 1
	endWhile
	
	Debug.Trace("FNIS aa GetAAmodID - MOD MISSING (not included by FNIS generator) mod: " + mod + " prefix: " + myAAprefix)
	return -1
endFunction

; =============================================================================
; int FNIS_aa.GetGroupBaseValue(int AAmodID, int AAgroupID, string mod, bool debugOutput = false)
; =============================================================================
; Function returns the GroupBaseValue for the mod identified by AAmodID and
; and anim group identified by AAgroupID.
; The resulting base value has to be added to the mod's animation index when 
; setting the group specific animation variable
;
; This function can be timeconsuming. If you intend to frequently set the
; AA animation variables, it is recommended to calculate the base values
; only once OnInit and OnPlayerLoadGame
; @param AAmodID		- mod ID for the mod calculated by GetAAmodID()
;		 AAgroupID		- group ID for the animation group 
;		 mod			- (full)full mod name (for error message and debug)
;		 debugOutput	- true to add debug output to logfile
; @return int 			- >=1: base value for the mod and anim group 
;						- 0: not found / parameters wrong

int Function GetGroupBaseValue(int AAmodID, int AAgroupID, string mod, bool debugOutput = false) global
	if ( AAmodID < 0 ) ||  ( AAmodID > 29 ) || ( AAgroupID < 0 ) || ( AAgroupID > 53 )
		Debug.Trace("FNIS aa GetGroupBaseValue BAD parameter - mod: " + mod + "/" + " modID: " + AAmodID + " groupID:" + AAgroupID)
		return 0		; wrong parameter
	endif
	
	string[] AASet
	int nSets = FNIS_aa2.GetAANumber(1)
	AASet = FNIS_aa2.GetAAsetList(nSets, mod)

	int i = 0
	while i < nSets
		int Data = AASet[i] as int
		int Prefix = Data / 10000
		int Group = ( Data - Prefix * 10000 ) / 100
		if ( Group == AAgroupID )
			if ( Prefix == AAmodID )
				if debugOutput
					Debug.Trace("FNIS aa GetGroupBaseValue - mod/id:" + mod + "/" + AAmodID + " group:" + AAgroupID + " return:" + (Data - Prefix * 10000 - Group * 100))
				endif
				return (Data - Prefix * 10000 - Group * 100)	; the group's base value (if > 1)
			endif
		elseif ( Group > AAgroupID )
			i = nSets											; entry not found
		endif
		i += 1
	endWhile
		
	Debug.Trace("FNIS aa GetGroupBaseValueFNIS - Mod/Group DEFINITION MISSING (not included by FNIS generator) mod: " + mod + " modID:" + AAmodID + " group:" + AAgroupID)  
	return 0													; entry not found
endFunction


; =============================================================================
; int[] FNIS_aa.GetAllGroupBaseValues(int AAmodID, string mod, bool debugOutput = false)
; =============================================================================
; Function returns an array with the GroupBaseValues for ALL groups defined by
; the mod AAmodID. The resulting base values have to be added to all of the
; mod's animation indeces when setting the group specific animation variable
;
; This function can be timeconsuming, however less timeconsuming than calling
; GetGroupBaseValue() for 3 or more animation groups. It's recommended to call
; this function always OnInit and OnPlayerLoadGame.
; @param AAmodID		- AA prefix ID for the mod calculated by GetAAmodID()
;		 mod			- (full)full mod name (for error message and debug)
;		 debugOutput	- true to add debug output to logfile
; @return int[54]		- >=1: base value for the mod and anim group 
;						- 0: not found / parameters wrong

int[] Function GetAllGroupBaseValues(int AAmodID, string mod, bool debugOutput = false) global
	int[] GroupBaseValue
	GroupBaseValue = new int[54]
	if ( AAmodID < 0 ) ||  ( AAmodID > 29 )
		Debug.Trace("FNIS aa GetAllGroupBaseValues BAD parameter - mod/id:" + mod + "/" + AAmodID)
		return GroupBaseValue		; wrong parameter (all elements "0")
	endif
	
	if debugOutput
		;Debug.Trace("FNIS aa GetAllGroupBaseValues mod/id:" + mod + "/" + AAmodID)
	endif

	string[] AASet
	int nSets = FNIS_aa2.GetAANumber(1) 
	AASet = FNIS_aa2.GetAAsetList(nSets, mod)

	int i = 0
	while i < nSets
		int Data = AASet[i] as int
		int Prefix = Data / 10000
		int Group = ( Data - Prefix * 10000 ) / 100
		if ( Prefix == AAmodID )
			GroupBaseValue[Group] = (Data - Prefix * 10000 - Group * 100)
			if debugOutput
				Debug.Trace("FNIS aa GetAllGroupBaseValues - group:" + Group + " base:" + GroupBaseValue[Group])
			endif
		endif
		i += 1
	endWhile
	return GroupBaseValue
endFunction


; =============================================================================
; int FNIS_aa.GetInstallationCRC()
; =============================================================================
; Function returns a crc value for the current user installation.
; Whenever this value changes after game load, the mod's base values might have 
; changed and need to be re-loaded
; @return int			- crc value for thecurrent user installation

int Function GetInstallationCRC() global
	return FNIS_aa2.GetAANumber(2)
endFunction


; =============================================================================
; FNIS_aa.GetAAsets(int nSets, int[] GroupId, int[] ModId, int[] Base, int[] Index, string mod, bool debugOutput = false)
; =============================================================================
; Internal function returning all defined AA sets as 3 int arrays GroupId, ModId, base.
; A 4th array Index is returned, which defines the position of the first
; appearance of a group in GroupId[] (for faster access). 
; All values in Index[] are +1. 0 indicates that the group is not used. 
; @param nSets						- number of sets defined (in)
;		 GroupID[], ModId[], Base[]	- set values (out)
;		 Index[]					- position of first appearance of group
;									- all Index[] values are +1. 0: group is not used.
;		 mod			- (full)full mod name (for error message and debug)
;		 debugOutput	- true to add debug output to logfile

Function GetAAsets(int nSets, int[] GroupId, int[] ModId, int[] Base, int[] Index, string mod, bool debugOutput = false) global
	if ( debugOutput == debugOutput )				; for the time being: always output
		Debug.Trace("FNIS aa GetAAsets mod: " + mod + " nSets: " + nSets)
	endif

	string[] AASet = FNIS_aa2.GetAAsetList(nSets, mod)
	int[] MyIndex
	MyIndex = new int[54]

	int i = 0
	int lastGroup = -1
	while i < nSets
		int Data = AASet[i] as int
		ModId[i] = Data / 10000
		GroupId[i] = ( Data - ModId[i] * 10000 ) / 100
		Base[i] = ( Data - ModId[i] * 10000 - GroupiD[i] * 100 )
		if ( GroupId[i] != lastGroup )
			lastGroup = GroupId[i]
			Index[GroupId[i]] = i + 1			; all indices + 1 (0: group not used)
		endif
		i += 1
	endWhile
endFunction


; =============================================================================
; int FNIS_aa.<AA_groupname>()
; =============================================================================
; These functions return the int values of the 54 Alternate Animation Groups
; e.g FNIS_aa._2hmidle() returns 2
; @return int 			- 0 <= int value <= 53

int Function _mtidle() global
	return 0
endFunction

int Function _1hmidle() global
	return 1
endFunction

int Function _2hmidle() global
	return 2
endFunction

int Function _2hwidle() global
	return 3
endFunction

int Function _bowidle() global
	return 4
endFunction

int Function _cbowidle() global
	return 5
endFunction

int Function _h2hidle() global
	return 6
endFunction

int Function _magidle() global
	return 7
endFunction

int Function _sneakidle() global
	return 8
endFunction

int Function _staffidle() global
	return 9
endFunction

int Function _mt() global
	return 10
endFunction

int Function _mtx() global
	return 11
endFunction

int Function _mtturn() global
	return 12
endFunction

int Function _1hmmt() global
	return 13
endFunction

int Function _2hmmt() global
	return 14
endFunction

int Function _bowmt() global
	return 15
endFunction

int Function _magmt() global
	return 16
endFunction

int Function _magcastmt() global
	return 17
endFunction

int Function _sneakmt() global
	return 18
endFunction

int Function _1hmatk() global
	return 19
endFunction

int Function _1hmatkpow() global
	return 20
endFunction

int Function _1hmblock() global
	return 21
endFunction

int Function _1hmstag() global
	return 22
endFunction

int Function _2hmatk() global
	return 23
endFunction

int Function _2hmatkpow() global
	return 24
endFunction

int Function _2hmblock() global
	return 25
endFunction

int Function _2hmstag() global
	return 26
endFunction

int Function _2hwatk() global
	return 27
endFunction

int Function _2hwatkpow() global
	return 28
endFunction

int Function _2hwblock() global
	return 29
endFunction

int Function _2hwstag() global
	return 30
endFunction

int Function _bowatk() global
	return 31
endFunction

int Function _bowblock() global
	return 32
endFunction

int Function _h2hatk() global
	return 33
endFunction

int Function _h2hatkpow() global
	return 34
endFunction

int Function _h2hstag() global
	return 35
endFunction

int Function _magatk() global
	return 36
endFunction

int Function _1hmeqp() global
	return 37
endFunction

int Function _2hweqp() global
	return 38
endFunction

int Function _2hmeqp() global
	return 39
endFunction

int Function _axeeqp() global
	return 40
endFunction

int Function _boweqp() global
	return 41
endFunction

int Function _cboweqp() global
	return 42
endFunction

int Function _dageqp() global
	return 43
endFunction

int Function _h2heqp() global
	return 44
endFunction

int Function _maceqp() global
	return 45
endFunction

int Function _mageqp() global
	return 46
endFunction

int Function _stfeqp() global
	return 47
endFunction

int Function _shout() global
	return 48
endFunction

int Function _magcon() global
	return 49
endFunction

int Function _dw() global
	return 50
endFunction

int Function _jump() global
	return 51
endFunction

int Function _sprint() global
	return 52
endFunction

int Function _shield() global
	return 53
endFunction
