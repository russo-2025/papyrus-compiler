Scriptname REQ_Konahrik extends ActiveMagicEffect  

Spell Property FlameCloak Auto
Spell Property FrostCloak Auto
Spell Property LightningCloak Auto
Spell Property Healing Auto
Spell Property SummonDragonPriest Auto


Actor Wearer

Bool IsReady = True


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Wearer = akTarget
EndEvent


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
	If IsReady && (akAggressor As Actor) != None && akAggressor != Wearer
		IsReady = False
		Float Dice = Utility.RandomFloat()
		If Dice < 0.5
			Healing.Cast(Wearer)
			If Dice < 0.25
				Wearer.DispelSpell(FlameCloak)
				Wearer.DispelSpell(FrostCloak)
				Wearer.DispelSpell(LightningCloak)
				FlameCloak.Cast(Wearer)
				FrostCloak.Cast(Wearer)
				LightningCloak.Cast(Wearer)
				If Dice < 0.05
					SummonDragonPriest.Cast(Wearer)
				EndIf
			EndIf
		EndIf
		Utility.Wait(1.0)
		IsReady = True
	EndIf
EndEvent
