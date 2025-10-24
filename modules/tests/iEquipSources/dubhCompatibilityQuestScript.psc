ScriptName dubhCompatibilityQuestScript Extends Quest

Import dubhUtilityScript

; =============================================================================
; PROPERTIES
; =============================================================================

GlobalVariable Property Global_fDetectionViewConeMCM Auto
GlobalVariable Property Global_fScriptUpdateFrequencyCompatibility Auto
GlobalVariable Property Global_iFactionsUpdateCompleted Auto
GlobalVariable Property Global_iPapyrusLoggingEnabled Auto

Faction Property DA03VampireFaction Auto
Faction Property VampireFaction Auto
Faction Property VampireThrallFaction Auto

; =============================================================================
; FUNCTIONS
; =============================================================================

Function _Log(String asTextToPrint, Int aiSeverity = 0)
  If IntToBool(Global_iPapyrusLoggingEnabled)
    Debug.OpenUserLog("MasterOfDisguise")
    Debug.TraceUser("MasterOfDisguise", "Master of Disguise: dubhCompatibilityQuestScript> " + asTextToPrint, aiSeverity)
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


Function SetUpFactions()
  Faction UDGPVampireFriendFaction = Game.GetFormFromFile(0x000969F9, "Unofficial Skyrim Special Edition Patch.esp") as Faction

  If UDGPVampireFriendFaction
    LogInfo("Updating faction relationships: Unofficial Skyrim Special Edition Patch")

    DA03VampireFaction.SetAlly(UDGPVampireFriendFaction, true, true)  ; Friend
    VampireFaction.SetAlly(UDGPVampireFriendFaction, true, true)  ; Friend
    VampireThrallFaction.SetAlly(UDGPVampireFriendFaction, true, true)  ; Friend

    LogInfo("Finished factions update.")
  EndIf
EndFunction

; =============================================================================
; EVENTS
; =============================================================================

Event OnInit()
  RegisterForSingleUpdate(Global_fScriptUpdateFrequencyCompatibility.GetValue())
EndEvent


Event OnUpdate()
  If !IntToBool(Global_iFactionsUpdateCompleted)
    SetUpFactions()
    Global_iFactionsUpdateCompleted.SetValue(1)
  EndIf

  Float fDetectionViewCone = Game.GetGameSettingFloat("fDetectionViewCone")
  Global_fDetectionViewConeMCM.SetValue(fDetectionViewCone)

  RegisterForSingleUpdate(Global_fScriptUpdateFrequencyCompatibility.GetValue())
EndEvent
