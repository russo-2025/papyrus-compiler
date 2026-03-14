ScriptName REQ_UpdateLockpickHealth Extends ActiveMagicEffect

ReferenceAlias Property LockpickHealth Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer()
		(LockpickHealth As REQ_LockpickHealth).UpdateLockpickingHealth()
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer()
		(LockpickHealth As REQ_LockpickHealth).UpdateLockpickingHealth()
	EndIf
EndEvent
