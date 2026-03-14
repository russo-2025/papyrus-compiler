ScriptName REQ_ConditionalSubEffect extends ActiveMagicEffect
{This script can be applied to a magic effect which is conditionalized at the spell level (and thus temporarily dispelled when the conditions are not satisfied) to apply another spell (ability type) only when the condition is currecntly fulfilled. Use this to deliver spells that require rescaling at runtime, like mass-dependent blocking costs.}

Spell[] Property SubSpells Auto
Actor target

Event OnEffectStart(Actor akTarget, Actor akCaster)
	target = akTarget
	Int i = 0
	While i < SubSpells.Length
		target.AddSpell(SubSpells[i], False)
		i += 1
	EndWhile
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Int i = 0
	While i < SubSpells.Length 
		target.RemoveSpell(SubSpells[i])
		i += 1
	EndWhile
EndEvent
