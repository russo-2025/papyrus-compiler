Scriptname FlameAtronachEffectScript extends ActiveMagicEffect  

{This is a temp script to get the art working right for the flame atronach.}
;===============================================

import utility
import form

;===============================================

Actor selfRef
VisualEffect Property AtronachFlameTrail Auto
Armor Property AtronachFlameDeadSkin  Auto  
EffectShader Property AtronachFlameDeathFXS Auto
EffectShader Property AtronachUnsummonDeathFXS Auto
explosion property AtronachFlameDeathExplosion auto
int atronachHealth 

	EVENT OnEffectStart(Actor Target, Actor Caster)	
		selfRef = caster
		
		;USKP 2.0.1 - Stop this from attaching to the player.
		if( selfRef == Game.GetPlayer() )
			Return
		EndIf

		;USKP 2.0.3 - 3D check, shaders, etc
		if( selfRef.Is3DLoaded() )
			AtronachFlameTrail.Play(selfRef, -1)
		EndIf
	ENDEVENT
	
	Event OnEffectFinish(Actor akTarget, Actor akCaster)
		AtronachFlameTrail.Stop(selfRef)
	ENDEVENT
	
	EVENT onDying(actor myKiller)
		atronachHealth = selfRef.GetAV("Health") as int
		if atronachHealth > 0
; 			debug.trace("flame health  > 0")
			AtronachFlameTrail.Stop(selfRef)
			AtronachUnsummonDeathFXS.Play(selfRef)
		elseIf atronachHealth <= 0
			wait(1.0)
; 			debug.trace("flame health  <= 0")
			AtronachFlameDeathFXS.Play(selfRef)
			wait(0.5)
			selfRef.placeAtMe(AtronachFlameDeathExplosion)
			wait(0.1)
			AtronachFlameTrail.Stop(selfRef)
			selfRef.EquipItem(AtronachFlameDeadSkin)
			wait(1)
			AtronachFlameDeathFXS.Stop(selfRef)
		endif
	ENDEVENT
