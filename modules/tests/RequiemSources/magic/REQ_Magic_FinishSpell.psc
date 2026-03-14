ScriptName REQ_Magic_FinishSpell extends ActiveMagicEffect
{Dispels this effect if a new effect has a given keyword
OR
Dispels a given spell if a new effect has a given keyword, removing all effects from it}

Spell Property ToDispel Auto
{the spell to dispel}
Keyword Property Exclusive Auto
{the keyword which new effects must have to dispel this one}

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if (Todispel != None)
		akTarget.DispelSpell(ToDispel)
	endif
EndEvent


Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	if (Exclusive != None && akEffect.HasKeyword(Exclusive))
		if (ToDispel != None)
			GetTargetActor().DispelSpell(ToDispel)
		else
			Dispel()
		endif
	endif
EndEvent
