;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname PF_REQ_Package_Follower_PickLock Extends Package Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(Actor akActor)
;BEGIN CODE
    ObjectReference target = unlockingTarget.GetReference()
    If (akActor.GetDistance(target) <= 150)
        ; we are now close to the obejct to be unlocked, allow second package
        followerControl.lockpickInAnimPhase = True
    Else
        ; package ended but we're still away from the target, abort everything
        followerControl.ClearAliases()
    EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

REQ_LockedObjectsControl Property dataStorage Auto
ReferenceAlias Property unlockingTarget Auto
REQ_FollowerRegistration Property followerControl Auto