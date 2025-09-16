Scriptname _oGlobal

;  ██████╗ ███████╗ █████╗      ██████╗ ██╗      ██████╗ ██████╗  █████╗ ██╗
; ██╔═══██╗██╔════╝██╔══██╗    ██╔════╝ ██║     ██╔═══██╗██╔══██╗██╔══██╗██║
; ██║   ██║███████╗███████║    ██║  ███╗██║     ██║   ██║██████╔╝███████║██║
; ██║   ██║╚════██║██╔══██║    ██║   ██║██║     ██║   ██║██╔══██╗██╔══██║██║
; ╚██████╔╝███████║██║  ██║    ╚██████╔╝███████╗╚██████╔╝██████╔╝██║  ██║███████╗
;  ╚═════╝ ╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
; █████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
; ╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝
; OSA Global Script, holds all global functions that the OSA family of scripts share.
; Mainly used by multiple instances of the Actra script.


String Function GetFormID_S(Form zForm) Global
    String ModID = IntToHex(Math.RightShift(OSANative.GetFormID(zForm), 24))
    String SubID = IntToHex(Math.LogicalAnd(0x00FFFFFF, OSANative.GetFormID(zForm)))

    If (ModID == "")
        ModID = "00"
    ElseIf (StringUtil.GetLength(ModID) < 2)
        ModID = "0" + ModID
    EndIf

    Int SubLen = StringUtil.GetLength(SubID)

    If (SubLen == 0)
        SubID = "000000"
    ElseIf (SubLen == 1)
        SubID = "00000" + SubID
    ElseIf (SubLen == 2)
        SubID = "0000" + SubID
    ElseIf (SubLen == 3)
        SubID = "000" + SubID
    ElseIf (SubLen == 4)
        SubID = "00" + SubID
    ElseIf (SubLen == 5)
        SubID = "0" + SubID
    EndIf

    Return ModID + SubID
EndFunction

Bool Function DirectionCheck_D(Actor Initiator, Actor Target, Int Min, Int Max) Global
    Float Angle = Target.GetHeadingAngle(Initiator)
    If (Angle < 0)
        Angle = 180 + (180 + Angle)
    Endif
    If (Angle > Min && Angle < Max)
        Return True
    Endif
    Return False
EndFunction


;  █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗ ██████╗ ███████╗██████╗
; ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔════╝██╔══██╗
; ███████║██║        ██║   ██║   ██║██████╔╝    ██████╔╝██████╔╝█████╗  ██████╔╝
; ██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔═══╝ ██╔══██╗██╔══╝  ██╔═══╝
; ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██║     ██║  ██║███████╗██║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝
; Functions that prepare the actors to perform in the scene and counter functions.


; Performs a series of random skyrim locks on the actors so they don't repel each other during a scene.
Function ActorLock(Actor Actra, Actor Player) Global
    If (Player == Actra)
        If !OSANative.IsFreeCam()
            Game.ForceThirdPerson()
        EndIf
        Game.SetPlayerAIDriven()
        Game.DisablePlayerControls(False, False, False, False, False, False, True, False, 0)
    Else
        Actra.SetRestrained(True)
        Actra.SetDontMove(True)
    EndIf
EndFunction

; Disables all locking stuff used in OSA,
; also reverts their footIK to normal and puts them back into an idle animation
Function ActorUnlock(Actor Actra, Actor Player) Global
    If (Player == Actra)
        Game.SetPlayerAIDriven(False)
        Game.EnablePlayerControls()
    Else
        Actra.SetRestrained(False)
        Actra.SetDontMove(False)
    EndIf

    Actra.StopTranslation()
    Actra.SetVehicle(None)
    Actra.SetAnimationVariableBool("bHumanoidFootIKDisable", False)
    Debug.SendAnimationEvent(Actra, "IdleForceDefaultState")
EndFunction

Function ActorSmoothUnlock(Actor Actra, Actor Player, Float Xp, Float Yp) Global
    If (Player == Actra)
        Game.SetPlayerAIDriven(False)
        Game.EnablePlayerControls()
    Else
        Actra.SetRestrained(False)
        Actra.SetDontMove(False)
    EndIf

    Actra.StopTranslation()
    Actra.SetVehicle(None)
    ;Actra.SetPosition(Xp, Yp, Actra.z)
    ;Actra.SplineTranslateTo(Xp, Yp, Actra.z, Actra.GetAngleX(), Actra.GetAngleY(), Actra.GetAngleZ(), 1.0, 70, 0)
    Actra.SetAnimationVariableBool("bHumanoidFootIKDisable", False)
    Debug.SendAnimationEvent(Actra, "IdleForceDefaultState")
EndFunction

; Overwrites the Actor's package with a DoNothing package.
Function PackageSquelch(Actor Actra, Package[] OPackage) Global 
    ;OStim: package overrides are broken in SE I think?
    ActorUtil.AddPackageOverride(Actra, OPackage[0], 100, 1)
    Actra.EvaluatePackage()
EndFunction

; Reverse the above squelch package override.
Function PackageClean(Actor Actra, Package[] OPackage) Global
    ActorUtil.RemovePackageOverride(Actra, OPackage[0])
    Actra.EvaluatePackage()
EndFunction

; Cleans all factions used by OSA from an Actor.
Function FactionClean(Actor Actra, Faction[] OFaction) Global
    Actra.RemoveFromFaction(OFaction[0])
    Actra.RemoveFromFaction(OFaction[1])
    Actra.RemoveFromFaction(OFaction[2])
EndFunction

Function SheathWep(Actor Actra, Actor Player) Global
    If (Actra == Player && Actra.IsWeaponDrawn())
        Actra.SheatheWeapon()
    EndIf
EndFunction


; ██████╗  ██████╗ ███████╗██╗████████╗██╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗
; ██╔══██╗██╔═══██╗██╔════╝██║╚══██╔══╝██║██╔═══██╗████╗  ██║██║████╗  ██║██╔════╝
; ██████╔╝██║   ██║███████╗██║   ██║   ██║██║   ██║██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
; ██╔═══╝ ██║   ██║╚════██║██║   ██║   ██║██║   ██║██║╚██╗██║██║██║╚██╗██║██║   ██║
; ██║     ╚██████╔╝███████║██║   ██║   ██║╚██████╔╝██║ ╚████║██║██║ ╚████║╚██████╔╝
; ╚═╝      ╚═════╝ ╚══════╝╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝


Function GetStageLoc(Actor Actra, Float[] Loc) Global
    Loc[0] = Actra.GetPositionX()
    Loc[1] = Actra.GetPositionY()
    Loc[2] = Actra.GetPositionZ()
    Loc[3] = Actra.GetAngleX()
    Loc[4] = Actra.GetAngleY()
    Loc[5] = Actra.GetAngleZ()
EndFunction

Float[] Function GetStageLocArray(ObjectReference Actra) Global
    Float[] Loc = new Float[6]
    Loc[0] = Actra.GetPositionX()
    Loc[1] = Actra.GetPositionY()
    Loc[2] = Actra.GetPositionZ()
    Loc[3] = Actra.GetAngleX()
    Loc[4] = Actra.GetAngleY()
    Loc[5] = Actra.GetAngleZ()
    Return Loc
EndFunction

Function EnforceAngle(Actor Actra, Float[] Loc) Global
    If (Math.Abs(Actra.GetAngleZ() - Loc[5]) > 0.5)
        Actra.SetAngle(Loc[3], Loc[4], Loc[5])
    EndIf
EndFunction

Function EnforcePosition(Actor Actra, ObjectReference StageSpot, Float[] Loc) Global
    If (Actra.GetDistance(stageSpot) > 0.5)
        Actra.SetPosition(Loc[0], Loc[1], Loc[2])
        Actra.SetVehicle(StageSpot)
    EndIf
    Actra.SplineTranslateTo(Loc[0], Loc[1], Loc[2], Loc[3], Loc[4], Loc[5], 1.0, 10000, 0.0001)
    Actra.SetVehicle(stageSpot)
EndFunction

String[] Function SendActraDetails(Actor Actra, String FormID, _oOmni OSO) Global
    ;/
    If (!CPConvert.CPIsValid(Oso.codepage))
        ; CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
        Debug.Notification(Oso.codepage + " is not a valid codepage value!")
    EndIf
    /;

    ActorBase ActB = OSANative.GetLeveledActorBase(actra)
    String[] Details = new String[20]
    Details[0] = FormID
    Details[1] = OSANative.GetFormID(Actra)
    ; CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
    ;details[2] = CPConvert.CPConv(oso.codepage, "UTF-8", ActB.GetName())
    Details[2] = OSANative.GetDisplayName(Actra)
    Details[3] = OSANative.GetSex(actb)

    If (Actra == OSO.PlayerRef)
        Details[4] = "1"
        ConsoleUtil.SetSelectedReference(None)
        ;Consoleutil.ExecuteCommand("tcl")
        ;Actra.SetScale(1.0)
        ;Consoleutil.ExecuteCommand("tcl")
    Else
        ;Actra.SetScale(1.0)
        Details[4] = "0"
        Details[10] = Details[0] ; it is now already a String in hex
        ;Details[11] = Game.GetModName(ModNameHex10(Details[10])) ;unused except for datalibrary
        Details[11] = "Skyrim"
        Details[10] = StringUtil.SubString(Details[10], 2) ; last 6 of hex 
        Details[12] = StringUtil.SubString(Details[11], 0, StringUtil.Find(Details[11], ".es")) 
        Details[13] = Details[12] + Details[10]
    EndIf
    Details[8] = OSANative.GetWeight(ActB)
    Details[7] = OSANative.GetFormID( OSANative.GetVoiceType(ActB) )


    
    Details[6] = OSANative.GetName( OSANative.GetRace(Actb) )
    ;Details[5] = Actra.GetScale() ;unneeded with new scaling sys?
    Details[5] = 1.0
    Return Details
EndFunction

String[] Function SendActraScale(Actor Actra, String FormID) Global
    
    String[] ret = PapyrusUtil.StringArray(20, "1.0")
    ret[0] = FormID
    return ret

    ; OStim: don't think the below stuff is needed? It's a ton of wasted frames so...
    String[] Scale = new String[20]
    Scale[0] = FormID
    Scale[1] = NetImmerse.GetNodeScale(Actra, "NPC Root [Root]", False)
    Scale[2] = NetImmerse.GetNodeScale(Actra, "NPC Belly", False)
    Scale[3] = NetImmerse.GetNodeScale(Actra, "NPC L Butt", False)
    Scale[4] = NetImmerse.GetNodeScale(Actra, "NPC R Butt", False)
    Scale[5] = NetImmerse.GetNodeScale(Actra, "NPC L Breast", False)
    Scale[6] = NetImmerse.GetNodeScale(Actra, "NPC R Breast", False)

    Scale[10] = NetImmerse.GetNodeScale(Actra, "NPC GenitalsBase [GenBase]", False)
    Scale[11] = NetImmerse.GetNodeScale(Actra, "NPC GenitalsScrotum [GenScrot]", False)
    Scale[12] = NetImmerse.GetNodeScale(Actra, "NPC Genitals01 [Gen01]", False)
    Scale[13] = NetImmerse.GetNodeScale(Actra, "NPC Genitals02 [Gen02]", False)
    Scale[14] = NetImmerse.GetNodeScale(Actra, "NPC Genitals03 [Gen03]", False)
    Scale[15] = NetImmerse.GetNodeScale(Actra, "NPC Genitals04 [Gen04]", False)
    Scale[16] = NetImmerse.GetNodeScale(Actra, "NPC Genitals05 [Gen05]", False)
    Scale[17] = NetImmerse.GetNodeScale(Actra, "NPC Genitals06 [Gen06]", False)
    Return Scale
EndFunction

;/
String[] Function ActraHostility(Actor Actra, Actor[] Actro) Global
    String[] Hostile = new String[10]

    Int i = 0
    Int Length = Actro.Length
    While (i < Length)
        Hostile[i] = Actra.IsHostileToActor(Actro[i]) as Int
        ActorBase ActraBase = Actra.GetLeveledActorBase()
        i += 1
    EndWhile

    Return Hostile
EndFunction
/;

Function SendEQSuite(Actor Actra, String FormID, Int Glyph, String CodePage) Global
    Int zSlot = 0
    String[] Eq = new String[73]
    Armor EqCur

    While (zSlot <= 32)
        EqCur = Actra.GetWornForm(GetOSlot(zSlot)) as Armor
        If (EqCur)
            Eq[zSlot] = OSANative.GetFormID(EqCur)

            ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
            ;Eq[zSlot+40] = CPConvert.CPConv(CodePage, "UTF-8", EqCur.GetName())
            Eq[zSlot+40] = OSANative.GetName(EqCur)
        Else
            Eq[zSlot] = 0
            Eq[zSlot+40] = "noeq"
        EndIf
        zSlot += 1
    EndWhile

    Eq[39] = FormID
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraAttireWorn", Eq)
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraWeaponWorn", AnalyzeWeapon(0, Actra, FormID, Glyph, CodePage))
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraWeaponWorn", AnalyzeWeapon(1, Actra, FormID, Glyph, CodePage))
EndFunction

String[] Function AnalyzeWeapon(Int zTrueHand, Actor Actra, String FormID, Int Glyph, String CodePage) Global
    Int zHand = 0
    Int zExHand = 2

    If (zTrueHand == 0)
        zHand = 1
        zExHand = 1
    EndIf

    String[] WepUnit = new String[5]
    WepUnit[0] = FormID
    WepUnit[1] = zTrueHand

    Form zWep = Actra.GetEquippedObject(zHand)
    If (!zWep)
        WepUnit[2] = 0
        WepUnit[3] = "noeq"
        WepUnit[4] = 9
    ElseIf (zWep as Weapon)
        WepUnit[2] = OSANative.GetFormID(zWep)
        ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
        ;WepUnit[3] = CPConvert.CPConv(CodePage, "UTF-8", zWep.GetName())
        ;zWep.GetName()
        WepUnit[4] = "0"
    ElseIf (zWep as Spell)
        WepUnit[2] = OSANative.GetFormID(zWep)
        ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
        ;WepUnit[3] = CPConvert.CPConv(CodePage, "UTF-8", zWep.GetName())
        ;zWep.GetName()
        WepUnit[4] = "1"
    Else
        WepUnit[2] = 0
        WepUnit[3] = "noeq"
        WepUnit[4] = 9
    EndIf

    Return WepUnit
EndFunction

Int Function BindActionKeyPair(Int Index, Int[] KBind, String[] KIndex, Int Glyph) Global
    KBind[Index] = UI.GetInt("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.olib.a" + Index + ".bind")
    KIndex[Index] = UI.GetString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.olib.a" + Index + ".id")
    Return KBind[Index]
EndFunction

Function ScanFolders(Int Glyph) Global
    String[] ScannedFiles = MiscUtil.FilesInFolder("Data/meshes/0SA/mod/__install/mod/",".osmod")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.scan.scanMods", ScannedFiles)
    ScannedFiles = MiscUtil.FilesInFolder("Data/meshes/0SA/mod/__install/plugin/",".osplug")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.scan.scanPlugs", ScannedFiles)
    Utility.wait(0.2)
    ScannedFiles = MiscUtil.FilesInFolder("Data/OSA/Persona/base/identity/",".oiden")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.lib.codex.scanIdentity", ScannedFiles)
    Utility.wait(0.2)
    ScannedFiles = MiscUtil.FilesInFolder("Data/OSA/Persona/base/form",".oform")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.lib.codex.scanForm", ScannedFiles)
EndFunction

Function CleanPositionArray(ObjectReference[] PositionObjArray) Global
    Int i = 0
    Int L = PositionObjArray.Length
    While (i < L)
        If (PositionObjArray[i])
            PositionObjArray[i].Delete()
        EndIf
        i += 1
    EndWhile
EndFunction


; ██╗  ██╗███████╗██╗  ██╗██╗███╗   ██╗ ██████╗
; ██║  ██║██╔════╝╚██╗██╔╝██║████╗  ██║██╔════╝
; ███████║█████╗   ╚███╔╝ ██║██╔██╗ ██║██║  ███╗
; ██╔══██║██╔══╝   ██╔██╗ ██║██║╚██╗██║██║   ██║
; ██║  ██║███████╗██╔╝ ██╗██║██║ ╚████║╚██████╔╝
; ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝
; Functions to convert Actors FormIDs into Hex to use as a serial number for records.
; This is the only concrete way I've found to generate a universal ID that an Actor
; can be searched for in a String format.


; Converts the first two Hex of the Actor's Hex into a Mod Name (Minus the .esp or .esm)
String Function IDSerial_Name(String zHex) Global
    String TempMod = Game.GetModName(ModNameHex10(zHex))
    Return StringUtil.SubString(TempMod, 0, StringUtil.Find(TempMod, ".es"))
EndFunction

String Function HeHexMe(String zHex) Global
    Int HexL = StringUtil.GetLength(zHex)
    If (HexL == 7)
        Return StringUtil.Substring(zHex, 1)
    ElseIf (HexL == 8)
        Return StringUtil.Substring(zHex, 2)
    ElseIf (HexL == 6)
        Return zHex
    ElseIf (HexL == 5)
        Return "0" + zHex
    ElseIf (HexL == 4)
        Return "00" + zHex
    ElseIf (HexL == 3)
        Return "000" + zHex
    ElseIf (HexL == 2)
        Return "0000" + zHex
    ElseIf (HexL == 1)
        Return "00000" + zHex
    ElseIf (HexL == 0)
        Return "000000" + zHex
    EndIf
EndFunction

String Function IntToHex(Int Dez) Global
    String Hex = ""
    Int Rest = Dez
    While (Rest > 0)
        Int m16 = Rest % 16
        Rest = Rest / 16
        String Temp = ""
        If (m16 > 0 && m16 < 10)
            Temp = (m16 as String)
        ElseIf (m16 == 10)
            Temp = "A"
        ElseIf (m16 == 11)
            Temp = "B"
        ElseIf (m16 == 12)
            Temp = "C"
        ElseIf (m16 == 13)
            Temp = "D"
        ElseIf (m16 == 14)
            Temp = "E"
        ElseIf (m16 == 15)
            Temp = "F"
        Else
            Temp = "0"
        EndIf
        Hex = Temp + Hex
    EndWhile
    Return Hex
EndFunction

Int Function HexTo10(String zHex) Global
    Int AsInt = (zHex as Int)
    If (AsInt > 0 && AsInt < 10)
        Return AsInt
    ElseIf (zHex == "A" || zHex == "a")
        Return 10
    ElseIf (zHex == "B" || zHex == "b")
        Return 11
    ElseIf (zHex == "C" || zHex == "c")
        Return 12
    ElseIf (zHex == "D" || zHex == "d")
        Return 13
    ElseIf (zHex == "E" || zHex == "e")
        Return 14
    ElseIf (zHex == "F" || zHex == "f")
        Return 15
    EndIf
    Return 0
EndFunction

Int Function ModNameHex10(String zHex) Global
    Int Len = StringUtil.GetLength(zHex)
    If (Len == 7)
        Return HexTo10(StringUtil.GetNthChar(zHex, 0))
    ElseIf (Len == 8)
        Int x1 = HexTo10(StringUtil.GetNthChar(zHex, 0))
        Int x2 = HexTo10(StringUtil.GetNthChar(zHex, 1))
        Return (x1 * 16) + x2
    EndIf
EndFunction

; To get equipped item by slot through the SKSE Function you can't just put in 45 to get slot 45 for example.
; If I was checking slot 45 EquipSlot would be 45.

; Since I get slot masks in a lot of cases checking slots 30-62 all at once i use a While + array[i] set up
; getOSlot is for the array set up so I can start from 0,  Slot 30 = 0 etc. basicaly. getSlot would take the standard slot number "30"
Int Function GetOSlot(Int EqSlot) Global
    Return Math.Pow(2, EqSlot) as Int
EndFunction

Int Function GetSlot(Int EqSlot) Global
    Return Math.Pow(2, EqSlot - 30) as Int
EndFunction


; ███╗   ███╗███████╗ ██████╗        ██╗       ███████╗ ██████╗ █████╗ ██╗     ███████╗
; ████╗ ████║██╔════╝██╔════╝        ██║       ██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
; ██╔████╔██║█████╗  ██║  ███╗    ████████╗    ███████╗██║     ███████║██║     █████╗
; ██║╚██╔╝██║██╔══╝  ██║   ██║    ██╔═██╔═╝    ╚════██║██║     ██╔══██║██║     ██╔══╝
; ██║ ╚═╝ ██║██║     ╚██████╔╝    ██████║      ███████║╚██████╗██║  ██║███████╗███████╗
; ╚═╝     ╚═╝╚═╝      ╚═════╝     ╚═════╝      ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
; Softly blend adjusts for MFG console & Node Scale.


; Blends MFG Modifier.
Function BlendMo(Actor Actra, Int zGoal, Int zCur, Int zMode, Int zSpeed) Global
    zGoal = PapyrusUtil.ClampInt(zGoal, 0, 100)
    zCur = PapyrusUtil.ClampInt(zCur, 0, 100)
    zSpeed = PapyrusUtil.SignInt(zGoal < zCur, zSpeed)
    If (zSpeed != 0)
        While (zCur != zGoal)
            zCur += zSpeed
            If (zSpeed > 0 && zCur > zGoal || zSpeed < 0 && zCur < zGoal)
                zCur = zGoal
            EndIf
            MfgConsoleFunc.SetModifier(Actra, zMode, zCur)
        EndWhile
    EndIf
EndFunction

; Blends MFG Phonome.
Function BlendPh(Actor Actra, Int zGoal, Int zCur, Int zMode, Int zSpeed) Global
    zGoal = PapyrusUtil.ClampInt(zGoal, 0, 100)
    zCur = PapyrusUtil.ClampInt(zCur, 0, 100)
    zSpeed = PapyrusUtil.SignInt(zGoal < zCur, zSpeed)
    If (zSpeed != 0)
        While (zCur != zGoal)
            zCur += zSpeed
            If (zSpeed > 0 && zCur > zGoal || zSpeed < 0 && zCur < zGoal)
                zCur = zGoal
            EndIf
            MfgConsoleFunc.SetPhoneme(Actra, zMode, zCur)
        EndWhile
    EndIf
EndFunction

; Blends NiNode Scale.
Function BlendSc(Actor Actra, float zGoal, float zCur, String zNode, float zSpeed) Global
    If (zCur != zGoal)
        If (zCur >= zGoal)
            zCur -= zSpeed
            If (zCur <= zGoal)
                zCur = zGoal
            EndIf
            NetImmerse.SetNodeScale(Actra, zNode, zCur, False)
            BlendSC(Actra, zGoal, zCur, zNode, zSpeed)
        ElseIf (zCur <= zGoal)
            zCur += zSpeed
            If (zCur >= zGoal)
                zCur = zGoal
            EndIf
            NetImmerse.SetNodeScale(Actra, zNode, zCur, False)
            BlendSC(Actra, zGoal, zCur, zNode, zSpeed)
        EndIf
    EndIf
EndFunction


;  ██████╗ ██████╗  ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
; ██╔════╝██╔═══██╗██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
; ██║     ██║   ██║██║   ██║██████╔╝██║  ██║██║██╔██╗ ██║███████║   ██║   ██║██║   ██║██╔██╗ ██║
; ██║     ██║   ██║██║   ██║██╔══██╗██║  ██║██║██║╚██╗██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
; ╚██████╗╚██████╔╝╚██████╔╝██║  ██║██████╔╝██║██║ ╚████║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
;  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
; Functions related to coordinating the sub spells Actro and Actra and the UI


Function GameLoaded() Global
    Int a = ModEvent.Create("0S_LoadGame")
    If (a)
        ModEvent.Send(a)
    EndIf
EndFunction

; When an Actra completes it's set up it "Reveals" itself (Actor) to the Global
; Actro script so it can have access to all the actors in the scene.
Function ActraReveal(Actor Actra, String ActorID, String zPass) Global
    Int a = ModEvent.Create("0SAO" + zPass + "_ActraReveal")
    If (a)
        ModEvent.PushForm(a, Actra)
        ModEvent.PushString(a, ActorID)
        ModEvent.Send(a)
    EndIf
EndFunction

Function OEND(String zPass) Global
    Int x = ModEvent.Create("0S0" + zPass + "_OEND")
    If (x)
        ModEvent.Send(x)
    EndIf
EndFunction

Function ActroReady(String StageID) Global
    Int a = ModEvent.Create("0S0" + StageID + "_StageReady")
    If (a)
        ModEvent.Send(a)
    EndIf
EndFunction

Function AlignActraStage(String ActraID) Global
    Int a = ModEvent.Create("0SAA" + ActraID + "_AlignStage")
    If (a)
        ModEvent.Send(a)
    EndIf
EndFunction

; Calibrating Scale involves putting the actors in a TPose animation to be measured.
; The issue is certain game animations takes priority over playing scene animations (Sitting Standing Sheathing weapon etc.)
; Calibrate Spam, rapidly sends the request to play the OS-Tpose animation until the animation actually starts.
; When it does start it's received by an OnAnimationEvent and the spam is canceled.
Function TPoseSpam(String ActraID) Global
    Int a = ModEvent.Create("0Temp" + ActraID + "_TPoseSpam")
    If (a)
        ModEvent.Send(a)
    EndIf
EndFunction


; ███████╗███████╗ ██████╗     ██╗   ██╗██████╗ ██╗      ██████╗  █████╗ ██████╗
; ██╔════╝██╔════╝██╔════╝     ██║   ██║██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗
; █████╗  ███████╗██║  ███╗    ██║   ██║██████╔╝██║     ██║   ██║███████║██║  ██║
; ██╔══╝  ╚════██║██║   ██║    ██║   ██║██╔═══╝ ██║     ██║   ██║██╔══██║██║  ██║
; ███████╗███████║╚██████╔╝    ╚██████╔╝██║     ███████╗╚██████╔╝██║  ██║██████╔╝
; ╚══════╝╚══════╝ ╚═════╝      ╚═════╝ ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝
; Functions related to the game recording information about actors equipmen and sending it to the UI.


; I use an event to multithread the process since there is some small time factor involved with
; processing 30 slots per Actor and I want the delay on starting the scene to be minimal.
; This function calls the event.
Function EquipmentUpload(String ActraID) Global
    Int a = ModEvent.Create("0SEQ" + ActraID + "_UploadEQ")
    If (a)
        ModEvent.Send(a)
    EndIf
EndFunction

Function ActorLight(Actor Actra, String zWhich, Spell[] LSP, MagicEffect[] LME) Global
    If (zWhich == "FaceBright")
        If Actra.HasMagicEffect(LME[1])
            LSP[1].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[2])
            LSP[2].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[3])
            LSP[3].Cast(Actra, Actra)
        EndIf
        LSP[0].Cast(Actra, Actra)
    ElseIf (zWhich == "FaceDim")
        If Actra.HasMagicEffect(LME[0])
            LSP[0].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[2])
            LSP[2].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[3])
            LSP[3].Cast(Actra, Actra)
        EndIf
        LSP[1].Cast(Actra, Actra)
    ElseIf (zWhich == "AssBright")
        If Actra.HasMagicEffect(LME[0])
            LSP[0].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[1])
            LSP[1].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[3])
            LSP[3].Cast(Actra, Actra)
        EndIf
        LSP[2].Cast(Actra, Actra)
    ElseIf (zWhich == "AssDim")
        If Actra.HasMagicEffect(LME[0])
            LSP[0].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[1])
            LSP[1].Cast(Actra, Actra)
        Elseif Actra.HasMagicEffect(LME[2])
            LSP[2].Cast(Actra, Actra)
        EndIf
        LSP[3].Cast(Actra, Actra)
    ElseIf (zWhich == "Remove")
        If Actra.HasMagicEffect(LME[0])
            ActorLight(Actra, "FaceBright", LSP, LME)
        EndIf
        If Actra.HasMagicEffect(LME[1])
            ActorLight(Actra, "FaceDim", LSP, LME)
        EndIf
        If Actra.HasMagicEffect(LME[2])
            ActorLight(Actra, "AssBright", LSP, LME)
        EndIf
        If Actra.HasMagicEffect(LME[3])
            ActorLight(Actra, "AssDim", LSP, LME)
        EndIf
    EndIf
EndFunction

Function OGlyphSet(GlobalVariable Glyph, Int Identifier) Global
    Glyph.SetValue(Identifier)
EndFunction


;  █████╗ ██████╗ ██╗   ██╗
; ██╔══██╗██╔══██╗██║   ██║
; ███████║██║  ██║██║   ██║
; ██╔══██║██║  ██║╚██╗ ██╔╝
; ██║  ██║██████╔╝ ╚████╔╝ ██╗
; ╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝
;  ██████╗ ██╗     ██╗   ██╗██████╗ ██╗  ██╗
; ██╔════╝ ██║     ╚██╗ ██╔╝██╔══██╗██║  ██║
; ██║  ███╗██║      ╚████╔╝ ██████╔╝███████║
; ██║   ██║██║       ╚██╔╝  ██╔═══╝ ██╔══██║
; ╚██████╔╝███████╗   ██║   ██║     ██║  ██║
;  ╚═════╝ ╚══════╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝
; Lighter Glyphs with no checks
; For internal OSA use when checks aren't needed to
; speed up the process.


Function OSendO(String zMethod, Int Glyph) Global
    UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod)
EndFunction

Function OSendI(String zMethod, Int zInt, Int Glyph) Global
    UI.InvokeInt("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod, zInt)
EndFunction

Function OSendS(String zMethod, String zString, Int Glyph) Global
    UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod, zString)
EndFunction

Function OSendSS(String zMethod, String[] zStringArray, Int Glyph) Global
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod, zStringArray)
EndFunction

String Function OGetS(String Path, Int Glyph) Global
    Return UI.GetString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + Path)
EndFunction

Int Function OGetI(String Path,Int Glyph) Global
    Return UI.GetInt("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + Path)
EndFunction


;  ██████╗ ███████╗ █████╗
; ██╔═══██╗██╔════╝██╔══██╗
; ██║   ██║███████╗███████║
; ██║   ██║╚════██║██╔══██║
; ╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚══════╝╚═╝  ╚═╝
; ███████╗██╗  ██╗████████╗███████╗███╗   ██╗██████╗ ███████╗██████╗
; ██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
; █████╗   ╚███╔╝    ██║   █████╗  ██╔██╗ ██║██║  ██║█████╗  ██║  ██║
; ██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██║  ██║
; ███████╗██╔╝ ██╗   ██║   ███████╗██║ ╚████║██████╔╝███████╗██████╔╝
; ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═════╝

; Functions that assist the OSA script that holds functions
; for papyrus developers to directly call.
;
; These are quarantined here because they are in support to
; the OSA functions and not intended to be called directly through papyrus.


; Checks to see If the Actor is an acceptable candidate before sending them to be Actra infused.
Bool Function CheckActra(String StageID, Actor Actra, faction StatusFaction = None, Bool Creature = False) Global
    If (StatusFaction)
        If (Actra.GetFactionRank(StatusFaction) != 1)
            If (OSA.IsAllowed(Actra, Creature))
                Return True
            EndIf
        EndIf
    Else
        If (OSA.IsAllowed(Actra, Creature))
            Return True
        EndIf
    EndIf
    Return False
EndFunction

Function SystemReport() Global
    String[] Log = new String[49]

    Log[0] = "SystemReport"
    Log[1] = Utility.GetINIString("sLanguage:General")
    Log[2] = (Quest.GetQuest("0SA") as _oOmni).CodePage

    If (NetImmerse.HasNode(Game.GetPlayer(), "NPC GenitalsBase [GenBase]", False))
        Log[3] = 1
    Else
        Log[3] = 0
    EndIf

    Log[4] = ""
    Log[5] = ""
    Log[6] = ""
    Log[7] = ""
    Log[8] = ""
    Log[9] = ""
    Log[10] = _oV.GetScriptVersion_s()
    Log[11] = _oV.GetBracket_s()
    Log[12] = _oV.GetIVersion() as String
    Log[13] = SKSE.GetPluginVersion("OSA")

    Log[20] = SKSE.getVersion()
    Log[21] = SKSE.GetPluginVersion("chargen")
    Log[22] = SKSE.GetPluginVersion("CPConvert")
    Log[23] = SKSE.GetPluginVersion("papyrusutil plugin")
    Log[24] = PapyrusUtil.GetVersion()
    Log[25] = SKSE.GetPluginVersion("nioverride")
    ;Log[26] = NiOverride.GetScriptVersion()
    Log[27] = SKSE.GetPluginVersion("Mfg Console plugin")
    Log[28] = SKSE.GetPluginVersion("SchlongsOfSkyrim")

    Log[40] = SKSE.GetPluginVersion("CrashFixPlugin")
    Log[41] = SKSE.GetPluginVersion("hdtHighHeelNative")
    Log[42] = SKSE.GetPluginVersion("hdtPhysicsExtensions")
    Log[43] = SKSE.GetPluginVersion("hdtSkinnedMeshPhysics")
    Log[44] = SKSE.GetPluginVersion("hdtSkyrimMemPatch")
    Log[45] = SKSE.GetPluginVersion("OneTweak")
    Log[46] = SKSE.GetPluginVersion("Safety Load plugin")
    Log[47] = SKSE.GetPluginVersion("ShowRaceMenu preCacheKiller plugin")
    Log[48] = SKSE.GetPluginVersion("SkyrimReloaded")

    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + (Quest.GetQuest("0SA") as _oOmni).Glyph + ".widget.com.skyReport", Log)
EndFunction

Bool Function OStimGlobalLoaded() Global
    Return True
EndFunction
