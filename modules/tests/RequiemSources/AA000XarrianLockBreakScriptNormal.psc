ScriptName AA000XarrianLockBreakScriptNormal Extends ObjectReference  

Weapon Property Unarmed Auto


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	Actor player = Game.GetPlayer()
	; only player-executed melee attacks qualify as lockbreaking attacks
	If akAggressor == player && (akSource As Weapon) != None && akSource != Unarmed && akProjectile == None && !abBashAttack && IsLocked()
		Int lock = GetLockLevel()
		Float power = 2 * player.GetActorValue("Health") + player.GetActorValue("Stamina")
		If (lock <= 1 && power >= 350.0) || (lock <= 25 && power >= 450.0) || (lock <= 50 && power >= 550.0)
			Lock(False)
		EndIf
		((Self As ObjectReference) As REQ_LockpickControl).MagicCrimeAlarm(player)
	EndIf
EndEvent
