ScriptName REQ_Magic_Toggle extends ActiveMagicEffect
{toggles the given spells of by dispelling them}

Spell[] Property ToDispel Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Int i = 0
	While( i < ToDispel.Length )
		akTarget.DispelSpell(ToDispel[i])
		i += 1
	EndWhile
EndEvent
