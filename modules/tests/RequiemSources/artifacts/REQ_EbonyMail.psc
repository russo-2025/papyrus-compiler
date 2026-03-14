ScriptName REQ_EbonyMail Extends ActiveMagicEffect

Actor Property ChampionOfBoethiah Auto

Spell Property EnchAbility Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleEnchantment()
	akTarget.AddSpell(EnchAbility, False)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.RemoveSpell(EnchAbility)
EndEvent


Function RescaleEnchantment()
	If GetTargetActor() == ChampionOfBoethiah
		EnchAbility.SetNthEffectMagnitude(0, 20)
		EnchAbility.SetNthEffectMagnitude(1, 60)
	Else
		Int Murders = Game.QueryStat("Murders")
		Float MagicResist = Min(10.0 + Murders * 0.25, 30.0)
		Float FireResist = Min(30.0 + Murders * 0.75, 90.0)
		EnchAbility.SetNthEffectMagnitude(0, MagicResist)
		EnchAbility.SetNthEffectMagnitude(1, FireResist)
	EndIf
EndFunction

Float Function Min(Float a, Float b)
	If a < b
		Return a
	Else
		Return b
	EndIf
EndFunction
