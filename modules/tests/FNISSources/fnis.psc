Scriptname FNIS Hidden
; =============================================================================
; FNIS Alternate Animation  ===================================================
; =============================================================================

; =============================================================================
; FNIS.set_AACondition(actor ac, string AAtype, string mod, int AAcond, int AAdebug = 1)
; =============================================================================
; This function sets the (Behavior) AnimVariable responsible for selecting the
; desired Alternate Animation
; @param actor ac		- actor , for which condition has to be set
;				IMPORTANT: actor is set to 3rd person (player) / has to be 3Dloaded (NPC)
; @param string AAType	- AA type for which condition is set. 
;				See FNIS Documentation for modders. Currently supported:
;				"mt_loco_forward"
;				"mt_locomotion" (planned)
; @param string mod		- name of the FNIS mod (that defines the AA animations)
; @param int AAcond		- mod specific AA condition (1 <= AAcond <= 10)
; @param int AAdebug	- level of debug output
;				0 no output 
;				1 trace errors (default)
;				2 trace errors && trace AnimVar setting
; 				3 trace && notification of actor assignment
;				4 trace && notification && error messagebox
; @return int 			- result
;				-1 NPC not 3D loaded
;				-2 wrong AA type
;				-3 wrong AA condition (1 <= condition <= 10)
;				-4 mod not installed
;				0 could not set AAcondition (unknown cause)
;				>0 AA condition set


int Function set_AACondition(actor ac, string AAtype, string mod, int AAcond, int AAdebug = 1) global
	string AA_var
	string mod_var
	string s
	int iAA
	int ibase
	int iresult
	int iset
;	string acname = (ac.GetBaseObject() as ActorBase).Getname()
	string acname = (ac.GetBaseObject() as ActorBase)
	
	if ac == Game.GetPlayer()
		Game.ForceThirdPerson()
	elseif !ac.Is3DLoaded()
		AAReport(mod + "/FNIS Alternate Animation ERROR 1: 3D not loaded for " + acname, "", AAdebug)
		return -1
	endif
	
	iset = 0
	if ( AAtype == "mt_loco_forward" )
		iAA = 1
	elseif ( AAtype == "mt_locomotion" )
		iAA = 2
	else
		AAReport(mod + "/FNIS Alternate Animation ERROR 2: wrong AA type " + AAtype, "", AAdebug)
		return -2
	endif
	
	if ( AAcond < 0 ) || ( AAcond > 10 )
		AAReport(mod + "/FNIS Alternate Animation ERROR 3: wrong AA condition " + AAcond, "", AAdebug)
		return -3
	endif
	
	AA_var = "FNISvaa" + iAA
	mod_var = "FNISvaa_" + mod
	ibase = ac.GetAnimationVariableInt(mod_var)
	if ( ibase <= 0 )
;		AAReport(mod + "/FNIS Alternate Animation ERROR 4: AnimVar " + mod_var + " not defined. " + ac + " " + (ac.GetBaseObject() as ActorBase).Getname(), "", AAdebug)
		AAReport(mod + "/FNIS Alternate Animation ERROR 4: AnimVar " + mod_var + " not defined. " + ac + " " + (ac.GetBaseObject() as ActorBase), "", AAdebug)
		return -4
	endif
	
	if AAcond > 0
		iset = ibase + AAcond
	else
		iset = 0	; set to standard default
	endif
	ac.SetAnimationVariableInt(AA_var,iset)
	iresult = ac.GetAnimationVariableInt(AA_var)
	AAReport(mod + "/FNIS Alternate Animation: AnimVar " + AA_var + " set to " + iset + " for " + acname, "", AAdebug, false)
	AAReport("", mod +": " + acname + " " + AA_var + " " + iset, AAdebug)
	if ( iset != iresult )
		AAReport(mod + "/FNIS Alternate Animation ERROR 0: AnimVar " + AA_var + " cant be set", "", AAdebug)
		return 0
	endif

	return iset
endFunction

Function AAReport(string longReport, string shortReport, int AAdebug = 0, bool isError = true) global
	If ( AAdebug >= 1 )
		Debug.Trace(longReport, 0)
		If ( AAdebug >= 2 ) && ( shortReport != "" )
			Debug.Notification(shortReport)
			If ( AAdebug == 3 ) && isError
				Debug.Messagebox(longReport)
			endIf
		endIf
	endIf
endFunction


; =============================================================================
; FNIS Versioning =============================================================
; =============================================================================

; =============================================================================
; FNIS.IsGenerated() ==========================================================
; =============================================================================
; This function returns TRUE, if the last FNIS Generator run was with the
; currently installed FNIS version, and was successful.
; @return bool

bool function IsGenerated() global
	String VersInstall = FNISVersion.Get()
	String VersGenerated = FNISVersionGenerated.Get()

	Return ( VersInstall != "" ) && ( VersGenerated == VersInstall )
endFunction

; =============================================================================
; FNIS.VersionToString(bool abCreature = false) ===============================
; =============================================================================
; This function returns the concatenation of Major & minor versions as well
; as the version flags. A period (full stop) delimiter is used.
; @param bool abCreature - check FNIS Creature Pack version info. defaults to
;        false and FNIS Behavior version info.
; @return string - concatenated version info

string function VersionToString( bool abCreature = false ) global
;	if !IsGenerated()
;		Return ""
;	EndIf

	String VersInstall
	If abCreature
		VersInstall = FNISCreatureVersion.Get()
	Else
		VersInstall = FNISVersion.Get()
	EndIf
	
	If VersInstall == ""
		Return ""
	EndIf
	
	Int VMajor = StringUtil.SubString(VersInstall,1,2) as Int
	Int VMinor1 = StringUtil.SubString(VersInstall,4,2) as Int
	Int VMinor2 = StringUtil.SubString(VersInstall,7,2) as Int
	Int VFlags = StringUtil.SubString(VersInstall,10,1) as Int
	String Vers = "V" + VMajor + "." + VMinor1
	If VMinor2 != 0
		Vers = Vers + "." + VMinor2
	endIf
	If VFlags == 1
		Vers = Vers + " Alpha"
	ElseIf VFlags == 2
		Vers = Vers + " Beta"
	Else
		Vers = Vers + "." + VFlags
	EndIf

	Return Vers
endFunction

; =============================================================================
; FNIS.VersionCompare(int iCompMajor, int iCompMinor1, int iCompMinor2, bool abCreature = false)
; =============================================================================
; Compares the major, minor1 & minor2 versions ints passed as attributes to the
; current version of FNIS installed. This function returns an int reflecting
; the result of the comparision between Major, Minor1 & Minor2 version numbers.
; Note that FNISFlags values are not compared.
; @param int iCompMajor  - Major version
; @param int iCompMinor1 - Mminor1 version
; @param int iCompMinor2 - Mminor2 version
; @param bool abCreature - check FNIS Creature Pack version info. defaults to
;        false and FNIS Behavior version info.
; @return int - 0 = Both versions match
;  				1 = Installed version is newer/greater than the compared version
; 				-1 = Installed version is older/less than the compared version / No FNIS Version

int function VersionCompare( int iCompMajor, int iCompMinor1, int iCompMinor2, bool abCreature = false ) global
;	if !IsGenerated()
;		Return -1
;	EndIf

	String VersInstall
	If abCreature
		VersInstall = FNISCreatureVersion.Get()
	Else
		VersInstall = FNISVersion.Get()
	EndIf
	
	If VersInstall == ""
		Return -1
	EndIf

	Int VMajor = StringUtil.SubString(VersInstall,1,2) as Int
	Int VMinor1 = StringUtil.SubString(VersInstall,4,2) as Int
	Int VMinor2 = StringUtil.SubString(VersInstall,7,2) as Int
	if VMajor == iCompMajor
		if VMinor1 == iCompMinor1
			if VMinor2 == iCompMinor2
				return 0
			elseIf VMinor2 > iCompMinor2
				return 1
			else
				return -1
			endIf
		elseIf VMinor1 > iCompMinor1
			return 1
		else
			return -1
		endIf
	elseIf VMajor > iCompMajor
		return 1
	else
		return -1
	endIf
endFunction

; =============================================================================
; call FNIS.GetMajor(bool abCreature = false) =================================
; =============================================================================
; Major changes and upgrades
; @param bool abCreature - check FNIS Creature Pack version info. defaults to
;        false and FNIS Behavior version info.
; @return int - major version
int function GetMajor( bool abCreature = false ) global
;	if !IsGenerated()
;		Return 0
;	EndIf

	String VersInstall
	If abCreature
		VersInstall = FNISCreatureVersion.Get()
	Else
		VersInstall = FNISVersion.Get()
	EndIf
	
	If VersInstall == ""
		Return 0
	Else
		Return StringUtil.SubString(VersInstall,1,2) as Int
	EndIf
endFunction

; =============================================================================
; call FNIS.GetMinor1(bool abCreature = false) ================================
; =============================================================================
; Functional enhancements
; @param bool abCreature - check FNIS Creature Pack version info. defaults to
;        false and FNIS Behavior version info.
; @return int - minor1 version
int function GetMinor1( bool abCreature = false ) global
;	if !IsGenerated()
;		Return 0
;	EndIf

	String VersInstall
	If abCreature
		VersInstall = FNISCreatureVersion.Get()
	Else
		VersInstall = FNISVersion.Get()
	EndIf
	
	If VersInstall == ""
		Return 0
	Else
		Return StringUtil.SubString(VersInstall,4,2) as Int
	EndIf
endFunction

; =============================================================================
; call FNIS.GetMinor2(bool abCreature = false) ================================
; =============================================================================
; Bug fixes
; @param bool abCreature - check FNIS Creature Pack version info. defaults to
;        false and FNIS Behavior version info.
; @return int - minor2 version
int function GetMinor2( bool abCreature = false ) global
;	if !IsGenerated()
;		Return 0
;	EndIf

	String VersInstall
	If abCreature
		VersInstall = FNISCreatureVersion.Get()
	Else
		VersInstall = FNISVersion.Get()
	EndIf
	
	If VersInstall == ""
		Return 0
	Else
		Return StringUtil.SubString(VersInstall,7,2) as Int
	EndIf
endFunction

; =============================================================================
; call FNIS.GetFlags(bool abCreature = false) =================================
; =============================================================================
; Version flags.
; 0 = Release
; 1 = Alpha
; 2 = Beta
; @param bool abCreature - check FNIS Creature Pack version info. defaults to
;        false and FNIS Behavior version info.
; @return int - minor2 version
int function GetFlags( bool abCreature = false ) global
;	if !IsGenerated()
;		Return 3
;	EndIf

	String VersInstall
	If abCreature
		VersInstall = FNISCreatureVersion.Get()
	Else
		VersInstall = FNISVersion.Get()
	EndIf

	If VersInstall == ""
		Return 3
	Else
;SSE		Return StringUtil.SubString(VersInstall,10,1) as Int
		Return 0
	EndIf
endFunction

; =============================================================================
; call FNIS.IsRelease(bool abCreature = false) ================================
; =============================================================================
; Returns true if the installed FNIS version is flagged as a stable release.
; @param bool abCreature - check FNIS Creature Pack version info. defaults to
;        false and FNIS Behavior version info.
; @return bool
Bool function IsRelease( bool abCreature = false ) global
;	if !IsGenerated()
;		Return false
;	EndIf

	String VersInstall
	If abCreature
		VersInstall = FNISCreatureVersion.Get()
	Else
		VersInstall = FNISVersion.Get()
	EndIf
	
	If VersInstall == ""
		Return false
	Else
		Return StringUtil.SubString(VersInstall,10,1) == "0"
	EndIf
endFunction
