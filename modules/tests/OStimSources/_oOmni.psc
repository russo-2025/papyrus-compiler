Scriptname _oOmni extends Quest

;   ___    ___     _
; ██████╗ ███████╗ █████╗        ██████╗ ███╗   ███╗███╗   ██╗██╗
;██╔═══██╗██╔════╝██╔══██╗      ██╔═══██╗████╗ ████║████╗  ██║██║
;██║   ██║███████╗███████║█████╗██║   ██║██╔████╔██║██╔██╗ ██║██║
;██║   ██║╚════██║██╔══██║╚════╝██║   ██║██║╚██╔╝██║██║╚██╗██║██║
;╚██████╔╝███████║██║  ██║      ╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║
; ╚═════╝ ╚══════╝╚═╝  ╚═╝       ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝
;███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗
;╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
;Quest bound script for OSA.
;
;Manages keybinds, bootup configuration and some general
;communication with the UI. Houses forms commonly used
;by Actra spells so they can be accessed quickly and cheaply.

; OSA Global Functions

Actor Property PlayerRef Auto
Int Property Glyph Auto Hidden

; Add the _oUI persistent script to talk to the UI
_oUI Property OI Hidden
    _oUI Function get()
        return Quest.GetQuest("0SUI") as _oUI
    EndFunction
EndProperty


Int iVersion

_oControl OControl

Package[] Property OPackage Auto
Faction[] Property OFaction Auto
Keyword[] Property OKeyword Auto
;Faction[0] OSAStatusFaction, used to stop multi OSA scenes from occuring on the same actors.
;       0: Not in a scene, 1:In a scene, 2:Double NPC scene that the player can observe or join in on.
;1= Faction 1 is RoleFaction, OBSOLETE
;2= The stage ID of the actors current scene is recorded here to relay information between spells.

String Property CodePage Auto Hidden

String[] PreferenceSaves

Ammo Property OBlankAmmo Auto
Static Property OBlankStatic Auto
Spell[] Property OSpell Auto
MagicEffect[] Property OME Auto
Spell[] Property OLightSP Auto
MagicEffect[] Property OLightME Auto

FormList Property OProjectile  Auto
FormList Property OShader  Auto

ObjectReference[] Property GlobalPosition Auto

Int [] OKB_Code
String[] OKB_Module
String[] OKB_Data
String[] OINI

Int Property StageNumber = 10 Auto Hidden

; Ticking mechanism for the stageID so each cast increases it by 1.
; Stats at 10 to ensure that there are always double digits in case substring has to be used to trim the information.
; caps at 10 - 99 to ensure it's always in double digits.
; 10-49 are for KeyBound Scenes. 50-99 are for UI or Papyrus Initiated Scenes.
Int Function StageID()
    StageNumber += 1
    If (StageNumber > 49)
        StageNumber = 10
    EndIf
    Return StageNumber
EndFunction


;   ____    _   _     _____   _   _   _____   _______
;  / __ \  | \ | |   |_   _| | \ | | |_   _| |__   __|
; | |  | | |  \| |     | |   |  \| |   | |      | |
; | |  | | | . ` |     | |   | . ` |   | |      | |
; | |__| | | |\  |    _| |_  | |\  |  _| |_     | |
;  \____/  |_| \_|   |_____| |_| \_| |_____|    |_|


Event OnInit()
    PreferenceSaves = Utility.CreateStringArray(10, "")
    Maintenance()
EndEvent

Function Maintenance()
    String File = "Data/OSA/Logs/_maintenance_log.txt"
    MiscUtil.WriteToFile(File, "OSA BootUp Maitenance\n---------------------" + "   Running iVersion:" + iVersion + "\n   Script iVersion:" + _oV.GetIVersion() + "\n", False, True)

    ;;TESTING
    ;;Armor MyArmor = Game.GetFormEx(0x1802376B) as Armor
    ;;ConsoleUtil.SetSelectedReference(Game.GetPlayer())
    ;;ConsoleUtil.ExecuteCommand("equipitem 1802376B 1")
    ;;EndTESTING

    _oPatch.OSAPatch(Self as _oOmni)

    If (iVersion < _oV.GetIVersion())
   ;if true
        If (iVersion)
        ;if true
            OUtils.console("Omni cleaning")

            CleanScript()
            RebootScript()
            MiscUtil.WriteToFile(File, "Cleaning and Rebooting Script/n", True, True)
        Else
            _oPatch.OSAPatchMaint(Self as _oOmni)
            RebootScript()
            MiscUtil.WriteToFile(File, "OSA first time initializinon. Booting up script.../n", True, True)
        EndIf
    Else
        MiscUtil.WriteToFile(File, "Reboot not needed, current version matches installed version", True, True)
    EndIf
    iVersion = _oV.GetIVersion()

    _oPatch.OSAPatchEnd(Self as _oOmni)
EndFunction

Function CleanScript()
    _oGlobal.CleanPositionArray(GlobalPosition)
EndFunction

Function RebootScript()
    OINI = SetOINI(PlayerRef)

    UnregisterForAllModEvents()
    UnregisterForAllKeys()

    RegisterForModEvent("0SA_UIBoot", "OnUIBoot")

    OKB_Code = Utility.CreateIntArray(126, 0)
    OKB_Module = Utility.CreateStringArray(126, "")
    OKB_Data = Utility.CreateStringArray(126, "")

    If (!PreferenceSaves)
        PreferenceSaves = Utility.CreateStringArray(10, "")
    EndIf

    RegisterForModEvent("0SA_BindModule", "onBindModule")
    RegisterForModEvent("0SA_StartModuleUI", "OnStartModuleUI")
    RegisterForModEvent("0SA_Special", "OnSpecial")
    RegisterForModEvent("0SA_Reset", "OnReset")
    RegisterForModEvent("0SA_Report", "OnReport")
    RegisterForModEvent("0SA_INIBool", "OnINIBool")
    RegisterForModEvent("0SA_INIFull", "OnINIFull")
    RegisterForModEvent("0SA_Preferences", "OnPreferences")
    RegisterForModEvent("0SA_UnBind", "OnUnBind")
    RegisterForModEvent("OSA_OStart", "OnOStart")
    RegisterForModEvent("OSA_OutputLog", "OnOutputLog")
    RegisterForModEvent("OSA_ScanDirectoryForFileType", "OnScanDirectoryForFileType")

    OControl = Quest.GetQuest("0SAControl") as _oControl
    ;OControl.ResetControls()
    ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
    ;;codePage = CPConvert.GetCPForGameLng()
    CodePage = 1252
    OINI[2] = CodePage
    GlobalPosition = new ObjectReference[100]
EndFunction

;   ____    _   _     _____    _____    ______            ____     ____     ____    _______
;  / __ \  | \ | |   |  __ \  |  __ \  |  ____|          |  _ \   / __ \   / __ \  |__   __|
; | |  | | |  \| |   | |__) | | |__) | | |__     ______  | |_) | | |  | | | |  | |    | |
; | |  | | | . ` |   |  ___/  |  _  /  |  __|   |______| |  _ <  | |  | | | |  | |    | |
; | |__| | | |\  |   | |      | | \ \  | |____           | |_) | | |__| | | |__| |    | |
;  \____/  |_| \_|   |_|      |_|  \_\ |______|          |____/   \____/   \____/     |_|
;


Event OnOStart(String EventName, String SoundType, Float NumArg, Form Sender)
    ;Debug.MessageBox(UI.getInt("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.__"+"0Sex"))
EndEvent

Event OnPreferences(String EventName, String DataString, Float LoadSave, Form Sender)
    Int Type = LoadSave as Int
    If (Type <= 9)
        UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.cfg.loadSkySettings", PreferenceSaves[Type])
    ElseIf (Type <= 19)
        PreferenceSaves[Type - 10] = DataString
    ElseIf (Type <= 29)
        PreferenceSaves[Type - 20] = ""
    EndIf
EndEvent

Event OnUIBoot(String EventName, String SoundType, Float NumArg, Form Sender)
   outils.console("UI booting...")

    Glyph = OI.WidgetID
    _oGlobal.ScanFolders(Glyph)
    OControlSetUp()
    SendINI()
    Utility.Wait(0.1)
    UI.InvokeIntA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyMKeyCode", OKB_Code)
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyMKeyMod", OKB_Module)
EndEvent

Event OnINIFull(String EventName, String LoadString, Float b, Form c)
    String[] Vals = StringUtil.Split(LoadString, ",")
    Int i = 0
    Int L = Vals.Length
    While (i < L)
        OINI[i] = Vals[i]
        i += 1
    EndWhile
EndEvent

Function SendINI()
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyINI", OINI)
EndFunction

Event OnBindModule(String EventName, String ModuleData, Float BindKey, Form Sender)
    Int KeyBind = BindKey as Int
    String[] Split = StringUtil.Split(ModuleData, ",")

    Int AlreadyBound = OKB_Module.Find(Split[0])
    If (AlreadyBound != -1)
        UnregisterForKey(OKB_Code[alreadyBound])
        OKB_Code[alreadyBound] = 0
        OKB_Module[alreadyBound] = ""
        OKB_Data[alreadyBound] = ""
    EndIf

    Int i
    Bool SlotFound
    While (i < 127)
        If (OKB_Code[i] == 0)
            SlotFound = True
            OKB_Code[i] = KeyBind
            OKB_Module[i] = Split[0]
            OKB_Data[i] = ModuleData
            RegisterForKey(OKB_Code[i])

            String[] Report = new String[3]
            Report[0] = Split[0]
            Report[1] = KeyBind
            Report[2] = i
            UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.cfg.binds.bindModule", Report)
            i += 500
        Else
            i += 1
        EndIf
    EndWhile
EndEvent

Function OControlSetUp()
    ;OControl.ResetControls()
    OControl.UpdateControls()
EndFunction

Function PrepActra(String[] sceneSuite, Actor[] Actra)
    Int StageID = SceneSuite[0] as Int

    If (GlobalPosition[StageID])
        GlobalPosition[StageID].Delete()
    EndIf

    GlobalPosition[StageID] = Actra[0].PlaceAtMe(OBlankStatic) as ObjectReference

    Int i = 0
    Int L = Actra.Length
    While (i < L)
        ProcessActraAll(Actra[i], SceneSuite[i + 1])
        Actra[i].SetFactionRank(OFaction[0], 1)
        Actra[i].SetFactionRank(OFaction[1], StageID)
        _oGlobal.PackageSquelch(Actra[i], OPackage)
        i += 1
    EndWhile

    OSpell[1].Cast(Actra[0], Actra[0])

    i = 0
    While (i < L)
        OSpell[0].Cast(Actra[i], Actra[i])
        i += 1
    Endwhile
EndFunction

Event OnKeyDown(Int KeyPress)
    ;If (Keypress == 184)
        ;TestingOutput()
    ;Else
        OSAByKey(StageID(), OKB_Code.Find(KeyPress))
    ;EndIf
EndEvent


;  _______   _____    _____    _____                _  __  ______  __     __
; |__   __| |  __ \  |_   _|  / ____|              | |/ / |  ____| \ \   / /
;    | |    | |__) |   | |   | |  __     ______    | ' /  | |__     \ \_/ /
;    | |    |  _  /    | |   | | |_ |   |______|   |  <   |  __|     \   /
;    | |    | | \ \   _| |_  | |__| |              | . \  | |____     | |
;    |_|    |_|  \_\ |_____|  \_____|              |_|\_\ |______|    |_|


Function OSAByKey(String StageID, Int Index)
    If (PlayerRef.GetFactionRank(OFaction[0]) != 1)
        If (Index != -1)
            String[] TrigData = StringUtil.Split(OKB_Data[Index], ",")
            If (TrigData[3] == "C")
                If (StringUtil.GetNthChar(TrigData[2], 0) != "1")
                    Actor[] Actra = new Actor[2]
                    Actra[0] = PlayerRef
                    Actra[1] = Game.GetCurrentCrosshairRef() as Actor
                    If (Actra[1])
                        CheckActraByKey(Actra, StageID, Index, TrigData)
                    EndIf
                Else
                    Actor[] Actra = new Actor[1]
                    Actra[0] = Game.GetCurrentCrosshairRef() as Actor
                    If (Actra[0])
                        If (Actra[0].GetFactionRank(OFaction[0]) != 1)
                            If (OSA.IsAllowed(Actra[0]))
                                ActraReadyByKey(Actra, StageID, Index, True)
                            Endif
                        EndIf
                        CheckActraByKey(Actra, StageID, Index, TrigData)
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
EndFunction

Function CheckActraByKey(Actor[] Actra, String StageID, Int Index, String[] TrigData)
    If (Actra[1].GetFactionRank(OFaction[0]) != 1)
        If OSA.IsAllowed(Actra[1])
            String Directional = StringUtil.GetNthChar(TrigData[4], 0)
            If (Directional == "O")
                ActraReadyByKey(Actra, StageID, Index)
            ElseIf (directional == "D")
                Int SubInt1 = StringUtil.SubString(TrigData[4], 1, 3) as Int
                Int SubInt2 = StringUtil.SubString(TrigData[4], 4, 3) as Int
                If (_oGlobal.DirectionCheck_D(Actra[0], Actra[1], SubInt1, SubInt2))
                    ActraReadyByKey(Actra, StageID, Index)
                EndIf
            EndIf
        Endif
    EndIf
EndFunction

Function ActraReadyByKey(Actor[] Actra, String StageID, Int Index, Bool Solo = False)
    Int StageIDint = StageID as Int

    Int L = Actra.length
    String[] DataPush = Utility.CreateStringArray(2 + L)
    DataPush[0] = StageID
    DataPush[1] = OKB_Data[index]

    Int i = 0
    While (i < L)
        DataPush[2 + i] = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(actra[i]))
        ProcessActraAll(Actra[i], DataPush[2 + i])
        Actra[i].SetFactionRank(OFaction[0], 1)
        Actra[i].SetFactionRank(OFaction[1], StageIDint)
        _oGlobal.PackageSquelch(Actra[i], OPackage)
        i += 1
    EndWhile

    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.playerCreateStage", DataPush)

    DataPush = new String[7]
    DataPush[0] = StageID
    If (!Solo)
        DataPush[1] = Actra[1].GetHeadingAngle(Actra[0])
        DataPush[3] = (Actra[0].IsHostileToActor(Actra[1]) as Int) as String
        DataPush[4] = (Actra[1].IsHostileToActor(Actra[1]) as Int) as String
        DataPush[5] = Actra[0].GetRelationshipRank(Actra[1])
        DataPush[6] = Actra[1].GetRelationshipRank(Actra[0])
    Else
        DataPush[1] = 0
        DataPush[3] = 0 as String
        DataPush[4] = 0 as String
        DataPush[5] = 0
        DataPush[6] = 0
    EndIf

    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.playerStartStage", DataPush)

    If (GlobalPosition[StageIDInt])
        GlobalPosition[StageIDInt].Delete()
    EndIf

    GlobalPosition[StageIDint] = Actra[0].PlaceAtMe(OBlankStatic) as ObjectReference
    OSpell[1].Cast(Actra[0], Actra[0])

    i = 0
    While (i < L)
        OSpell[0].Cast(Actra[i], Actra[i])
        i += 1
    EndWhile
EndFunction


;              _____   _______   _____                 _____   _   _   ______    ____
;     /\      / ____| |__   __| |  __ \      /\       |_   _| | \ | | |  ____|  / __ \
;    /  \    | |         | |    | |__) |    /  \        | |   |  \| | | |__    | |  | |
;   / /\ \   | |         | |    |  _  /    / /\ \       | |   | . ` | |  __|   | |  | |
;  / ____ \  | |____     | |    | | \ \   / ____ \     _| |_  | |\  | | |      | |__| |
; /_/    \_\  \_____|    |_|    |_|  \_\ /_/    \_\   |_____| |_| \_| |_|       \____/


Function ProcessActraAll(Actor Actra, String FormID)
    If (Actra.GetFactionRank(OFaction[0]) != 1)
        UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraInit", FormID)
        UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraDetails", _oGlobal.SendActraDetails(Actra, FormID, Self as _oOmni))
        UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraScale", _oGlobal.SendActraScale(Actra, FormID))
    EndIf
EndFunction

Function ProcessActraDetails(Actor Actra, String FormID)
    If (Actra.GetFactionRank(OFaction[0]) != 1)
        UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraInit", FormID)
        UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraDetails", _oGlobal.SendActraDetails(Actra, FormID, Self as _oOmni))
    EndIf
EndFunction

Event OnStartModuleUI(String EventName, String DataString, Float NumArg, Form Sender)
    String[] Data = StringUtil.Split(DataString, ",")

    Int L = Data.Length
    Actor[] Actra = PapyrusUtil.ActorArray(L - 1)

    Int i = 0
    While (i < L)
        Actra[i] = Game.GetFormEx(Data[i + 1] as Int) as Actor
        i += 1
    EndWhile

    i = 0
    Bool InScene = False
    While (i < L)
        If (Actra[i].GetFactionRank(OFaction[0]) != 1)
            ; Skip, maybe revise this?
        Else
            InScene = True
            i + 10
        EndIf
        i += 1
    EndWhile

    If (!InScene)
        String[] NewScene = OSA.MakeStage()
        OSA.SetActors(NewScene, Actra)
        OSA.SetModule(NewScene, Data[0])
        OSA.Start(NewScene)
    EndIf
EndEvent

Event OnScanDirectoryForFileType(String EventName, String DataString, Float BoolIndex, Form Sender)
    String[] Data = StringUtil.Split(DataString, ",")
    ;UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.lib.codex.scanIdentity", MiscUtil.FilesInFolder("Data/meshes/0SP/base/identity/", ".oiden"))
    If (Data[0] == "1")
        String[] Files = MiscUtil.FilesInFolder("Data/" + Data[1], Data[2])
        UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget." + data[3], Files)
    EndIf
EndEvent

Event OnINIBool(String EventName, String BoolValue, Float BoolIndex, Form Sender)
    OINI[BoolIndex as Int] = BoolValue
EndEvent

Event OnUnBind(String EventName, String IndexValue, Float BoolIndex, Form Sender)
    Int i = IndexValue as Int
    UnregisterForKey(OKB_Code[i])
    OKB_Code[i] = 0
    OKB_Module[i] = ""
    OKB_Data[i] = ""
EndEvent

Event OnSpecial(String EventName, String Special, Float FloatVal, Form Sender)
    If (Special == "ExposureException")
        _oFrostFall.OFrostFall(GlobalPosition[FloatVal as Int])
    ElseIf (Special == "RefreshCodepage")
        ;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
        ;codePage = CPConvert.GetCPForGameLng()
        CodePage = 1252
        OINI[2] = CodePage
    EndIf
EndEvent

Event OnReset(String EventName, String ResetCommand, Float FloatVal, Form Sender)
EndEvent

Event OnReport(String EventName, String ReportValue, Float ReportCommand, Form ReportForm)
    Int Report = ReportCommand as Int
    If (Report == 1)
        _oGlobal.SystemReport()
    EndIf
EndEvent

Event OnOutputLog(String NoEvent, String OutputLog, Float NoFloat, Form NoForm)
    String[] StringData = StringUtil.Split(OutputLog, "$#$#$")
    String File = "Data/OSA/Logs/" + StringData[0] + ".txt"
    Miscutil.WriteToFile(File, StringData[1], False, True)
EndEvent

Function TestingArea()
    ;RegisterForKey(184)
EndFunction

Function TestingOutput()
EndFunction

Function TestingOutputBak()
EndFunction

String[] Function SetOINI(Actor Player) Global
    OsexIntegrationMain ostim = outils.getostim()

 
    String[] OIN = new String[120]
    OIN[0]  = ""
    OIN[1]  = "!dg" ; Player Symbol
    OIN[2]  = ""    ; CodePage
    OIN[3]  = "1"   ; AutoCodePage
    OIN[4]  = "1"   ; HelpMode
    OIN[5]  = "0"   ; PurityMode
    OIN[6]  = "0"   ; UseMetric
    OIN[7]  = "0"   ; DevMode (SET TO 0)
    OIN[8]  = "ic"  ; SubColor
    OIN[9]  = "op"  ; ThemeColor
    OIN[10] = "0"   ; SortRoleByAnimGender

    ;OIN[11] = "1"   ; AllowBodyScaling
    if ostim.IsModLoaded("3BBB.esp")
        osexintegrationmain.console("3bbb loaded")
        OIN[11] = "0"   ; NoBodyScaling
    else 
        osexintegrationmain.console("3bbb not loaded")
        OIN[11] = "1"   ; AllowBodyScaling
    endif 
    OIN[12] = "0"   ; AllowMaleGenitalScaling
    OIN[13] = "0"
    OIN[14] = ""
    OIN[15] = ""
    OIN[16] = ""
    OIN[17] = ""
    OIN[18] = _oFrostfall.OFrostCompat() ; FrostFallInstall
    OIN[19] = "1"   ; FrostfallException
    OIN[20] = "0"   ; InternationalFont
    OIN[21] = "1"   ; InternationalFontSansSerif
    OIN[22] = "0"   ; TextOptUI
    OIN[23] = "1"   ; DynamicIconDisplay
    OIN[24] = "1"   ; SkinToneDisplay
    OIN[25] = "1"   ; NavVanish
    OIN[26] = "1"   ; Logging (SET TO 0)
    OIN[27] = ""
    OIN[28] = ""
    OIN[29] = ""
    OIN[30] = ""    ; MyEquip
    OIN[31] = ""    ; MyHero
    OIN[32] = ""    ; MyBody
    OIN[38] = "0"   ; RenameInGame
    OIN[39] = "0"   ; RenameNpc
    ;~ FLAGS
        ;~GENERAL
    OIN[40] = "0"   ; FlagPillage
    OIN[41] = "0"   ; FlagHyper-Taboo
    OIN[42] = "0"   ; FlagModernObjects
        ;~Combat
    OIN[50] = "0"   ; fComDismemberment
    OIN[51] = "0"   ; fComModernWeapons
    OIN[52] = "0"   ; fComUltimates
    OIN[53] = "0"   ; fComSupremes
    OIN[54] = "0"   ; fComNaughty
    OIN[55] = "0"   ; fComStripping
    OIN[56] = "0"   ; fComSex
        ;~Intimacy
        ;~SEX
    OIN[60] = "0"   ; fSexFantastical
    OIN[61] = "0"   ; fSexRough

    OIN[79] = "0"
    OIN[80] = "helmet,x,cuirass,gloves,x,necklace,rings,boots,x,shield,x,x,x,earrings,glasses,intlow,pants,x,miscup,miscmid,x,x,x,misclow,stockings,x,inthigh,cape,x,miscarms,x,x!61" ; esgSettings0
    OIN[81] = "helmet,x,cuirass,gloves,x,necklace,rings,boots,x,shield,x,x,x,earrings,glasses,intlow,pants,x,miscup,miscmid,x,x,x,misclow,stockings,x,inthigh,cape,x,miscarms,x,x!61" ; esgSettings1
    OIN[82] = "1"   ; hideUnwornESG
    OIN[83] = "0"   ; AIintlow1 (Auto-Intimates, LowerBody Female)
    OIN[84] = "0"   ; AIinthigh1 (Auto-Intimates, UpperBody Female)
    OIN[85] = "0"   ; AIintlow0 (Auto-Intimates, LowerBody Male)
    OIN[86] = "0"   ; AIinthigh0 (Auto-Intimates, UpperBody Male)
    OIN[87] = "0"   ; Reserved for Socks
    OIN[88] = "0"   ; Reserved for Socks
    OIN[89] = "0"   ; Genital
    OIN[90] = "0"   ; Genital
    OIN[91] = "0"   ; Reserved
    OIN[92] = "0"   ; Reserved
    OIN[93] = "1"   ; AnimRedressPlayer
    OIN[94] = "0"   ; InstaRedressPlayer
    OIN[95] = "1"   ; AnimRedressNPC
    OIN[96] = "0"   ; InstaRedressNPC
    OIN[97] = "1"   ; ClothingAudio
    OIN[98] = "1"   ; CuirassHasPantsMale
    OIN[99] = "1"   ; CuirassHasPantsFemale

    OIN[100] = "0"  ; SmallNavigationIcons
    OIN[101] = "0"  ; LargeMenuDescriptions
    OIN[102] = "0"  ; DropShadowLightText
    OIN[103] = "0"  ; DropShadowIcons
    OIN[104] = "0"  ; DropShadowFlareText
    OIN[105] = "0"  ; GlowLightText
    OIN[106] = "0"  ; GlowFlareText
    OIN[107] = "1"  ; IconShading

    Return OIN
EndFunction




