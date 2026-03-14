ScriptName REQ_CidhnaMine_Redemption extends ObjectReference
{Reduces the Lifetime bounty of the player, if the "Escape from Cidhna Mine"
Quest is currently running and the PC escaping (with or without Madanach)}

Quest Property CidhnaMineEscape  Auto

auto STATE waitingForPlayer
	EVENT onTriggerEnter(objectReference triggerRef)
		If triggerRef == Game.getPlayer() as actor
            Bool correctstate = CidhnaMineEscape.IsStageDone(70)
            correctstate = correctstate || CidhnaMineEscape.IsStageDone(230)
			If (CidhnaMineEscape.IsRunning() && correctstate)
				Int CidhnaBounty = 1000 + Game.GetGameSettingInt("iCrimeGoldEscape")
				Game.IncrementStat("Total Lifetime Bounty", -CidhnaBounty)
				GoToState("hasBeenTriggered")
			EndIf
		EndIf
	EndEvent
EndSTATE

STATE hasBeenTriggered
	; this is an empty state.
endSTATE
