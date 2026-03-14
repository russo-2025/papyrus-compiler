Scriptname REQ_ReflectiveWard extends ActiveMagicEffect
{reflects spells if they were to be absorbed by the ward}

Sound Property DeflectSound Auto
Spell Property NullSpell Auto

Actor WardCaster

Event OnEffectStart(Actor akTarget, Actor akCaster)
	WardCaster = akCaster
EndEvent

Event OnWardHit(ObjectReference akCaster, Spell akSpell, Int aiStatus)
	; concentration spells will repeatedly spam OnWardHit which is bad
	GoToState("WardEventBlock")
	If aiStatus == 1 && akCaster && (WardCaster.HasLOS(akCaster) && !WardCaster.GetAnimationVariableBool("IsStaggering"))
		akSpell.Cast(WardCaster, akCaster)
		DeflectSound.Play(WardCaster)
		Utility.Wait(0.5)
		NullSpell.Cast(WardCaster, akCaster)
	EndIf
	GotoState("")
EndEvent

State WardEventBlock
	Event OnWardHit(ObjectReference akCaster, Spell akSpell, Int aiStatus)
	EndEvent
EndState