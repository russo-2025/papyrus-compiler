ScriptName REQ_DispelSpellsOnStart extends ActiveMagicEffect
{This script dispels the specified spells when the effect starts. Abilities can also be removed. Optionally, a delay can be added.}

Spell[] Property ToRemove Auto
Spell[] Property ToDispel Auto
Float Property Delay = 0.0 Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If Delay > 0.0
		Utility.Wait(Delay)
	EndIf
	Int i = 0
	While i < ToDispel.Length && ToDispel[i] != None
		akTarget.DispelSpell(ToDispel[i])
		i += 1
	EndWhile
	i = 0
	While i < ToRemove.Length && ToRemove[i] != None
		akTarget.RemoveSpell(ToRemove[i])
		i += 1
	EndWhile
EndEvent
