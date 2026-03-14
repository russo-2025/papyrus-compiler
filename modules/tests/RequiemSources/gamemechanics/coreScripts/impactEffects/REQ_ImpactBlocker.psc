Scriptname REQ_ImpactBlocker extends ActiveMagicEffect
{kill the blocker for Player ImpactEffects faster than the CK allows}

Float Property Duration Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	RegisterForSingleUpdate(Duration)
EndEvent

Event OnUpdate()
	Self.Dispel()
EndEvent
