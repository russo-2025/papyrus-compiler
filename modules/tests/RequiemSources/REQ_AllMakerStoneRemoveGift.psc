ScriptName REQ_AllMakerStoneRemoveGift Extends ActiveMagicEffect  

Location Property Apocrypha Auto
Location Property Solstheim Auto

Spell Property StoneSpell Auto 


Event OnCellLoad()
	Actor Target = GetTargetActor()
	If !Target.IsInLocation(Apocrypha) && !Target.IsInLocation(Solstheim)
		Target.RemoveSpell(StoneSpell)
	EndIf
EndEvent
