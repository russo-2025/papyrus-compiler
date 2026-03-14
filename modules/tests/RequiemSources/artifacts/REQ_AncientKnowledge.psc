ScriptName REQ_AncientKnowledge Extends ActiveMagicEffect


Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer()
		Game.AdvanceSkill("Smithing", 3000.0)
	EndIf
EndEvent
