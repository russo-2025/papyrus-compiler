Scriptname Req_AlduinAbilityScript extends activemagiceffect  

Int Property Random  Auto  
Int Property Marked  Auto  


ObjectReference Property TeleportXHeader  Auto  




Event OnEffectStart(actor Target, actor Caster)


		Game.GetPlayer().DamageActorValue("Magicka", 100)
		Caster.RestoreActorValue("Magicka", 100)

		Game.GetPlayer().DamageActorValue("Stamina", 100)
		Caster.RestoreActorValue("Stamina",  100)

		Game.GetPlayer().DamageActorValue("Health", 100)
		Caster.RestoreActorValue("Health", 100)


		If Marked == 1

			Marked = 0
			Game.GetPlayer().MoveTo(TeleportXHeader)

		EndIf

		If Marked != 1

			Marked = 1
			TeleportXHeader.MoveTo(Game.GetPlayer())

		EndIf



EndEvent



