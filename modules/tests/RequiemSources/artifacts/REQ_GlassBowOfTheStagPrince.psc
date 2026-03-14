ScriptName REQ_GlassBowOfTheStagPrince Extends ActiveMagicEffect

ActorBase Property EarthMother Auto
ActorBase Property GiantSlaughterfish Auto
ActorBase Property GiganticMudcrab Auto
ActorBase Property Gorak Auto
ActorBase Property Kruul Auto
ActorBase Property Ragnok Auto
ActorBase Property Snow Auto
ActorBase Property Ulik Auto

Enchantment Property GlassBowOfTheStagPrinceEnch Auto

Quest Property DA05 Auto

Spell Property Description Auto

REQ_ReapplyNonPersistentChanges Property ReapplyNonPersistentChanges Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleEnchantment()
	akTarget.AddSpell(Description, False)
	ReapplyNonPersistentChanges.GlassBowOfTheStagPrinceScript = Self
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.RemoveSpell(Description)
	ReapplyNonPersistentChanges.GlassBowOfTheStagPrinceScript = None
EndEvent

Function ReapplyNonPersistentChanges()
	Actor Target = GetTargetActor()
	Target.RemoveSpell(Description)
	RescaleEnchantment()
	Target.AddSpell(Description, False)
EndFunction

Function RescaleEnchantment()
	Int GreatBeastsSlain = 0
	If DA05.IsStageDone(50)  ; White Stag
		GreatBeastsSlain += 1
	EndIf
	If DA05.IsStageDone(100)  ; Sinding
		GreatBeastsSlain += 1
	EndIf
	If GiantSlaughterfish.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	If GiganticMudcrab.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	If Gorak.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	If Kruul.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	If Ragnok.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	If Snow.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	If EarthMother.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	If Ulik.GetDeadCount() >= 1
		GreatBeastsSlain += 1
	EndIf
	GlassBowOfTheStagPrinceEnch.SetNthEffectMagnitude(0, GreatBeastsSlain * 10)
	Description.SetNthEffectMagnitude(0, GreatBeastsSlain * 10)
EndFunction
