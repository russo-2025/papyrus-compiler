Scriptname IceWraithParticlesSCRIPT extends ActiveMagicEffect  
{Particles to auto add to ice wraith}

;===============================================

import utility
import actor
import form
;===============================================
Actor selfRef
VisualEffect Property IceWraithParticles01 Auto
Armor Property SkinIceWraithSmokeFins  Auto   
VisualEffect Property FXIceWraith2ndFormEffect auto

String property GroundDiveIceHazard auto 
String property ChangeForms auto 
Spell Property WallOfFrostIceWraith Auto

Float Property scaleRangeMax = 1.1Auto 
Float Property scaleRangeMin = 0.9 Auto 
Explosion Property deathExplosion Auto
Activator property AshPileObject auto
{The object we use as a pile.}

Bool isSummoned = False

	EVENT OnEffectStart(Actor Target, Actor Caster)
		selfRef = caster

		If selfRef.IsCommandedActor()
			isSummoned = True
		EndIf
		
		;Added by USKP to prevent this effect from appearing on the player.
		If selfRef == Game.GetPlayer()
			Dispel()
			return
		EndIf
		
		;USKP 2.0.3 - 3D check, shaders, etc
		if( selfRef.Is3DLoaded() )
			selfRef.setScale(RandomFloat(scaleRangeMin, scaleRangeMax))
			IceWraithParticles01.Play(selfRef, -1)
			FXIceWraith2ndFormEffect.play(selfRef, -1)
		EndIf
		selfRef.EquipItem(SkinIceWraithSmokeFins)	
		registerForAnimationEvent(selfRef, GroundDiveIceHazard)
		registerForAnimationEvent(selfRef, ChangeForms)
	ENDEVENT
	
	Event OnEffectFinish(Actor akTarget, Actor akCaster)
		IceWraithParticles01.Stop(selfRef)
		selfRef.unEquipItem(SkinIceWraithSmokeFins)	
		FXIceWraith2ndFormEffect.Stop(selfRef)
	ENDEVENT
	
	EVENT onAnimationEvent(ObjectReference akSource, string asEventName)
		if (asEventName == GroundDiveIceHazard)
; 			debug.trace("event")
			WallOfFrostIceWraith.Cast(selfRef) 
		endif
		if (asEventName == ChangeForms)

			selfRef.PlaySubGraphAnimation("SkinFadeOut")
			wait(2.0)
			selfRef.PlaySubGraphAnimation("SkinFadeIn")
		endif
	endEVENT
	
	EVENT onDying(actor myKiller)
		
		IceWraithParticles01.Stop(selfRef)
		FXIceWraith2ndFormEffect.stop(selfRef)
		selfRef.unEquipItem(SkinIceWraithSmokeFins)	

		; Summoned ice wraiths should not drop lootable ice piles
		If isSummoned
			Return
		EndIf

		selfRef.placeAtMe(deathExplosion)
		
		selfRef.SetCriticalStage(selfRef.CritStage_DisintegrateStart)
		selfRef.AttachAshPile(AshPileObject)		
		selfRef.SetAlpha (0.0,True)
		wait(1.0)		
		selfRef.SetCriticalStage(selfRef.CritStage_DisintegrateEnd)
	ENDEVENT

