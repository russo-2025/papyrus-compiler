ScriptName REQ_FeedPenaltyScript Extends ActiveMagicEffect


GlobalVariable Property EssentialNPCs Auto

MagicEffect Property Req_FeedPenaltyEffect01 Auto

Spell Property Penalty01 Auto
Spell Property Penalty02 Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Utility.Wait(3.0)
	If akTarget.GetActorValue("Health") <= 125.0
		If EssentialNPCs.GetValue()
			akTarget.Kill(akCaster)
		Else
			akTarget.KillEssential(akCaster)
		EndIf
	EndIf
	If !akTarget.HasMagicEffect(Req_FeedPenaltyEffect01)
		Penalty01.Cast(akTarget, akTarget)
	Else
		Penalty02.Cast(akTarget, akTarget)
	Endif
EndEvent
