ScriptName REQ_MehrunesRazor Extends ActiveMagicEffect

GlobalVariable Property HitChance Auto

Spell Property Description Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleEnchantment()
	akTarget.AddSpell(Description, False)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.RemoveSpell(Description)
EndEvent


Function RescaleEnchantment()
	Float Chance = 1.0
	If Game.QueryStat("People Killed") >= 100
		Chance += 1.0
	EndIf
	If Game.QueryStat("Animals Killed") >= 100
		Chance += 1.0
	EndIf
	If Game.QueryStat("Creatures Killed") >= 100
		Chance += 1.0
	EndIf
	If Game.QueryStat("Undead Killed") >= 100
		Chance += 1.0
	EndIf
	If Game.QueryStat("Daedra Killed") >= 100
		Chance += 1.0
	EndIf
	If Game.QueryStat("Automatons Killed") >= 100
		Chance += 1.0
	EndIf
	HitChance.SetValue(Chance)
EndFunction
