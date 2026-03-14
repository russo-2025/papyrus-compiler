ScriptName REQ_Volendrung Extends ActiveMagicEffect

Enchantment Property VolendrungEnch Auto

Spell Property EnchAbility Auto

REQ_ReapplyNonPersistentChanges Property ReapplyNonPersistentChanges Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleEnchantment()
	akTarget.AddSpell(EnchAbility, False)
	ReapplyNonPersistentChanges.VolendrungScript = Self
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.RemoveSpell(EnchAbility)
	ReapplyNonPersistentChanges.VolendrungScript = None
EndEvent


Function ReapplyNonPersistentChanges()
	Actor Target = GetTargetActor()
	Target.RemoveSpell(EnchAbility)
	RescaleEnchantment()
	Target.AddSpell(EnchAbility, False)
EndFunction

Function RescaleEnchantment()
	Float Strength = Max(Game.GetPlayer().GetBaseActorValue("Health") - 100, 0.0)
	Float Absorb = Min(10.0 + Strength * 0.5, 75.0)
	VolendrungEnch.SetNthEffectMagnitude(0, Absorb)
	VolendrungEnch.SetNthEffectMagnitude(2, Absorb)
	EnchAbility.SetNthEffectMagnitude(0, Absorb)
EndFunction

Float Function Min(Float a, Float b)
	If a < b
		Return a
	Else
		Return b
	EndIf
EndFunction

Float Function Max(Float a, Float b)
	If a > b
		Return a
	Else
		Return b
	EndIf
EndFunction
