ScriptName dubhDisguiseMCMQuestScript Extends dubhDisguiseMCMHelper

GlobalVariable Property Global_fBestSkillContribMax Auto
GlobalVariable Property Global_fBountyPenaltyMult Auto
GlobalVariable Property Global_fDetectionViewConeMCM Auto
GlobalVariable Property Global_fEscapeDistance Auto
GlobalVariable Property Global_fFOVPenaltyClear Auto
GlobalVariable Property Global_fFOVPenaltyDistorted Auto
GlobalVariable Property Global_fFOVPenaltyPeripheral Auto
GlobalVariable Property Global_fLOSDistanceMax Auto
GlobalVariable Property Global_fLOSPenaltyFar Auto
GlobalVariable Property Global_fLOSPenaltyMid Auto
GlobalVariable Property Global_fMobilityBonus Auto
GlobalVariable Property Global_fMobilityPenalty Auto
GlobalVariable Property Global_fRaceArgonian Auto
GlobalVariable Property Global_fRaceArgonianVampire Auto
GlobalVariable Property Global_fRaceBreton Auto
GlobalVariable Property Global_fRaceBretonVampire Auto
GlobalVariable Property Global_fRaceDarkElf Auto
GlobalVariable Property Global_fRaceDarkElfVampire Auto
GlobalVariable Property Global_fRaceHighElf Auto
GlobalVariable Property Global_fRaceHighElfVampire Auto
GlobalVariable Property Global_fRaceImperial Auto
GlobalVariable Property Global_fRaceImperialVampire Auto
GlobalVariable Property Global_fRaceKhajiit Auto
GlobalVariable Property Global_fRaceKhajiitVampire Auto
GlobalVariable Property Global_fRaceNord Auto
GlobalVariable Property Global_fRaceNordVampire Auto
GlobalVariable Property Global_fRaceOrc Auto
GlobalVariable Property Global_fRaceOrcVampire Auto
GlobalVariable Property Global_fRaceRedguard Auto
GlobalVariable Property Global_fRaceRedguardVampire Auto
GlobalVariable Property Global_fRaceWoodElf Auto
GlobalVariable Property Global_fRaceWoodElfVampire Auto
GlobalVariable Property Global_fScriptDistanceMax Auto
GlobalVariable Property Global_fScriptSuspendTime Auto
GlobalVariable Property Global_fScriptSuspendTimeBeforeAttack Auto
GlobalVariable Property Global_fScriptUpdateFrequencyCompatibility Auto
GlobalVariable Property Global_fScriptUpdateFrequencyMonitor Auto
GlobalVariable Property Global_fSlotAmulet Auto
GlobalVariable Property Global_fSlotBody Auto
GlobalVariable Property Global_fSlotCirclet Auto
GlobalVariable Property Global_fSlotFeet Auto
GlobalVariable Property Global_fSlotHair Auto
GlobalVariable Property Global_fSlotHands Auto
GlobalVariable Property Global_fSlotRing Auto
GlobalVariable Property Global_fSlotShield Auto
GlobalVariable Property Global_fSlotWeaponLeft Auto
GlobalVariable Property Global_fSlotWeaponRight Auto
GlobalVariable Property Global_iAlwaysSucceedDremora Auto
GlobalVariable Property Global_iAlwaysSucceedWerewolves Auto
GlobalVariable Property Global_iCrimeFalkreath Auto
GlobalVariable Property Global_iCrimeHjaalmarch Auto
GlobalVariable Property Global_iCrimeImperial Auto
GlobalVariable Property Global_iCrimeMarkarth Auto
GlobalVariable Property Global_iCrimePale Auto
GlobalVariable Property Global_iCrimeRavenRock Auto
GlobalVariable Property Global_iCrimeRiften Auto
GlobalVariable Property Global_iCrimeSolitude Auto
GlobalVariable Property Global_iCrimeStormcloaks Auto
GlobalVariable Property Global_iCrimeWhiterun Auto
GlobalVariable Property Global_iCrimeWindhelm Auto
GlobalVariable Property Global_iCrimeWinterhold Auto
GlobalVariable Property Global_iDiscoveryEnabled Auto
GlobalVariable Property Global_iDisguiseEssentialSlotBandit Auto
GlobalVariable Property Global_iNotifyEnabled Auto
GlobalVariable Property Global_iPapyrusLoggingEnabled Auto
GlobalVariable Property Global_iVampireNightOnly Auto
GlobalVariable Property Global_iVampireNightOnlyDayHourBegin Auto
GlobalVariable Property Global_iVampireNightOnlyDayHourEnd Auto

GlobalVariable[] Property rgDisguisesEnabled Auto

Actor Property PlayerRef Auto
Faction Property DisguiseFaction03 Auto  ; Dark Brotherhood
Faction Property DisguiseFaction12 Auto  ; Thieves Guild
Faction Property DisguiseFaction31 Auto  ; Bandits
Faction Property DarkBrotherhoodFaction Auto
Faction Property ThievesGuildFaction Auto
FormList Property BaseFactions Auto
FormList Property DisguiseFactions Auto
FormList Property DisguiseFormLists Auto
FormList Property GuardFactions Auto
FormList Property TrackedBounties Auto
Quest Property CompatibilityQuest Auto
Quest Property DetectionQuest Auto

dubhPlayerScript Property PlayerScript Auto

Sound Property PickUpSound Auto

Bool bGuardsVsDarkBrotherhood    = False
Bool bGuardsVsDarkBrotherhoodNPC = False
Bool bGuardsVsThievesGuild       = False
Bool bGuardsVsThievesGuildNPC    = False

String ModName

; =============================================================================
; FUNCTIONS
; =============================================================================

Function _Log(String asTextToPrint, Int aiSeverity = 0)
  If (Global_iPapyrusLoggingEnabled.GetValue() as Int) as Bool
    Debug.OpenUserLog("MasterOfDisguise")
    Debug.TraceUser("MasterOfDisguise", "dubhDisguiseMCMQuestScript> " + asTextToPrint, aiSeverity)
  EndIf
EndFunction


Function LogInfo(String asTextToPrint)
  _Log("[INFO] " + asTextToPrint, 0)
EndFunction


Function LogWarning(String asTextToPrint)
  _Log("[WARN] " + asTextToPrint, 1)
EndFunction


Function LogError(String asTextToPrint)
  _Log("[ERRO] " + asTextToPrint, 2)
EndFunction


Function Alias_DefineMCMToggleOptionModEvent(String asName, String asModEvent, Bool abInitialState = False, Int aiFlags = 0)
  ; when asName and asModEvent need to differ
  RegisterForModEvent(asModEvent, "OnBooleanToggleClick")
  DefineMCMToggleOption("$dubh" + asName, abInitialState, aiFlags, "$dubhHelp" + asName, asModEvent)
EndFunction

Function Alias_DefineMCMToggleModEvent(String asModEvent, Bool abInitialState = False, Int aiFlags = 0)
  ; when mod event name will be used as option name
  RegisterForModEvent(asModEvent, "OnBooleanToggleClick")
  DefineMCMToggleOption("$dubh" + asModEvent, abInitialState, aiFlags, "$dubhHelp" + asModEvent, asModEvent)
EndFunction


Function Alias_DefineMCMToggleOptionGlobal(String asName, GlobalVariable akGlobal, Int aiFlags = 0)
  DefineMCMToggleOptionGlobal("$dubh" + asName, akGlobal, aiFlags, "$dubhHelp" + asName)
EndFunction


Function Alias_DefineMCMSliderOptionGlobal(String asName, GlobalVariable akGlobal, Float afMin, Float afMax, Float afInterval, Int aiFlags = 0)
  DefineMCMSliderOptionGlobal("$dubh" + asName, akGlobal, akGlobal.GetValue(), afMin, afMax, afInterval, "$dubhHelp" + asName, "{2}", aiFlags)
EndFunction

Function Alias_DefineMCMMenuOptionGlobal(String asTextLabel, String asValuesCSV, GlobalVariable akGlobal, Int iDefault = 0)
  DefineMCMMenuOptionGlobal("$dubh" + asTextLabel, asValuesCSV, akGlobal, iDefault, 0, "$dubhHelp" + asTextLabel, "")
EndFunction


Function DefineMCMToggleDisguise(Int aiIndex)
  Int actualIndex = aiIndex - 1
  String sModEvent = "TryUpdateDisguise_" + actualIndex
  RegisterForModEvent(sModEvent, "OnBooleanToggleClick")
  DefineMCMToggleOptionGlobal("$dubhDisguise" + aiIndex, rgDisguisesEnabled[actualIndex] as GlobalVariable, 0, "$dubhHelpDisguise" + aiIndex, sModEvent)
EndFunction

Function DefineMCMCheatDisguise(Int aiIndex)
  String sModEvent = "CheatDisguise_" + aiIndex
  RegisterForModEvent(sModEvent, "OnBooleanToggleClick")
  DefineMCMTextOption("$dubhDisguise" + aiIndex, "", OPTION_FLAG_AS_TEXTTOGGLE, "$dubhHelpCheatDisguise" + aiIndex, sModEvent)
EndFunction


Function ClearDisguiseFactions()
  ; Removes player from all disguise factions

  Int i = 0

  While i < DisguiseFactions.GetSize()
    Faction kFaction = DisguiseFactions.GetAt(i) as Faction
    If PlayerRef.IsInFaction(kFaction)
      PlayerRef.RemoveFromFaction(kFaction)
    EndIf
    i += 1
  EndWhile

  LogInfo("Removed the player from all disguise factions.")
EndFunction


Bool Function StartQuest(Quest akQuest)
  If akQuest.IsStopping()
    LogInfo(akQuest + ": could not start because quest is stopping")
    Return False
  EndIf

  If !akQuest.IsStopped()
    LogInfo(akQuest + ": could not start because quest is not stopped")
    Return False
  EndIf

  If akQuest.Start()
    LogInfo(akQuest + ": successfully started")
    Return True
  EndIf

  LogWarning(akQuest + ": could not start due to unknown reasons")
  Return False
EndFunction


Bool Function StopQuest(Quest akQuest)
  If akQuest.IsStopped() || akQuest.IsStopping()
    LogWarning(akQuest + ": could not stop because quest is already stopped or stopping")
    Return False
  EndIf

  Int _cycles = 0

  akQuest.Stop()

  While akQuest.IsRunning()
    LogInfo(akQuest + ": waiting until quest stops running")
    _cycles += 1
  EndWhile

  While akQuest.IsStopping()
    LogInfo(akQuest + ": waiting until quest stops stopping")
    _cycles += 1
  EndWhile

  If akQuest.IsStopped()
    LogInfo(akQuest + ": successfully stopped")
    Return True
  EndIf

  LogWarning(akQuest + ": could not stop due to unknown reasons")
  Return False
EndFunction

; =============================================================================
; EVENTS
; =============================================================================

Event OnConfigInit()
  Pages = new String[9]
  Pages[0] = "$dubhPageInformation"
  Pages[1] = "$dubhPageDisguises"
  Pages[2] = "$dubhPageDiscovery"
  Pages[3] = "$dubhPageScoring"
  Pages[4] = "$dubhPageRace"
  Pages[5] = "$dubhPageCrime"
  Pages[6] = "$dubhPageCrimeBounties"
  Pages[7] = "$dubhPageAdvanced"
  Pages[8] = "$dubhPageCheats"
EndEvent

Event OnPageReset(String asPageName)
  SetCursorFillMode(TOP_TO_BOTTOM)

  If asPageName == ""
    LoadCustomContent("dubhDisguiseLogo.dds")
    Return
  EndIf

  If asPageName != ""
    UnloadCustomContent()
  EndIf

  If asPageName == "$dubhPageInformation"
    SetCursorFillMode(TOP_TO_BOTTOM)

    AddHeaderOption("$dubhHeadingInformationAccolades")
    DefineMCMParagraph("$dubhInformationAccoladesText01")
    DefineMCMParagraph("$dubhInformationAccoladesText02")
    DefineMCMParagraph("$dubhInformationAccoladesText03")
    DefineMCMParagraph("$dubhInformationAccoladesText04")
    DefineMCMParagraph("$dubhInformationAccoladesText05")
    DefineMCMParagraph("$dubhInformationAccoladesText06")

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingInformationCredits")
    DefineMCMParagraph("$dubhInformationCredits01")
    DefineMCMParagraph("$dubhInformationCredits02")
    DefineMCMParagraph("$dubhInformationCredits03")

    SetCursorPosition(1)

    AddHeaderOption("$dubhHeadingInformationSupport")

    DefineMCMParagraph("$dubhInformationSupportText01")
    DefineMCMParagraph("$dubhInformationSupportText02")
    DefineMCMParagraph("$dubhInformationSupportText03")

    AddEmptyOption()

    DefineMCMParagraph("$dubhInformationSupportText04")
    DefineMCMParagraph("$dubhInformationSupportText05")

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingInformationPermissions")
    DefineMCMParagraph("$dubhInformationPermissions01")
    DefineMCMParagraph("$dubhInformationPermissions02")

  ElseIf asPageName == "$dubhPageDiscovery"
    SetCursorFillMode(TOP_TO_BOTTOM)

    AddHeaderOption("$dubhHeadingDiscoveryFov")
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionViewCone", Global_fDetectionViewConeMCM, 30.0, 360.0, 5.0)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingDiscoveryLos")
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionLosMax",   Global_fLOSDistanceMax, 1024.0, Global_fScriptDistanceMax.GetValue(), 256.0)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingDiscoveryFovPenalties")
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionFovClear",      Global_fFOVPenaltyClear,      0.0, 1.0, 0.05)
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionFovDistorted",  Global_fFOVPenaltyDistorted,  0.0, 1.0, 0.05)
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionFovPeripheral", Global_fFOVPenaltyPeripheral, 0.0, 1.0, 0.05)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingDiscoveryLosPenalties")
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionLosMid",      Global_fLOSPenaltyMid, 0.0, 1.0, 0.05)
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionLosFar",      Global_fLOSPenaltyFar, 0.0, 1.0, 0.05)

    SetCursorPosition(1)

    AddHeaderOption("$dubhHeadingDiscoveryBiWinning")
    Alias_DefineMCMToggleOptionGlobal("DiscoveryOptionDremora",     Global_iAlwaysSucceedDremora)
    Alias_DefineMCMToggleOptionGlobal("DiscoveryOptionWerewolves",  Global_iAlwaysSucceedWerewolves)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingDiscoveryVN")
    Alias_DefineMCMToggleOptionGlobal("DiscoveryOptionVN",          Global_iVampireNightOnly)
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionVNDayBegins", Global_iVampireNightOnlyDayHourBegin, 0.0, 24.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("DiscoveryOptionVNDayEnds",   Global_iVampireNightOnlyDayHourEnd,   0.0, 24.0, 1.0)

  ElseIf asPageName == "$dubhPageScoring"
    SetCursorFillMode(TOP_TO_BOTTOM)

    AddHeaderOption("$dubhHeadingScoringBestSkill")
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionBestSkillMax",  Global_fBestSkillContribMax, 0.0, 100.0, 10.0)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingScoringMobility")
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionMobilityBonus",   Global_fMobilityBonus,   1.0, 1.5, 0.05)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionMobilityPenalty", Global_fMobilityPenalty, 0.5, 1.0, 0.05)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingScoringWeapons")
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionWeaponLeft",    Global_fSlotWeaponLeft,      0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionWeaponRight",   Global_fSlotWeaponRight,     0.0, 100.0, 1.0)

    SetCursorPosition(1)

    AddHeaderOption("$dubhHeadingScoringEquipment")
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionAmulet",        Global_fSlotAmulet,          0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionBody",          Global_fSlotBody,            0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionCirclet",       Global_fSlotCirclet,         0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionFeet",          Global_fSlotFeet,            0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionHair",          Global_fSlotHair,            0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionHands",         Global_fSlotHands,           0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionRing",          Global_fSlotRing,            0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("ScoringOptionShield",        Global_fSlotShield,          0.0, 100.0, 1.0)

  ElseIf asPageName == "$dubhPageRace"
    SetCursorFillMode(TOP_TO_BOTTOM)

    AddHeaderOption("$dubhHeadingRaceModifiers1")
    Alias_DefineMCMSliderOptionGlobal("RaceOptionAltmer",           Global_fRaceHighElf,         0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionArgonian",         Global_fRaceArgonian,        0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionBosmer",           Global_fRaceWoodElf,         0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionBreton",           Global_fRaceBreton,          0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionDunmer",           Global_fRaceDarkElf,         0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionImperial",         Global_fRaceImperial,        0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionKhajiit",          Global_fRaceKhajiit,         0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionNord",             Global_fRaceNord,            0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionOrc",              Global_fRaceOrc,             0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionRedguard",         Global_fRaceRedguard,        0.0, 100.0, 1.0)

    SetCursorPosition(1)

    AddHeaderOption("$dubhHeadingRaceModifiers2")
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireAltmer",    Global_fRaceHighElfVampire,  0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireArgonian",  Global_fRaceArgonianVampire, 0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireBosmer",    Global_fRaceWoodElfVampire,  0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireBreton",    Global_fRaceBretonVampire,   0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireDunmer",    Global_fRaceDarkElfVampire,  0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireImperial",  Global_fRaceImperialVampire, 0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireKhajiit",   Global_fRaceKhajiitVampire,  0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireNord",      Global_fRaceNordVampire,     0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireOrc",       Global_fRaceOrcVampire,      0.0, 100.0, 1.0)
    Alias_DefineMCMSliderOptionGlobal("RaceOptionVampireRedguard",  Global_fRaceRedguardVampire, 0.0, 100.0, 1.0)

  ElseIf asPageName == "$dubhPageCrime"
    SetCursorFillMode(TOP_TO_BOTTOM)

    AddHeaderOption("$dubhHeadingCrimeBountyPenalty")
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionBountyMult", Global_fBountyPenaltyMult, 0.0, 1.0, 0.01, 1)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingCrimeBanditDisguise")
    Alias_DefineMCMToggleOptionGlobal("CrimeOptionBandits", rgDisguisesEnabled[30] as GlobalVariable)
    Alias_DefineMCMMenuOptionGlobal("CrimeOptionBanditSlot", "$dubhSlot0,$dubhSlot1,$dubhSlot2,$dubhSlot3,$dubhSlot4,$dubhSlot5,$dubhSlot6,$dubhSlot7,$dubhSlot8,$dubhSlot9", Global_iDisguiseEssentialSlotBandit, 1)

    SetCursorPosition(1)

    AddHeaderOption("$dubhHeadingCrimeFactionRelations")
    Alias_DefineMCMToggleOptionModEvent("CrimeOptionGuardsVsDB",    "dubhToggleGuardsVsDarkBrotherhood",    bGuardsVsDarkBrotherhood)
    Alias_DefineMCMToggleOptionModEvent("CrimeOptionGuardsVsTG",    "dubhToggleGuardsVsThievesGuild",       bGuardsVsThievesGuild)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingCrimeFactionRelationsNPC")
    Alias_DefineMCMToggleOptionModEvent("CrimeOptionGuardsVsDBNPC", "dubhToggleGuardsVsDarkBrotherhoodNPC", bGuardsVsDarkBrotherhoodNPC)
    Alias_DefineMCMToggleOptionModEvent("CrimeOptionGuardsVsTGNPC", "dubhToggleGuardsVsThievesGuildNPC",    bGuardsVsThievesGuildNPC)

  ElseIf asPageName == "$dubhPageCrimeBounties"
    SetCursorFillMode(TOP_TO_BOTTOM)

    AddHeaderOption("$dubhHeadingCrimeEmpireLovesLists")
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionImperial",    Global_iCrimeImperial,    0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionStormcloaks", Global_iCrimeStormcloaks, 0.0, 99999.0, 1.0, 1)

    SetCursorPosition(1)

    AddHeaderOption("$dubhHeadingCrimeTrackedBounties")
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionFalkreath",   Global_iCrimeFalkreath,   0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionHjaalmarch",  Global_iCrimeHjaalmarch,  0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionMarkarth",    Global_iCrimeMarkarth,    0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionPale",        Global_iCrimePale,        0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionRavenRock",   Global_iCrimeRavenRock,   0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionRiften",      Global_iCrimeRiften,      0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionSolitude",    Global_iCrimeSolitude,    0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionWhiterun",    Global_iCrimeWhiterun,    0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionWindhelm",    Global_iCrimeWindhelm,    0.0, 99999.0, 1.0, 1)
    Alias_DefineMCMSliderOptionGlobal("CrimeOptionWinterhold",  Global_iCrimeWinterhold,  0.0, 99999.0, 1.0, 1)

  ElseIf asPageName == "$dubhPageAdvanced"
    SetCursorFillMode(TOP_TO_BOTTOM)

    AddHeaderOption("$dubhHeadingAdvancedWatchRate")
    Alias_DefineMCMSliderOptionGlobal("AdvancedOptionWatchRate", Global_fScriptSuspendTime, 0.0, 60.0, 1.0)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingAdvancedDiscovery")
    Alias_DefineMCMSliderOptionGlobal("AdvancedOptionDiscoveryMax", Global_fScriptDistanceMax, 0.0, Global_fEscapeDistance.GetValue(), 256.0)
    Alias_DefineMCMSliderOptionGlobal("AdvancedOptionUpdateRateDiscovery", Global_fScriptUpdateFrequencyMonitor, 0.0, 30.0, 1.0)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingAdvancedCompatibility")
    Alias_DefineMCMSliderOptionGlobal("AdvancedOptionUpdateRateCompatibility", Global_fScriptUpdateFrequencyCompatibility, 0.0, 30.0, 1.0)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingAdvancedEnemies")
    Alias_DefineMCMSliderOptionGlobal("AdvancedOptionEscapeDistance", Global_fEscapeDistance, Global_fScriptDistanceMax.GetValue(), 8192.0, 256.0)

    SetCursorPosition(1)

    AddHeaderOption("$dubhHeadingAdvancedCombatDelay")
    Alias_DefineMCMSliderOptionGlobal("AdvancedOptionCombatDelay", Global_fScriptSuspendTimeBeforeAttack, 0.0, 60.0, 1.0)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingAdvancedDebug")
    Alias_DefineMCMToggleOptionGlobal("AdvancedOptionNotifyEnabled", Global_iNotifyEnabled)
    Alias_DefineMCMToggleOptionGlobal("AdvancedOptionPapyrusLogging", Global_iPapyrusLoggingEnabled)

    AddEmptyOption()

    AddHeaderOption("$dubhHeadingAdvancedSetup")
    Alias_DefineMCMToggleOptionModEvent("AdvancedOptionCompatibility", "ToggleDynamicCompatibility", CompatibilityQuest.IsRunning())
    Alias_DefineMCMToggleOptionModEvent("AdvancedOptionDiscoverySystem", "ToggleDiscoverySystem", DetectionQuest.IsRunning())

  ElseIf asPageName == "$dubhPageDisguises"
    SetCursorFillMode(TOP_TO_BOTTOM)

    DefineMCMParagraph("$dubhHelpPageDisguises1")
    DefineMCMParagraph("$dubhHelpPageDisguises2")

    AddEmptyOption()

    DefineMCMParagraph("$dubhHelpPageDisguises3")
    DefineMCMParagraph("$dubhHelpPageDisguises4")
    DefineMCMParagraph("$dubhHelpPageDisguises5")

    SetCursorPosition(1)

    DefineMCMToggleDisguise(1)
    DefineMCMToggleDisguise(2)
    DefineMCMToggleDisguise(3)
    DefineMCMToggleDisguise(4)
    DefineMCMToggleDisguise(5)
    DefineMCMToggleDisguise(6)
    DefineMCMToggleDisguise(7)
    DefineMCMToggleDisguise(8)
    DefineMCMToggleDisguise(9)
    DefineMCMToggleDisguise(10)
    DefineMCMToggleDisguise(11)
    DefineMCMToggleDisguise(12)
    DefineMCMToggleDisguise(13)
    DefineMCMToggleDisguise(14)
    DefineMCMToggleDisguise(15)
    DefineMCMToggleDisguise(16)
    DefineMCMToggleDisguise(17)
    DefineMCMToggleDisguise(18)
    DefineMCMToggleDisguise(19)
    DefineMCMToggleDisguise(20)
    DefineMCMToggleDisguise(21)
    DefineMCMToggleDisguise(22)
    DefineMCMToggleDisguise(23)
    DefineMCMToggleDisguise(24)
    DefineMCMToggleDisguise(25)
    DefineMCMToggleDisguise(26)
    DefineMCMToggleDisguise(27)
    DefineMCMToggleDisguise(28)
    DefineMCMToggleDisguise(29)
    DefineMCMToggleDisguise(30)
    DefineMCMToggleDisguise(31)

  ElseIf asPageName == "$dubhPageCheats"
    SetCursorFillMode(TOP_TO_BOTTOM)

    DefineMCMParagraph("$dubhHelpPageCheats1")
    DefineMCMParagraph("$dubhHelpPageCheats2")

    SetCursorPosition(1)

    DefineMCMCheatDisguise(1)
    DefineMCMCheatDisguise(2)
    DefineMCMCheatDisguise(3)
    DefineMCMCheatDisguise(4)
    DefineMCMCheatDisguise(5)
    DefineMCMCheatDisguise(6)
    DefineMCMCheatDisguise(7)
    DefineMCMCheatDisguise(8)
    DefineMCMCheatDisguise(9)
    DefineMCMCheatDisguise(10)
    DefineMCMCheatDisguise(11)
    DefineMCMCheatDisguise(12)
    DefineMCMCheatDisguise(13)
    DefineMCMCheatDisguise(14)
    DefineMCMCheatDisguise(15)
    DefineMCMCheatDisguise(16)
    DefineMCMCheatDisguise(17)
    DefineMCMCheatDisguise(18)
    DefineMCMCheatDisguise(19)
    DefineMCMCheatDisguise(20)
    DefineMCMCheatDisguise(21)
    DefineMCMCheatDisguise(22)
    DefineMCMCheatDisguise(23)
    DefineMCMCheatDisguise(24)
    DefineMCMCheatDisguise(25)
    DefineMCMCheatDisguise(26)
    DefineMCMCheatDisguise(27)
    DefineMCMCheatDisguise(28)
    DefineMCMCheatDisguise(29)
    DefineMCMCheatDisguise(30)
    DefineMCMCheatDisguise(31)
  EndIf
EndEvent

Event OnBooleanToggleClick(String asEventName, String strArg, Float numArg, Form sender)
  FormList kForms = None

  If asEventName == "dubhToggleDynamicCompatibility"
    If CompatibilityQuest.IsRunning()
      StopQuest(CompatibilityQuest)
    Else
      StartQuest(CompatibilityQuest)
    EndIf
  ElseIf asEventName == "dubhToggleDiscoverySystem"
    If DetectionQuest.IsRunning()
      StopQuest(DetectionQuest)
    Else
      StartQuest(DetectionQuest)
    EndIf
  ElseIf LibFire.ContainsText(asEventName, "CheatDisguise")
    String[] results = LibFire.SplitString(asEventName, "_")
    Int factionIndex = (results[1] as Int) - 1
    PlayerRef.AddItem(DisguiseFormLists.GetAt(factionIndex) as FormList, 1, True)
    LogInfo("Added items from disguise formlist: factionIndex = " + factionIndex)
    Int instanceId = PickUpSound.Play(PlayerRef)
    Sound.SetInstanceVolume(instanceId, 1.0)
  ElseIf LibFire.ContainsText(asEventName, "TryUpdateDisguise")
    String[] results = LibFire.SplitString(asEventName, "_")
    Int factionIndex = results[1] as Int
    PlayerScript.UpdateDisguise(factionIndex)
    LogInfo("Updated disguise: factionIndex = " + factionIndex)
  ElseIf asEventName == "dubhToggleGuardsVsDarkBrotherhood"
    bGuardsVsDarkBrotherhood = numArg as Bool
    If bGuardsVsDarkBrotherhood
      LibFire.SetEnemies(DisguiseFaction03, GuardFactions)
    Else
      LibFire.SetEnemies(DisguiseFaction03, GuardFactions, True, True)
    EndIf
  ElseIf asEventName == "dubhToggleGuardsVsDarkBrotherhoodNPC"
    bGuardsVsDarkBrotherhoodNPC = numArg as Bool
    If bGuardsVsDarkBrotherhoodNPC
      LibFire.SetEnemies(DarkBrotherhoodFaction, GuardFactions)
    Else
      LibFire.SetEnemies(DarkBrotherhoodFaction, GuardFactions, True, True)
    EndIf
  ElseIf asEventName == "dubhToggleGuardsVsThievesGuild"
    bGuardsVsThievesGuild = numArg as Bool
    If bGuardsVsThievesGuild
      LibFire.SetEnemies(DisguiseFaction12, GuardFactions)
      LogInfo("Guards vs. Thieves Guild toggled on for Player")
    Else
      LibFire.SetEnemies(DisguiseFaction12, GuardFactions, True, True)
      LogInfo("Guards vs. Thieves Guild toggled off for Player")
    EndIf
  ElseIf asEventName == "dubhToggleGuardsVsThievesGuildNPC"
    bGuardsVsThievesGuildNPC = numArg as Bool
    If bGuardsVsThievesGuildNPC
      LibFire.SetEnemies(ThievesGuildFaction, GuardFactions)
      LogInfo("Guards vs. Thieves Guild toggled on for NPCs")
    Else
      LibFire.SetEnemies(ThievesGuildFaction, GuardFactions, True, True)
      LogInfo("Guards vs. Thieves Guild toggled off for NPCs")
    EndIf
  EndIf
EndEvent