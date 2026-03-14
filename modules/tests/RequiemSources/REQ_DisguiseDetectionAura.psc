Scriptname REQ_DisguiseDetectionAura extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If ( akTarget == Game.GetPlayer() )
		Game.GetPlayer().OnHit(akCaster, None, None, False, False,  False, False)
	EndIf
EndEvent
