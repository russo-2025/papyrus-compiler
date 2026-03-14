Scriptname bwcNightingaleGhostSCRIPT extends ACTOR  

EFFECTSHADER PROPERTY ghostEffect AUTO
FLOAT PROPERTY ghostAlpha=0.3 AUTO
CONTAINER PROPERTY ghostCorpse AUTO
LEVELEDITEM PROPERTY pdefaultGhostLeveledList AUTO

BOOL PROPERTY bdefaultLoot=FALSE AUTO
{mark true if you want the default ghost loot and not the NPCs}

BOOL bFlash=FALSE

; //////////
; //ASH PILE VARIABLES
; //////////
float property fDelay = 0.75 auto
{time to wait before Spawning Ash Pile}
float property fDelayEnd = 1.65 auto
{time to wait before Removing Base Actor}
float property ShaderDuration = 0.00 auto
{Duration of Effect Shader.}
Activator property pDefaultAshPileGhost auto
{The object we use as a pile.}
Bool property bSetAlphaZero = True auto
{The Effect Shader we want.}
FormList Property pDisintegrationMainImmunityList auto
{If the target is in this list, they will not be disintegrated.}
EFFECTSHADER PROPERTY pGhostDeathFXShader AUTO
{the shader to play while dying}

race VictimRace
bool TargetIsImmune = True

EVENT onLOAD()

	;USKP 2.0.3 - Delay added. Cause obviously an ONLOAD event does it's job absolutely perfectly.
	Utility.Wait(2)
	ghostEffect.play(SELF)
	SELF.SetAlpha(0.3)
	
	registerForAnimationEvent(SELF, "bowDraw")
	registerForAnimationEvent(SELF, "weaponSwing")
	registerForAnimationEvent(SELF, "arrowRelease")
	
ENDEVENT

EVENT onHIT(OBJECTREFERENCE akAggressor, FORM akSource, Projectile akProjectile, BOOL abPowerAttack, BOOL abSneakAttack, BOOL abBashAttack, BOOL abHitBlocked)
	ghostFlash()
	

ENDEVENT

EVENT OnAnimationEvent(ObjectReference akSource, string EventName)
		ghostFlash()
		
ENDEVENT

; /////////
; //ONDYING: On dying play an explosion to mask the ghost vanishing and being replaced by his corpse
; /////////
EVENT onDYING(ACTOR killer)
	
		; //check to see if the target is in the immunity list
		IF(pDisintegrationMainImmunityList == none)
			TargetIsImmune = False
		ELSE
			ActorBase VictimBase = SELF.GetBaseObject() as ActorBase
			VictimRace = VictimBase.GetRace()
			
			IF(pDisintegrationMainImmunityList.hasform(VictimRace) || pDisintegrationMainImmunityList.hasform(VictimBase))
				TargetIsImmune = True
			ELSE
				TargetIsImmune = False
			ENDIF
		ENDIF

		; //if the target is not immune, disintegrate them
		IF(TargetIsImmune == False)
; 			debug.trace("victim just died")

			SELF.SetCriticalStage(SELF.CritStage_DisintegrateStart)

			IF(pGhostDeathFXShader != none)
				pGhostDeathFXShader.play(SELF,ShaderDuration)
			ENDIF
			
			SELF.SetAlpha (0.0,True)
			
			; //attach the ash pile
			SELF.AttachAshPile(pDefaultAshPileGhost)
			
			IF(bdefaultLoot)
				SELF.RemoveAllItems()
				SELF.addItem(pdefaultGhostLeveledList)
			ENDIF
			
				
			utility.wait(fDelayEnd)
			IF(pGhostDeathFXShader != none)
				pGhostDeathFXShader.stop(SELF)
			ENDIF
			IF(bSetAlphaZero == True)
				SELF.SetAlpha (0.0,True)
			ENDIF
			SELF.SetCriticalStage(SELF.CritStage_DisintegrateEnd)
		ENDIF
	
	
ENDEVENT


; //play this to flash the ghost when hit or attacking
FUNCTION ghostFlash()

	IF(!bFlash)
	
		bFlash = TRUE
	
		SELF.setAlpha(0.7, TRUE)
	
		utility.wait(1)
		
		SELF.setAlpha(0.3)
		
		bFlash = FALSE
	ENDIF
	
ENDFUNCTION
