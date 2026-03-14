ScriptName REQ_MiraaksRobes Extends ActiveMagicEffect

Spell Property TentacleExplosion Auto

Bool CanExplode = True


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)  
	If CanExplode && (akAggressor As Actor) != None && akAggressor != GetTargetActor()
		CanExplode = False
		TentacleExplosion.Cast(GetTargetActor())
		Utility.Wait(3.0)
		CanExplode = True
	EndIf
EndEvent
