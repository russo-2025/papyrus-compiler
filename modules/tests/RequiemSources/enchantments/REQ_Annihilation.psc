ScriptName REQ_Annihilation Extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Float MagicResist = akTarget.GetActorValue("MagicResist")
	Float Magnitude = GetMagnitude()
	Float Damage = Magnitude / (100.0 - MagicResist) * 100.0
	akTarget.DamageActorValue("Health", Damage)
EndEvent
