ScriptName dubhFactionEnemyScript Extends ActiveMagicEffect

Import dubhUtilityScript

; =============================================================================
; PROPERTIES
; =============================================================================

GlobalVariable Property Global_fEscapeDistance Auto
GlobalVariable Property Global_fScriptDistanceMax Auto
GlobalVariable Property Global_iDiscoveryEnabled Auto
GlobalVariable Property Global_iPapyrusLoggingEnabled Auto

Actor Property PlayerRef Auto
FormList Property BaseFactions Auto
FormList Property DisguiseFactions Auto
Spell Property FactionEnemyAbility Auto

; States
Bool[] Property rgDisguisesRemoved Auto

; =============================================================================
; SCRIPT-LOCAL VARIABLES
; =============================================================================

Actor NPC

; =============================================================================
; FUNCTIONS
; =============================================================================

Function _Log(String asTextToPrint, Int aiSeverity = 0)
  If IntToBool(Global_iPapyrusLoggingEnabled)
    Debug.OpenUserLog("MasterOfDisguise")
    Debug.TraceUser("MasterOfDisguise", "dubhFactionEnemyScript> " + asTextToPrint, aiSeverity)
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


Function TryAddDisguises()
  ; Restores previously removed disguises to player

  Int i = 0

  While i < rgDisguisesRemoved.Length
    If rgDisguisesRemoved[i]
      If TryAddToFaction(PlayerRef, DisguiseFactions.GetAt(i) as Faction)
        rgDisguisesRemoved[i] = False
        LogInfo("Successfully added disguise to player at index: " + i)
      EndIf

      ; TODO: if player is wearing guard disguise, save bounties to crime gold arrays and clear actual crime gold
    EndIf

    i += 1
  EndWhile
EndFunction


Function TryRemoveDisguises()
  ; Removes all disguises from player

  Int i = 0

  While i < rgDisguisesRemoved.Length
    If !rgDisguisesRemoved[i]
      If TryRemoveFromFaction(PlayerRef, DisguiseFactions.GetAt(i) as Faction)
        rgDisguisesRemoved[i] = True
        LogInfo("Successfully removed disguise from player at index: " + i)
      EndIf

      ; TODO: if player is wearing guard disguise, add penalty amount to current crime faction and restore bounties
    EndIf

    i += 1
  EndWhile
EndFunction


Function TryRestoreDisguise(String asLogText)
  ; Restore disguised state

  If NPC && !NPC.HasSpell(FactionEnemyAbility)
    Return
  EndIf

  If !PlayerRef.IsDead()
    TryAddDisguises()
  EndIf

  If NPC && NPC.RemoveSpell(FactionEnemyAbility)
    LogInfo(asLogText)
    NPC = None
  EndIf
EndFunction

; ===============================================================================
; EVENTS
; ===============================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
  NPC = akCaster

  If PlayerRef.IsDead()
    If NPC && NPC.RemoveSpell(FactionEnemyAbility)
      LogInfo("Detached enemy marker from " + NPC + " because the Player was prematurely dead")
      NPC = None
      Return
    EndIf
  Else
    If NPC && NPC.GetDistance(PlayerRef) <= Global_fScriptDistanceMax.GetValue()
      TryRemoveDisguises()

      NPC.EvaluatePackage()

      If NPC.IsHostileToActor(PlayerRef)
        If !NPC.IsAlerted()
          NPC.SetAlert(True)
        EndIf

        If !NPC.IsWeaponDrawn()
          NPC.DrawWeapon()
        EndIf

        Game.ShakeCamera(afStrength = 0.4)

        NPC.EvaluatePackage()
      EndIf

      Suspend(5.0)
    EndIf
  EndIf

  If NPC && NPC.Is3DLoaded() && !NPC.IsDead()
    RegisterForSingleUpdate(1.0)
  Else
    TryRestoreDisguise("Detached enemy marker from " + NPC + " because the NPC was either not loaded or dead")
  EndIf
EndEvent


Event OnCellDetach()
  TryRestoreDisguise("Detached enemy marker from " + NPC + " because the NPC's parent cell has been detached")
EndEvent


Event OnDetachedFromCell()
  TryRestoreDisguise("Detached enemy marker from " + NPC + " because the NPC was detached from the cell")
EndEvent


Event OnUnload()
  TryRestoreDisguise("Detached enemy marker from " + NPC + " because the NPC has been unloaded")
EndEvent


Event OnUpdate()
  If !IntToBool(Global_iDiscoveryEnabled)
    If NPC && NPC.RemoveSpell(FactionEnemyAbility)
      LogInfo("Detached enemy marker from " + NPC + " because detection is disabled")
      NPC = None
      Return
    EndIf
  ElseIf PlayerRef.IsDead()
    If NPC && NPC.RemoveSpell(FactionEnemyAbility)
      LogInfo("Detached enemy marker from " + NPC + " because the Player died")
      NPC = None
      Return
    EndIf
  ElseIf NPC && NPC.IsDead()
    TryRestoreDisguise("Detached enemy marker from " + NPC + " because the NPC was dead")
    Return
  ElseIf NPC && NPC.IsHostileToActor(PlayerRef) && NPC.GetDistance(PlayerRef) >= Global_fEscapeDistance.GetValue()
    TryRestoreDisguise("Detached enemy marker from " + NPC + " because the Player escaped")
    Return
  ElseIf NPC && !NPC.IsHostileToActor(PlayerRef)
    TryRestoreDisguise("Detached enemy marker from " + NPC + " because the NPC was no longer hostile")
    Return
  ElseIf NPC && !NPC.IsDead() && NPC.IsHostileToActor(PlayerRef)
    RegisterForSingleUpdate(1.0)
  EndIf
EndEvent


Event OnDeath(Actor akKiller)
  TryRestoreDisguise("Detached enemy marker from " + NPC + " because the NPC was killed by " + akKiller)
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
  TryRestoreDisguise("Detached enemy marker from " + NPC + " because the effect finished")
EndEvent
