ScriptName REQ_AncientDawnguardWarhammer Extends ActiveMagicEffect

Spell Property RuneSpell Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RegisterForAnimationEvent(akTarget, "weaponSwing")
EndEvent

Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	If akSource.GetAngleX() > 45.0
		RuneSpell.Cast(akSource)
	EndIf
EndEvent
