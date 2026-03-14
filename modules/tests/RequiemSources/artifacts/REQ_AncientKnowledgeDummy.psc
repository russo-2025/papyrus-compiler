ScriptName REQ_AncientKnowledgeDummy Extends ActiveMagicEffect

Spell Property AncientKnowledgeDummy Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.RemoveSpell(AncientKnowledgeDummy)
EndEvent
