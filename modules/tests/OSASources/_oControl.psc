Scriptname _oControl extends Quest

_oOmni Property OSO hidden
    _oOmni function get()
        return Quest.GetQuest("0SA") as _oOmni 
    endFunction
endProperty

import _oGlobal


int glyph
actor playerRef
bool _isSetup = false
bool _isKeySetup = false
int[] OKEY

armor[] inspectArmor
int[] inspectArmorWorn

function resetControls()
_isSetup = false
endFunction

function UpdateControls()
    
    glyph = OSO.glyph
    if !_isSetup
        playerRef = oso.playerRef
        unregisterForAllModEvents()
        RegisterForModEvent("0SA_Targeting", "OnTargeting")
        RegisterForModEvent("0SC_BindKey", "OnBindKey")
        RegisterForModEvent("0SC_MyEquip", "OnMyEquip")
        RegisterForModEvent("0SC_MyEquipEx", "OnMyEquipEx")
        RegisterForModEvent("0SC_MyUnEquip", "OnMyUnEquip")
        RegisterForModEvent("0SC_ResetEquip", "OnResetEquip")
        RegisterForModEvent("0SC_MyAnim_1", "OnMyAnim_1")
        RegisterForModEvent("0SC_ChangeName", "OnChangeName")
        RegisterForModEvent("0SC_InspectActraTrue", "OnInspectActraTrue")
        RegisterForModEvent("0SC_EqReadCuirassStyle", "OnEqReadCuirassStyle")
        RegisterForModEvent("0SC_EqOConsole", "OnEqOConsole")
        RegisterForModEvent("0SC_EqXConsole", "OnEqXConsole")

        if !_isKeySetup
        oPlayerControls()
        endif
         _isSetup = true
    endif
    UI.InvokeIntA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyOKey", OKey)
endFunction

function oPlayerControls()
    UnregisterForAllKeys()
    OKEY = setOKey()
    int i = 0
    while i < 14
    RegisterForKey(OKey[i])
    i+=1
    endWhile
     _isKeySetup = true
endFunction


Event OnKeyDown(int KeyPress)


If KeyPress == OKey[2]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.UP")
ElseIf KeyPress == OKey[3]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.DOWN")
ElseIf KeyPress == OKey[4]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.LEFT")
ElseIf KeyPress == OKey[5]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.RIGHT")
ElseIf KeyPress == OKey[6]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.TOG")
ElseIf KeyPress == OKey[7]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.YES")
ElseIf KeyPress == OKey[8]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.NO")
ElseIf KeyPress == OKey[1]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.MENU")
ElseIf KeyPress == OKey[0]
UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.END")
ElseIf KeyPress == OKey[9]
inspectActra()


ElseIf KeyPress == OKey[13]
API_TestingFunction()
EndIf


EndEvent


function API_TestingFunction()


actor inspectActra = Game.GetCurrentCrosshairRef() as Actor
if inspectActra

string[] myStage = osa.makeStage()
osa.setModule(myStage, "0Sex")

actor[] myActors = new Actor[2]
myActors[0] = playerRef
myActors[1] = inspectActra

planString(myStage)

osa.setActors(myStage, myActors)
osa.start(myStage)

endIf

endFunction

function planArr(string[] myStage)
string[] myPlan = new string[22]

;[0] is used by OSA so skip that and start with [1]
myPlan[1] = "$Wait,10"
myPlan[2] = "$Go,0MF|Sy6!Sy6|Ho|St6Pop"
myPlan[3] = "$Wait,6"
myPlan[4] = "$Warp,0MF|Sy6!Sy6|Ho|St6Pop+01SexSpankR"
myPlan[5] = "$ModEvent,0S_TestingThing"
myPlan[6] = "$Wait,4"
myPlan[7] = "$EqUndressAll,1"
myPlan[8] =  "$Wait, 4"
myPlan[9] = "$Go,0MF|Sy6!Sy6|Po|StOvBa2Po"
myPlan[10] = "$Wait,6"
myPlan[11] = "$Speed,0,1"
myPlan[12] = "$Wait,6"
myPlan[13] = "$Speed,0,1"
myPlan[14] = "$Wait,6"
myPlan[15] = "$Speed,0,1"
myPlan[16] = "$Wait,6"
myPlan[17] = "$Speed,0,-6"
myPlan[18] = "$Wait,4"
myPlan[19] = "$EqRedressAll,1"
myPlan[20] = "$Wait,4"
myPlan[21] = "$EndScene"
osa.setPlan(myStage, myPlan)
endFunction

function planString(string[] myStage)

string myPlan = ""

myPlan = osa.plan(myPlan, "$Wait,4")
myPlan = osa.plan(myPlan, "$Go,0MF|Sy6!Sy9|Ap|St9Dally")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$Warp,EMF|Sy6!Sy9|ApU|St9Dally+01intlow")
myPlan = osa.plan(myPlan, "$Wait,0")
myPlan = osa.plan(myPlan, "$EqUndressAll,1")
myPlan = osa.plan(myPlan, "$Warp,EMF|Sy6!Sy9|ApU|St9Dally+10cuirass")
myPlan = osa.plan(myPlan, "$Wait,0")
myPlan = osa.plan(myPlan, "$EqUndressAll,0")
myPlan = osa.plan(myPlan, "$Go,0MF|Sy6!Sy6|Ho|St6Pop")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$Warp,0MF|Sy6!Sy6|Ho|St6Pop+01SexSpankR")
myPlan = osa.plan(myPlan, "$ModEvent,0S_TestingThing")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$Go,0MF|Sy6!Sy6|Po|StOvBa2Po")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$Speed,0,1")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$Speed,0,3")
myPlan = osa.plan(myPlan, "$Wait,4")
myPlan = osa.plan(myPlan, "$Go,0MF|Sy6!Sy6|Sx|StOvBa2SxPm")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$Speed,0,1")
myPlan = osa.plan(myPlan, "$Wait,4")
myPlan = osa.plan(myPlan, "$Speed,0,1")
myPlan = osa.plan(myPlan, "$Wait,4")
myPlan = osa.plan(myPlan, "$Go,0MF|Sy6!Sy6|Sx|StOvBa2SxPm")
myPlan = osa.plan(myPlan, "$Speed,0,2")
myPlan = osa.plan(myPlan, "$Wait,4")
myPlan = osa.plan(myPlan, "$Speed,0,-6")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$EqRedressAll,0")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$EqRedressAll,1")
myPlan = osa.plan(myPlan, "$Wait,2")
myPlan = osa.plan(myPlan, "$EndScene")
osa.setPlanString(myStage, myPlan)

;myPlan += "$Wait,10"+"__"
;myPlan += "$Go,0MF|Sy6!Sy6|Ho|St6Pop"+"__"
;myPlan += "$Wait,6"+"__"
;myPlan += "$Warp,0MF|Sy6!Sy6|Ho|St6Pop+01SexSpankR"+"__"
;myPlan += "$ModEvent,0S_TestingThing"+"__"
;myPlan += "$Wait,4"+"__"
;myPlan += "$EqUndressAll,1"+"__"
;myPlan += "$Wait, 4"+"__"
;myPlan += "$Go,0MF|Sy6!Sy6|Po|StOvBa2Po"+"__"
;myPlan += "$Wait,6"+"__"
;myPlan += "$Speed,1,0"+"__"
;myPlan += "$Wait,6"+"__"
;myPlan += "$Speed,1,0"+"__"
;myPlan += "$Wait,6"+"__"
;myPlan += "$Speed,1,0"+"__"
;myPlan += "$Wait,6"+"__"
;myPlan += "$Speed,-6,0"+"__"
;myPlan += "$Wait,4"+"__"
;myPlan += "$EndScene"+"__"


endFunction

Event OnKeyUp(int KeyPress, float HoldTime)
if KeyPress == OKey[13]
    if HoldTime > 5.0
        unregisterForKey(OKEY[2])
        OKEY[2] = 17
        RegisterForKey(OKEY[2]) 
        unregisterForKey(OKEY[3])
        OKEY[3] = 31
        RegisterForKey(OKEY[3]) 
        unregisterForKey(OKEY[4])
        OKEY[4] = 30
        RegisterForKey(OKEY[4]) 
        unregisterForKey(OKEY[5])
        OKEY[5] = 32
        RegisterForKey(OKEY[5]) 
        unregisterForKey(OKEY[7])
        OKEY[7] = 16
        RegisterForKey(OKEY[7]) 
        unregisterForKey(OKEY[8])
        OKEY[8] = 18
        RegisterForKey(OKEY[8]) 
        unregisterForKey(OKEY[1])
        OKEY[1] = 42
        RegisterForKey(OKEY[1]) 
        UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyEmergencyBinds")
    endIf
endif
endEvent

function inspectActra()
actor inspectActra = Game.GetCurrentCrosshairRef() as Actor
if inspectActra != none && !inspectActra.IsChild() && inspectActra.HasKeywordString("ActorTypeNPC")
    UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.hud.addSigInspect", inspectActra.getActorBase().getName())
    string actraID = _oGlobal.GetFormID_s(inspectActra.getActorBase())
    oso.processActraAll(inspectActra, actraID)
    _oGlobal.SendEQSuite(inspectActra, actraID, glyph, oso.codePage)
    UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.INSPECT", actraID)
endIf
endFunction

event OnInspectActraTrue(string eventName, string formID, float arg, Form actra)
actor inspectedActor = actra as actor
int mode = arg as int
if inspectedActor  != none && !inspectedActor.IsChild() && inspectedActor.HasKeywordString("ActorTypeNPC")
        string actraID = _oGlobal.GetFormID_s(inspectedActor.getActorBase())
        if arg == 1
        SendEQSuite(inspectedActor, actraID, glyph, oso.codePage)
        else        
        oso.processActraAll(inspectedActor, actraID)        
        SendEQSuite(inspectedActor, actraID, glyph, oso.codePage)
        UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.INSPECT", actraID)
        endif
endIf
endEvent

Event OnBindKey(string eventName, string keyIndex, float newKey, Form actra)

int index = keyIndex as int
int indexF = OKey.find(newKey as int)
if indexF != -1
    if indexF != index
    unregisterForKey(OKEY[index])
    endIf
endif
OKEY[index] = newKey as int
registerForKey(newKey as int)
EndEvent

Event OnMyEquip(string eventName, string equipData, float formID, Form actra)
String[] equipVal = StringUtil.split(equipData, ",")
armor eq = Game.GetFormFromFile(formID as int, equipVal[0]) as armor
actor eqActra = actra as actor


if eqActra.GetItemCount(eq) < 1
eqActra.additem(eq, 1, true)
endIf

eqActra.UnequipItemSlot(equipVal[1] as int) 

if eqActra != playerRef
eqActra.EquipItemEx(eq, 0, true, false)
Else
eqActra.EquipItemEx(eq, 0, false, false)  
endIf
EndEvent

Event OnMyEquipEx(string eventName, string formID, float slot, Form actra)
actor eqActra = actra as actor
eqActra.UnequipItemSlot(slot as int) 
if eqActra != playerRef
eqActra.EquipItemEx(Game.GetFormEx(formID as int) as armor, 0, true, false)
Else
eqActra.EquipItemEx(Game.GetFormEx(formID as int) as armor, 0, false, false) 
endIf
EndEvent

Event OnMyUnequip(string eventName, string slot, float arrrgh, Form actra)
(actra as actor).UnequipItemSlot(slot as int) 
EndEvent

Event OnEqXConsole(string eventName, string AutoIntCMD, float arrrgh, Form actra)
String[] data = StringUtil.split(AutoIntCMD, ",")
actor eqActra = actra as actor
if data[0] == 1

consoleUtil.SetSelectedReference(eqActra)
data[1] = _oGlobal.IntToHex(Game.GetModByName(data[1]))
consoleUtil.ExecuteCommand("unequipitem "+Data[1]+Data[2]+" 1")
else
consoleUtil.SetSelectedReference(eqActra)
data[1] = _oGlobal.IntToHex(Game.GetModByName(data[1]))
data[3] = _oGlobal.IntToHex(Game.GetModByName(data[4]))
consoleUtil.ExecuteCommand("unequipitem "+Data[1]+Data[2]+" 1")
consoleUtil.ExecuteCommand("unequipitem "+Data[3]+Data[4]+" 1")
endif
EndEvent

Event OnEqOConsole(string eventName, string AutoIntCMD, float arrrgh, Form actra)
String[] data = StringUtil.split(AutoIntCMD, ",")
actor eqActra = actra as actor
if data[0] == 1

consoleUtil.SetSelectedReference(eqActra)
data[1] = _oGlobal.IntToHex(Game.GetModByName(data[1]))
consoleUtil.ExecuteCommand("equipitem "+Data[1]+Data[2]+" 1")
else
consoleUtil.SetSelectedReference(eqActra)
data[1] = _oGlobal.IntToHex(Game.GetModByName(data[1]))
data[3] = _oGlobal.IntToHex(Game.GetModByName(data[3]))
consoleUtil.ExecuteCommand("equipitem "+Data[1]+Data[2]+" 1")
consoleUtil.ExecuteCommand("equipitem "+Data[3]+Data[4]+" 1")
endif
EndEvent

Event OnResetEquip(string eventName, string strArg, float arrrgh, Form actra)
int zSlot = 30
actor eqActra = actra as actor
while zSlot < 62
eqActra.UnequipItemSlot(zSlot) 
zSlot += 1
endwhile
armor clearItem = Game.GetFormFromFile(0x12E49, "skyrim.esm") as armor
eqActra.additem(clearItem, 1, true)
eqActra.removeItem(clearItem)
EndEvent

Event OnMyAnim_1(string eventName, string anim, float actraID, Form actra)
debug.sendAnimationEvent(actra as actor, anim)
EndEvent



event OnTargeting(string eventName, string Query, float numArg, Form sender)
string IDs
If Query == "ScanCell"

    ;TEMPORARY REMOVED. ScanCellActors is currently not functioning in MiscUtil
    ;actor[] actraInRange = MiscUtil.ScanCellActors(PlayerRef, 5000.0)

    ;This is an uncomfortable band-aid to fix the lack of ScanCellActors() in MiscUtil.
    ;Cannot find any papyrus functions which recreate the above cleanly.
    ;Potentially a spell cloak could be used but that sounds like it might be even more expensive.

    

    actor actraFound


    int scanAmount = 25
    actor[] actraFoundArr = new actor[25]
    int iscan = 0
    int foundCount = 0
    while iscan < scanAmount
    actraFound = Game.FindRandomActorFromRef(PlayerRef, 5000.0)
    if actraFoundArr.find(actraFound)==-1
       ;;PapyrusUtil.PushActor(actraInRange, actorFound)
       actraFoundArr[iscan] = actraFound
       foundCount+=1
    endIf
    iscan+=1
    endWhile


    actor[] actraInRange = PapyrusUtil.ActorArray(foundCount)

    iscan = 0
    int foundCountAdded = 0
    while iscan < scanAmount

    if actraFoundArr[iscan]!=none
       actraInRange[foundCountAdded] = actraFoundArr[iscan]
       foundCountAdded+=1
    endIf
    iscan+=1
    endWhile

    ;;END OF SHITTY BAND-AID


    debug.notification("scandone")


    

    int i = 0
    int l = actraInRange.length
    while i < l
    if actraInRange[i].HasKeywordString("ActorTypeNPC")
        IDs = GetFormID_s(actraInRange[i].getActorBase())
        oso.processActraDetails(actraInRange[i], IDs)
        UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.targ.addTarg", IDs)
    endIf
    i+=1
    endWhile
        UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.beacon.cbCellScan")
elseif Query == "CrossHair"
    actor targetedActra = Game.GetCurrentCrosshairRef() as Actor
    if targetedActra != none
        if targetedActra.HasKeywordString("ActorTypeNPC")
            IDs = GetFormID_s(targetedActra.getActorBase())
            oso.processActraDetails(targetedActra, IDs)
            UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.targ.addTarg", IDs)
        endIf
    EndIf
elseif Query == "Player"
            oso.processActraDetails(playerRef, "00000007")
            UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.targ.addTarg", "00000007")
EndIf
endEvent



Event OnChangeName(string eventName, string newName, float arrrgh, Form actra)
(actra as actor).SetDisplayName(newName)
EndEvent

int[] function setOKey() global
int[] OK = new int[14]
OK[0]   = 83    ;EXIT
OK[1]   = 156   ;MENU
OK[2]   = 72    ;UP
OK[3]   = 76    ;DOWN
OK[4]   = 75    ;LEFT
OK[5]   = 77    ;RIGHT
OK[6]   = 73    ;TOG
OK[7]   = 71    ;YES
OK[8]   = 79    ;NO
OK[9]   = 78    ;INSPECT
OK[10]  = 74    ;VANISH
OK[11]  = 201   ;HUD
OK[12]  = 209   ;OPTION
OK[13]  = 66    ;HARD / EMERGENCY
return OK
endFunction

Event OnEqReadCuirassStyle(string eventName, string ReturnTo, float EQForm, Form sender)
String[] data = StringUtil.split(ReturnTo, ",")

if (Game.GetFormEx(EQForm as int) as armor).HasKeywordString(data[1])
data[1] = "1"
else
data[1] = "0"
endif
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyEqReadCuirassStyle", data)
EndEvent