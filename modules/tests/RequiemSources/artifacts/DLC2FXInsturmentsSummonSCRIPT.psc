Scriptname DLC2FXInsturmentsSummonSCRIPT extends ActiveMagicEffect conditional
{moves the instruments actor to player on effect start and moves actor back to holding cell on effect end}

import utility
import debug

ObjectReference property myMarker auto
ObjectReference property myBard auto
Activator property myFX Auto
Quest property myQuest auto
sound property IntroSoundFX auto
sound property OutroSoundFX auto

;******************************************************

Event OnEffectStart(Actor Target, Actor Caster)
	(myBard as actor).StopCombat()
	
	if(IntroSoundFX)
		IntroSoundFX.play((target as objectReference))
	endif
	myBard.enable()
	myBard.moveTo(game.GetPlayer())
	myQuest.setStage(500)
	wait(2)
endEvent

;******************************************************

Event OnEffectFinish(Actor Target, Actor Caster)
		;UDBP 2.0.2 - Perhaps a 3D check is needed?
		if( myBard.Is3DLoaded() )
			(myBard as Actor).PlaySubGraphAnimation("stopeffect")
		EndIf
		if(OutroSoundFX)
			OutroSoundFX.play((target as objectReference))
		endif
		wait(0.5)
		myBard.MoveTo(myMarker)
		(myBard as actor).StopCombat()
		myQuest.setStage(600)
endEvent
	
;******************************************************