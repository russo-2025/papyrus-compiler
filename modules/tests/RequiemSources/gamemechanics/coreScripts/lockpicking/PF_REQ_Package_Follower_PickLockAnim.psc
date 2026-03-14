;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname PF_REQ_Package_Follower_PickLockAnim Extends Package Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(Actor akActor)
;BEGIN CODE
    ;Package finished as intended, time to unlock the epic loot
    ObjectReference target = unlockingTarget.GetReference()
    akActor.RemoveItem(dataStorage.lockpick, dataStorage.nLockPicksToUse)
    dataStorage.unlocking.play(unlockingTarget.GetReference())
    target.lock(False)
    If (followerControl.lockpickCrimeGold > 0)
        ObjectReference alarm = crimeTrigger.GetReference()
        alarm.MoveTo(target)
        alarm.GetBaseObject().SetGoldValue(followerControl.lockpickCrimeGold)
        alarm.SendStealAlarm(akActor)
    EndIf

    ;get us out of this alias so we won't "pick" the lock again
    followerControl.lockpickInAnimPhase = False
    followerControl.ClearAliases()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

REQ_LockedObjectsControl Property dataStorage Auto
ReferenceAlias Property unlockingTarget Auto
ReferenceAlias Property crimeTrigger Auto
REQ_FollowerRegistration Property followerControl Auto