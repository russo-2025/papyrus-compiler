ScriptName REQ_DestroyRangedWeapons Extends ActiveMagicEffect  
{Destroys ranged weapons when hit by a melee weapon}

Keyword Property Breakable Auto 

Message Property MsgDestroyedBow Auto  
Message Property MsgDestroyedCrossbow Auto  


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Weapon TargetWeapon = akTarget.GetEquippedWeapon()
	Int TargetWeaponType = akTarget.GetEquippedItemType(1)
	; Is the target using a ranged weapon that's flagged as breakable?
	If (TargetWeaponType == 7 && TargetWeapon.HasKeyword(Breakable))
		akTarget.UnequipItem(TargetWeapon)
		akTarget.RemoveItem(TargetWeapon)
		MsgDestroyedBow.Show()
	ElseIf (TargetWeaponType == 12 && TargetWeapon.HasKeyword(Breakable))
		akTarget.UnequipItem(TargetWeapon)
		akTarget.RemoveItem(TargetWeapon)
		MsgDestroyedCrossbow.Show()
	EndIf
EndEvent
