ScriptName REQ_Illusion_Nightmare extends ActiveMagicEffect
{kills the target instantly if the spell was empowered and casted on a sleeping target}

MagicEffect Property Empowered Auto
{the effect indicating empowered casting}

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If ( akTarget.HasMagicEffect(Empowered) )
		akTarget.EnableAI(False)
		akTarget.Kill(akCaster)
		Utility.Wait(2)
		akTarget.EnableAI(True)
	EndIf
EndEvent
