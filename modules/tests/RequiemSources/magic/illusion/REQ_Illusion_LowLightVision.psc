scriptName REQ_Illusion_LowLightVision extends ActiveMagicEffect
{Scripted effect for the Low Light Vision Spell, extend original nighteye by toggle for dualcast}

import GlobalVariable

;======================================================================================;
;               PROPERTIES  /
;=============/

float property fDelay = 0.83 auto
{time to wait before switching to constant Imod}
ImageSpaceModifier property IntroFX auto
{IsMod applied at the start of the spell effect}
ImageSpaceModifier property MainFX auto
{main isMod for spell}
ImageSpaceModifier property OutroFX auto
{IsMod applied at the end of the spell effect}
Float Property fImodStrength = 1.0 auto
{IsMod Strength from 0.0 to 1.0}
sound property IntroSoundFX auto ; create a sound property we'll point to in the editor
sound property OutroSoundFX auto ; create a sound property we'll point to in the editor
GlobalVariable Property NightEyeTransitionGlobal auto
MagicEffect Property DualcastVision Auto
;MagicEffect Property NightEyeEffect auto
;Spell Property NightEyeDispelEffectSpell auto
; Obtain the target of the active fire effect


;Actor CasterActor
;======================================================================================;
;               EVENTS                     /
;=============/

Event OnEffectStart(Actor Target, Actor Caster)
	If ( Target.HasMagicEffect(DualcastVision) )
		Return
	EndIf
	
	;CasterActor = Caster

	; IntroFX.remove()
	; MainFX.remove()									;Kill Imods from another cast, if running.
	; OutroFX.remove()	
	
	if NightEyeTransitionGlobal.GetValue() == 0.0
		NightEyeTransitionGlobal.setValue(1.0)
		int instanceID = IntroSoundFX.play((target as objectReference))          ; play IntroSoundFX sound from my self
		introFX.apply(fImodStrength)                                  ; apply isMod at full strength
		utility.wait(fDelay)                            ; NOTE - neccessary? 
		;MainFX.apply()
		if NightEyeTransitionGlobal.GetValue() == 1.0
			introFX.PopTo(MainFX,fImodStrength)	
			NightEyeTransitionGlobal.setValue(2.0)
		endif
	; elseif NightEyeTransitionGlobal.GetValue() == 1.0
		; introFX.PopTo(MainFX,fImodStrength)	
		; NightEyeTransitionGlobal.setValue(2.0)
		; self.dispel()
	else
		self.dispel()
	endif
	
EndEvent

; Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect NightEyeEffect)
	; NightEyeDispelEffectSpell.Cast(CasterActor)
; endEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	if NightEyeTransitionGlobal.GetValue() == 1.0
		utility.wait(fDelay)
	endif
; 	;debug.trace (self + ": We are killing the spell.  The Globale is: " + NightEyeTransitionGlobal.GetValue())
	if NightEyeTransitionGlobal.GetValue() == 2.0
		NightEyeTransitionGlobal.setValue(3.0)
; 		;debug.trace (self + ": This is a valid outro play, see because 2.0 = " + NightEyeTransitionGlobal.GetValue())
		int instanceID = OutroSoundFX.play((target as objectReference))         ; play OutroSoundFX sound from my self
		;MainFX.remove()
		MainFX.PopTo(OutroFX,fImodStrength)
		introFX.remove()
		NightEyeTransitionGlobal.setValue(0.0)
	endif

endEvent
