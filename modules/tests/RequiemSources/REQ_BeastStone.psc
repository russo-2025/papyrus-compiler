ScriptName REQ_BeastStone Extends ActiveMagicEffect

Faction Property BeastFaction Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.AddToFaction(BeastFaction)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.RemoveFromFaction(BeastFaction)
EndEvent
