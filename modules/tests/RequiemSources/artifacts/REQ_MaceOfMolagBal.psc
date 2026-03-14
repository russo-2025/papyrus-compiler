ScriptName REQ_MaceOfMolagBal Extends ActiveMagicEffect

Enchantment Property MaceOfMolagBalEnch Auto

GlobalVariable Property SoulTrapDuration Auto

Spell Property Description Auto

REQ_ReapplyNonPersistentChanges Property ReapplyNonPersistentChanges Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleEnchantment()
	akTarget.AddSpell(Description, False)
	ReapplyNonPersistentChanges.MaceOfMolagBalScript = Self
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.RemoveSpell(Description)
	ReapplyNonPersistentChanges.MaceOfMolagBalScript = None
EndEvent


Function ReapplyNonPersistentChanges()
	Actor Target = GetTargetActor()
	Target.RemoveSpell(Description)
	RescaleEnchantment()
	Target.AddSpell(Description, False)
EndFunction

Function RescaleEnchantment()
	Int SoulsTrapped = Game.QueryStat("Souls Trapped")
	Float Absorb = Min(10.0 + SoulsTrapped * 0.1, 75.0)
	Int SoulTrap = MinInt(4 + SoulsTrapped / 25, 30)
	MaceOfMolagBalEnch.SetNthEffectMagnitude(0, Absorb)
	MaceOfMolagBalEnch.SetNthEffectMagnitude(1, Absorb)
	MaceOfMolagBalEnch.SetNthEffectDuration(2, SoulTrap)
	Description.SetNthEffectMagnitude(0, Absorb)
	SoulTrapDuration.SetValueInt(SoulTrap)
EndFunction

Float Function Min(Float a, Float b)
	If a < b
		Return a
	Else
		Return b
	EndIf
EndFunction

Int Function MinInt(Int a, Int b)
	If a < b
		Return a
	Else
		Return b
	EndIf
EndFunction
