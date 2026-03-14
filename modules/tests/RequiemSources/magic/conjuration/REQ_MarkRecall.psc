Scriptname REQ_MarkRecall extends ActiveMagicEffect  

ObjectReference Property Mark Auto
ObjectReference Property Park Auto
Cell Property XarrianCell Auto

Event OnEffectStart(Actor Caster, Actor Target)
	If Caster.GetAngleX() > 80 || Mark.GetParentCell() == XarrianCell
		Mark.MoveTo(Caster)
	Else
		Park.MoveTo(Caster)
		Caster.MoveTo(Mark)
		Mark.MoveTo(Park)
	EndIf 
EndEvent