ScriptName REQ_Disarm Extends ActiveMagicEffect  


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Weapon Weap = akTarget.GetEquippedWeapon()
	akTarget.UnequipItem(Weap)
	If Weap.IsPlayable()
		akTarget.DropObject(Weap)
	EndIf
EndEvent
