ScriptName REQ_Spellbreaking Extends ActiveMagicEffect


MagicEffect Property CooldownEffect Auto

Spell Property CooldownSpell Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If !akTarget.HasMagicEffect(CooldownEffect)
		akTarget.DispelAllSpells()
		CooldownSpell.Cast(akTarget, akTarget)
	EndIf
EndEvent
