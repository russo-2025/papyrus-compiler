ScriptName REQ_TheReclamations Extends ObjectReference

Message Property MessageBlessingAdded Auto
Message Property MessageNotDunmer Auto

Race Property DunmerRace Auto
Race Property DunmerVampireRace Auto

Sound Property BlessingSFX Auto

Spell Property Blessing Auto


Event OnActivate(ObjectReference akActivator)
	Actor Player = Game.GetPlayer()
	If akActivator == Player
		Race PlayerRace = Player.GetRace()
		If PlayerRace == DunmerRace || PlayerRace == DunmerVampireRace
			If !Player.HasSpell(Blessing)
				Player.AddSpell(Blessing, False)
				MessageBlessingAdded.Show()
				BlessingSFX.Play(Player)
			Else
				Player.RemoveSpell(Blessing)
			EndIf
		Else
			MessageNotDunmer.Show()
		EndIf
	EndIf
EndEvent
