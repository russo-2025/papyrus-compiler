Scriptname REQ_NPCpower_phaseshift extends Actor
{allow boss enemies to swap positions with their minions via teleport when hit}

FormList Property allowedtypes Auto
Int Property maxtries = 10 Auto
Spell Property PhaseOptics Auto

Event OnDeath(Actor akKiller)
	GotoState("Dead")
EndEvent

Auto State active

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		GotoState("Cooldown")
		Int tries = 0
		Actor found
		If (akSource as Weapon || (akSource as Spell && (akSource as Spell).isHostile()))
			While tries < maxtries && (found == None || found.isdead() )
				found = Game.FindRandomReferenceOfAnyTypeInListFromRef(allowedtypes, Self, 2500) as Actor
				tries += 1
			EndWhile
			If found != None && !found.IsDead()
				Float new_x = found.GetPositionX()
				Float new_y = found.GetPositionY()
				Float new_z = found.GetPositionZ()
				PhaseOptics.Cast(self,self)
				PhaseOptics.Cast(found,found)
				found.SetPosition(Self.GetPositionX(), Self.GetPositionY(), Self.GetPositionZ() )
				SetPosition(new_x, new_y, new_z)
			EndIf
		EndIf
	EndEvent

EndState

State Cooldown

	Event OnBeginState()
		RegisterForSingleUpdate(10)
	EndEvent
	
	Event OnUpdate()
		If GetState() != "Dead"
			GotoState("active")
		EndIf
	EndEvent

Endstate

State Dead

EndState
