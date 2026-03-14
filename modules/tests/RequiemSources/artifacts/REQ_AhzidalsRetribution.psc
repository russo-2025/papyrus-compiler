ScriptName REQ_AhzidalsRetribution Extends ActiveMagicEffect

Spell Property AhzidalsRetribution Auto

Actor Me
Float Chance


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Me = akTarget
	Chance = GetMagnitude() * 0.01
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
	If (akSource As Weapon) != None && akProjectile == None && (akAggressor As Actor) != None && !abHitBlocked
		If Utility.RandomFloat() < Chance
			AhzidalsRetribution.Cast(Me, akAggressor)
		EndIf
	EndIf
EndEvent
