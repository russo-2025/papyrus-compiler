ScriptName REQ_Slighted_VisibleAfterHit Extends ActiveMagicEffect

Spell Property appearanceEffect Auto

Bool visualInactive = true
Actor target

Event OnEffectStart(Actor akTarget, Actor akCaster)
    target = akTarget
	target.SetAlpha(0.0)
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
    If (visualInactive)
        visualInactive = false
        target.addSpell(appearanceEffect)
    EndIf
	target.SetAlpha(0.8, True)
	RegisterForSingleUpdate(3.0)
EndEvent

Event OnUpdate()
    visualInactive = true
    target.removeSpell(appearanceEffect)
    Utility.Wait(0.2)
	target.SetAlpha(0.0)
EndEvent
