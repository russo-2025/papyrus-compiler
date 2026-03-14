Scriptname REQ_RetroActiveFixes extends REQ_CoreScript
{this script applies one-time changes after an update to fix bugs from prior versions}

GlobalVariable Property AlcoholLevelStorage Auto

Enchantment Property HarbingerCuirass Auto
Enchantment Property HarbingerHelmet Auto
Enchantment Property HarbingerGauntlets Auto
Enchantment Property HarbingerBoots Auto

Faction Property KynesPeaceFaction Auto

Spell Property OutOfCombatRegeneration Auto

Spell Property MassEffect Auto

Perk[] Property AttackSpeedReapply Auto

Function initScript(Int currentVersion, Int nevVersion)
	If currentVersion > 0
		If currentVersion <= 60000 && nevVersion >= 60001
			Apply_6_0_0_to_6_0_1_fixes()
		EndIf
		If currentVersion <= 60001 && nevVersion >= 60002
			Apply_6_0_1_to_6_0_2_fixes()
		EndIf
	EndIf
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
EndFunction

Function Apply_6_0_0_to_6_0_1_fixes()
	AlcoholLevelStorage.SetValue(0.0)

	Player.RemoveSpell(OutOfCombatRegeneration)
	
	Player.RemoveSpell(MassEffect)
	Player.AddSpell(MassEffect, False)
	Player.ForceActorValue("IgnoreCrippledLimbs", 0.0)
EndFunction

Function Apply_6_0_1_to_6_0_2_fixes()
	HarbingerCuirass.SetPlayerKnows(False)
	HarbingerHelmet.SetPlayerKnows(False)
	HarbingerGauntlets.SetPlayerKnows(False)
	HarbingerBoots.SetPlayerKnows(False)

	Int i = 0
	While i < AttackSpeedReapply.Length
		If Player.HasPerk(AttackSpeedReapply[i])
			Player.RemovePerk(AttackSpeedReapply[i])
			Player.AddPerk(AttackSpeedReapply[i])
		EndIf
		i += 1
	EndWhile

	Player.RemoveFromFaction(KynesPeaceFaction)
EndFunction
