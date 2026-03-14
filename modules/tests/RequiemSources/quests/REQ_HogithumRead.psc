Scriptname REQ_HogithumRead extends ReferenceAlias

Bool Property Reward = False Auto

Event OnRead()
	If GetOwningQuest().GetStage() < 100
		(GetOwningQuest() as REQ_HogithumQuest).FragmentsRead()
	ElseIf Reward
		GetOwningQuest().SetStage(120)
		Self.Clear()
		GetOwningQuest().CompleteAllObjectives()
	EndIf
EndEvent