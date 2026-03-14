ScriptName REQ_Alteration_TelekineticExecution Extends ActiveMagicEffect  


GlobalVariable Property EssentialNPCs Auto

ObjectReference Property Marker Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Marker.MoveTo(akTarget)
	If akTarget.IsInInterior()
		Marker.PushActorAway(akTarget, 50.0)
	Else
		Marker.PushActorAway(akTarget, 75.0)
	EndIf
	Utility.Wait(0.5)
	If EssentialNPCs.GetValue()
		akTarget.Kill(akCaster)
	Else
		akTarget.KillEssential(akCaster)
	EndIf
EndEvent
