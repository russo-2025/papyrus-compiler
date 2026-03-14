Scriptname REQ_FollowerRegistration Extends Quest Conditional
{Keep track of the player's current follower(s) to integrate them into some
features, e.g. lockpicking}

ReferenceAlias Property vanillaFollower Auto
{all aliases in this list will be checked for the player's current follower(s)}
Faction Property playerFollowerFaction Auto
{to be considered a current follower, the alias must be in this faction}

ReferenceAlias[] checkForFollowers
Int nAliasesToCheck = 0
Actor[] minions

Bool Property lockpickInAnimPhase = False Auto Conditional
Int Property lockpickCrimeGold = 0 Auto Conditional
{zero crime gold means that picking the lock is not considered a crime}

Event OnInit()
   checkForFollowers = new ReferenceAlias[30]
   checkForFollowers[0] = vanillaFollower
   nAliasesToCheck = 1
   minions = new Actor[4]
EndEvent

Bool Function RegisterFollowerAlias(ReferenceAlias toRegister)
   If (checkForFollowers.RFind(toRegister, nAliasesToCheck) >= 0)
      Debug.Trace("REQ WARNING: trying to register an already known " \
            + "follower alias, ignoring: " + toregister)
      Return False
   ElseIf (nAliasesToCheck >= checkForFollowers.Length)
      Debug.Trace("REQ WARNING: trying to register a follower alias, but "\
            + "our storage is exceeded, ignoring: " + toregister)
      Return False
   Else
      checkForFollowers[nAliasesToCheck] = toRegister
      nAliasesToCheck += 1
      Return True
   EndIf
EndFunction

Bool Function UnregisterFollowerAlias(ReferenceAlias toUnregister)
   If (checkForFollowers.RFind(toUnregister, nAliasesToCheck) < 0)
      Debug.Trace("REQ WARNING: trying to unregister a follower alias " \
            + "that was not known, ignoring: " + toUnregister)
      Return False
   ElseIf (toUnregister == vanillaFollower)
      Debug.Trace("REQ WARNING: trying to unregister the Vanilla follower "\
            + "alias, ignoring: " + toUnregister)
      Return False
   Else
      Int iPosition = checkForFollowers.RFind(toUnregister, nAliasesToCheck)
      While (iPosition < nAliasesToCheck)
         checkForFollowers[iPosition] = checkForFollowers[iPosition + 1]
         iPosition += 1
      EndWhile
      checkForFollowers[iPosition] = None
      nAliasesToCheck += -1 
      Return True
   EndIf
EndFunction

Actor[] Function GetCurrentFollowers()
   Int iMinion = 0
   Int iAlias = 0
   While (iAlias < nAliasesToCheck && iMinion < minions.Length)
      Actor minion = checkForFollowers[iAlias].GetReference() As Actor
      If (minion)
         If (minion.IsPlayerTeammate())
            (GetAlias(iMinion) as ReferenceAlias).ForceRefTo(minion)
            minions[iMinion] = minion
            iMinion += 1
         EndIf
      EndIf
      iAlias += 1
   EndWhile
   While (iMinion < minions.Length)
      minions[iMinion] = None
      iMinion += 1
   EndWhile
   return minions
EndFunction

; set the follower to be used in lockpicking messages
Function SetLockpickMinion(Actor minion)
   If (minion == none)
      (GetAlias(4) as ReferenceAlias).Clear()
   Else
      (GetAlias(4) as ReferenceAlias).ForceRefTo(minion)
   EndIf
EndFunction

; set the to be unlocked object
Function SetLockpickTarget(ObjectReference target)
   (GetAlias(6) as ReferenceAlias).ForceRefTo(target)
EndFunction

; set temporary ownership on the crime marker to trigger theft alarms
Function SetTargetOwner(ActorBase owner, Faction ownerFaction)
   ObjectReference alarm = (GetAlias(10) as ReferenceAlias).GetReference()
   alarm.SetActorOwner(owner)
   alarm.SetFactionOwner(ownerFaction)
EndFunction

; give the follower the command to pick the lock
Function StartLockpicking()
   ObjectReference minion = (GetAlias(4) as ReferenceAlias).GetReference()
   (GetAlias(7) as ReferenceAlias).ForceRefTo(minion)
EndFunction

; clear aliases once the lockpicking operation ended
Function ClearAliases()
   (GetAlias(7) as ReferenceAlias).Clear()
   (GetAlias(4) as ReferenceAlias).Clear()
   (GetAlias(6) as ReferenceAlias).Clear()
EndFunction

