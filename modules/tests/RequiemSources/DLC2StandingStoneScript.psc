Scriptname DLC2StandingStoneScript extends ObjectReference  

PROJECTILE Property DLC2VoicePushProjectile01  Auto  
PROJECTILE Property DLC2VoicePushProjectile03  Auto  
SPELL Property DLC2SpellLearned  Auto  
bool property Freed auto hidden
float DelayReady

auto State Waiting

Event OnActivate(ObjectReference akActionRef)
	gotoState("Busy")
; 	debug.Trace("STANDING STONE: I've been touched")
	if akActionRef == game.GetPlayer()
		if Freed == true
; 			debug.Trace("STANDING STONE: has been freed - DelayReady: " + DelayReady + ", GameDays: " + GameDaysPassed.GetValue())
			if !(akActionRef as Actor).HasSpell(DLC2SpellLearned)
; 				debug.Trace("STANDINGSTONE: it's been a day since the spell was last added")
				PlayAnimation("stage3")
				DLC2StoneActivateSound.play(self)				
				(akActionRef as actor).AddSpell(DLC2SpellLearned, true)
; 				debug.Trace("STANDINGSTONE: DLC2SacredStoneSpell" + DLC2SacredStoneSpell)
			else
				DLC2StandingStoneNotReadyMsg.Show()
			endif
		else
			WorkOnPillar(false)
		endif
	else
		if Freed == false && (akActionRef as Actor)
			WorkOnPillarNPC(akActionRef as Actor)
		endif
	endif
	gotoState("Waiting")
EndEvent

endState

State Busy
	Event OnActivate(ObjectReference akActionRef)
	EndEvent
EndState

function WorkOnPillarNPC(Actor pillarNPC)
	; put into alias
	FollowerAtPillar.ForceRefTo(pillarNPC)
	; clear favor state
	pillarNPC.SetDoingFavor(false)
	; work on pillar scene
	DLC2PillarFollowerScene.Start()
endFunction

function WorkOnPillar(bool bSleepMove = true)
	if GetLinkedRef()
		; player blacks out, wakes up working on pillar
		Game.DisablePlayerControls()
		if bSleepMove == false
			FadeToBlackImod.Apply()
			MAGStandingStoneActivateA.Play(Game.GetPlayer())
			utility.wait(2)
			FadeToBlackImod.PopTo(FadeToBlackHoldImod)
		else
			FadeToBlackImod.PopTo(FadeToBlackHoldImod)
			utility.wait(2)
		endif
		Game.ForceThirdPerson()
		; put player in furniture
		Game.GetPlayer().MoveTo(GetLinkedRef())
		DLC2PillarMiraakVoice.Start()
		utility.wait(2)
		FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
		FadeToBlackHoldImod.Remove()
		MAGStandingStoneActivateB.Play(Game.GetPlayer())
		utility.wait(2)
; 		debug.trace(self + " enabling controls")
		Game.EnablePlayerControls()
		while GetLinkedRef().IsFurnitureInUse()
			utility.wait(1.0)
		endWhile
		DLC2PillarMiraakVoice.Stop()
		DLC2Pillar.SetStage(100) ; runs Neloth scene, tracks player having touched pillar once
	endif

endFunction


ImageSpaceModifier Property FadeToBlackImod  Auto  

ImageSpaceModifier Property FadeToBlackHoldImod  Auto  

ImageSpaceModifier Property FadeToBlackBackImod  Auto  

Topic Property DLC2PillarBlockingTopic  Auto  

Scene Property DLC2PillarMiraakVoice  Auto  

Quest Property DLC2Pillar  Auto  

GlobalVariable Property GameDaysPassed  Auto  

Message Property DLC2StandingStoneNotReadyMsg  Auto  

Scene Property DLC2PillarFollowerScene  Auto  
ReferenceAlias Property FollowerAtPillar Auto

Sound Property MAGStandingStoneActivateA  Auto  
Sound Property MAGStandingStoneActivateB  Auto  

SPELL Property DLC2SacredStoneSpell  Auto  

Sound Property DLC2StoneActivateSound  Auto  
