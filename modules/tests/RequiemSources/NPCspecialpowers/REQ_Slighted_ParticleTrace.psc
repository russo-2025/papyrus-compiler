ScriptName REQ_Slighted_ParticleTrace Extends ActiveMagicEffect

EffectShader Property aggressionModeOutline Auto
Explosion Property deathExplosion Auto
Activator property AshPileObject auto

Bool ShaderInactive = true
Actor target

Event OnEffectStart(Actor akTarget, Actor akCaster)
    target = akTarget
	RegisterForAnimationEvent(target, "BeginCastLeft")
	RegisterForAnimationEvent(target, "BeginCastRight")
	RegisterForAnimationEvent(target, "bowDrawStart")
	RegisterForAnimationEvent(target, "preHitFrame")
	target.SetActorValue("invisibility", 1.0)
EndEvent


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
    If (ShaderInactive)
        shaderInactive = false
        aggressionModeOutline.Play(target)
        target.SetActorValue("invisibility", 0.0)
    EndIf
	RegisterForSingleUpdate(6.0)
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
    If (ShaderInactive)
        shaderInactive = false
        aggressionModeOutline.Play(target)
        target.SetActorValue("invisibility", 0.0)
    EndIf
	RegisterForSingleUpdate(6.0)
EndEvent


Event OnUpdate()
    aggressionModeOutline.stop(target)
    target.SetActorValue("invisibility", 1.0)
    shaderInactive = true
EndEvent

Event onDying(actor myKiller)
    target.placeAtMe(deathExplosion)

    target.SetCriticalStage(target.CritStage_DisintegrateStart)
    target.AttachAshPile(AshPileObject)
    target.SetAlpha (0.0,True)
    Utility.wait(1.0)
    target.SetCriticalStage(target.CritStage_DisintegrateEnd)
EndEvent