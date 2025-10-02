ScriptName dubhPlayerScript Extends ReferenceAlias

Import dubhUtilityScript

; =============================================================================
; PROPERTIES
; =============================================================================

GlobalVariable Property Global_iCloakEnabled Auto
GlobalVariable Property Global_iDisguiseEquippedVampire Auto
GlobalVariable Property Global_iDisguiseEssentialSlotBandit Auto
GlobalVariable Property Global_iNotifyEnabled Auto
GlobalVariable Property Global_iPapyrusLoggingEnabled Auto
GlobalVariable Property Global_iTutorialCompleted Auto
GlobalVariable Property Global_iVampireNightOnly Auto
GlobalVariable Property Global_iVampireNightOnlyDayHourBegin Auto
GlobalVariable Property Global_iVampireNightOnlyDayHourEnd Auto

Actor Property PlayerRef Auto
Spell Property CloakAbility Auto

; FormLists
FormList Property BaseFactions Auto
FormList Property DisguiseFactionAllies Auto
FormList Property DisguiseFactionEnemies Auto
FormList Property DisguiseFactionFriends Auto
FormList Property DisguiseFactionNeutrals Auto
FormList Property DisguiseFactions Auto
FormList Property DisguiseFormLists Auto
FormList Property DisguiseMessageOff Auto
FormList Property DisguiseMessageOn Auto
FormList Property DisguiseNotifyOff Auto
FormList Property DisguiseNotifyOn Auto

; Ranges
Int[] Property rgGuardFactions Auto
Int[] Property rgVampireFactions Auto
GlobalVariable[] Property rgDisguisesEnabled Auto

; Sequences
Message[] Property MessageChain Auto


; =============================================================================
; SCRIPT-LOCAL VARIABLES
; =============================================================================

Bool[] FactionStates

; =============================================================================
; FUNCTIONS
; =============================================================================

Function _Log(String asTextToPrint, Int aiSeverity = 0)
  If Global_iPapyrusLoggingEnabled.GetValue() as Bool
    Debug.OpenUserLog("MasterOfDisguise")
    Debug.TraceUser("MasterOfDisguise", "dubhPlayerScript> " + asTextToPrint, aiSeverity)
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


Bool Function IsKeySlotEquipped(Int aiFactionIndex)
  Form[] rgWornEquipment = LibTurtleClub.GetWornEquipment(PlayerRef, True, True)

  If !rgWornEquipment
    LogError("rgWornEquipment was None - cannot get worn equipment for Player")
    Return False
  EndIf

  If rgWornEquipment.Length == 0
    LogWarning("rgWornEquipment was empty - Player has no worn equipment")
    Return False
  EndIf

  FormList kCurrentDisguise = DisguiseFormLists.GetAt(aiFactionIndex) as FormList

  If aiFactionIndex == 1  ; Cultists
    Return rgWornEquipment[7] && kCurrentDisguise.HasForm(rgWornEquipment[7] as Form)
  EndIf

  If aiFactionIndex == 8  ; Silver Hand
    Return rgWornEquipment[4] && kCurrentDisguise.HasForm(rgWornEquipment[4] as Form)
  EndIf

  If aiFactionIndex == 12  ; Vigil of Stendarr
    Return rgWornEquipment[3] && kCurrentDisguise.HasForm(rgWornEquipment[3] as Form)
  EndIf

  If aiFactionIndex == 26  ; Windhelm Guard
    Return rgWornEquipment[6] && kCurrentDisguise.HasForm(rgWornEquipment[6] as Form)
  EndIf

  If aiFactionIndex == 28  ; Daedric Influence
    ; When Daedric gear is equipped in ANY slot, that's enough to match.
    Bool[] rgDaedricWornForms = LibFire.SearchListForForms(kCurrentDisguise, rgWornEquipment)

    Return rgDaedricWornForms && rgDaedricWornForms.Find(True) > -1
  EndIf

  If aiFactionIndex == 30  ; Bandits
    ; The essential slot for Bandits is configurable because this disguise can be disabled.
    Int iSlot = Global_iDisguiseEssentialSlotBandit.GetValue() as Int

    If LibMathf.InRange(iSlot, 0, 9)
      Return rgWornEquipment[iSlot] && kCurrentDisguise.HasForm(rgWornEquipment[iSlot] as Form)
    EndIf
  EndIf

  Return rgWornEquipment[1] && kCurrentDisguise.HasForm(rgWornEquipment[1] as Form)
EndFunction


Function ShowMessageChain()
  If Global_iTutorialCompleted.GetValue() as Int == 1
    Return
  EndIf

  Global_iTutorialCompleted.SetValue(1)

  (MessageChain[0] as Message).Show()
  (MessageChain[1] as Message).Show()
  (MessageChain[2] as Message).Show()
EndFunction


Function UpdateFactionRelations(Int aiFactionIndex)
  LogInfo("Updating faction relations: aiFactionIndex = " + aiFactionIndex)

  Faction kFaction = DisguiseFactions.GetAt(aiFactionIndex) as Faction

  LibFire.SetAllies(kFaction, DisguiseFactionAllies.GetAt(aiFactionIndex) as FormList)
  LibFire.SetEnemies(kFaction, DisguiseFactionEnemies.GetAt(aiFactionIndex) as FormList)
  LibFire.SetAllies(kFaction, DisguiseFactionFriends.GetAt(aiFactionIndex) as FormList, True, True)
  LibFire.SetEnemies(kFaction, DisguiseFactionNeutrals.GetAt(aiFactionIndex) as FormList, True, True)
EndFunction


Function AddDisguise(Int aiFactionIndex)
  If FactionStates[aiFactionIndex]
    Return
  EndIf

  Faction kDisguiseFaction = DisguiseFactions.GetAt(aiFactionIndex) as Faction

  If TryAddToFaction(PlayerRef, kDisguiseFaction)
    LogInfo("Added player to disguise faction: aiFactionIndex = " + aiFactionIndex)

    UpdateFactionRelations(aiFactionIndex)

    If IntToBool(Global_iNotifyEnabled)
      (DisguiseNotifyOn.GetAt(aiFactionIndex) as Message).Show()
    Else
      (DisguiseMessageOn.GetAt(aiFactionIndex) as Message).Show()
    EndIf

    FactionStates[aiFactionIndex] = True

    ; TODO: if faction is a guard disguise, save bounties to crime gold arrays and clear actual crime gold
    ;If Mathf.InRange(aiFactionIndex, 18, 27)
      ; save bounties to crime gold arrays
      ; clear actual crime gold
    ;EndIf
  EndIf

  If FactionStates[aiFactionIndex]
    ShowMessageChain()
  EndIf
EndFunction


Function TryAddDisguise(Int aiFactionIndex)
  If FactionStates[aiFactionIndex]
    Return
  EndIf

  ; prevent adding disguise if disabled
  If !IntToBool(rgDisguisesEnabled[aiFactionIndex])
    LogWarning("Cannot add disguise because disguise " + aiFactionIndex + " is disabled.")
    Return
  EndIf

  If PlayerRef.IsInFaction(BaseFactions.GetAt(aiFactionIndex) as Faction)
    LogWarning("Cannot add disguise because player is in base faction: aiFactionIndex = " + aiFactionIndex)
    Return
  EndIf

  ; prevent adding mutually exclusive disguises
  If !LibTurtleClub.CanDisguiseActivate(aiFactionIndex, FactionStates) || !IntToBool(rgDisguisesEnabled[aiFactionIndex])
    LogWarning("Cannot activate disguise because disguise " + aiFactionIndex + " is disabled.")
    Return
  EndIf

  Bool bVampireDisguise = rgVampireFactions.Find(aiFactionIndex) > -1
  Bool bKeySlotEquipped = IsKeySlotEquipped(aiFactionIndex)

  ; for vampire night only feature
  If bVampireDisguise
    Global_iDisguiseEquippedVampire.SetValue(LibMathf.IfThen(bKeySlotEquipped, aiFactionIndex, 0))
  EndIf

  If bVampireDisguise && IntToBool(Global_iVampireNightOnly)
    Float fCurrentHourOfDay = LibFire.GetCurrentHourOfDay()
    If LibMathf.InRange(fCurrentHourOfDay, Global_iVampireNightOnlyDayHourBegin.GetValue(), Global_iVampireNightOnlyDayHourEnd.GetValue())
      LogInfo("Vampire disguise can be activated at night only because day/night mode is enabled.")
      Return
    EndIf
  EndIf

  If bKeySlotEquipped && !FactionStates[aiFactionIndex]
    AddDisguise(aiFactionIndex)
  EndIf
EndFunction


Function RemoveDisguise(Int aiFactionIndex)
  If !FactionStates[aiFactionIndex]
    LogWarning("Cannot remove disguise because player is not in disguise faction: aiFactionIndex = " + aiFactionIndex)
    Return
  EndIf

  Faction kDisguiseFaction = DisguiseFactions.GetAt(aiFactionIndex) as Faction

  If TryRemoveFromFaction(PlayerRef, kDisguiseFaction)
    LogInfo("Removed player from disguise faction: kDisguiseFaction = " + kDisguiseFaction)

    If IntToBool(Global_iNotifyEnabled)
      (DisguiseNotifyOff.GetAt(aiFactionIndex) as Message).Show()
    Else
      (DisguiseMessageOff.GetAt(aiFactionIndex) as Message).Show()
    EndIf

    FactionStates[aiFactionIndex] = False

    ; TODO: if faction is a guard disguise, restore bounties and clear crime gold arrays
    ;If Mathf.InRange(aiFactionIndex, 18, 27)
      ; restore bounties
      ; clear crime gold arrays
    ;EndIf
  EndIf
EndFunction


Function TryRemoveDisguise(Int aiFactionIndex)
  If !FactionStates[aiFactionIndex]
    Return
  EndIf

  ; remove disguise if player had disguise equipped and then disabled it
  If !IntToBool(rgDisguisesEnabled[aiFactionIndex])
    RemoveDisguise(aiFactionIndex)
    LogWarning("Removed disguise because disguise " + aiFactionIndex + " is disabled.")
    Return
  EndIf

  If PlayerRef.IsInFaction(BaseFactions.GetAt(aiFactionIndex) as Faction)
    RemoveDisguise(aiFactionIndex)
    LogWarning("Removed disguise because player is in base faction: aiFactionIndex = " + aiFactionIndex)
    Return
  EndIf

  Bool bVampireDisguise = rgVampireFactions.Find(aiFactionIndex) > -1

  If bVampireDisguise && IntToBool(Global_iVampireNightOnly)
    Float fCurrentHourOfDay = LibFire.GetCurrentHourOfDay()
    If LibMathf.InRange(fCurrentHourOfDay, Global_iVampireNightOnlyDayHourBegin.GetValue(), Global_iVampireNightOnlyDayHourEnd.GetValue())
      RemoveDisguise(aiFactionIndex)
      LogWarning("Removed vampire disguise because time restrictions are enabled.")
      Return
    EndIf
  EndIf

  If FactionStates[aiFactionIndex]
    ; if essential gear is still equipped, do not remove disguise
    If IsKeySlotEquipped(aiFactionIndex)
      LogInfo("Cannot remove disguise because key slot still equipped: aiFactionIndex = " + aiFactionIndex)
      Return
    EndIf

    RemoveDisguise(aiFactionIndex)

    ; for vampire night only feature
    If bVampireDisguise
      Global_iDisguiseEquippedVampire.SetValueInt(aiFactionIndex)
    EndIf
  EndIf
EndFunction


Function UpdateDisguise(Int aiFactionIndex)  ; used in event scope
  TryRemoveDisguise(aiFactionIndex)
  TryAddDisguise(aiFactionIndex)
EndFunction


Function TryUpdateDisguise(Form akBaseObject)  ; used in event scope
  ; Attempts to update disguise and base faction memberships

  Int iCycles = 0
  While Utility.IsInMenuMode() || PlayerRef.IsInCombat()
    iCycles += 1
  EndWhile

  Bool[] rgPossibleDisguises = LibFire.SearchListsForForm(DisguiseFormLists, akBaseObject)

  If rgPossibleDisguises.Find(True) < 0
    LogWarning("Cannot determine possible disguises for form: " + akBaseObject)
    Return
  EndIf

  Int i = 0

  While i < rgPossibleDisguises.Length
    If rgPossibleDisguises[i]
      UpdateDisguise(i)
    EndIf

    i += 1
  EndWhile
EndFunction


; =============================================================================
; EVENTS
; =============================================================================

Event OnInit()
  RegisterForSingleUpdate(1.0)
EndEvent


Event OnPlayerLoadGame()
  RegisterForSingleUpdate(1.0)
EndEvent


Event OnCellLoad()
  RegisterForSingleUpdate(1.0)
EndEvent


Event OnUpdate()
  If !PlayerRef.IsInCombat()
    If Global_iCloakEnabled.GetValue() as Bool
      If !PlayerRef.HasSpell(CloakAbility)
        PlayerRef.AddSpell(CloakAbility, False)
        Utility.Wait(1.0)
        PlayerRef.RemoveSpell(CloakAbility)
      EndIf
    EndIf

    ; for vampire night only feature
    ; try to add vampire disguise, needed for day/night cycle
    Int iFactionIndex = Global_iDisguiseEquippedVampire.GetValue() as Int

    If rgVampireFactions.Find(iFactionIndex) > -1
      UpdateDisguise(iFactionIndex)
    EndIf
  EndIf

  RegisterForSingleUpdate(4.0)
EndEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  Int _cycles = 0

  While Utility.IsInMenuMode() || PlayerRef.IsInCombat()
    _cycles += 1
  EndWhile

  Utility.Wait(1.0)

  If akBaseObject
    FactionStates = LibTurtleClub.GetFactionStates(PlayerRef, DisguiseFactions)

    LogInfo("Trying to update disguise because the player equipped: " + akBaseObject)
    TryUpdateDisguise(akBaseObject)
  EndIf
EndEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
  Int _cycles = 0

  While Utility.IsInMenuMode() || PlayerRef.IsInCombat()
    _cycles += 1
  EndWhile

  If akBaseObject
    FactionStates = LibTurtleClub.GetFactionStates(PlayerRef, DisguiseFactions)

    LogInfo("Trying to update disguise because the player unequipped: " + akBaseObject)
    TryUpdateDisguise(akBaseObject)
  EndIf
EndEvent
