Scriptname REQ_DisableAlcoholBlur extends ActiveMagicEffect
{update the alcohol visuals every time this effect starts or ends}

REQ_AlcoholEffectsPlayer Property controller Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If (akTarget == Game.GetPlayer())
	    controller.UpdatePlayerAlcoholPenalties()
    EndIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
    If (akTarget == Game.GetPlayer())
        controller.UpdatePlayerAlcoholPenalties()
    EndIf
EndEvent
