Scriptname _oGlobal


; ██████╗ ███████╗ █████╗      ██████╗ ██╗      ██████╗ ██████╗  █████╗ ██╗                                                                                           
;██╔═══██╗██╔════╝██╔══██╗    ██╔════╝ ██║     ██╔═══██╗██╔══██╗██╔══██╗██║                                                                                           
;██║   ██║███████╗███████║    ██║  ███╗██║     ██║   ██║██████╔╝███████║██║                                                                                           
;██║   ██║╚════██║██╔══██║    ██║   ██║██║     ██║   ██║██╔══██╗██╔══██║██║                                                                                           
;╚██████╔╝███████║██║  ██║    ╚██████╔╝███████╗╚██████╔╝██████╔╝██║  ██║███████╗                                                                                      
; ╚═════╝ ╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                                                      
;█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗                                                                                       
;╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝ 
;OSA Global Script, holds all global functions that the OSA family of scripts share. 
;Mainly used by multiple instances of the Actra script.





String function GetFormID_s(Form zForm) global
    String ModID = IntToHex(Math.RightShift(zForm.GetFormID(), 24))
    String SubID = IntToHex(Math.LogicalAnd(0x00FFFFFF, zForm.GetFormID()))
    If ModID == ""
        ModID = "00"
    ElseIf StringUtil.getLength(ModID) < 2
        ModID = "0" + ModID
    EndIf

    int SubLen = StringUtil.getLength(SubID)

    If SubLen == 0
        SubID = "000000"
    ElseIf SubLen == 1
        SubID = "00000" + SubID
    ElseIf SubLen == 2
        SubID = "0000" + SubID
    ElseIf SubLen == 3
        SubID = "000" + SubID
    ElseIf SubLen == 4
        SubID = "00" + SubID
    ElseIf SubLen == 5
        SubID = "0" + SubID
    EndIf

    return ModID + SubID
endFunction


bool function directionCheck_D(actor initiator, actor target, int min, int max) global
float angle = target.GetHeadingAngle(initiator)
if angle < 0 
    angle = 180 + (180+angle)
endif
if angle > min && angle < max
return true
else    
return false
endif
endFunction

; █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗ ██████╗ ███████╗██████╗                                                                                        
;██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔════╝██╔══██╗                                                                                       
;███████║██║        ██║   ██║   ██║██████╔╝    ██████╔╝██████╔╝█████╗  ██████╔╝                                                                                       
;██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔═══╝ ██╔══██╗██╔══╝  ██╔═══╝                                                                                        
;██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██║     ██║  ██║███████╗██║                                                                                            
;╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝         
;Functions that prepare the actors to perform in the scene and counter functions.


;Performs a series of random skyrim locks on the actors so they don't repel each other during a scene.
function actorLock(actor actra, actor player) global
     If player == actra
        Game.ForceThirdPerson()
        Game.SetPlayerAIDriven()
        Game.DisablePlayerControls(false, false, false, false, false, false, true, false, 0)
    else
        actra.SetRestrained(true)
        actra.SetDontMove(true)
    endIf
endFunction

;Disables all locking stuff used in OSA,
;also reverts their footIK to normal and puts them back into an idle animation
function actorUnlock(actor actra, actor player) global
     If player == actra
        Game.SetPlayerAIDriven(false)
        Game.EnablePlayerControls()
    else
        actra.SetRestrained(False)
        actra.SetDontMove(False)

    endIf
    actra.StopTranslation()
    actra.SetVehicle(None)
    actra.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
    Debug.SendAnimationEvent(actra, "IdleForceDefaultState")
endFunction

function actorSmoothUnlock(actor actra, actor player, float Xp, float Yp) global
     If player == actra
        Game.SetPlayerAIDriven(false)
        Game.EnablePlayerControls()
    else
        actra.SetRestrained(False)
        actra.SetDontMove(False)

    endIf
    actra.StopTranslation()
    actra.SetVehicle(None)
    actra.setPosition(Xp, Yp, actra.z)
    actra.SplineTranslateTo(Xp, Yp, actra.z, actra.GetAngleX(), actra.GetAngley(), actra.GetAnglez(), 1.0, 70, 0)
    actra.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
    Debug.SendAnimationEvent(actra, "IdleForceDefaultState")
endFunction

;Overwrites the actor's package with a DoNothing package.
function packageSquelch(actor actra, package[] oPackage) global
     ActorUtil.AddPackageOverride(actra, oPackage[0], 100, 1)
                actra.EvaluatePackage()
endFunction

;Reverse the above squelch package override.
Function packageClean(actor actra, package[] oPackage) global
ActorUtil.RemovePackageOverride(actra, oPackage[0])
actra.EvaluatePackage()
EndFunction

;Cleans all factions used by OSA from an actor.
Function FactionClean(actor actra, faction[] OFaction) global
actra.RemoveFromFaction(OFaction[0])
actra.RemoveFromFaction(OFaction[1])
actra.RemoveFromFaction(OFaction[2])
EndFunction

Function sheathWep(actor actra, actor player) global
    If actra == player && actra.IsWeaponDrawn() 
        actra.SheatheWeapon()
    EndIf
EndFunction

;██████╗  ██████╗ ███████╗██╗████████╗██╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗                                                                                     
;██╔══██╗██╔═══██╗██╔════╝██║╚══██╔══╝██║██╔═══██╗████╗  ██║██║████╗  ██║██╔════╝                                                                                     
;██████╔╝██║   ██║███████╗██║   ██║   ██║██║   ██║██╔██╗ ██║██║██╔██╗ ██║██║  ███╗                                                                                    
;██╔═══╝ ██║   ██║╚════██║██║   ██║   ██║██║   ██║██║╚██╗██║██║██║╚██╗██║██║   ██║                                                                                    
;██║     ╚██████╔╝███████║██║   ██║   ██║╚██████╔╝██║ ╚████║██║██║ ╚████║╚██████╔╝                                                                                    
;╚═╝      ╚═════╝ ╚══════╝╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝    


Function getStageLoc(actor actra, float[] loc) global
loc [0] = actra.GetPositionX()    
loc [1] = actra.GetPositionY()
loc [2] = actra.GetPositionZ()
loc [3] = actra.GetAngleX()
loc [4] = actra.GetAngleY()
loc [5] = actra.GetAngleZ()
EndFunction

float[] Function getStageLocArray(objectReference actra) global
float[] loc = new float[6] 
loc [0] = actra.GetPositionX()    
loc [1] = actra.GetPositionY()
loc [2] = actra.GetPositionZ()
loc [3] = actra.GetAngleX()
loc [4] = actra.GetAngleY()
loc [5] = actra.GetAngleZ()

Return loc
EndFunction




function enforceAngle(actor actra, float[] loc) Global
            if Math.Abs(actra.GetAngleZ() - loc[5]) > 0.5    
            actra.SetAngle(loc[3], loc[4], loc[5])
            EndIf
EndFunction

function enforcePosition(actor actra, ObjectReference stageSpot, float[] loc) Global
            If actra.GetDistance(stageSpot) > 0.5
            actra.SetPosition(loc[0], loc[1], loc[2])
                    actra.SetVehicle(stageSpot)  
            EndIf  
                   actra.SplineTranslateTo(loc[0], loc[1], loc[2], loc[3], loc[4], loc[5], 1.0, 10000, 0.0001)
                   actra.SetVehicle(stageSpot) 
EndFunction





string[] function sendActraDetails(actor actra, string FormID, _oOmni oso) global

If (!CPConvert.CPIsValid(oso.codepage))
    ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
    ;Debug.Notification(oso.codepage + " is not a valid codepage value!")
EndIf




actorBase ActB = actra.GetActorBase()
string[] details = new string[20]
details[0] = FormID
details[1] = actra.getFormId()
;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
;details[2] = CPConvert.CPConv(oso.codepage, "UTF-8", ActB.GetName())
details[2] = ActB.GetName()

details[3] = ActB.GetSex()
if actra == oso.PlayerRef
details[4] = "1"
consoleUtil.SetSelectedReference(none)
consoleutil.executeCommand("tcl")
actra.SetScale(1.0)
consoleutil.executeCommand("tcl")
Else
actra.SetScale(1.0)
details[4] = "0"
details[10] = details[0] ; it is now already a string in hex
details[11] = Game.GetModName(ModNameHex10(details[10]))
details[10] = StringUtil.SubString(details[10], 2) ; last 6 of hex
details[12] = stringUtil.SubString(Details[11], 0, StringUtil.Find(details[11], ".es"))
details[13] = details[12]+details[10]
EndIf
details[8] = ActB.GetWeight()
details[7] = ActB.GetVoiceType().getFormId()


   ;if !noMove
   ;if actra != PlayerRef
   ;     if actra.GetSitState() > 2 || actra.GetSleepState() > 2
   ;     Debug.SendAnimationEvent(actra, "Reset")
   ;     Debug.SendAnimationEvent(actra, "ReturnToDefault")
   ;     Debug.SendAnimationEvent(actra, "ForceFurnExit")
   ;     Actra.MoveTo(PlayerRef, (40 * Math.Sin(PlayerRef.GetAngleZ())), (40 * Math.Cos(PlayerRef.GetAngleZ())), 0.0, abMatchRotation = false)
   ;     endif
   ; endif
   ; endIf

;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
;details[6] = CPConvert.CPConv(oso.codepage, "UTF-8", ActB.GetRace().GetName())
details[6] = ActB.GetRace().GetName()

details[5] = actra.getScale()


return details
endfunction



string[] function sendActraScale(actor actra, string FormID) global
string[] scale = new string[20]
scale[0] = FormID
scale[1] = NetImmerse.GetNodeScale(actra, "NPC Root [Root]", False)
scale[2] = NetImmerse.GetNodeScale(actra, "NPC Belly", False)
scale[3] = NetImmerse.GetNodeScale(actra, "NPC L Butt", False)
scale[4] = NetImmerse.GetNodeScale(actra, "NPC R Butt", False)
scale[5] = NetImmerse.GetNodeScale(actra, "NPC L Breast", False)
scale[6] = NetImmerse.GetNodeScale(actra, "NPC R Breast", False)

scale[10] = NetImmerse.GetNodeScale(actra, "NPC GenitalsBase [GenBase]", False)
scale[11] = NetImmerse.GetNodeScale(actra, "NPC GenitalsScrotum [GenScrot]", False)
scale[12] = NetImmerse.GetNodeScale(actra, "NPC Genitals01 [Gen01]", False)
scale[13] = NetImmerse.GetNodeScale(actra, "NPC Genitals02 [Gen02]", False)
scale[14] = NetImmerse.GetNodeScale(actra, "NPC Genitals03 [Gen03]", False)
scale[15] = NetImmerse.GetNodeScale(actra, "NPC Genitals04 [Gen04]", False)
scale[16] = NetImmerse.GetNodeScale(actra, "NPC Genitals05 [Gen05]", False)
scale[17] = NetImmerse.GetNodeScale(actra, "NPC Genitals06 [Gen06]", False)
return scale
EndFunction


string[] function actraHostility(actor actra, actor[] actro) global 
string[] hostile= new string[10]

int i = 0
int L = actro.length
while i < L
hostile[i] = actra.IsHostileToActor(actro[i]) as int  
ActorBase actraBase = actra.GetLeveledActorBase()
i+=1
endwhile
EndFunction


function SendEQSuite(actor actra, string formID, int glyph, string codePage) global
int zSlot = 0
string[] Eq = new string[73]
armor EqCur
While zSlot <= 32
EqCur = Actra.GetWornForm(getOSlot(zSlot)) as armor
If EqCur
Eq[zSlot] = EqCur.getFormID()

;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
;Eq[zSlot+40] = CPConvert.CPConv(codePage, "UTF-8", EqCur.getName())
Eq[zSlot+40] = EqCur.getName()
Else
Eq[zSlot] = 0
Eq[zSlot+40] = "noeq"   
EndIf
zSlot += 1
EndWhile
Eq[39] = formID
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraAttireWorn", Eq)
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraWeaponWorn", analyzeWeapon(0, actra, formID, glyph, codePage))
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraWeaponWorn", analyzeWeapon(1, actra, formID, glyph, codePage))
endFunction


string[] Function analyzeWeapon(int zTrueHand, actor actra, string formID, int glyph, string codePage) global
int zHand
int zExHand
If zTrueHand == 0
zHand = 1
zExHand = 1
Else
zHand = 0
zExHand = 2
EndIf

string[] WepUnit = new String[5]
WepUnit[0] = formID
WepUnit[1] = zTrueHand
Form zWep = Actra.GetEquippedObject(zHand)

If !zWep
    WepUnit[2] = 0
    WepUnit[3] = "noeq"
    WepUnit[4] = 9
ElseIf (zWep as Weapon)
    WepUnit[2] = zWep.getFormID()
    ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
    ;WepUnit[3] = CPConvert.CPConv(codePage, "UTF-8", zWep.getName())
    zWep.getName()
    WepUnit[4] = "0"
ElseIf (zWep as Spell)
    WepUnit[2] = zWep.getFormID()
    ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
    ;WepUnit[3] = CPConvert.CPConv(codePage, "UTF-8", zWep.getName())
    zWep.getName()
    WepUnit[4] = "1"    
Else
    WepUnit[2] = 0
    WepUnit[3] = "noeq"
    WepUnit[4] = 9
EndIf

return WepUnit
EndFunction





int function bindActionKeyPair(int index, int[] KBind, string[] KIndex, int glyph) global

KBind[index] = UI.GetInt("HUD Menu", "_root.WidgetContainer."+glyph+".widget.olib.a"+index+".bind")
KIndex[index] = UI.GetString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.olib.a"+index+".id")
return KBind[index]
endFunction





function scanFolders(int glyph) global
    String[] scanedFiles = MiscUtil.FilesInFolder("Data/meshes/0SA/mod/__install/mod/",".osmod")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.scan.scanMods", scanedFiles)
    scanedFiles = MiscUtil.FilesInFolder("Data/meshes/0SA/mod/__install/plugin/",".osplug")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.scan.scanPlugs", scanedFiles)
    
    utility.wait(0.2)
    scanedFiles = MiscUtil.FilesInFolder("Data/OSA/Persona/base/identity/",".oiden")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.lib.codex.scanIdentity", scanedFiles)
    utility.wait(0.2)
    scanedFiles = MiscUtil.FilesInFolder("Data/OSA/Persona/base/form",".oform")
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.lib.codex.scanForm", scanedFiles)
endFunction



















function cleanPositionArray(objectReference[] positionObjArray) global
int i = 0
int L = positionObjArray.length
while i < L
    if positionObjArray[i]
        positionObjArray[i].Delete()
    endif
    i+=1
endWhile
endFunction





;██╗  ██╗███████╗██╗  ██╗██╗███╗   ██╗ ██████╗                                                                                                                        
;██║  ██║██╔════╝╚██╗██╔╝██║████╗  ██║██╔════╝                                                                                                                        
;███████║█████╗   ╚███╔╝ ██║██╔██╗ ██║██║  ███╗                                                                                                                       
;██╔══██║██╔══╝   ██╔██╗ ██║██║╚██╗██║██║   ██║                                                                                                                       
;██║  ██║███████╗██╔╝ ██╗██║██║ ╚████║╚██████╔╝                                                                                                                       
;╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝  
;Functions to convert Actors FormIDs into Hex to use as a serial number for records.
;This is the only concrete way I've found to generate a universal ID that an actor
;can be searched for in a string format.


;Converts the first two Hex of the actor's Hex into a Mod Name (Minus the .esp or .esm) 
string Function IDSerial_Name(string zHex) global
    String TempMod = Game.GetModName(ModNameHex10(zHex))
    Return StringUtil.SubString(TempMod, 0, StringUtil.Find(TempMod, ".es"))
EndFunction


String Function HeHexMe(string zHex) global
    Int HexL = StringUtil.getLength(zHex)
        
        If HexL == 7
        Return StringUtil.Substring(zHex, 1)
        ElseIf HexL == 8
        Return StringUtil.Substring(zHex, 2)
        ElseIf HexL == 6
        Return zHex
        ElseIf HexL == 5
        Return "0"+zHex
        ElseIf HexL == 4
        Return "00"+zHex
        ElseIf HexL == 3
        Return "000"+zHex
        ElseIf HexL == 2
        Return "0000"+zHex
        ElseIf HexL == 1
        Return "00000"+zHex
        ElseIf HexL == 0
        Return "000000"+zHex 
        EndIf

EndFunction



String function IntToHex (int dez) global
    String hex = ""
    int rest = dez
    while (rest > 0)
        int m16 = rest % 16
        rest = rest / 16
        String temp = ""
        if (m16 == 1)
            temp = "1"
        elseif (m16 == 2)
            temp = "2"
        elseif (m16 == 3)
            temp = "3"
        elseif (m16 == 4)
            temp = "4"
        elseif (m16 == 5)
            temp = "5"
        elseif (m16 == 6)
            temp = "6"
        elseif (m16 == 7)
            temp = "7"
        elseif (m16 == 8)
            temp = "8"
        elseif (m16 == 9)
            temp = "9"
        elseif (m16 == 10)
            temp = "A"
        elseif (m16 == 11)
            temp = "B"
        elseif (m16 == 12)
            temp = "C"
        elseif (m16 == 13)
            temp = "D"
        elseif (m16 == 14)
            temp = "E"
        elseif (m16 == 15)
            temp = "F"
        else
            temp = "0"
        endif
        hex = temp + hex
    endWhile
    return hex
endFunction


Int Function HexTo10(String zHex) global

        If (zHex == "1")
            Return 1
        ElseIf (zHex == "2")
            Return 2
        ElseIf (zHex == "3")
            Return 3
        ElseIf (zHex == "4")
            Return 4
        ElseIf (zHex == "5")
            Return 5
        ElseIf (zHex == "6")
            Return 6
        ElseIf (zHex == "7")
            Return 7
        ElseIf (zHex == "8")
            Return 8
        ElseIf (zHex == "9")
            Return 9
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
        Else
            Return 0
        EndIf
EndFunction

Int Function ModNameHex10(string zHex) global

        If StringUtil.getLength(zHex) == 7
        Return HexTo10(StringUtil.GetNthChar(zHex, 0))
        ElseIf StringUtil.getLength(zHex) == 8
        int x1 = HexTo10(StringUtil.GetNthChar(zHex, 0))
        int x2 = HexTo10(StringUtil.GetNthChar(zHex, 1))
        Return (x1*16) + x2 
        EndIf

EndFunction


;To get equipped item by slot through the SKSE function you can't just put in 45 to get slot 45 for example.
;If I was checking slot 45 EquipSlot would be 45.

;Since I get slot masks in a lot of cases checking slots 30-62 all at once i use a While + array[i] set up
;getOSlot is for the array set up so I can start from 0,  Slot 30 = 0 etc. basicaly. getSlot would take the standard slot number "30"
Int Function getOSlot(Int EqSlot) global
    Return Math.Pow(2, EqSlot) as Int
EndFunction   


Int Function getSlot(Int EqSlot) global
    Return Math.Pow(2, EqSlot - 30) as Int
EndFunction   


;███╗   ███╗███████╗ ██████╗        ██╗       ███████╗ ██████╗ █████╗ ██╗     ███████╗                                                                                
;████╗ ████║██╔════╝██╔════╝        ██║       ██╔════╝██╔════╝██╔══██╗██║     ██╔════╝                                                                                
;██╔████╔██║█████╗  ██║  ███╗    ████████╗    ███████╗██║     ███████║██║     █████╗                                                                                  
;██║╚██╔╝██║██╔══╝  ██║   ██║    ██╔═██╔═╝    ╚════██║██║     ██╔══██║██║     ██╔══╝                                                                                  
;██║ ╚═╝ ██║██║     ╚██████╔╝    ██████║      ███████║╚██████╗██║  ██║███████╗███████╗                                                                                
;╚═╝     ╚═╝╚═╝      ╚═════╝     ╚═════╝      ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝   
;Softly blend adjusts for MFG console & Node Scale.


;Blends MFG Modifier.
Function blendMo(actor actra, int zGoal, int zCur, int zMode, int zSpeed) global
If zCur > zGoal
    While zCur > zGoal
    zCur -= zSpeed
    MfgConsoleFunc.SetModifier(actra, zMode, papyrusUtil.ClampInt(zCur, 0, 100))
    EndWhile
ElseIf zCur < zGoal
    While zCur < zGoal
    zCur += zSpeed
    MfgConsoleFunc.SetModifier(actra, zMode, papyrusUtil.ClampInt(zCur, 0, 100))
    EndWhile
EndIf   
EndFunction


;Blends MFG Phonome.
Function blendPh(actor actra, int zGoal, int zCur, int zMode, int zSpeed) global     
If zCur > zGoal
    While zCur > zGoal
    zCur -= zSpeed
    MfgConsoleFunc.SetPhoneme(actra, zMode, papyrusUtil.ClampInt(zCur, 0, 100))
    EndWhile
ElseIf zCur < zGoal
    While zCur < zGoal
    zCur += zSpeed
    MfgConsoleFunc.SetPhoneme(actra, zMode, papyrusUtil.ClampInt(zCur, 0, 100))
    EndWhile
EndIf   
EndFunction


;Blends NiNode Scale.
Function blendSc(actor actra, float zGoal, float zCur, string zNode, float zSpeed) global
If zCur != zGoal 
    If zCur >= zGoal 
        zCur -= zSpeed
        If zCur <= zGoal
            zCur = zGoal
        EndIf
    NetImmerse.SetNodeScale(actra, zNode, zCur, False)
    blendSC(actra, zGoal, zCur, zNode, zSpeed)
    ElseIf zCur <= zGoal
        zCur += zSpeed
        If zCur >= zGoal
            zCur = zGoal
        EndIf
            NetImmerse.SetNodeScale(actra, zNode, zCur, False)
            blendSC(actra, zGoal, zCur, zNode, zSpeed)
    EndIf   
EndIf
EndFunction






; ██████╗ ██████╗  ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗                                                                       
;██╔════╝██╔═══██╗██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║                                                                       
;██║     ██║   ██║██║   ██║██████╔╝██║  ██║██║██╔██╗ ██║███████║   ██║   ██║██║   ██║██╔██╗ ██║                                                                       
;██║     ██║   ██║██║   ██║██╔══██╗██║  ██║██║██║╚██╗██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║                                                                       
;╚██████╗╚██████╔╝╚██████╔╝██║  ██║██████╔╝██║██║ ╚████║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║                                                                       
; ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ 
; Functions related to coordinating the sub spells Actro and Actra and the UI


Function GameLoaded() global
int a = ModEvent.Create("0S_LoadGame")
if (a)
ModEvent.Send(a)
endIf
EndFunction

;When an Actra completes it's set up it "Reveals" itself (actor) to the global 
;Actro script so it can have access to all the actors in the scene.
Function ActraReveal(actor actra, string ActorID, string zPass) global
int a = ModEvent.Create("0SAO"+zPass+"_ActraReveal")
if (a)
        ModEvent.PushForm(a, actra)
        ModEvent.PushString(a, ActorID)
        ModEvent.Send(a)
    endIf
EndFunction


Function OEND(string zPass) global
int x = ModEvent.Create("0S0"+zPass+"_OEND")
if (x)
ModEvent.Send(x)
endIf
EndFunction


Function ActroReady(string stageID) global
int a = ModEvent.Create("0S0"+StageID+"_StageReady")
if (a)
ModEvent.Send(a)
endIf
EndFunction

Function alignActraStage(string ActraID) global
int a = ModEvent.Create("0SAA"+ActraID+"_AlignStage")
if (a)
ModEvent.Send(a)
endIf
EndFunction

;Calibrating Scale involves putting the actors in a TPose animation to be measured.
;The issue is certain game animations takes priority over playing scene animations (Sitting Standing Sheathing weapon etc.)  
;Calibrate Spam, rapidly sends the request to play the OS-Tpose animation until the animation actually starts.
;When it does start it's received by an OnAnimationEvent and the spam is canceled.
Function TPoseSpam(string ActraID) global
int a = ModEvent.Create("0Temp"+ActraID+"_TPoseSpam")
if (a)
ModEvent.Send(a)
endIf
EndFunction


;███████╗███████╗ ██████╗     ██╗   ██╗██████╗ ██╗      ██████╗  █████╗ ██████╗                                                                  
;██╔════╝██╔════╝██╔════╝     ██║   ██║██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗                                                                 
;█████╗  ███████╗██║  ███╗    ██║   ██║██████╔╝██║     ██║   ██║███████║██║  ██║                                                                 
;██╔══╝  ╚════██║██║   ██║    ██║   ██║██╔═══╝ ██║     ██║   ██║██╔══██║██║  ██║                                                                 
;███████╗███████║╚██████╔╝    ╚██████╔╝██║     ███████╗╚██████╔╝██║  ██║██████╔╝                                                                 
;╚══════╝╚══════╝ ╚═════╝      ╚═════╝ ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝   
;Functions related to the game recording information about actors equipmen and sending it to the UI.


;I use an event to multithread the process since there is some small time factor involved with
;processing 30 slots per actor and I want the delay on starting the scene to be minimal. 
;This function calls the event.
Function EquipmentUpload(string ActraID) global
int a = ModEvent.Create("0SEQ"+ActraID+"_UploadEQ")
if (a)
ModEvent.Send(a)
endIf
EndFunction


Function ActorLight(actor actra, string zWhich, Spell[] LSP, MagicEffect[] LME) global

            If zWhich == "FaceBright" 
                If actra.HasMagicEffect(LME[1])
                    LSP[1].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[2])
                    LSP[2].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[3])
                    LSP[3].cast(actra, actra)
                EndIf
                LSP[0].cast(actra, actra)
            
            ElseIf zWhich == "FaceDim" 
                If actra.HasMagicEffect(LME[0])
                    LSP[0].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[2])
                    LSP[2].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[3])
                    LSP[3].cast(actra, actra)
                EndIf
                LSP[1].cast(actra, actra)

            ElseIf zWhich == "AssBright"
                If actra.HasMagicEffect(LME[0])
                    LSP[0].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[1])
                    LSP[1].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[3])
                    LSP[3].cast(actra, actra)
                EndIf
                LSP[2].cast(actra, actra)

            ElseIf zWhich == "AssDim"
                If actra.HasMagicEffect(LME[0])
                    LSP[0].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[1])
                    LSP[1].cast(actra, actra)
                Elseif actra.HasMagicEffect(LME[2])
                    LSP[2].cast(actra, actra)
                EndIf
                LSP[3].cast(actra, actra)

            ElseIf zWhich == "Remove"
                if actra.HasMagicEffect(LME[0])
                    ActorLight(actra, "FaceBright", LSP, LME)
                EndIf               
                If actra.HasMagicEffect(LME[1])
                    ActorLight(actra, "FaceDim", LSP, LME)
                EndIf               
                If actra.HasMagicEffect(LME[2])
                    ActorLight(actra, "AssBright", LSP, LME)
                EndIf
                If actra.HasMagicEffect(LME[3])
                    ActorLight(actra, "AssDim", LSP, LME)
                EndIf   
            
            EndIf
EndFunction













function oGlyphSet(globalVariable glyph, int identifier) global
glyph.setValue(identifier) 
endFunction


; █████╗ ██████╗ ██╗   ██╗                 
;██╔══██╗██╔══██╗██║   ██║                 
;███████║██║  ██║██║   ██║                 
;██╔══██║██║  ██║╚██╗ ██╔╝                 
;██║  ██║██████╔╝ ╚████╔╝ ██╗              
;╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝              
; ██████╗ ██╗     ██╗   ██╗██████╗ ██╗  ██╗
;██╔════╝ ██║     ╚██╗ ██╔╝██╔══██╗██║  ██║
;██║  ███╗██║      ╚████╔╝ ██████╔╝███████║
;██║   ██║██║       ╚██╔╝  ██╔═══╝ ██╔══██║
;╚██████╔╝███████╗   ██║   ██║     ██║  ██║
; ╚═════╝ ╚══════╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝
;Lighter Glyphs with no checks
;For internal OSA use when checks aren't needed to
;speed up the process.


Function oSendO(string zMethod, int glyph) global
    UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod)
EndFunction

Function oSendI(string zMethod, int zInt, int glyph) global
    UI.InvokeInt("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod, zInt)
EndFunction

Function oSendS(string zMethod, string zString, int glyph) global
    UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod, zString)
EndFunction

Function oSendSS(string zMethod, string[] zStringArray, int glyph) global
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod, zStringArray)
EndFunction

string Function oGetS(string path, int glyph) global
return  UI.GetString("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+path)
EndFunction

int Function oGetI(string path,int glyph) global
return  UI.GetInt("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+path)
EndFunction



; ██████╗ ███████╗ █████╗                                           
;██╔═══██╗██╔════╝██╔══██╗                                          
;██║   ██║███████╗███████║                                          
;██║   ██║╚════██║██╔══██║                                          
;╚██████╔╝███████║██║  ██║                                          
; ╚═════╝ ╚══════╝╚═╝  ╚═╝                                          
;███████╗██╗  ██╗████████╗███████╗███╗   ██╗██████╗ ███████╗██████╗ 
;██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
;█████╗   ╚███╔╝    ██║   █████╗  ██╔██╗ ██║██║  ██║█████╗  ██║  ██║
;██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██║  ██║
;███████╗██╔╝ ██╗   ██║   ███████╗██║ ╚████║██████╔╝███████╗██████╔╝
;╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═════╝ 

;Functions that assist the OSA script that holds functions
;for papyrus developers to directly call.
; 
;These are quarantined here because they are in support to
;the OSA functions and not intended to be called directly through papyrus.




;Checks to see if the actor is an acceptable candidate before sending them to be actra infused.

bool function checkActra(string stageID, actor actra, faction statusFaction=none, bool creature=false) global
    if statusFaction
        if actra.GetFactionRank(statusFaction) != 1
            if(osa.isAllowed(actra, creature))                
            return true
            else
            return false
            endif
        else
        return false
        endif
    else
        if(osa.isAllowed(actra, creature))                
            return true
            else
            return false
            endif
    endif
endFunction






function systemReport() global
string[] log = new string[49]

log[0] = "systemReport"
log[1] = Utility.GetINIString("sLanguage:General")
log[2] = (Quest.GetQuest("0SA") as _oOmni).codePage
if NetImmerse.HasNode(game.GetPlayer(), "NPC GenitalsBase [GenBase]", false)
log[3] = 1
else
log[3] = 0
endIf
log[4] = ""
log[5] = ""
log[6] = ""
log[7] = ""
log[8] = ""
log[9] = ""
log[10] = _oV.getScriptVersion_s()
log[11] = _oV.getBracket_s()
log[12] = _oV.GetIVersion() as string
log[13] = SKSE.GetPluginVersion("OSA")

log[20] = SKSE.getVersion()
log[21] = SKSE.GetPluginVersion("chargen")
log[22] = SKSE.GetPluginVersion("CPConvert")
log[23] = SKSE.GetPluginVersion("papyrusutil plugin")
log[24] = PapyrusUtil.GetVersion()
log[25] = SKSE.GetPluginVersion("nioverride")
;log[26] = NiOverride.GetScriptVersion()
log[27] = SKSE.GetPluginVersion("Mfg Console plugin")
log[28] = SKSE.GetPluginVersion("SchlongsOfSkyrim")


log[40] = SKSE.GetPluginVersion("CrashFixPlugin")
log[41] = SKSE.GetPluginVersion("hdtHighHeelNative")
log[42] = SKSE.GetPluginVersion("hdtPhysicsExtensions")
log[43] = SKSE.GetPluginVersion("hdtSkinnedMeshPhysics")
log[44] = SKSE.GetPluginVersion("hdtSkyrimMemPatch")
log[45] = SKSE.GetPluginVersion("OneTweak")
log[46] = SKSE.GetPluginVersion("Safety Load plugin")
log[47] = SKSE.GetPluginVersion("ShowRaceMenu preCacheKiller plugin")
log[48] = SKSE.GetPluginVersion("SkyrimReloaded")

UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+(Quest.GetQuest("0SA") as _oOmni).glyph+".widget.com.skyReport", log)

endFunction




