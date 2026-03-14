Scriptname REQ_LockpickControl Extends ObjectReference
{custom lockpicking mechanism, player cannot access the minigame if he lacks
the required expertise, follower can no longer open the lock via command mode,
but they can still pick the lock for the player if they meet the requirements}

REQ_FollowerRegistration Property followerControl Auto
REQ_LockedObjectsControl Property dataStorage Auto

; used to ensure that the player only gets Alteration XP once for unlocking an
; object in case it becomes locked again (e.g. NPC homes)
Bool alreadyUnlocked = False

; used to track if we're responsible for the activation block
Bool myBlock = False

Event OnLoad()
    UpdateStatus()
EndEvent

Event OnLockStateChanged()
    ; this seems to trigger only for one side of load doors, but followers
    ; anyway refuse using load doors when the player orders them to do so,
    ; thus the perhaps not correct favorstate of this object doesn't matter
    UpdateStatus()
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ; if we get hit by a magic unlocking pseudo projectile (these are invisible
    ; and mimic touch-range spells) unlock the object if the spell is
    ; sufficiently powerful
    If (!IsLocked())
        Return
    EndIf
    Int level = GetLockClass()
    If (level == 1 && datastorage.unlocking_level1.HasForm(akProjectile))
        MagicUnlock(akAggressor)
    ElseIf (level == 2 && datastorage.unlocking_level2.HasForm(akProjectile))
        MagicUnlock(akAggressor)
    ElseIf (level == 3 && datastorage.unlocking_level3.HasForm(akProjectile))
        MagicUnlock(akAggressor)
    ElseIf (level == 4 && datastorage.unlocking_level4.HasForm(akProjectile))
        MagicUnlock(akAggressor)
    ElseIf (level == 5 && datastorage.unlocking_level5.HasForm(akProjectile))
        MagicUnlock(akAggressor)
    ElseIf (level >= 1 && datastorage.unlocking_level1.HasForm(akProjectile))
        ; trigger crime and noise alarms anyway to punish would-be intruders
        MagicCrimeAlarm(akAggressor)
    EndIf
EndEvent

; unlock the container by magical means and send a steal alarm if appropriate
Function MagicUnlock(ObjectReference castsource)
    datastorage.unlockShader.Play(Self, 2.0)
    Actor caster = castsource as Actor
    MagicCrimeAlarm(castsource)
    Utility.Wait(1.0)
    If (caster == Game.GetPlayer() && !alreadyUnlocked)
        Game.AdvanceSkill("Alteration", GetSkillUsageReward())
        alreadyUnlocked = True
    EndIf
    Lock(False)
    dataStorage.unlocking.play(Self)
    SetOpen(True)
EndFunction

Function MagicCrimeAlarm(ObjectReference castsource)
    Actor caster = castsource as Actor
    If (caster)
        ActorBase base = caster.GetActorBase()
        Int crimeGold = GetCrimeGold(base)
        If (CrimeGold > 0)
            ObjectReference alarm = datastorage.crimeTrigger.GetReference()
            alarm.MoveTo(caster)
            alarm.GetBaseObject().SetGoldValue(crimeGold)
            alarm.SendStealAlarm(caster)
        EndIf
        CreateDetectionEvent(caster, 100)
    EndIf
EndFunction

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    If (akActionRef as Actor == player && player.getItemCount(dataStorage.lockpick) == 0 && player.getItemCount(dataStorage.skeletonKey) == 0 && IsLocked() && !IsActivationBlocked())
        Utility.WaitMenuMode(0.5)
        Bool isLockpicking = UI.IsMenuOpen("Lockpicking Menu")
        Utility.Wait(0.1)
        If(!Utility.IsInMenuMode() && !isLockpicking && Self.IsNearPlayer())
            PickLock(true)
        EndIf
    EndIf
EndEvent

Function PickLock(Bool externalTrigger)

    If (!IsLocked())
        Return
    EndIf

    Int required = GetRequiredExpertise()
    Int optimal = GetOptimalExpertise()

    If (required == -1)
        ; lock is of "requires key" difficulty, we should not be here...
        Debug.Trace("[REQ] ERROR PickLock() invoked on key-locked object " + self)
        Return
    EndIf

    ; let's see how this lock fares against mighty Dovahkiin and his minions
    Actor player = Game.GetPlayer()
    Int expertisePlayer = GetExpertise(player)
    Actor bestMinion = GetBestFollower()
    Int expertiseBestMinion = 0
    If bestMinion != None
        expertiseBestMinion = GetExpertise(bestMinion)
    EndIf
    followerControl.SetLockpickMinion(bestMinion)
    followerControl.lockpickCrimeGold = GetCrimeGold(player.GetActorBase())

    Int choice = 0
    If (expertisePlayer >= optimal)
        choice = ShowOptionsEasyForPlayer(expertisePlayer, expertiseBestMinion, bestMinion, required, optimal)
    ElseIf (expertisePlayer >= required)
        choice = ShowOptionsChallengingForPlayer(expertisePlayer, expertiseBestMinion, bestMinion, required, optimal)
    Else
        choice = ShowOptionsImpossibleForPlayer(expertisePlayer, expertiseBestMinion, bestMinion, required, optimal)
    EndIf

    Int nLockpicks = GetFollowerLockpickUsage(expertiseBestMinion >= optimal)
    Bool notAllowed = externalTrigger || expertisePlayer < required
    ProcessPlayerChoice(choice, nLockpicks, bestMinion, notAllowed)

EndFunction

Function UpdateStatus()
    SetNoFavorAllowed(IsLocked())
EndFunction

; obtain the highest lockpick expertise of this actor
Int Function GetExpertise(Actor subject)
    Int expertise = subject.GetActorValue("lockpickingmod") As Int
    If expertise == 0 && subject.HasKeyword(datastorage.LockpickUnperked)
        expertise = 1
    EndIf
    return expertise
EndFunction

; determine the complexity (1=novice, 2=apprentice, ...) of this lock, 6 means
; that lock needs a key to be unlocked, -1 means not locked
Int Function GetLockClass()
    If (!IsLocked())
        Return -1
    EndIf
    Int locklevel = GetLockLevel()
    If (locklevel <= Game.GetGameSettingInt("iLockLevelMaxVeryEasy"))
        Return 1
    ElseIf (locklevel <= Game.GetGameSettingInt("iLockLevelMaxEasy"))
        Return 2
    ElseIf (locklevel <= Game.GetGameSettingInt("iLockLevelMaxAverage"))
        Return 3
    ElseIf (locklevel <= Game.GetGameSettingInt("iLockLevelMaxHard"))
        Return 4
    ElseIf (locklevel <= Game.GetGameSettingInt("iLockLevelMaxVeryHard"))
        Return 5
    Else
        Return 6
    EndIf
EndFunction

;get the skill usage reward for this lock complexity class
Float Function GetSkillUsageReward()
    Int locklevel = GetLockClass()
    If (locklevel == 1)
        Return Game.GetGameSettingFloat("fSkillUsageLockPickVeryEasy")
    ElseIf (locklevel == 2)
        Return Game.GetGameSettingFloat("fSkillUsageLockPickEasy")
    ElseIf (locklevel == 3)
        Return Game.GetGameSettingFloat("fSkillUsageLockPickAverage")
    ElseIf (locklevel == 4)
        Return Game.GetGameSettingFloat("fSkillUsageLockPickHard")
    ElseIf (locklevel == 5)
        Return Game.GetGameSettingFloat("fSkillUsageLockPickVeryHard")
    Else
        Return 0
    EndIf
EndFunction

;get the required expertise level for the lock, -1 means key required
Int Function GetRequiredExpertise()
    Int locklevel = GetLockClass()
    If (locklevel == 1)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level1Min.GetValueInt()
    ElseIf (locklevel == 2)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level2Min.GetValueInt()
    ElseIf (locklevel == 3)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level3Min.GetValueInt()
    ElseIf (locklevel == 4)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level4Min.GetValueInt()
    ElseIf (locklevel == 5)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level5Min.GetValueInt()
    Else
        Return -1
    EndIf
EndFunction

;get the optimal expertise level for the lock, -1 means key required
Int Function GetOptimalExpertise()
    Int locklevel = GetLockClass()
    If (locklevel == 1)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level1Opt.GetValueInt()
    ElseIf (locklevel == 2)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level2Opt.GetValueInt()
    ElseIf (locklevel == 3)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level3Opt.GetValueInt()
    ElseIf (locklevel == 4)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level4Opt.GetValueInt()
    ElseIf (locklevel == 5)
        Return dataStorage.REQ_GV_Lockpick_Expertise_Level5Opt.GetValueInt()
    Else
        Return -1
    EndIf
EndFunction

;get the follower with the highest expertise
Actor Function GetBestFollower()
    Int bestExpertise = 0
    Actor bestFollower = None
    Actor[] followers = followerControl.GetCurrentFollowers()
    Int i = 0
    While (i < followers.Length)
        If followers[i] != None
            Int expertise = GetExpertise(Followers[i])
            If (bestExpertise < expertise || bestFollower == None)
                bestExpertise = expertise
                bestFollower = Followers[i]
            EndIf
        EndIf
        i += 1
    EndWhile
    Return bestFollower
EndFunction

;get the number of lockpicks the follower would need to spend
Int Function GetFollowerLockpickUsage(Bool isEasyTarget)
    Int base = 0
    Int scale = 0
    If (isEasyTarget)
        base = dataStorage.REQ_GV_Lockpick_NumLockPicks_OptBase.GetValueInt()
        scale = dataStorage.REQ_GV_Lockpick_NumLockPicks_OptScale.GetValueInt()
    Else
        base = dataStorage.REQ_GV_Lockpick_NumLockPicks_MinBase.GetValueInt()
        scale = dataStorage.REQ_GV_Lockpick_NumLockPicks_MinScale.GetValueInt()
    EndIf

    Int nLockpicks = base

    Int locklevel = GetLockClass()
    If (locklevel == 1)
        nLockpicks += scale
    ElseIf (locklevel == 2)
        nLockpicks += scale * 2
    ElseIf (locklevel == 3)
        nLockpicks += scale * 3
    ElseIf (locklevel == 4)
        nLockpicks += scale * 4
    ElseIf (locklevel == 5)
        nLockpicks += scale * 5
    Else
        nLockpicks = 0
    EndIf
    return nLockpicks
EndFunction

;let the follower open the lock
Function MinionOpensLock(Actor minion, Int nLockpicks)
    followerControl.SetLockpickTarget(Self)
    dataStorage.nLockPicksToUse = nLockPicks
    followerControl.StartLockpicking()
EndFunction

; if the door/container belongs to another actor or a faction, only non
; law-abiding followers will do the task
Int Function GetCrimeGold(ActorBase player)
    ActorBase owner = GetActorOwner()
    ; unfortunately I have no clue how to get the crime value associated with
    ; trespassing for a specific crime faction, but Requiem anyway uses the
    ; same bounties in all holds, so this works fine unless someone adds
    ; a faction with non-standard steal or trespass bounties
    Float crimeValue = Game.GetGameSettingInt("iCrimeGoldTrespass") as Float
    crimeValue = crimeValue / Game.GetGameSettingFloat("fCrimeGoldSteal")
    Int crimeGold = Math.ceiling(crimeValue)
    If (owner != None && owner != player)
        followerControl.SetTargetOwner(owner, None)
        Return crimeGold
    EndIf
    If (GetFactionOwner() != None)
        followerControl.SetTargetOwner(None, GetFactionOwner())
        Return crimeGold
    EndIf
    ActorBase cellOwner = GetParentCell().GetActorOwner()
    If (owner != None && owner != player)
        followerControl.SetTargetOwner(cellOwner, None)
        Return crimeGold
    EndIf
    If (GetParentCell().GetFactionOwner() != None)
        followerControl.SetTargetOwner(None, GetParentCell().GetFactionOwner())
        Return crimeGold
    EndIf
    Return 0
EndFunction

; the lock is easy for the player, present him the available options
Int Function ShowOptionsEasyForPlayer(Int expertisePlayer, Int expertiseBestMinion, Actor bestMinion, Int required, Int optimal)

    Actor player = Game.GetPlayer()
    Int choice = 0
    Int nLockpicks = 0

    If (bestMinion == None || player.GetItemCount(dataStorage.lockpick) > 0 || player.GetItemCount(dataStorage.skeletonKey) > 0)
        choice = 0
    ElseIf (expertiseBestMinion >= optimal)
        nLockpicks = GetFollowerLockpickUsage(True)
        Int nMinionLockpicks = bestMinion.GetItemCount(dataStorage.lockpick)
        If (nMinionLockpicks >= nLockpicks)
            choice = dataStorage.easyLock_FollowerCanPickOptimal.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        Else
            choice = dataStorage.easyLock_FollowerNoLockpicksOptimal.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        EndIf
    ElseIf (expertiseBestMinion >= required)
        nLockpicks = GetFollowerLockpickUsage(False)
        Int nMinionLockpicks = bestMinion.GetItemCount(dataStorage.lockpick)
        If (nMinionLockpicks >= nLockpicks)
            choice = dataStorage.easyLock_FollowerCanPickRequired.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        Else
            choice = dataStorage.easyLock_FollowerNoLockpicksRequired.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        EndIf
    ElseIf (expertiseBestMinion < required)
        choice = dataStorage.easyLock_FollowerTooDumb.Show(optimal, expertisePlayer, expertiseBestMinion)
    EndIf

    return choice

EndFunction

; the lock is challenging for the player, present him the available options
Int Function ShowOptionsChallengingForPlayer(Int expertisePlayer, Int expertiseBestMinion, Actor bestMinion, Int required, Int optimal)

    Int choice = 0
    Int nLockpicks = 0

    If (bestMinion == None)
        choice = 0
    ElseIf (expertiseBestMinion >= optimal)
        nLockpicks = GetFollowerLockpickUsage(True)
        Int nMinionLockpicks = bestMinion.GetItemCount(dataStorage.lockpick)
        If (nMinionLockpicks >= nLockpicks)
            choice = dataStorage.challengingLock_FollowerCanPickOptimal.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        Else
            choice = dataStorage.challengingLock_FollowerNoLockpicksOptimal.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        EndIf
    ElseIf (expertiseBestMinion >= required)
        nLockpicks = GetFollowerLockpickUsage(False)
        Int nMinionLockpicks = bestMinion.GetItemCount(dataStorage.lockpick)
        If (nMinionLockpicks >= nLockpicks)
            choice = dataStorage.challengingLock_FollowerCanPickRequired.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        Else
            choice = dataStorage.challengingLock_FollowerNoLockpicksRequired.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        EndIf
    ElseIf (expertiseBestMinion < required)
        choice = dataStorage.challengingLock_FollowerTooDumb.Show(optimal, expertisePlayer, expertiseBestMinion)
    EndIf

    return choice

EndFunction

; the lock is impossible for the player, present him the available options
Int Function ShowOptionsImpossibleForPlayer(Int expertisePlayer, Int expertiseBestMinion, Actor bestMinion, Int required, Int optimal)

    Int choice = 0
    Int nLockpicks = 0

    If (bestMinion == None)
        choice = dataStorage.insufficientExpertise_Solo.Show(required, expertisePlayer, expertiseBestMinion)
    ElseIf (expertiseBestMinion >= optimal)
        nLockpicks = GetFollowerLockpickUsage(True)
        Int nMinionLockpicks = bestMinion.GetItemCount(dataStorage.lockpick)
        If (nMinionLockpicks >= nLockpicks)
            choice = dataStorage.followerHasOptimalSkill_Confirmation.Show(nLockpicks, required, expertisePlayer, expertiseBestMinion)
        Else
            choice = dataStorage.followerHasOptimalSkill_NoLockpicks.Show(nLockpicks, required, expertisePlayer, expertiseBestMinion)
        EndIf
    ElseIf (expertiseBestMinion >= required)
        nLockpicks = GetFollowerLockpickUsage(False)
        Int nMinionLockpicks = bestMinion.GetItemCount(dataStorage.lockpick)
        If (nMinionLockpicks >= nLockpicks)
            choice = dataStorage.followerHasRequiredSkill_Confirmation.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        Else
            choice = dataStorage.followerHasRequiredSkill_NoLockpicks.Show(nLockpicks, optimal, expertisePlayer, expertiseBestMinion)
        EndIf
    Else
        choice = dataStorage.insufficientExpertise_WithFollower.Show(required, expertisePlayer, expertiseBestMinion)
    EndIf

    return choice

EndFunction

Function ProcessPlayerChoice(Int choice, Int nLockpicks, Actor bestMinion, Bool notAllowed)
    If ((choice == 1 || notAllowed) && UI.IsMenuOpen("Lockpicking Menu"))
        UI.InvokeString("Lockpicking Menu", "_global.skse.CloseMenu", "Lockpicking Menu")
    EndIf
    If (choice == 1)
        MinionOpensLock(bestMinion, nLockpicks)
    ElseIf (choice == 0)
        ; no lockpicking requested from minions, clear alias
        followerControl.ClearAliases()
    EndIf
EndFunction