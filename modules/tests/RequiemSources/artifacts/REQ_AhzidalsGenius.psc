ScriptName REQ_AhzidalsGenius Extends ActiveMagicEffect

Enchantment Property AhzidalsHelmet Auto
Enchantment Property AhzidalsCuirass Auto
Enchantment Property AhzidalsGauntlets Auto
Enchantment Property AhzidalsBoots Auto
Enchantment Property AhzidalsRingOfArcana Auto
Enchantment Property AhzidalsRingOfNecromancy Auto

FormList Property EnchantingPerks Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleEnchantments(akTarget)
	RegisterForMenu("StatsMenu")
EndEvent

Event OnPlayerLoadGame()
	RescaleEnchantments(GetTargetActor())
EndEvent

Event OnMenuClose(String Menu)
	RescaleEnchantments(GetTargetActor())
EndEvent

Function RescaleEnchantments(Actor akTarget)
	Float Factor = 1.0 + GetEnchantingPerkCount(akTarget)
	AhzidalsHelmet.SetNthEffectMagnitude(1, 1.5 * Factor)
	AhzidalsHelmet.SetNthEffectMagnitude(2, 1.5 * Factor)
	AhzidalsHelmet.SetNthEffectMagnitude(3, 1.5 * Factor)
	AhzidalsHelmet.SetNthEffectMagnitude(4, 1.5 * Factor)
	AhzidalsHelmet.SetNthEffectMagnitude(5, 1.5 * Factor)
	AhzidalsHelmet.SetNthEffectMagnitude(6, 1.5 * Factor)
	AhzidalsCuirass.SetNthEffectMagnitude(1, 10.0 * Factor)
	AhzidalsGauntlets.SetNthEffectMagnitude(1, 10.0 * Factor)
	AhzidalsBoots.SetNthEffectMagnitude(1, 10.0 * Factor)
	AhzidalsRingOfArcana.SetNthEffectMagnitude(1, 2.0 * Factor)
	AhzidalsRingOfArcana.SetNthEffectMagnitude(2, 2.0 * Factor)
	AhzidalsRingOfArcana.SetNthEffectMagnitude(3, 2.0 * Factor)
	AhzidalsRingOfArcana.SetNthEffectMagnitude(4, 2.0 * Factor)
	AhzidalsRingOfArcana.SetNthEffectMagnitude(5, 2.0 * Factor)
	AhzidalsRingOfArcana.SetNthEffectMagnitude(6, 2.0 * Factor)
	AhzidalsRingOfNecromancy.SetNthEffectMagnitude(1, 30.0 * Factor)
EndFunction

Int Function GetEnchantingPerkCount(Actor akTarget)
	Int i = 0
	Int EnchantingPerksSize = EnchantingPerks.GetSize()
	Int PerkCount = 0
	While i < EnchantingPerksSize
		If akTarget.HasPerk(EnchantingPerks.GetAt(i) As Perk)
			PerkCount += 1
		EndIf
		i += 1
	EndWhile
	Return PerkCount
EndFunction
