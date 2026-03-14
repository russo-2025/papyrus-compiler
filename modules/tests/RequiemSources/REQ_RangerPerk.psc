Scriptname REQ_RangerPerk extends ActiveMagicEffect
{fixes the ranger perk bug and prevents ranger from applying on anything but light (x)bows}

Keyword Property LightBow Auto
Keyword Property LightXBow Auto
Actor ranger

Event OnEffectStart(Actor akTarget, Actor akCaster)
	ranger = akTarget
	ranger.SetAnimationVariableBool("bPerkQuickShot", (ranger.WornHasKeyword(LightBow) || ranger.WornHasKeyword(LightXBow)))
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	If akBaseObject as Weapon
		ranger.SetAnimationVariableBool("bPerkQuickShot", (akBaseObject.HasKeyword(LightBow) || akBaseObject.HasKeyword(LightXBow)))
	EndIf
EndEvent