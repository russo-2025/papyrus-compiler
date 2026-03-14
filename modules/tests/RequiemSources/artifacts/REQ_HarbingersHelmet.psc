ScriptName REQ_HarbingersHelmet Extends ActiveMagicEffect

Spell Property SummonCompanion Auto

Actor Me
Float Chance


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Me = akTarget
	Chance = GetMagnitude() * 0.01
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)	
	If (akAggressor As Actor) != None && akAggressor != Me
		GoToState("Cooldown")
		If Utility.RandomFloat() < Chance
			SummonCompanion.Cast(Me)
		EndIf
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent

Event OnUpdate()
	GoToState("")
EndEvent

State Cooldown
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)	
	EndEvent
EndState
