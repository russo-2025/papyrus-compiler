ScriptName _oControl Extends Quest

_oOmni Property OSO Hidden
    _oOmni Function get()
        Return Quest.GetQuest("0SA") as _oOmni
    EndFunction
EndProperty

Import _oGlobal

OsexIntegrationMain ostim

Int Glyph
Actor PlayerRef
Bool _IsSetup = False
Bool _IsKeySetup = False
Int[] OKEY

Bool property disableControl auto

Armor[] InspectArmor
Int[] InspectArmorWorn

Function ResetControls()
    _IsSetup = False
    _IsKeySetup = False
EndFunction

int[] Function GetOKEY()
    if OKEY.Length < 1 
        OKEY = SetOKey()
    endif 

    return OKEY
EndFunction

Function UpdateControls()
    Glyph = OSO.Glyph
    If (!_IsSetup)
        PlayerRef = OSO.PlayerRef
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

        ostim = OUtils.GetOStim()

        disableControl = false

        If (!_IsKeySetup)
            oPlayerControls()
        EndIf
         _IsSetup = True
    EndIf
    UI.InvokeIntA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyOKey", OKey)
EndFunction

Function OPlayerControls()
    UnregisterForAllKeys()
    OKey = SetOKey()

    Int i = 0
    While i < 14
        RegisterForKey(OKey[i])
        i += 1
    EndWhile
    _IsKeySetup = True
EndFunction

Event OnKeyDown(Int KeyPress)
    If (OUtils.MenuOpen())
        Return
    EndIf

    If (KeyPress == OKey[0])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.END")
    ElseIf disableControl
        If !Utility.IsInMenuMode()
            OsexIntegrationMain.Console("OSA controls disabled by OStim property")
        EndIf
        return 
    EndIf

    If (KeyPress == OKey[2])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.UP")
    ElseIf (KeyPress == OKey[3])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.DOWN")
    ElseIf (KeyPress == OKey[4])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.LEFT")
    ElseIf (KeyPress == OKey[5])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.RIGHT")
    ElseIf (KeyPress == OKey[6])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.TOG")
    ElseIf (KeyPress == OKey[7])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.YES")
    ElseIf (KeyPress == OKey[8])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.NO")
    ElseIf (KeyPress == OKey[1])
        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.MENU")
    ElseIf (KeyPress == OKey[9])
        InspectActra()
    ElseIf (KeyPress == OKey[13])
        API_TestingFunction()
    EndIf
EndEvent

Function API_TestingFunction()
    Actor InspectActra = Game.GetCurrentCrosshairRef() as Actor
    If (InspectActra)
        String[] MyStage = OSA.MakeStage()
        OSA.SetModule(myStage, "0Sex")

        Actor[] MyActors = new Actor[2]
        MyActors[0] = PlayerRef
        MyActors[1] = InspectActra

        PlanString(MyStage)

        OSA.SetActors(MyStage, MyActors)
        OSA.Start(MyStage)
    EndIf
EndFunction

Function PlanArr(String[] MyStage)
    String[] MyPlan = new String[22]
    ;[0] is used by OSA so skip that and start with [1]
    MyPlan[1] = "$Wait,10"
    MyPlan[2] = "$Go,0MF|Sy6!Sy6|Ho|St6Pop"
    MyPlan[3] = "$Wait,6"
    MyPlan[4] = "$Warp,0MF|Sy6!Sy6|Ho|St6Pop+01SexSpankR"
    MyPlan[5] = "$ModEvent,0S_TestingThing"
    MyPlan[6] = "$Wait,4"
    MyPlan[7] = "$EqUndressAll,1"
    MyPlan[8] = "$Wait, 4"
    MyPlan[9] = "$Go,0MF|Sy6!Sy6|Po|StOvBa2Po"
    MyPlan[10] = "$Wait,6"
    MyPlan[11] = "$Speed,0,1"
    MyPlan[12] = "$Wait,6"
    MyPlan[13] = "$Speed,0,1"
    MyPlan[14] = "$Wait,6"
    MyPlan[15] = "$Speed,0,1"
    MyPlan[16] = "$Wait,6"
    MyPlan[17] = "$Speed,0,-6"
    MyPlan[18] = "$Wait,4"
    MyPlan[19] = "$EqRedressAll,1"
    MyPlan[20] = "$Wait,4"
    MyPlan[21] = "$EndScene"
    OSA.SetPlan(MyStage, MyPlan)
EndFunction

Function PlanString(String[] MyStage)
    String MyPlan = ""
    MyPlan = OSA.Plan(MyPlan, "$Wait,4")
    MyPlan = OSA.Plan(MyPlan, "$Go,0MF|Sy6!Sy9|Ap|St9Dally")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$Warp,EMF|Sy6!Sy9|ApU|St9Dally+01intlow")
    MyPlan = OSA.Plan(MyPlan, "$Wait,0")
    MyPlan = OSA.Plan(MyPlan, "$EqUndressAll,1")
    MyPlan = OSA.Plan(MyPlan, "$Warp,EMF|Sy6!Sy9|ApU|St9Dally+10cuirass")
    MyPlan = OSA.Plan(MyPlan, "$Wait,0")
    MyPlan = OSA.Plan(MyPlan, "$EqUndressAll,0")
    MyPlan = OSA.Plan(MyPlan, "$Go,0MF|Sy6!Sy6|Ho|St6Pop")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$Warp,0MF|Sy6!Sy6|Ho|St6Pop+01SexSpankR")
    MyPlan = OSA.Plan(MyPlan, "$ModEvent,0S_TestingThing")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$Go,0MF|Sy6!Sy6|Po|StOvBa2Po")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$Speed,0,1")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$Speed,0,3")
    MyPlan = OSA.Plan(MyPlan, "$Wait,4")
    MyPlan = OSA.Plan(MyPlan, "$Go,0MF|Sy6!Sy6|Sx|StOvBa2SxPm")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$Speed,0,1")
    MyPlan = OSA.Plan(MyPlan, "$Wait,4")
    MyPlan = OSA.Plan(MyPlan, "$Speed,0,1")
    MyPlan = OSA.Plan(MyPlan, "$Wait,4")
    MyPlan = OSA.Plan(MyPlan, "$Go,0MF|Sy6!Sy6|Sx|StOvBa2SxPm")
    MyPlan = OSA.Plan(MyPlan, "$Speed,0,2")
    MyPlan = OSA.Plan(MyPlan, "$Wait,4")
    MyPlan = OSA.Plan(MyPlan, "$Speed,0,-6")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$EqRedressAll,0")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$EqRedressAll,1")
    MyPlan = OSA.Plan(MyPlan, "$Wait,2")
    MyPlan = OSA.Plan(MyPlan, "$EndScene")
    OSA.setPlanString(MyStage, MyPlan)

    ;MyPlan += "$Wait,10"+"__"
    ;MyPlan += "$Go,0MF|Sy6!Sy6|Ho|St6Pop"+"__"
    ;MyPlan += "$Wait,6"+"__"
    ;MyPlan += "$Warp,0MF|Sy6!Sy6|Ho|St6Pop+01SexSpankR"+"__"
    ;MyPlan += "$ModEvent,0S_TestingThing"+"__"
    ;MyPlan += "$Wait,4"+"__"
    ;MyPlan += "$EqUndressAll,1"+"__"
    ;MyPlan += "$Wait, 4"+"__"
    ;MyPlan += "$Go,0MF|Sy6!Sy6|Po|StOvBa2Po"+"__"
    ;MyPlan += "$Wait,6"+"__"
    ;MyPlan += "$Speed,1,0"+"__"
    ;MyPlan += "$Wait,6"+"__"
    ;MyPlan += "$Speed,1,0"+"__"
    ;MyPlan += "$Wait,6"+"__"
    ;MyPlan += "$Speed,1,0"+"__"
    ;MyPlan += "$Wait,6"+"__"
    ;MyPlan += "$Speed,-6,0"+"__"
    ;MyPlan += "$Wait,4"+"__"
    ;MyPlan += "$EndScene"+"__"
EndFunction

Event OnKeyUp(Int KeyPress, Float HoldTime)
    If (KeyPress == OKey[13])
        If (HoldTime > 5.0)
            UnregisterForKey(OKey[2])
            OKey[2] = 17
            RegisterForKey(OKey[2])
            UnregisterForKey(OKey[3])
            OKEY[3] = 31
            RegisterForKey(OKey[3])
            UnregisterForKey(OKey[4])
            OKey[4] = 30
            RegisterForKey(OKey[4])
            UnregisterForKey(OKey[5])
            OKey[5] = 32
            RegisterForKey(OKey[5])
            UnregisterForKey(OKey[7])
            OKey[7] = 16
            RegisterForKey(OKey[7])
            UnregisterForKey(OKey[8])
            OKey[8] = 18
            RegisterForKey(OKey[8])
            UnregisterForKey(OKey[1])
            OKey[1] = 42
            RegisterForKey(OKey[1])
            UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyEmergencyBinds")
        EndIf
    EndIf
EndEvent

Function InspectActra()
    Actor InspectActra = Game.GetCurrentCrosshairRef() as Actor
    If (InspectActra)
        If (!InspectActra.IsChild() && InspectActra.HasKeywordString("ActorTypeNPC"))
            ActorBase ActraBase = InspectActra.GetActorBase()
            UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.hud.addSigInspect", ActraBase.GetName())

            String ActraID = _oGlobal.GetFormID_S(ActraBase)
            OSO.ProcessActraAll(InspectActra, ActraID)
            _oGlobal.SendEQSuite(InspectActra, ActraID, Glyph, OSO.CodePage)
            UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.INSPECT", ActraID)
        EndIf
    EndIf
EndFunction

Event OnInspectActraTrue(String EventName, String FormID, Float Arg, Form Actra)
    Actor InspectedActor = Actra as Actor
    If (InspectedActor)
        ; Int Mode = Arg as Int
        If (!InspectedActor.IsChild() && InspectedActor.HasKeywordString("ActorTypeNPC"))
            String ActraID = _oGlobal.GetFormID_S(InspectedActor.GetActorBase())
            If (Arg == 1)
                SendEQSuite(InspectedActor, ActraID, Glyph, OSO.CodePage)
            Else
                OSO.ProcessActraAll(InspectedActor, ActraID)
                SendEQSuite(InspectedActor, ActraID, Glyph, OSO.CodePage)
                UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.INSPECT", ActraID)
            EndIf
        EndIf
    EndIf
EndEvent

Event OnBindKey(String EventName, String KeyIndex, Float NewKey, Form Actra)
    Int i = KeyIndex as Int
    Int F = OKey.Find(NewKey as Int)
    If (F != -1)
        If (F != i)
            UnregisterForKey(OKey[i])
        EndIf
    EndIf
    OKey[i] = NewKey as Int
    RegisterForKey(NewKey as Int)
EndEvent

Event OnMyEquip(String EventName, String EquipData, Float FormID, Form Actra)
    String[] EquipVal = StringUtil.split(EquipData, ",")
    Armor Eq = Game.GetFormFromFile(FormID as Int, EquipVal[0]) as Armor
    Actor EqActra = Actra as Actor

    If (EqActra.GetItemCount(Eq) < 1)
        EqActra.Additem(Eq, 1, True)
    EndIf

    EqActra.UnequipItemSlot(EquipVal[1] as Int)

    If (EqActra != PlayerRef)
        EqActra.EquipItemEx(Eq, 0, True, False)
    Else
        EqActra.EquipItemEx(Eq, 0, False, False)
    EndIf
EndEvent

Event OnMyEquipEx(String EventName, String FormID, Float Slot, Form Actra)
    Actor EqActra = Actra as Actor
    EqActra.UnequipItemSlot(Slot as Int)
    If (EqActra != PlayerRef)
        EqActra.EquipItemEx(Game.GetFormEx(FormID as Int) as Armor, 0, True, False)
    Else
        EqActra.EquipItemEx(Game.GetFormEx(FormID as Int) as Armor, 0, False, False)
    EndIf
EndEvent

Event OnMyUnequip(String EventName, String Slot, Float Arrrgh, Form Actra)
    (Actra as Actor).UnequipItemSlot(Slot as Int)
EndEvent

Event OnEqXConsole(String EventName, String AutoIntCMD, Float Arrrgh, Form Actra)
    String[] Data = StringUtil.Split(AutoIntCMD, ",")
    Actor EqActra = Actra as Actor

    ConsoleUtil.SetSelectedReference(EqActra)
    If (Data[0] == 1)
        Data[1] = _oGlobal.IntToHex(Game.GetModByName(Data[1]))
        ConsoleUtil.ExecuteCommand("unequipitem " + Data[1] + Data[2] + " 1")
    Else
        Data[1] = _oGlobal.IntToHex(Game.GetModByName(Data[1]))
        Data[3] = _oGlobal.IntToHex(Game.GetModByName(Data[4]))
        ConsoleUtil.ExecuteCommand("unequipitem " + Data[1] + Data[2] + " 1")
        ConsoleUtil.ExecuteCommand("unequipitem " + Data[3] + Data[4] + " 1")
    EndIf
EndEvent

Event OnEqOConsole(String EventName, String AutoIntCMD, Float Arrrgh, Form Actra)
    String[] Data = StringUtil.Split(AutoIntCMD, ",")
    Actor EqActra = Actra as Actor

    ConsoleUtil.SetSelectedReference(EqActra)
    If (Data[0] == 1)
        Data[1] = _oGlobal.IntToHex(Game.GetModByName(Data[1]))
        ConsoleUtil.ExecuteCommand("equipitem " + Data[1] + Data[2] + " 1")
    Else
        Data[1] = _oGlobal.IntToHex(Game.GetModByName(Data[1]))
        Data[3] = _oGlobal.IntToHex(Game.GetModByName(Data[3]))
        ConsoleUtil.ExecuteCommand("equipitem " + Data[1] + Data[2] + " 1")
        ConsoleUtil.ExecuteCommand("equipitem " + Data[3] + Data[4] + " 1")
    EndIf
EndEvent

Event OnResetEquip(String EventName, String StrArg, Float Arrrgh, Form Actra)
    Actor EqActra = Actra as Actor

    Int zSlot = 30
    While (zSlot < 62)
        EqActra.UnequipItemSlot(zSlot)
        zSlot += 1
    EndWhile

    Armor ClearItem = Game.GetFormFromFile(0x12E49, "Skyrim.esm") as Armor
    EqActra.AddItem(ClearItem, 1, True)
    EqActra.RemoveItem(ClearItem)
EndEvent

Event OnMyAnim_1(String EventName, String Anim, Float ActraID, Form Actra)
    Debug.SendAnimationEvent(Actra as Actor, Anim)
EndEvent

Event OnTargeting(String EventName, String Query, Float NumArg, Form Sender)
    String IDs
    If (Query == "ScanCell")
        ; TEMPORARY REMOVED. ScanCellActors is currently not functioning in MiscUtil
        ; Actor[] actraInRange = MiscUtil.ScanCellActors(PlayerRef, 5000.0)

        ; This is an uncomfortable band-aid to fix the lack of ScanCellActors() in MiscUtil.
        ; Cannot find any papyrus functions which recreate the above cleanly.
        ; Potentially a spell cloak could be used but that sounds like it might be even more expensive.

        Actor ActraFound
        Actor[] ActraFoundArr = new Actor[25]

        Int i = 0
        Int ScanAmount = 25
        Int FoundCount = 0
        While (i < ScanAmount)
            ActraFound = Game.FindRandomActorFromRef(PlayerRef, 5000.0)
            If (ActraFoundArr.Find(ActraFound) == -1)
                ;PapyrusUtil.PushActor(actraInRange, actorFound)
                ActraFoundArr[i] = ActraFound
                FoundCount += 1
            EndIf
            i += 1
        endWhile

        Actor[] ActraInRange = PapyrusUtil.ActorArray(FoundCount)

        i = 0
        Int FoundCountAdded = 0
        While (i < ScanAmount)
            If (ActraFoundArr[i])
                ActraInRange[FoundCountAdded] = ActraFoundArr[i]
                FoundCountAdded += 1
            EndIf
            i += 1
        EndWhile

        ; END OF SHITTY BAND-AID

        Debug.Notification("Scan Done")

        i = 0
        Int L = ActraInRange.Length
        While i < L
            If (ActraInRange[i].HasKeywordString("ActorTypeNPC"))
                IDs = GetFormID_S(ActraInRange[i].GetActorBase())
                OSO.ProcessActraDetails(ActraInRange[i], IDs)
                UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.targ.addTarg", IDs)
            EndIf
            i += 1
        EndWhile

        UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.beacon.cbCellScan")
    ElseIf (Query == "CrossHair")
        Actor TargetedActra = Game.GetCurrentCrosshairRef() as Actor
        If (TargetedActra)
            If (TargetedActra.HasKeywordString("ActorTypeNPC"))
                IDs = GetFormID_S(TargetedActra.GetActorBase())
                OSO.ProcessActraDetails(TargetedActra, IDs)
                UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.targ.addTarg", IDs)
            EndIf
        EndIf
    ElseIf (Query == "Player")
        OSO.ProcessActraDetails(PlayerRef, "00000007")
        UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.targ.addTarg", "00000007")
    EndIf
EndEvent

Event OnChangeName(String EventName, String NewName, Float Arrrgh, Form Actra)
    (Actra as Actor).SetDisplayName(NewName)
EndEvent

Int[] Function SetOKey() Global
    Int[] OK = new Int[14]
    OK[0]  = 83  ; EXIT
    OK[1]  = 156 ; MENU
    OK[2]  = 72  ; UP
    OK[3]  = 76  ; DOWN
    OK[4]  = 75  ; LEFT
    OK[5]  = 77  ; RIGHT
    OK[6]  = 73  ; TOG
    OK[7]  = 71  ; YES
    OK[8]  = 79  ; NO
    OK[9]  = 78  ; INSPECT
    OK[10] = 74  ; VANISH
    OK[11] = 201 ; HUD
    OK[12] = 209 ; OPTION
    OK[13] = 66  ; HARD / EMERGENCY
    Return OK
EndFunction

Event OnEqReadCuirassStyle(String EventName, String ReturnTo, Float EQForm, Form Sender)
    String[] Data = StringUtil.Split(ReturnTo, ",")
    If (Game.GetFormEx(EQForm as Int) as Armor).HasKeywordString(Data[1])
        Data[1] = "1"
    Else
        Data[1] = "0"
    EndIf

    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyEqReadCuirassStyle", Data)
EndEvent
