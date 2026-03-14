;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname PF_REQ_Package_Follower_PickLockMoral Extends Package Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(Actor akActor)
;BEGIN CODE
    ;get us out of this alias so we won't pick the lock
    followerControl.lockpickInAnimPhase = False
    followerControl.ClearAliases()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

REQ_FollowerRegistration Property followerControl Auto