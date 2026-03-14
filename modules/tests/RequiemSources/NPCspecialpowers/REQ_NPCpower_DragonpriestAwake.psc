ScriptName REQ_NPCpower_DragonpriestAwake Extends ActiveMagicEffect
{Casts the armor spells on dragonpriests as soon as they awake from their coffins}

Spell Property ArmorSpell Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	int timeout = 10
	While (!RegisterForAnimationEvent(akCaster, "SoundPlay.NPCDragonpriestCoffinAppear"))
		Utility.Wait(0.5)
		timeout = timeout - 1
		If timeout == 0
			return
		EndIf
	EndWhile
	
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	If (asEventName == "SoundPlay.NPCDragonpriestCoffinAppear")
   		ArmorSpell.Cast(akSource)
	EndIf
EndEvent
