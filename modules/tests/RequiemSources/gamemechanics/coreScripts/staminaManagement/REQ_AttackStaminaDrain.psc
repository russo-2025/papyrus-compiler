Scriptname REQ_AttackStaminaDrain extends ActiveMagicEffect

Spell Property BlockRemover Auto
Spell Property Drainspell Auto

Actor Target
Bool Shutdown = False

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget == None || !akTarget.Is3DLoaded()
		Self.Dispel()
		return
	EndIf
	RegisterForSingleUpdate(0.1)
	Target = akTarget
	Target.AddSpell(BlockRemover, False)
	Target.RemoveSpell(BlockRemover)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Shutdown = True
EndEvent

Event OnUpdate()
	Target.AddSpell(BlockRemover, False)
	Target.RemoveSpell(BlockRemover)
	Utility.Wait(0.1)
	If !Shutdown && self != None
		RegisterForSingleUpdate(0.1)
	EndIf
EndEvent

Event OnCellDetach()
	Shutdown = True
	Target.RemoveSpell(Drainspell)
EndEvent
