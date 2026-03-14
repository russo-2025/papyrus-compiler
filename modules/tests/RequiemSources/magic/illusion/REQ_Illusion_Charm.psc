ScriptName REQ_Illusion_Charm extends ActiveMagicEffect
{charmed actor will headtrack the caster to prevent sneak attacks while charmed}


Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.SetLookAt(akCaster, False)
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.ClearLookAt()
EndEvent
