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


import _oGlobal
import _oPatch
;OSA Global Functions

actor Property PlayerRef Auto
int Property glyph Auto hidden

_oUI Property OI hidden
    _oUI function get()
        return Quest.GetQuest("0SUI") as _oUI 
    endFunction
endProperty
;Add the _oUI persistent script to talk to the UI


int iVersion

_oControl OControl

package[] Property OPackage Auto 
faction[] Property OFaction Auto
Keyword[] Property OKeyword Auto
;Faction[0] OSAStatusFaction, used to stop multi OSA scenes from occuring on the same actors.
;       0: Not in a scene, 1:In a scene, 2:Double NPC scene that the player can observe or join in on.
;1= Faction 1 is RoleFaction, OBSOLETE
;2= The stage ID of the actors current scene is recorded here to relay information between spells.

string property codePage Auto Hidden

string[] preferenceSaves

ammo Property OBlankAmmo Auto
static Property OBlankStatic Auto
spell[] Property OSpell Auto
magicEffect[] Property OME Auto
spell[] Property OLightSP Auto
magicEffect[] Property OLightME Auto

formList Property OProjectile  Auto
formList Property OShader  Auto


objectReference[] Property GlobalPosition Auto

int [] OKB_Code
string[] OKB_Module
string[] OKB_Data

string[] OINI



int Property StageNumber = 10 Auto Hidden

;Ticking mechanism for the stageID so each cast increases it by 1.
;Stats at 10 to ensure that there are always double digits in case substring has to be used to trim the information.
; caps at 10 - 99 to ensure it's always in double digits.
; 10-49 are for KeyBound Scenes. 50-99 are for UI or Papyrus Initiated Scenes.
int Function stageID()
StageNumber +=1
If StageNumber > 49
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
    preferenceSaves = utility.createStringArray(10, "")
    Maintenance()
EndEvent
 

Function Maintenance()
miscutil.WriteToFile("Data/OSA/Logs/_maintenance_log.txt", "OSA BootUp Maitenance\n---------------------"+"   Running iVersion:"+iVersion+"\n   Script iVersion:"+_oV.GetIVersion()+"\n", false, true)


;;TESTING
armor MyArmor = Game.GetFormEx(0x1802376B) as armor

consoleUtil.SetSelectedReference(game.getPlayer())
consoleUtil.ExecuteCommand("equipitem 1802376B 1")


;;EndTESTING
osaPatch(self as _oOmni)

        If iVersion < _oV.GetIVersion()
            if iVersion
                cleanScript()
                rebootScript()
                miscutil.WriteToFile("Data/OSA/Logs/_maintenance_log.txt", "Cleaning and Rebooting Script/n", true, true)
            Else
                osaPatchMaint(self as _oOmni)
                rebootScript()
                miscutil.WriteToFile("Data/OSA/Logs/_maintenance_log.txt", "OSA first time initializinon. Booting up script.../n", true, true)
            EndIf
        Else
             miscutil.WriteToFile("Data/OSA/Logs/_maintenance_log.txt", "Reboot not needed, current version matches installed version", true, true)
        EndIf
    iVersion = _oV.GetIVersion()
       
osaPatchEnd(self as _oOmni)
EndFunction





function cleanScript()
cleanPositionArray(globalPosition)
endFunction

function rebootScript()
OINI = setOINI(PlayerRef)

UnregisterForAllModEvents()
unregisterForAllKeys()
RegisterForModEvent("0SA_UIBoot", "OnUIBoot")
OKB_Code = utility.createIntArray(126, 0)
OKB_Module = utility.createStringArray(126, "")
OKB_Data = utility.createStringArray(126, "")
if !preferenceSaves
    preferenceSaves = utility.createStringArray(10, "")
endIf
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

OControl= Quest.GetQuest("0SAControl") as _oControl
OControl.resetControls()
;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
;;codePage = CPConvert.GetCPForGameLng()
codePage = 1252
OINI[2] = Codepage
GlobalPosition = new ObjectReference[100]
endFunction

;   ____    _   _     _____    _____    ______            ____     ____     ____    _______ 
;  / __ \  | \ | |   |  __ \  |  __ \  |  ____|          |  _ \   / __ \   / __ \  |__   __|
; | |  | | |  \| |   | |__) | | |__) | | |__     ______  | |_) | | |  | | | |  | |    | |   
; | |  | | | . ` |   |  ___/  |  _  /  |  __|   |______| |  _ <  | |  | | | |  | |    | |   
; | |__| | | |\  |   | |      | | \ \  | |____           | |_) | | |__| | | |__| |    | |   
;  \____/  |_| \_|   |_|      |_|  \_\ |______|          |____/   \____/   \____/     |_|   
;                                                                                           


Event OnOStart(string eventName, string soundType, float numArg, Form sender)
;debug.messagebox(UI.getInt("HUD Menu", "_root.WidgetContainer."+glyph+".widget.__"+"0Sex"))
EndEvent



Event OnPreferences(string eventName, string DataString, float loadSave, Form sender)
int type = loadSave as int
if type <= 9
UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.cfg.loadSkySettings", preferenceSaves[type])
elseif type <= 19
preferenceSaves[type - 10] = DataString
elseif type <= 29
preferenceSaves[type - 20] = ""
endif
EndEvent

Event OnUIBoot(string eventName, string soundType, float numArg, Form sender)
 
Glyph = oi.WidgetID
scanFolders(glyph)
OControlSetUp()
SendINI()
utility.wait(0.1)
UI.InvokeIntA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyMKeyCode", OKB_Code)
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyMKeyMod", OKB_Module)
EndEvent

event OnINIFull(string eventName, string loadString, float b, Form c)
String[] vals = StringUtil.split(loadString, ",")
int i = 0
int L = vals.length
while i < L
OINI[i] = vals[i]
i+=1
endWhile
endEvent

function SendINI()
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyINI", OINI)
endFunction


event OnBindModule(string eventName, string moduleData, float bindKey, Form sender)
int keyBind = bindKey as int
String[] split = StringUtil.split(moduleData, ",")
int alreadyBound = OKB_Module.find(split[0])
if alreadyBound != -1
UnregisterForKey(OKB_Code[alreadyBound])
OKB_Code[alreadyBound] = 0
OKB_Module[alreadyBound] = ""
OKB_Data[alreadyBound] = ""
endIf
int i
bool slotFound
while i < 127
if OKB_Code[i] == 0
slotFound = true
OKB_Code[i] = keyBind
OKB_Module[i] = split[0]
OKB_Data[i] = moduleData
registerForKey(OKB_Code[i])

string[] report = new string[3]
report[0] = split[0]
report[1] = keyBind
report[2] = i
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.cfg.binds.bindModule", report)
i+=500
else
i+=1
endIf   
endWhile

endEvent




function OControlSetUp()
OControl.UpdateControls()
endFunction



function prepActra(string[] sceneSuite, actor[] actra)
int i = 0
int l = actra.length  
int stageID = sceneSuite[0] as int

            if GlobalPosition[stageID]
               GlobalPosition[stageID].Delete()
            endIf
            GlobalPosition[stageID] = actra[0].PlaceAtMe(OBlankStatic) as ObjectReference
           

while i < l
    processActraAll(actra[i], sceneSuite[i+1])
    actra[i].SetFactionRank(OFaction[0], 1) 
    actra[i].SetFactionRank(OFaction[1], stageID)    
    _oGlobal.packageSquelch(actra[i], OPackage)
i+=1
endwhile

OSpell[1].cast(actra[0], actra[0])

i = 0
while i < l
OSpell[0].cast(actra[i], actra[i])
i+=1
endwhile
endFunction

event OnKeyDown(int KeyPress)
;if keypress == 184
;testingOutput()
;else

osaByKey(StageID(), OKB_Code.Find(KeyPress))          
;endif
EndEvent




;  _______   _____    _____    _____                _  __  ______  __     __
; |__   __| |  __ \  |_   _|  / ____|              | |/ / |  ____| \ \   / /
;    | |    | |__) |   | |   | |  __     ______    | ' /  | |__     \ \_/ / 
;    | |    |  _  /    | |   | | |_ |   |______|   |  <   |  __|     \   /  
;    | |    | | \ \   _| |_  | |__| |              | . \  | |____     | |   
;    |_|    |_|  \_\ |_____|  \_____|              |_|\_\ |______|    |_|  


function osaByKey(string stageID, int index) 

if PlayerRef.GetFactionRank(OFaction[0]) != 1
    if index != -1 
    

    String[] trigData = StringUtil.split(OKB_Data[index], ",")

        if trigData[3] == "C"
                
                if stringUtil.getNthChar(trigData[2], 0)!="1"
                actor[] actra = New Actor[2]
                actra[0] = PlayerRef
                actra[1] = Game.GetCurrentCrosshairRef() as Actor            
                        if actra[1]
                            checkActra_ByKey(actra, StageID, index, trigData) 
                        endIf
                else
                actor[] actra = New Actor[1]
                actra[0] = Game.GetCurrentCrosshairRef() as Actor            
                        if actra[0]
                            if actra[0].GetFactionRank(OFaction[0]) != 1
                                if osa.isAllowed(actra[0])                                    
                                        actraReady_ByKey(actra, StageID, index, true) 
                                Endif
                            endif
                            checkActra_ByKey(actra, StageID, index, trigData) 
                        endif
                endif

        endIf
    
    endIf
EndIf
endFunction


function checkActra_ByKey(actor[] actra, string stageID, int index, string[] trigData)

            if actra[1].GetFactionRank(OFaction[0]) != 1
                if osa.isAllowed(actra[1])
                    string directional = stringUtil.getNthChar(trigData[4], 0)
                    if directional == "O"
                    actraReady_ByKey(actra, StageID, index) 
                    elseif directional == "D"
                        if directionCheck_D(actra[0], actra[1], StringUtil.SubString(trigData[4], 1, 3) as int, StringUtil.SubString(trigData[4], 4, 3) as int)
                            actraReady_ByKey(actra, StageID, index)
                        endif
                    endIf
                Endif
            EndIf
endFunction




function actraReady_ByKey(actor[] actra, string stageID, int index, bool solo=false)
    int L = actra.length
    int i = 0
    int stageIDint = stageID as int
    string[] dataPUSH = Utility.CreateStringArray(2+L)
    dataPUSH[0] = StageID
    dataPUSH[1] = OKB_Data[index]



                i = 0
                While i < L
                dataPush[2+i] = _oGlobal.GetFormID_s(actra[i].GetActorBase())
                processActraAll(actra[i], dataPush[2+i])
                actra[i].SetFactionRank(OFaction[0], 1) 
                actra[i].SetFactionRank(OFaction[1], stageIDint) 
                _oGlobal.packageSquelch(actra[i], OPackage)   


                i += 1
                EndWhile
                UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.playerCreateStage", dataPUSH)

             
                dataPush = new string[7]
                dataPush[0] = stageID
                if !solo
                dataPush[1] = actra[1].GetHeadingAngle(actra[0])

             
                dataPush[3] = (actra[0].IsHostileToActor(actra[1]) as int) as string
                dataPush[4] = (actra[1].IsHostileToActor(actra[1]) as int) as string
                dataPush[5] = actra[0].GetRelationshipRank(actra[1])
                dataPush[6] = actra[1].GetRelationshipRank(actra[0])
                else
                dataPush[1] = 0
                dataPush[3] = 0 as string
                dataPush[4] = 0 as string
                dataPush[5] = 0
                dataPush[6] = 0

                  endIf
                UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.playerStartStage", dataPUSH)

              

            if GlobalPosition[stageIDint]
              GlobalPosition[stageIDint].Delete()
            endIf
        GlobalPosition[stageIDint] = actra[0].PlaceAtMe(OBlankStatic) as ObjectReference
        OSpell[1].cast(actra[0], actra[0])

    i = 0
    While i < L
    OSpell[0].cast(actra[i], actra[i])
    i += 1
    EndWhile
endFunction






;              _____   _______   _____                 _____   _   _   ______    ____  
;     /\      / ____| |__   __| |  __ \      /\       |_   _| | \ | | |  ____|  / __ \ 
;    /  \    | |         | |    | |__) |    /  \        | |   |  \| | | |__    | |  | |
;   / /\ \   | |         | |    |  _  /    / /\ \       | |   | . ` | |  __|   | |  | |
;  / ____ \  | |____     | |    | | \ \   / ____ \     _| |_  | |\  | | |      | |__| |
; /_/    \_\  \_____|    |_|    |_|  \_\ /_/    \_\   |_____| |_| \_| |_|       \____/ 
                                                                                      


Function processActraAll(actor actra, string formID)
if actra.GetFactionRank(OFaction[0]) != 1
UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraInit", formID)
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraDetails", sendActraDetails(actra, formID, self as _oOmni))
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraScale", sendActraScale(actra, formID))
endif
endFunction

Function processActraDetails(actor actra, string formID)
if actra.GetFactionRank(OFaction[0]) != 1
UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraInit", formID)
UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraDetails", sendActraDetails(actra, formID, self as _oOmni))
endIf
endFunction











event OnStartModuleUI(string eventName, string dataString, float numArg, Form sender)
String[] data = StringUtil.split(dataString, ",")
Actor[] actro = PapyrusUtil.ActorArray(data.length - 1)

int i = 0
int l = data.length
    while i < l
actro[i] = game.getFormEx(data[i+1] as int) as actor
    i+=1
    endWhile

l = actro.length
i = 0
bool inScene = false
while i < l

if actro[i].GetFactionRank(OFaction[0]) != 1
else
inScene = true
i+10
endif
i+=1
endWhile
if inScene
else
    string[] newScene = osa.makeStage()
    osa.setActors(newScene, actro)
    osa.setModule(newScene, data[0])
    osa.start(newScene)
endif
endEvent


event OnScanDirectoryForFileType(string eventName, string stringData, float boolIndex, Form sender)
String[] data = StringUtil.split(stringData, ",")
    ;;UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.lib.codex.scanIdentity", MiscUtil.FilesInFolder("Data/meshes/0SP/base/identity/",".oiden"))
    if Data[0]=="1"
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget."+data[3], MiscUtil.FilesInFolder("Data/"+data[1], data[2]))
    endIf
endEvent


event OnINIBool(string eventName, string boolValue, float boolIndex, Form sender)
OINI[boolIndex as int] = boolValue
endEvent

event OnUnBind(string eventName, string indexValue, float boolIndex, Form sender)
int ix = indexValue as int
unregisterForKey(OKB_Code[ix])
OKB_Code[ix] = 0
OKB_Module[ix] = ""
OKB_Data[ix] = ""
endEvent

event OnSpecial(string eventName, string special, float floatVal, Form sender)
if special == "ExposureException"
_oFrostFall.oFrostFall(GlobalPosition[floatVal as int])
elseIf special == "RefreshCodepage"
;;CPConvert.dll NEED FIX (CPConvert needs 64bit recompile)
;codePage = CPConvert.GetCPForGameLng()
codePage = 1252
OINI[2] = Codepage
endIf
endEvent

event OnReset(string eventName, string resetCommand, float floatVal, Form sender)

endEvent


event OnReport(string eventName, string reportValue, float reportCommand, Form reportForm)
int report = reportCommand as int
if report == 1
systemReport()
endIf
endEvent

event OnOutputLog(string noEvent, string outputLog, float noFloat, Form noForm)
string[] stringData = StringUtil.split(outputLog, "$#$#$")
string fileDir = "Data/OSA/Logs/"+stringData[0]+".txt"
miscutil.WriteToFile(fileDir, stringData[1], false, true)
endEvent

function testingArea()
;RegisterForKey(184)
endFunction

function testingOutput()
endFunction

function testingOutputbak()
endFunction

string[] function setOINI(actor Player) global
string[] OIN = new string[120]
OIN[0]  = ""
OIN[1]  = "!dg"     ;Player symbol
OIN[2]  = ""            ;codePage
OIN[3]  = "1"            ;AutoCodePage 
OIN[4]  = "1"            ;helpMode
OIN[5]  = "1"            ;purityMode
OIN[6]  = "0"             ;useMetric
OIN[7]  = "0"           ;devMode                      /////////// SET TO 0
OIN[8]  = "ic"          ;subColor
OIN[9]  = "op"          ;themeColor
OIN[10] = "1"           ;sortRoleByAnimGender
OIN[11] = "1"           ;allowBodyScaling
OIN[12] = "1"           ;allowMaleGenitalScaling
OIN[13] = "0"
OIN[14] = ""            
OIN[15] = ""            
OIN[16] = ""
OIN[17] = ""
OIN[18] = _oFrostfall.oFrostCompat();frostFallInstall
OIN[19] = "1"           ;frostfallException
OIN[20] = "0"           ;internationalFont
OIN[21] = "1"           ;internationalFontSansSerif
OIN[22] = "0"           ;textOptUI
OIN[23] = "1"           ;dynamicIconDisplay
OIN[24] = "1"           ;skinToneDisplay
OIN[25] = "1"           ;navVanish
OIN[26] = "1"           ;logging                      /////////// SET TO 0
OIN[27] = ""
OIN[28] = ""
OIN[29] = ""
OIN[30] = ""           ;MyEquip
OIN[31] = ""           ;MyHero
OIN[32] = ""           ;MyBody
OIN[38] = "0"           ;renameInGame
OIN[39] = "0"           ;renameNpc
;~ FLAGS
    ;~GENERAL
OIN[40] = "0"           ;flagPillage
OIN[41] = "0"           ;flagHyper-Taboo
OIN[42] = "0"           ;flagModernObjects
    ;~Combat
OIN[50] = "0"           ;fComDismemberment
OIN[51] = "0"           ;fComModernWeapons
OIN[52] = "0"           ;fComUltimates
OIN[53] = "0"           ;fComSupremes
OIN[54] = "0"           ;fComNaughty
OIN[55] = "0"           ;fComStripping
OIN[56] = "0"           ;fComSex
    ;~Intimacy
    ;~SEX
OIN[60] = "0"           ;fSexFantastical
OIN[61] = "0"           ;fSexRough


OIN[79] = "0"           
OIN[80] = "helmet,x,cuirass,gloves,x,necklace,rings,boots,x,shield,x,x,x,earrings,glasses,intlow,pants,x,miscup,miscmid,x,x,x,misclow,stockings,x,inthigh,cape,x,miscarms,x,x!61"           ;esgSettings0
OIN[81] = "helmet,x,cuirass,gloves,x,necklace,rings,boots,x,shield,x,x,x,earrings,glasses,intlow,pants,x,miscup,miscmid,x,x,x,misclow,stockings,x,inthigh,cape,x,miscarms,x,x!61"           ;esgSettings1
OIN[82] = "1"           ;hideUnwornESG
OIN[83] = "0"           ;AIintlow1 (Auto-Intimates, LowerBody Female)
OIN[84] = "0"           ;AIinthigh1 (Auto-Intimates, UpperBody Female)
OIN[85] = "0"           ;AIintlow0 (Auto-Intimates, LowerBody Male)
OIN[86] = "0"           ;AIinthigh0 (Auto-Intimates, UpperBody Male)
OIN[87] = "0"           ;Reserved for socks
OIN[88] = "0"           ;Reserved for Socks
OIN[89] = "0"           ;Genital
OIN[90] = "0"           ;Genital 
OIN[91] = "0"           ;Reserved
OIN[92] = "0"           ;Reserved
OIN[93] = "1"           ;animRedressPlayer
OIN[94] = "0"           ;instaRedressPlayer
OIN[95] = "1"           ;animRedressNPC
OIN[96] = "0"           ;instaRedressNPC
OIN[97] = "1"           ;clothingAudio
OIN[98] = "1"           ;cuirassHasPantsMale
OIN[99] = "1"           ;cuirassHasPantsFemale

OIN[100] = "0"           ;smallNavigationIcons
OIN[101] = "0"           ;largeMenuDescriptions
OIN[102] = "0"           ;dropShadowLightText
OIN[103] = "0"           ;dropShadowIcons
OIN[104] = "0"           ;dropShadowFlareText
OIN[105] = "0"           ;glowLightText
OIN[106] = "0"           ;glowFlareText
OIN[107] = "1"           ;iconShading

return OIN
endFunction




