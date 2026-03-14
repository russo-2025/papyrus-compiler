Scriptname REQ_KillEssentials extends ActiveMagicEffect  
{Kills essential NPCs}

Message Property MsgEssentialKilled Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.KillEssential(akCaster)
	If (akTarget.IsDead())
		MsgEssentialKilled.Show()
	EndIf
EndEvent
