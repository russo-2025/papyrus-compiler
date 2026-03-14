Scriptname REQ_PoisonISM extends ActiveMagicEffect  

ImageSpaceModifier property ISM_hit Auto
ImageSpaceModifier property ISM_active Auto
ImageSpaceModifier property ISM_fade Auto

String Property Resistvalue = "PoisonResist" Auto
GlobalVariable Property Switch = None Auto
Float Property ISM_strengthoffset = 0.0 Auto

Float power = 0.0

Event OnEffectStart(actor akTarget, actor akCaster)
	If akTarget == game.GetPlayer()
		If ISM_hit != None
			ISM_hit.apply(1.0)
		EndIf
		power = 1.0 + ISM_strengthoffset
		If (Resistvalue != "None") 
			power = power - akTarget.GetActorValue(Resistvalue) / 100.0
		EndIf 
		If power > 1.0
			power = 1.0
		EndIf
		If !Switch || (Switch.GetValue() == 0 && power > 0.0)
			ISM_active.apply(power)
		EndIf
	EndIf
EndEvent

event onEffectFinish(actor akTarget, actor akCaster)
	If akTarget == game.GetPlayer()
		If ISM_fade != None
			ISM_fade.apply(1.0)
		EndIf
		If power > 0.0
			ISM_active.remove()
		EndIf
	EndIf
endEvent