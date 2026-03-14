ScriptName REQ_Dawnbreaker Extends ActiveMagicEffect

Enchantment Property DawnbreakerEnch Auto

GlobalVariable Property TurnUndeadMagnitude Auto

Spell Property Description Auto

REQ_ReapplyNonPersistentChanges Property ReapplyNonPersistentChanges Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleEnchantment()
	akTarget.AddSpell(Description, False)
	ReapplyNonPersistentChanges.DawnbreakerScript = Self
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.RemoveSpell(Description)
	ReapplyNonPersistentChanges.DawnbreakerScript = None
EndEvent


Function ReapplyNonPersistentChanges()
	Actor Target = GetTargetActor()
	Target.RemoveSpell(Description)
	RescaleEnchantment()
	Target.AddSpell(Description, False)
EndFunction

Function RescaleEnchantment()
	Int UndeadKilled = Game.QueryStat("Undead Killed")
	Float SunDamage = Min(20.0 + UndeadKilled * 0.25, 200.0)
	Float TurnUndead = Min(8.0 + UndeadKilled / 10, 80.0)
	DawnbreakerEnch.SetNthEffectMagnitude(1, SunDamage)
	DawnbreakerEnch.SetNthEffectMagnitude(2, TurnUndead)
	Description.SetNthEffectMagnitude(0, SunDamage)
	TurnUndeadMagnitude.SetValue(TurnUndead)
EndFunction

Float Function Min(Float a, Float b)
	If a < b
		Return a
	Else
		Return b
	EndIf
EndFunction
