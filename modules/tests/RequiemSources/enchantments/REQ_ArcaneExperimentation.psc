ScriptName REQ_ArcaneExperimentation Extends ActiveMagicEffect

Weapon Property CreatedWeapon1 Auto
Weapon Property CreatedWeapon2 Auto
Weapon Property CreatedWeapon3 Auto
Weapon Property CreatedWeapon4 Auto
Weapon Property CreatedWeapon5 Auto
Weapon Property IronDagger Auto

SoulGem Property SoulGemGrandFilled Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer() && akTarget.GetItemCount(IronDagger) >= 5 && akTarget.GetItemCount(SoulGemGrandFilled) >= 3
		akTarget.RemoveItem(IronDagger, 5)
		akTarget.RemoveItem(SoulGemGrandFilled, 3)
		akTarget.AddItem(CreatedWeapon1)
		akTarget.AddItem(CreatedWeapon2)
		akTarget.AddItem(CreatedWeapon3)
		akTarget.AddItem(CreatedWeapon4)
		akTarget.AddItem(CreatedWeapon5)
		Game.AdvanceSkill("Enchanting", 3)
	EndIf
EndEvent
