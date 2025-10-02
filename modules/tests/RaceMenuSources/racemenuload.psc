Scriptname RaceMenuLoad extends ReferenceAlias

Event OnPlayerLoadGame()
	(GetOwningQuest() as RaceMenuBase).OnGameReload()
EndEvent

Event OnRaceSwitchComplete()
	(GetOwningQuest() as RaceMenuBase).OnChangeRace(GetReference() as Actor)
EndEvent

Event OnLoad()
	(GetOwningQuest() as RaceMenuBase).On3DLoaded(GetReference())
EndEvent

Event OnCellLoad()
	(GetOwningQuest() as RaceMenuBase).OnCellLoaded(GetReference())
EndEvent
