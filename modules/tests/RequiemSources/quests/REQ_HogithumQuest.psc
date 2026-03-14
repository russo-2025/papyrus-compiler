;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname REQ_HogithumQuest Extends Quest Hidden

;BEGIN ALIAS PROPERTY Giraud
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Giraud Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY WolfskullCaveFragment
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_WolfskullCaveFragment Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FrostmereCryptFragment
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FrostmereCryptFragment Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY RobbersCoveFragment
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_RobbersCoveFragment Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DarklightTowerFragment
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DarklightTowerFragment Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MorthalSwampFragment
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MorthalSwampFragment Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PelagiusWingFragment
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PelagiusWingFragment Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Reward
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Reward Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
If GetCurrentStageID() < 50
	SetObjectiveDisplayed(10)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
SetObjectiveCompleted(10)
If !FragmentsRead()
	SetObjectiveDisplayed(50)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
SetObjectiveCompleted(50)
SetObjectiveDisplayed(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
Alias_Giraud.GetReference().AddItem(Alias_WolfskullCaveFragment.GetReference())
Alias_Giraud.GetReference().AddItem(Alias_FrostmereCryptFragment.GetReference())
Alias_Giraud.GetReference().AddItem(Alias_RobbersCoveFragment.GetReference())
Alias_Giraud.GetReference().AddItem(Alias_DarklightTowerFragment.GetReference())
Alias_Giraud.GetReference().AddItem(Alias_MorthalSwampFragment.GetReference())
Alias_Giraud.GetReference().AddItem(Alias_PelagiusWingFragment.GetReference())
Alias_DarklightTowerFragment.Clear()
Alias_MorthalSwampFragment.Clear()
Alias_PelagiusWingFragment.Clear()
Alias_RobbersCoveFragment.Clear()
Alias_FrostmereCryptFragment.Clear()
Alias_WolfskullCaveFragment.Clear()
Alias_Player.GetReference().AddItem(Alias_Reward.GetReference())
SetObjectiveCompleted(100)
SetObjectiveDisplayed(110)
Alias_Player.Clear()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Bool Function FragmentsRead()
	If IsStageDone(50) \
		&& (Alias_WolfskullCaveFragment.GetReference().GetBaseObject() as Book).IsRead() \
		&& (Alias_FrostmereCryptFragment.GetReference().GetBaseObject() as Book).IsRead() \
		&& (Alias_RobbersCoveFragment.GetReference().GetBaseObject() as Book).IsRead() \
		&& (Alias_DarklightTowerFragment.GetReference().GetBaseObject() as Book).IsRead() \
		&& (Alias_MorthalSwampFragment.GetReference().GetBaseObject() as Book).IsRead() \
		&& (Alias_PelagiusWingFragment.GetReference().GetBaseObject() as Book).IsRead()
		SetStage(100)
		Return True
	ElseIf !IsStageDone(50)
		SetStage(10)
	EndIf
	Return False
EndFunction

Event OnInit()
	SetStage(0)
EndEvent