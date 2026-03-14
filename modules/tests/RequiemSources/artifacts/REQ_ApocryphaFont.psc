ScriptName REQ_ApocryphaFont Extends ActiveMagicEffect

Location Property Apocrypha Auto

Event OnCellLoad()
	If !GetTargetActor().IsInLocation(Apocrypha)
		Dispel()
	EndIf
EndEvent
