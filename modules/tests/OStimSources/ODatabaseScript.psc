ScriptName ODatabaseScript Extends Quest

OsexIntegrationMain OStim
String[] Modules
Int Database

;odthreadmanager threadmanager

String[] property OriginalModules auto
String SavePath
Bool Built = False
Bool Loaded = False

; for debugging
Bool LoadInitialFromFile = False
Bool DumpConsole = False


; Structures
; Due to limitations with papyrus arrays, this script uses the following JContainers objects.
;--------------------------
; OArray - a JArray. Used to store:
; OMap - a JMap (i.e. dictionary). 1 OMap = 1 Animation scene
;--------------------------
;

;OMap Animation data

; name - String
; sceneid - String
; numactors - Int
; positiondata - String
; sourcemodule - String
; animclass - String
; OAanimids - OArray
; istransitory - Bool | "t="t""
; mainactor - Int | speed a="1"
; minspeed - Int
; maxspeed - Int

; hasidlespeed - Bool

; ishub - Bool | has only one animation
; isaggressive - Bool

Function InitDatabase()
	OriginalModules = new String[1]
	OriginalModules[0] = "0MF"
	OriginalModules = PapyrusUtil.PushString(OriginalModules, "0M2F")
	OriginalModules = PapyrusUtil.PushString(OriginalModules, "BB")
	OriginalModules = PapyrusUtil.PushString(OriginalModules, "BG")
	OriginalModules = PapyrusUtil.PushString(OriginalModules, "EMF")
	OriginalModules = PapyrusUtil.PushString(OriginalModules, "WZH0")

	SavePath = JContainers.UserDirectory() + "ODatabase.json"
	Built = False
	Loaded = False

	OStim = (Self as Quest) as OsexIntegrationMain

	;threadmanager.Destroy()
	;threadmanager = ODthreadmanager.NewObject()

	If (LoadInitialFromFile)
		Load()
	Else
		If (JContainers.FileExistsAtPath(SavePath))
			Console("Deleting old Database file...")
			JContainers.RemoveFileAtPath(SavePath)
		EndIf
		Database = NewOArray()
		JDB.SetObj("OStim.ODatabase", Database)

		If Build()
			Console(GetLengthOArray(Database) + " OSex scenes installed")
			Loaded = True

			SaveToDisk()
			Unload()
			Built = True
		Else
			Debug.Notification("OSTIM ERROR: OSTIM BuildNative has failed to create ODatabase.")
			Debug.Notification("OSTIM ERROR: Falling Back to old Build system, this will take longer.")
			if BuildPapyrus()
				Console(GetLengthOArray(Database) + " OSex scenes installed")
				Loaded = True
				SaveToDisk()
				Unload()
				Built = True
			Else
				Debug.MessageBox("Catastrophic Ostim Error/n ODatabase cannot be built./n This is likely because no animations have been detected./n please report this error on Nexus or Discord.")
			endif
		endif
	EndIf
EndFunction

Int Function GetDatabaseOArray(); never cache this for more than a few seconds, it can be cleared from memory at any time
	If (!Loaded)
		Load()
	EndIf
	Return Database
EndFunction

Function Unload()
	JDB.SetObj("OStim.ODatabase", 0)
	JValue.Release(GetDatabaseOArray())

	;threadmanager.Destroy()

	Console("Unloaded Database")
	Loaded = False
EndFunction

Function SaveToDisk()
	If (!Loaded)
		Load()
	EndIf

	JValue.WriteToFile(GetDatabaseOArray(), SavePath)
	Console("Wrote Database to disk")
EndFunction

Function Load()
	If (Loaded)
		Return
	EndIf

	If (JContainers.FileExistsAtPath(SavePath))
		Database = JValue.ReadFromFile(SavePath)
		JDB.SetObj("OStim.ODatabase", Database)
	Else
		Console("Error: Database not found at: " + SavePath)

		Database = NewOArray()
		JDB.SetObj("OStim.ODatabase", Database)

		Build()
		Loaded = True

		SaveToDisk()
	EndIf

	;threadmanager.Destroy()
	;threadmanager = ODThreadManager.newobject()

	Console("Loaded Database")
	Loaded = True
EndFunction

Bool Function IsBuilt()
	Return Built
EndFunction

;--------------------------------------------
;  	Retrieve Data from animation OMaps
;--------------------------------------------

String Function GetFullName(Int Animation)
	Return GetStringOMap(Animation, "name")
EndFunction

String Function GetAnimationClass(Int Animation)
	Return GetStringOMap(Animation, "animclass")
EndFunction

Int Function GetAnimationIDOArray(Int Animation) ; returns an OArray of animation IDs
	Return GetObjOMap(Animation, "OAanimids")
EndFunction

Int Function GetNumActors(Int Animation)
	Return GetIntOMap(Animation, "NumActors")
EndFunction

String Function GetPositionData(Int Animation)
	Return GetStringOMap(Animation, "positiondata")
EndFunction

String Function GetSceneID(Int Animation)
	Return GetStringOMap(Animation, "sceneid")
EndFunction

String Function GetModule(Int Animation)
	Return GetStringOMap(Animation, "sourcemodule")
EndFunction

Bool Function IsAggressive(Int Animation)
	Return GetBoolOMap(Animation, "aggressive")
EndFunction

Bool Function IsHubAnimation(Int Animation)
	Return GetBoolOMap(Animation, "ishub")
EndFunction

Bool Function IsTransitoryAnimation(Int Animation)
	Return GetBoolOMap(Animation, "istransitory")
EndFunction

Bool Function IsSexAnimation(Int Animation)
	Return (!IsHubAnimation(Animation) && !IsTransitoryAnimation(Animation))
EndFunction

Int Function GetMainActor(Int Animation) ; the main actor is the one doing the most work. 0 - dom | 1 - sub
	If (!IsSexAnimation(Animation))
		Return -1
	EndIf
	Return GetIntOMap(Animation, "mainActor")
EndFunction

Int Function GetMaxSpeed(Int Animation)
	If (!IsSexAnimation(Animation))
		Return -1
	EndIf
	Return GetIntOMap(Animation, "maxspeed")
EndFunction

Int Function GetMinSpeed(Int Animation)
	If (!IsSexAnimation(Animation))
		Return -1
	EndIf
	Return GetIntOMap(Animation, "minspeed")
EndFunction

Bool Function HasIdleSpeed(Int Animation) ; if the lowest speed on a sex animation is called "idle"
	If (!IsSexAnimation(Animation))
		Return -1
	EndIf
	Return GetBoolOMap(Animation, "hasidlespeed")
EndFunction

; extras
String Function GetPositionDataForActorSlot(Int Animation, Int Slot)
	Return StringUtil.Split(GetPositionData(Animation), "!")[Slot]
EndFunction

Bool Function HasPositionDataInSlot(Int Animation, Int Slot, String Data) ; this supports partial data, ie "Kn" at slot 0 will tell you if a dom actor is kneeling on both knees
	String slotdata = GetPositionDataForActorSlot(Animation, Slot)
	Return !(StringUtil.Find(SlotData, Data) == -1)
EndFunction

Bool Function HasPositionData(Int Animation, String Data) ; this supports partial data
	String SlotData = GetPositionData(Animation)
	Return !(StringUtil.Find(SlotData, Data) == -1)
EndFunction

;----------------------------------------------
;  	Retrieve OArray of animations from Database
;-----------------------------------------------

;Int Function DatabaseKeyAndParameterLookup(Int zDatabase, String zKey, Int IntParam = -100, String StringParam = "", Int BoolParam = -1, Bool AllowPartialStringResult = False, Bool NegativePartial = False)
;	OStim.Profile()
;
;	Int Base = zDatabase
;	Int Ret = JArray.object()
;
	;Int i = 0
;	Int L = JArray.Count(Base)
;
;	Int Animation ;optimization
;	Bool Parameter
	;Int iOutput
;	String sOutput
;
 ;   If (IntParam > -100)
  ;      while (i < L)
 ;           Animation = JArray.GetObj(base, i)
   ;         iOutput = JMap.GetInt(Animation, zKey, Default = -10001)
    ;        If (iOutput == IntParam) && (iOutput != 10001)
;				JArray.AddObj(Ret, Animation)
	;		EndIf
  ;          i += 1
   ;     endwhile
	;	OStim.Profile("Lookup")
;		Return Ret
 ;   elseif (StringParam != "")
  ;      If (!AllowPartialStringResult)
   ;         while (i < L)
    ;            Animation = JArray.GetObj(base, i)
 ;               sOutput = JMap.GetStr(Animation, zKey, Default = "")
     ;           If (sOutput == StringParam) && (sOutput != "")
	;				JArray.AddObj(Ret, Animation)
	;			EndIf
     ;           i += 1
      ;      endwhile
;			OStim.Profile("Lookup")
		;	Return Ret
  ;      Else
 ;           while (i < L)
   ;             Animation = JArray.GetObj(base, i)
   ;             sOutput = JMap.GetStr(Animation, zKey, Default = "")
    ;            If (StringUtil.Find(sOutput, StringParam) != -1)
     ;               If (!NegativePartial)
      ;                  JArray.AddObj(ret, Animation)
      ;              EndIf
       ;         Else
        ;            If (NegativePartial)
        ;;                JArray.AddObj(ret, Animation)
         ;           EndIf
         ;;       EndIf
         ;;       i += 1
        ;    endwhile
		;;	OStim.Profile("Lookup")
;			Return Ret
 ;       endif
  ;  ElseIf (BoolParam > -1)
 ;       while (i < L)
  ;          Animation = JArray.GetObj(base, i)
  ;          If ((JMap.getInt(Animation, zKey, Default = 0) as Bool) == BoolParam as Bool)
   ;             JArray.AddObj(Ret, Animation)
   ;         EndIf
    ;        i += 1
    ;    endwhile
	;	OStim.Profile("Lookup")
	;	Return Ret
    ;endif
;
;	OStim.Profile("Lookup")
;	Return Ret
;EndFunction

int function DatabaseKeyAndParameterLookup(Int zDatabase, String zKey, Int IntParam = -100, String StringParam = "", Int BoolParam = -1, Bool AllowPartialStringResult = False, Bool NegativePartial = False)
	Int Ret = JArray.object()
	if (IntParam > -100)
		ret = JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'"+zKey+"', "+IntParam+")")
		Return Ret
    elseif (StringParam != "")
        if (!AllowPartialStringResult)
			;normal
			ret = JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'"+zKey+"', '"+StringParam+"')")
		else
			if (NegativePartial)
				;negative partial
				ret = JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'"+zKey+"', '"+StringParam+"', 1, 1)")
			else
				;normal partial
				ret = JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'"+zKey+"', '"+StringParam+"', 1, 0)")
			endif
        endif
		Return Ret
    elseif (BoolParam > -1)
		ret = JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'"+zKey+"', "+BoolParam+")") ;no need to cast boolParam as int because it already is one.
		Return Ret
    endif
	Return Ret
endfunction

Int Function getAnimationWithAnimID(Int zDatabase, String AnimID) ;returns OArray
	Int Base = zDatabase
	Int Ret = NewOArray()

	Int i = 0
	Int L = GetLengthOArray(Base)

	Int Animation ;optimization
	Int OAAnimIDs
	while (i < L) ;iterate through scene objects
		Animation = GetObjectOArray(Base, i)
		OAAnimIDs = GetAnimationIDOArray(Animation)

		;Int i2 = 0
		;Int L2 = GetLengthOArray(OAanimIDs)
		;While (i2 < L2)
		;	If (AnimID == GetStringOArray(OAAnimIDs, i2))
		;		AppendObjectOArray(Ret, Animation)
		;		Return Ret ; short circuit out
		;	EndIf

		;	i2 += 1
		;EndWhile

		If JArray.findStr(OAAnimids, AnimID) != -1
			AppendObjectOArray(Ret, Animation)
			Return Ret
		EndIf

		i += 1
	endwhile
	Return Ret
EndFunction

Int Function GetAnimationsWithSpecificPositionData(Int zDatabase, String Data, Int Slot = -1, Bool Has = True)  ; this supports partial data, ie "Kn" at slot 0 will tell you if a dom actor is kneeling on both knees
	; slot -1 = search all slots
	;Has = False will give you animations that do not contain the data
	Int Base = zDatabase
	Int Ret = NewOArray()

	Int i = 0
	Int L = GetLengthOArray(base)
	While (i < L)
		Int Animation = GetObjectOArray(Base, i)
		If (Slot != -1)
			If (HasPositionDataInSlot(Animation, Slot, Data))
				If (Has)
					AppendObjectOArray(Ret, Animation)
				EndIf
			Else
				If (!Has)
					AppendObjectOArray(Ret, Animation)
				EndIf
			EndIf
		Else
			If (HasPositionData(Animation, Data))
				If (Has)
					AppendObjectOArray(Ret, Animation)
				EndIf
			Else
				If (!Has)
					AppendObjectOArray(Ret, Animation)
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	Return Ret
EndFunction

;-----------

Int Function GetAnimationsWithActorCount(Int zDatabase, Int Num) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'NumActors', "+Num+")")
EndFunction

Int Function GetAnimationsWithName(Int zDatabase, String Name, Bool AllowPartialResult = False, Bool Negative = False) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject, 'name', '"+Name+"', "+AllowPartialResult as int+", "+Negative as int+")")
EndFunction

Int Function GetAnimationsWithAnimationClass(Int zDatabase, String zClass) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'animclass', '"+zClass+"')")
EndFunction

Int Function GetAnimationsWithPositionData(Int zDatabase, String Pos) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'positiondata', '"+Pos+"')")
EndFunction

Int Function GetAnimationsWithSceneID(Int zDatabase, String SceneID) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'sceneid', '"+SceneID+"')")
EndFunction

Int Function GetAnimationsFromModule(Int zDatabase, String Module) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'sourcemodule', '"+Module+"')")
EndFunction

Int Function GetAnimationsByAggression(Int zDatabase, Bool IsAggressive) ; returns OArray
	Int Send = 0
	If (IsAggressive)
		Send = 1
	EndIf
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'aggressive', "+Send+")")
EndFunction

Int Function GetHubAnimations(Int zDatabase, Bool IsHub) ; returns OArray
	Int Send = 0
	If (IsHub)
		Send = 1
	EndIf
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'ishub', "+Send+")")
EndFunction

Int Function GetTransitoryAnimations(Int zDatabase, Bool IsTransitory) ; returns OArray
	Int Send = 0
	If (IsTransitory)
		Send = 1
	EndIf
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'istransitory', "+Send+")")
EndFunction

Int Function GetSexAnimations(Int zDatabase, Bool IsSex) ; returns OArray
	; returns all sexual animations, for intercourse animations only, use the animation class "Sx" as a lookup instead
	int[] merge = new int[2]
	merge[0] = GetHubAnimations(zDatabase, !issex)
	merge[1] = GetTransitoryAnimations(zDatabase, !issex)
	Return MergeOArrays(merge)
EndFunction

Int Function GetAnimationsByMainActor(Int zDatabase, Int MainActor) ; returns OArray
	; 0 - dom, 1 - sub
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'mainActor', "+MainActor+")")
EndFunction

Int Function GetAnimationsByMaxSpeed(Int zDatabase, Int Speed) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'maxspeed', "+Speed+")")
EndFunction

Int Function GetAnimationsByMinSpeed(Int zDatabase, Int Speed) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'minspeed', "+Speed+")")
EndFunction

Int Function GetAnimationsWithIdleSpeed(Int zDatabase, Bool zIdle) ; returns OArray
	Return JValue.evalLuaObj(zDatabase, "return ostim.getAnimationsKeyValuePair(jobject,'hasidlespeed', "+zIdle as Int+")")
EndFunction

;--- auxiliary functions

String Function GetSceneIDByAnimID(String AnimID)
	Int OMAnim = GetObjectOArray(GetAnimationWithAnimID(GetDatabaseOArray(), AnimID), 0)
	Return GetSceneID(OMAnim)
EndFunction

;----------------------
;  	Building
;----------------------

Function CheckForModules()
	String Path = "data/meshes/0SA/mod/0Sex/scene"
	Modules = MiscUtil.FoldersInFolder(Path)

	Int NumModules = Modules.Length

	Console("Modules found: " + NumModules)
	If (NumModules == 0)
		ShowPapyrusUtilsError()
	EndIf

	Int i = 0
	While (i < NumModules)
		If (!OStim.StringArrayContainsValue(OriginalModules, Modules[i]))
			Debug.Notification("OStim - loaded third-party animation pack: " + Modules[i])
		EndIf
		i += 1
	EndWhile
EndFunction

Int Function GetAllAnimationFiles()
	; returns an oarray of all file paths to all files
	String Path = "data/meshes/0SA/mod/0Sex/scene"
	Int Ret = NewOArray()

	Modules = MiscUtil.FoldersInFolder(Path)

	Int i = 0
	Int NumModules = Modules.Length
	Console("Modules found: " + NumModules)

	If (NumModules == 0)
		ShowPapyrusUtilsError()
	EndIf

	While (i < NumModules)
		If (!OStim.StringArrayContainsValue(OriginalModules, Modules[i]))
			Debug.Notification("OStim - Loaded third-party animation pack: " + Modules[i])
		EndIf
		String[] Positions = MiscUtil.FoldersInFolder(Path + "/" + Modules[i])

		Int i2 = 0
		Int NumPositions = Positions.Length

		While (i2 < NumPositions)
			If (Positions[i2] == "_TOG")
				;ignore
			Else
				String[] Classes = MiscUtil.FoldersInFolder(Path + "/" + Modules[i] + "/" + Positions[i2])

				Int i3 = 0
				Int NumClasses = Classes.Length
				While (i3 < NumClasses)
					String[] Files = MiscUtil.FilesInFolder(Path + "/" + Modules[i] + "/" + Positions[i2] + "/" + Classes[i3])

					Int i4 = 0
					Int NumFiles = Files.Length
					While (i4 < Numfiles)
						String FileLocation = Path + "/" + Modules[i] + "/" + Positions[i2] + "/" + Classes[i3] + "/" + Files[i4]

						If (StringUtil.Find(Files[i4], ".xml") != -1) || (StringUtil.Find(Files[i4], ".XML") != -1)
							AppendStringOArray(Ret, FileLocation)
							Console("Animation data found: " + FileLocation)
							JValue.Retain(Ret)
						Else
							Console("Skipping non-XML file: " + Files[i4])
						EndIf

						i4 += 1
					EndWhile
					i3 += 1
				EndWhile
			EndIf
			i2 += 1
		EndWhile
		i += 1
	EndWhile

	Return Ret
EndFunction

String Function GetFileContents(String File)
	Return MiscUtil.ReadFromFile(File)
EndFunction

Bool Function Build()
	If (OStim.UseNativeFunctions)
		Console("Using native build")
		Return BuildNative()
	Else
		Console("Using papyrus build")
		Return BuildPapyrus()
	EndIf
EndFunction

Bool Function BuildNative()
 	OSANative.BuildDB()
	if (JContainers.FileExistsAtPath(SavePath))
		Load()
		Return True
	Else
		Console("Error: OSANAtive buildDB failed, no database found at: " + SavePath)
		Return False
	endif

	CheckForModules()
	Console("ODatabase built using native Function")
	Return True
EndFunction

Bool Function BuildPapyrus() ; papyrus implementation of the odatabase builder - slow
	Int OAFiles = GetAllAnimationFiles()

	Int i = 0
	Int L = GetLengthOArray(OAFiles)
	While (i < L)
		String contents = GetFileContents(GetStringOArray(OAFiles, i))
		Int OMAnimation = NewOMap()

		AppendStringOMap(OMAnimation, "name", XMLGetName(Contents))
		AppendStringOMap(OMAnimation, "sceneid", XMLGetSceneID(Contents))
		AppendIntOMap(OMAnimation, "numactors", XMLGetNumActors(Contents))
		AppendStringOMap(OMAnimation, "positiondata", XMLGetPosData(OMAnimation))
		AppendStringOMap(OMAnimation, "sourcemodule", XMLGetSourceModule(GetStringOArray(OAFiles, i)))
		AppendStringOMap(OMAnimation, "animclass", XMLGetAnimClass(GetStringOArray(OAFiles, i)))
		AppendObjectOMap(OMAnimation, "OAanimids", XMLGetAnimIDs(Contents))
		AppendBoolOMap(OMAnimation, "aggressive", XMLIsAggressive(OMAnimation))

		Bool Transitory = XMLIsTransitory(Contents)
		AppendBoolOMap(OMAnimation, "istransitory", Transitory)
		Bool IsHub = XMLIsHub(Contents, OMAnimation)
		AppendBoolOMap(OMAnimation, "ishub", IsHub)

		If (!Transitory && !IsHub)
			Int MainActor = XMLMainActor(Contents)
			AppendIntOMap(OMAnimation, "mainactor", MainActor)
			AppendIntOMap(OMAnimation, "minspeed", XMLMinSpeed(Contents, MainActor))
			AppendIntOMap(OMAnimation, "maxspeed", XMLMaxSpeed(Contents))
			AppendBoolOMap(OMAnimation, "hasidlespeed", XMLHasIdleSpeed(Contents))
		EndIf

		AppendObjectOArray(Database, OMAnimation)
		JValue.Retain(OAFiles)
		;Console("-------------------------------------------------------------------------")
		i += 1
	EndWhile
	If (GetLengthOArray(Database) <= 0)
		return False
	else
		Return True
	endif
EndFunction

; Extracting data from XML input

String Function ToolExtractFirstString(String In, String Element)
	String XMLPart = Element + "\""
	Int PartLength = StringUtil.GetLength(XMLPart)

	Int	Start = StringUtil.Find(In, XMLPart)
	If (Start == -1)
		Return ""
	EndIf

	String SubString = StringUtil.SubString(In, Start + PartLength, Len = 0) ; we now just have to cut off the end
	Return StringUtil.Split(SubString, "\"")[0]
EndFunction

String Function ToolExtractNthString(String In, String Element, Int Nth)
	String XMLPart = Element + "\""
	Int PartLength = StringUtil.GetLength(XMLPart)

	Int End = 0
	Int i = 0
	While (i < Nth)
		End = StringUtil.Find(In, XMLPart, End) + PartLength
		i += 1
	EndWhile

	String SubString = StringUtil.Substring(In, End, Len = 0) ; we now just have to cut off the end
	Return StringUtil.Split(SubString, "\"")[0]
EndFunction

Int Function ToolSingleDigitStringNumberToInt(String In)
	Return OStim.SpeedStringToInt("s" + In)
EndFunction

String Function ToolExtractNthFolderPathFolder(String Path, Int Part)
	String[] SplitPath = StringUtil.Split(Path, "/")
	Return SplitPath[Part]
EndFunction

String Function XMLGetName(String In)
	String Ret = ToolExtractFirstString(In, "<info name=")
	;Console("	Name: " + Ret)
	Return Ret
EndFunction

String Function XMLGetSceneID(String In)
	String Ret = ToolExtractFirstString(In, "<scene id=")
	;Console("	Scene ID: " + Ret)
	Return Ret
EndFunction

Int Function XMLGetNumActors(String In)
	Int Ret = ToolSingleDigitStringnumberToInt(toolextractfirststring(In, "actors="))
	;Console("	Number of actors: " + Ret)
	Return Ret
EndFunction

String Function XMLGetPosData(Int OMAnim)
	String Ret = StringUtil.Split(getSceneID(OMAnim), "|")[1]
	;Console("	Position Data: " + Ret)
	Return Ret
EndFunction

String Function XMLGetSourceModule(String Path)
	String Ret = ToolExtractNthFolderPathFolder(Path, 6)
	;Console("	Source Module: " + Ret)
	Return Ret
EndFunction

String Function XMLGetAnimClass(String Path)
	String Ret = ToolExtractNthFolderPathFolder(Path, 8)
	;Console("	Animation Class: " + Ret)
	Return Ret
EndFunction

Int Function XMLGetAnimIDs(String In)
	String[] Ret

	If (ToolExtractNthString(In, "<anim id=", 2) != "=")
		Int Number = 2
		Ret = Utility.CreateStringArray(1, ToolExtractNthString(In, "<anim id=", Number))
		String Last = Ret[0]

		While (last != "=") ; assuming "=" marks end of file
			Number += 1
			Last = ToolExtractNthString(In, "<anim id=", Number)

			If (Last != "=")
				Ret = PapyrusUtil.PushString(Ret, Last)
			EndIf
		EndWhile
	Else
		Ret = Utility.CreateStringArray(1, ToolExtractNthString(In, "<anim id=", 1))
	EndIf

	;/
	Int i = 0
	Int L = Ret.Length
	While (i < L)
		Console("		Animation ID " + i + ": " + Ret[i])
		i += 1
	EndWhile
	/;

	Return JArray.ObjectWithStrings(Ret)
EndFunction

Bool Function XMLIsTransitory(String In)
	Bool Ret = (ToolExtractFirstString(In, "t=") == "T")
	;Console("	Is Transitory Animation: " + Ret)
	Return Ret
EndFunction

Int Function XMLMainActor(String In)
	Int Ret = ToolSingleDigitStringnumberToInt(ToolExtractFirstString(In, "<speed a="))
	;Console("	Main controlling actor: " + Ret)
	Return Ret
EndFunction

Int Function XMLMinSpeed(String In, Int mainActor)
	Int Ret = ToolSingleDigitStringNumberToInt(ToolExtractFirstString(In, "<speed a=\""+ mainactor + "\" min="))
	;Console("	Minimum Speed: " + Ret)
	Return Ret
EndFunction

Int Function XMLMaxSpeed(String In)
	Int Ret = ToolSingleDigitStringNumberToInt(ToolExtractFirstString(In, " max="))
	;Console("	Maximum Speed: " + Ret)
	Return Ret
EndFunction

Bool Function XMLHasIdleSpeed(String In)
	Bool Ret = ToolExtractFirstString(In, "<sp mtx=") == "^idle"
	;Console("	Has Idle Speed: " + Ret)
	Return Ret
EndFunction

Bool Function XMLIsHub(String In, Int OMAnim)
	Bool Ret
	If (ToolExtractFirstString(In, " max=") == "")
		If (IsTransitoryAnimation(OMAnim))
			Ret = False
		else
			Ret = True
		EndIf
	Else
		Ret = False
	EndIf
	;Console("	Is Hub Animation: " + Ret)
	Return Ret
EndFunction

Bool Function XMLIsAggressive(Int OMAnimation)
	Bool Ret = False
	String AClass = GetAnimationClass(OMAnimation)
	String Module = Getmodule(OMAnimation)

	If ((AClass == "Ro") || (AClass == "HhPJ") || (AClass == "HhBJ") || (AClass == "HhPo") || (AClass == "SJ"))
		Ret = True
	Elseif ((Module == "BG") || (Module == "BB"))
		Ret = True
	else
		Int	Start = StringUtil.Find(AClass, "Ag")
		If (Start != -1)
			Ret = True
		EndIf
	EndIf

	;Console("	Is Aggressive: " + Ret)
	Return Ret
EndFunction

;----------------------
;  OArray Manipulation
;----------------------

Int Function newOArray()
	Return JArray.object()
EndFunction

Function AppendIntOArray(Int OArray, Int Append)
	JArray.AddInt(OArray, Append)
EndFunction

Function AppendObjectOArray(Int OArray, Int Append)
	JArray.AddObj(OArray, Append)
EndFunction

Function AppendStringOArray(Int OArray, String Append)
	JArray.addStr(OArray, Append)
EndFunction

Int Function GetIntOArray(Int OArray, Int Index)
	Return JArray.GetInt(OArray, Index, Default = -10001)
EndFunction

Int Function GetObjectOArray(Int OArray, Int Index)
	Return JArray.GetObj(OArray, Index)
EndFunction

String Function GetStringOArray(Int OArray, Int Index)
	Return JArray.GetStr(OArray, Index, Default = "")
EndFunction

Int Function GetLengthOArray(Int OArray) ;number of items total
	Return JArray.Count(OArray)
EndFunction

Int Function MergeOArrays(Int[] Arrays) ;may only work if arrays are full of omap or oarray objects
	Int Ret = JArray.object()

	Int i = 0
	Int max = Arrays.Length
	While (i < max)
		JArray.addFromArray(ret, Arrays[i])

		i += 1
	EndWhile

	Return Ret
EndFunction

; Fisher–Yates shuffle Algorithm
Int Function ShuffleOArray(Int OArray)
	int L = GetLengthOArray(OArray)

	int i = L

	int j ; an index
	While (i > 0)
		i -= 1

		j = OStim.RandomInt(0, i)

		JArray.swapItems(OArray, i, j)

	EndWhile

	return OArray
EndFunction

;----------------------
;  OMap Manipulation
;----------------------

Int Function NewOMap()
	Return JMap.Object()
EndFunction

Function AppendStringOMap(Int OMap, String zKey, String zAppend)
	JMap.SetStr(OMap, zKey, zAppend)
EndFunction

Function AppendIntOMap(Int OMap, String zKey, Int zAppend)
	JMap.SetInt(OMap, zKey, zAppend)
EndFunction

Function AppendObjectOMap(Int OMap, String zKey, Int zAppend)
	JMap.SetObj(OMap, zKey, zAppend)
EndFunction

Function AppendBoolOMap(Int OMap, String zKey, Bool zAppend)
	Int Append
	If (zAppend)
		Append = 1
	Else
		Append = 0
	EndIf
	JMap.SetInt(OMap, zKey, Append)
EndFunction

String Function GetStringOMap(Int OMap, String zKey)
	Return JMap.GetStr(OMap, zKey, Default = "")
EndFunction

Int Function getIntOMap(Int OMap, String zKey)
	Return JMap.GetInt(OMap, zKey, Default = -10001)
EndFunction

Int Function getObjOMap(Int OMap, String zKey)
	Return JMap.GetObj(OMap, zKey)
EndFunction

Bool Function getBoolOMap(Int OMap, String zKey)
	Int a = JMap.getInt(OMap, zKey, Default = 0)
	If (a == 1)
		Return True
	EndIf
	Return False
EndFunction

;----------------------------------
; 			Other
;----------------------------------

Function Console(String In)
	OsexIntegrationMain.Console(In)
	If (DumpConsole)
		DumpString(In + "\n")
	EndIf
EndFunction

Function DumpString(String In)
	MiscUtil.WriteToFile("data/ostimdump.txt", In, TimeStamp = False)
EndFunction

Function DumpOmap(Int OMap)
	JValue.WriteToFile(OMap, "data/ostimdump.txt")
	Console("Dumped")
EndFunction

Function ShowPapyrusUtilsError()
	Debug.MessageBox("OStim: ERROR - Your version of PapyrusUtils is out of date - this is ALMOST CERTAINLY because OSA's packaged in (and out of date) PapyrusUtils is overwriting a more recent downloaded version. Please exit without saving, and move PapyrusUtils lower in mod organizer, or do the upcoming vortex instructions, or install the latest version if it is not installed so that OStim can Function. ")
	Debug.MessageBox("OStim (for Mod Organizer users): Move Papyrusutils lower in the left area, not in the ESP area. (PapyrusUtils does not have an ESP)")
	Debug.MessageBox("OStim (for Vortex users): open vortex and right click click PapyrusUtils. (anywhere in the dark grey line, NOT the enable or disable icon), click manage file conflicts then change all of the options on the right from OSA or anything else, to papyrusutils.")
EndFunction
