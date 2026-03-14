ScriptName REQ_Illusion_Hibernation extends ActiveMagicEffect
{break the hibernation effect, if the target is hit by a weapon/explosion/spell}

Spell Property Nightmare Auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack,  bool abBashAttack, bool abHitBlocked)
	If (akSource as Weapon != None || akSource as Explosion != None)
		Dispel()
	ElseIf( (akSource as Spell != None) && (akSource as Spell).IsHostile() && akSource != Nightmare )
		Dispel()
	EndIf
EndEvent
