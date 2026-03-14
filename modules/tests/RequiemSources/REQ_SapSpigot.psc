ScriptName REQ_SapSpigot Extends ObjectReference

LeveledItem Property Harvest Auto

Message Property FailureMessage Auto

Sound Property HarvestSound Auto


Bool ReadyForHarvest


Event OnLoad()
	ReadyForHarvest = True
EndEvent

Event OnActivate(ObjectReference akActivator)
	If akActivator == Game.GetPlayer()
		If ReadyForHarvest
			ReadyForHarvest = False
			HarvestSound.Play(akActivator)
			akActivator.AddItem(Harvest)
		Else
			FailureMessage.Show()
		EndIf
	EndIf
EndEvent
