Scriptname FNIS_aaQuest2 extends Quest  

FNIS_aaQuest Property FNIS_Q Auto

string[] PrefixOld
int[] GroupIdOld
int[] ModIdOld
int[] BaseOld
int[] IndexOld
int nModsOld
int nSetsOld
int crcOld
int[] ModConv
bool[] isGroupChanged
int[] BaseChange			; -999: missing  0: unchanged  <0,>0: base change (old -> new)


Event OnInit()
	int i
	int j
	Debug.Trace("FNIS aa (load game) started")
	
	if !isRunning()
		return
	endif
	
	nModsOld = FNIS_Q.nMods
	nSetsOld = FNIS_Q.nSets
	crcOld = FNIS_Q.crc
	ModIdOld = new int[128]
	GroupIdOld = new int[128]
	BaseOld = new int[128]
	IndexOld = new int[128]
	PrefixOld = new string[30]
	MyCopy(GroupIdOld, FNIS_Q.GroupId, nSetsOld)
	MyCopy(ModIdOld, FNIS_Q.ModId, nSetsOld)
	MyCopy(BaseOld, FNIS_Q.Base, nSetsOld)
	MyCopy(IndexOld, FNIS_Q.Index, 54)
	i = 0
	while i < nModsOld
		PrefixOld[i] = FNIS_Q.Prefix[i]
		i += 1
	endwhile
		
	FNIS_Q.nMods = FNIS_aa2.GetAAnumber(0)
	FNIS_Q.nSets = FNIS_aa2.GetAAnumber(1)
	FNIS_Q.crc = FNIS_aa2.GetAAnumber(2)
	Debug.Trace("FNIS aa nMods:" + FNIS_Q.nMods + " nSets:" + FNIS_Q.nSets + " crc:" + FNIS_Q.crc + " crcOld:" + crcOld)
		
	FNIS_Q.Prefix = FNIS_aa2.GetAAprefixList(FNIS_Q.nMods, "FNIS aa", true)
	FNIS_aa.GetAAsets(FNIS_Q.nSets, FNIS_Q.GroupId, FNIS_Q.ModId, FNIS_Q.Base, FNIS_Q.Index, "FNIS aa", true)

	if ( FNIS_Q.crc == crcOld )
		return					; no changes after load
	endIf
	
	BaseChange = new int[128]
	isGroupChanged = new bool[54]
	
;	i = 0
;	Debug.Trace("FNIS aa Old Sets:")
;	while i < nSetsOld
;		Debug.Trace("  GroupIdOld: " + GroupIdOld[i] + " ModIdOld:" + ModIdOld[i] + " BaseOld: " + BaseOld[i])
;		i += 1
;	endWhile
;	i = 0
;	Debug.Trace("FNIS aa New Sets:")
;	while i < FNIS_Q.nSets
;		Debug.Trace("  GroupID: " + FNIS_Q.GroupId[i] + " ModId:" + FNIS_Q.ModId[i] + " Base: " + FNIS_Q.Base[i])
;		i += 1
;	endWhile
	
	; create conversion list (old modId -> new modId)

	ModConv = new int[30] 
	i = 0
	While ( i < nModsOld )
		string pref = PrefixOld[i]
		ModConv[i] = -1
		j = 0
		While ( j < FNIS_Q.nMods )
			if ( pref == FNIS_Q.Prefix[j] )
				ModConv[i] = j
				j = 30
			endif
			j += 1
		endWhile
		i += 1
	endWhile

	string s = "FNIS aa ModConv " + nModsOld + ":"
	i = 0
	while i < nModsOld
		s += " " + ModConv[i]
		i += 1
	endwhile
	Debug.Trace(s)
	
	; find out, which set definitions have changed after load (missing, or base different)
	; mark the group, and calculate the base change

;	Debug.Trace("FNIS AA Check all old sets --------------------")
	
	i = 0
	while i < nSetsOld
		j = FNIS_Q.Index[GroupIdOld[i]] - 1
;		Debug.Trace("FNIS AA check " + i + " group/mod/base " + GroupIdOld[i] + "/" + ModIdOld[i] + "/" + BaseOld[i] + " IndexNew " + j)
		if ( j >= 0 )
			while j < FNIS_Q.nSets
				if ( GroupIdOld[i] == FNIS_Q.GroupId[j] )
;					Debug.Trace("FNIS AA check - same group. Mod Old " + ModIdOld[i] + " ModConv " + ModConv[ModIdOld[i]] + " ModNew " + FNIS_Q.ModId[j])
					int ModIdConv = ModConv[ModIdOld[i]]
					if ( ModIdConv < 0 )							; mod unistalled
						BaseChange[i] = -999
;						Debug.Trace("FNIS AA check - mod uninstalled")
						j = 128
					elseif ( ModIdConv == FNIS_Q.ModId[j] )		; same mod
;						Debug.Trace("FNIS AA check - same mod. BaseOld " + BaseOld[i] + " BaseNew " + FNIS_Q.Base[j])
						if ( BaseOld[i] != FNIS_Q.Base[j] )		; but different base
							isGroupChanged[GroupIdOld[i]] = true
							BaseChange[i] = FNIS_Q.Base[j] - BaseOld[i]
							j = 128
;							Debug.Trace("FNIS AA check - same mod, base change " + i + ": " + BaseChange[i])
						endif
					endif
				else
					j = 128											; next group
				endif
				j += 1
			endWhile
			i += 1
		endif
	endWhile

	
	; data to determine necessary changes is ready -> set flag
	; start with player to apply changes
	FNIS_Q.bConvDataReady = true
	UpdateAAvariables(Game.GetPlayer())
	
	RegisterForSingleUpdate(5.0)				; register for self destruction
endEvent

event OnUpdate()
	FNIS_Q.bConvDataReady = false
	Stop()										; work is done (even for NPCs) -> self destruct
endEvent

Function MyCopy(int[] ToAr, int[] FromAr, int n)
	int i
	while i < n
		ToAr[i] = FromAr[i]
		i += 1
	endwhile
endFunction

Function UpdateAAvariables(actor ac)
	int i
	while ( i < 54 )															; for all groups
		if isGroupChanged[i]
			string GroupName = GetGroupName(i)
			int AVvalue = ac.GetAnimationVariableInt("FNISaa" + GroupName)
			if ( AVvalue > 0 )													; Actor has group AV set
				if ( ac.GetAnimationVariableInt("FNISaa" + GroupName + "_crc") != FNIS_Q.crc )		; but only if this set was before the last load
					int j = IndexOld[i] - 1
;Debug.Trace("FNIS AA animvar set " + ac.GetBaseObject().GetName() + " FNISaa" + GroupName + ": " + AVvalue + " IndexOld: " + j)
					int change
					if ( j >= 0 )
						while ( j < nSetsOld )										; search for (possible) base change
							if ( j == 127 )
								change = BaseChange[j]
							elseif ( ( GroupIdOld[j] != GroupIdOld[j+1] ) || ( AVvalue <= BaseOld[j+1] ) )
;Debug.Trace("Change condition. j " + j + " GroupIdOld[j] " + GroupIdOld[j] + " GroupIdOld[j+1] " + GroupIdOld[j+1] + " AVvalue " + AVvalue + " BaseOld[j+1] " + BaseOld[j+1] + " BaseChange[j] " + BaseChange[j] + " Index " + IndexOld[GroupIdOld[j]]) 
								change = BaseChange[j]
								j = 127
							endif
							j += 1
						endWhile
					else
						change = -999
					endif
					if ( change == -999 )
;						Debug.Trace("FNIS AA update " + ac.GetBaseObject().GetName() + " FNISaa" + GroupName + " " + AVvalue + " to 0")
						Debug.Trace("FNIS AA update " + ac.GetBaseObject() + " FNISaa" + GroupName + " " + AVvalue + " to 0")
						ac.SetAnimationVariableInt("FNISaa" + GroupName, 0)
						ac.SetAnimationVariableInt("FNISaa" + GroupName + "_crc", FNIS_Q.crc )
					elseif ( change != 0 )
;						Debug.Trace("FNIS AA update " + ac.GetBaseObject().GetName() + " FNISaa" + GroupName + " " + AVvalue + " to " + (AVvalue + change))
						Debug.Trace("FNIS AA update " + ac.GetBaseObject() + " FNISaa" + GroupName + " " + AVvalue + " to " + (AVvalue + change))
						ac.SetAnimationVariableInt("FNISaa" + GroupName, AVvalue + change)
						ac.SetAnimationVariableInt("FNISaa" + GroupName + "_crc", FNIS_Q.crc )
					endif
				endif
			endif
		endif
		i += 1
	endWhile
			
endFunction


string Function GetGroupName(int i)
	if ( i < 16 )
		if ( i < 4 )
			if ( i == 0 )
				return "_mtidle"
			elseif ( i == 1 )
				return "_1hmidle"
			elseif ( i == 2 )
				return "_2hmidle"
			else
				return "_2hwidle"
			endif
		elseif ( i < 8 )
			if ( i == 4 )
				return "_bowidle"
			elseif ( i == 5 )
				return "_cbowidle"
			elseif ( i == 6 )
				return "_h2hidle"
			else
				return "_magidle"
			endif
		elseif ( i < 12 )
			if ( i == 8 )
				return "_sneakidle"
			elseif ( i == 9 )
				return "_staffidle"
			elseif ( i == 10 )
				return "_mt"
			else
				return "_mtx"
			endif
		else
			if ( i == 12 )
				return "_mtturn"
			elseif ( i == 13 )
				return "_1hmmt"
			elseif ( i == 14 )
				return "_2hmmt"
			else
				return "_bowmt"
			endif
		endif
	elseif ( i < 32 )
		if ( i < 20 )
			if ( i == 16 )
				return "_magmt"
			elseif ( i == 17 )
				return "_magcastmt"
			elseif ( i == 18 )
				return "_sneakmt"
			else
				return "_1hmatk"
			endif
		elseif ( i < 24 )
			if ( i == 20 )
				return "_1hmatkpow"
			elseif ( i == 21 )
				return "_1hmblock"
			elseif ( i == 22 )
				return "_1hmstag"
			else
				return "_2hmatk"
			endif
		elseif ( i < 28 )
			if ( i == 24 )
				return "_2hmatkpow"
			elseif ( i == 25 )
				return "_2hmblock"
			elseif ( i == 26 )
				return "_2hmstag"
			else
				return "_2hwatk"
			endif
		else
			if ( i == 28 )
				return "_2hwatkpow"
			elseif ( i == 29 )
				return "_2hwblock"
			elseif ( i == 30 )
				return "_2hwstag"
			else
				return "_bowatk"
			endif
		endif
	elseif ( i < 48 )
		if ( i < 36 )
			if ( i == 32 )
				return "_bowblock"
			elseif ( i == 33 )
				return "_h2hatk"
			elseif ( i == 34 )
				return "_h2hatkpow"
			else
				return "_h2hstag"
			endif
		elseif ( i < 40 )
			if ( i == 36 )
				return "_magatk"
			elseif ( i == 37 )
				return "_1hmeqp"
			elseif ( i == 38 )
				return "_2hweqp"
			else
				return "_2hmeqp"
			endif
		elseif ( i < 44 )
			if ( i == 40 )
				return "_axeeqp"
			elseif ( i == 41 )
				return "_boweqp"
			elseif ( i == 42 )
				return "_cboweqp"
			else
				return "_dageqp"
			endif
		elseif ( i < 48 )
			if ( i == 44 )
				return "_h2heqp"
			elseif ( i == 45 )
				return "_maceqp"
			elseif ( i == 46 )
				return "_mageqp"
			else
				return "_stfeqp"
			endif
		endif
	elseif ( i < 54 )
		if ( i == 48 )
			return "_shout"
		elseif ( i == 49 )
			return "_magcon"
		elseif ( i == 50 )
			return "_dw"
		elseif ( i == 51 )
			return "_jump"
		elseif ( i == 52 )
			return "_sprint"
		elseif ( i == 53 )
			return "_shield"
		endif
	else
		return "WRONG_GROUPID"
	endif

endFunction


