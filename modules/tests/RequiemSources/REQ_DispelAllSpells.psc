ScriptName REQ_DispelAllSpells Extends ActiveMagicEffect


Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.DispelAllSpells()
EndEvent
