Scriptname UIMenuLoad extends ReferenceAlias

Event OnPlayerLoadGame()
	(GetOwningQuest() as UIMenuBase).OnGameReload()
EndEvent