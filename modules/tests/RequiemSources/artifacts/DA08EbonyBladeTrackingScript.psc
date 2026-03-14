Scriptname DA08EbonyBladeTrackingScript extends Quest conditional

int Property FriendsKilled auto conditional
int Property MaxFriendsKilled auto

Scene Property GratsScene auto

REQ_ReapplyNonPersistentChanges Property ReapplyNonPersistentChanges Auto

Function FriendKilled()
	if (FriendsKilled < MaxFriendsKilled)
		FriendsKilled += 1
; 		Debug.Trace("EBONY BLADE: Killed a friend, current count: " + FriendsKilled)
		ReapplyNonPersistentChanges.EbonyBladeScript.ReapplyNonPersistentChanges()
		GratsScene.Start()
	endif
EndFunction


