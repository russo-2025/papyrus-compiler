ScriptName REQ_Debug_GetItemHealth Extends ActiveMagicEffect


Int Property WeaponSlot Auto
Int Property ArmorSlot Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Debug.MessageBox(WornObject.GetItemHealthPercent(akTarget, WeaponSlot, ArmorSlot))
EndEvent
