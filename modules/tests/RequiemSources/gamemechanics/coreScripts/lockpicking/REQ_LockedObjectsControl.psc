Scriptname REQ_LockedObjectsControl extends REQ_CoreScript
{provide centralized data for scripts that handle interactions with locked doors and containers}

Function initScript(Int currentVersion, Int nevVersion)
    RegisterForMenu("Lockpicking Menu")
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
    UnregisterForAllMenus()
EndFunction

Event OnMenuOpen(String MenuName)
    REQ_LockpickControl target = Game.GetCurrentCrosshairRef() as REQ_LockpickControl
    If (target)
        target.PickLock(false)
    EndIf
EndEvent

; This part is really just a data container. It is accessed by the lockpicking
; control script that is distributed by the Reqtificator to all doors and
; containers in the game. Storing the data here means we can avoid storing
; potentially changing properties on the persistent scripts attached to the
; object references, which simplifies future updates. The quest owning this
; alias can be restarted to refresh its properties, which can then be used on
; the objectrefs (with new script code) without having to flush the property
; values stored in the savegames.

GlobalVariable Property REQ_GV_Lockpick_Expertise_Level1Min Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level2Min Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level3Min Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level4Min Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level5Min Auto

GlobalVariable Property REQ_GV_Lockpick_Expertise_Level1Opt Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level2Opt Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level3Opt Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level4Opt Auto
GlobalVariable Property REQ_GV_Lockpick_Expertise_Level5Opt Auto

GlobalVariable Property REQ_GV_Lockpick_NumLockPicks_MinBase Auto
GlobalVariable Property REQ_GV_Lockpick_NumLockPicks_MinScale Auto
GlobalVariable Property REQ_GV_Lockpick_NumLockPicks_OptBase Auto
GlobalVariable Property REQ_GV_Lockpick_NumLockPicks_OptScale Auto

Message Property insufficientExpertise_Solo Auto
Message Property insufficientExpertise_WithFollower Auto

Message Property followerHasRequiredSkill_NoLockpicks Auto
Message Property followerHasRequiredSkill_Confirmation Auto

Message Property followerHasOptimalSkill_NoLockpicks Auto
Message Property followerHasOptimalSkill_Confirmation Auto

Message Property challengingLock_Solo Auto
Message Property challengingLock_FollowerTooDumb Auto
Message Property challengingLock_FollowerCanPickOptimal Auto
Message Property challengingLock_FollowerNoLockpicksOptimal Auto
Message Property challengingLock_FollowerCanPickRequired Auto
Message Property challengingLock_FollowerNoLockpicksRequired Auto

Message Property easyLock_FollowerTooDumb Auto
Message Property easyLock_FollowerCanPickOptimal Auto
Message Property easyLock_FollowerNoLockpicksOptimal Auto
Message Property easyLock_FollowerCanPickRequired Auto
Message Property easyLock_FollowerNoLockpicksRequired Auto

Sound Property unlocking Auto
EffectShader Property unlockShader Auto

MiscObject Property lockpick Auto
MiscObject Property skeletonKey Auto

Keyword Property LockpickUnperked Auto

FormList Property unlocking_level1 Auto
FormList Property unlocking_level2 Auto
FormList Property unlocking_level3 Auto
FormList Property unlocking_level4 Auto
FormList Property unlocking_level5 Auto

ReferenceAlias Property crimeTrigger Auto

Int Property nLockPicksToUse = 0 Auto Hidden
