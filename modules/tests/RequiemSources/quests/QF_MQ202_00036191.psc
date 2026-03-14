;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 58
Scriptname QF_MQ202_00036191 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Gissur
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Gissur Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FlagonAmbush1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FlagonAmbush1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MainAmbush4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MainAmbush4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Shavari
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Shavari Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FlagonAmbush3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FlagonAmbush3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Vekel
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Vekel Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FinalAmbush1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FinalAmbush1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FinalAmbush2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FinalAmbush2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY ShavariNote
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_ShavariNote Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EsbernsDoor
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EsbernsDoor Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Delphine
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Delphine Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FlagonAmbush2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FlagonAmbush2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FlagonBartender
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FlagonBartender Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Esbern
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Esbern Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Dirge
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Dirge Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MainAmbush1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MainAmbush1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MainAmbush3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MainAmbush3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Brynjolf
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Brynjolf Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY GissurNote
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_GissurNote Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_29
Function Fragment_29()
;BEGIN CODE
Alias_EsbernsDoor.GetReference().Lock(false)
Alias_EsbernsDoor.GetReference().SetOpen(true)
Alias_EsbernsDoor.GetReference().BlockActivation(false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_47
Function Fragment_47()
;BEGIN CODE
; Flagon ambush triggered
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_49
Function Fragment_49()
;BEGIN CODE
; clean up MQ202:
; disable thalmor guys
ThalmorAmbushEnableMarker.Disable()
FlagonAmbushMarker.Disable()
FinalAmbushEnableMarker.Disable()
; put ratway guys back
Ratway02EnableMarker.Enable()
Alias_Gissur.TryToDisable()
Alias_Shavari.TryToDisable()
MQ202ShavariTrigger.Disable()
; stop quest
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_21
Function Fragment_21()
;BEGIN CODE
; enable final ambush
FinalAmbushEnableMarker.Enable()
; move Gissur if still alive
actor gissur = Alias_Gissur.GetActorReference()
if( gissur != None )
	if gissur.IsDead() == 0
		gissur.setactorvalue("Aggression", 1)
		gissur.moveTo(Alias_MainAmbush1.GetReference())
	endif
endif
; Esbern outro scene finished
EsbernExplainScene.Stop()
; make him a teammate for trip to Riverwood
Alias_Esbern.GetActorReference().setPlayerTeammate(true, false)
; move final ambush into Esbern's Vault
Alias_FinalAmbush1.TryToMoveTo(EsbernVaultMoveMarker)
Alias_FinalAmbush2.TryToMoveTo(EsbernVaultMoveMarker)
; make Shavari always aggressive
(Alias_Shavari as MQ202MakeAggressiveInLocation).MakeAggressive(true)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
; Esbern opens door
EsbernOpenDoorScene.Start()
; complete all previous objectives
SetObjectiveCompleted(10)
SetObjectiveCompleted(20)
SetObjectiveCompleted(30)
SetObjectiveDisplayed(40)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
; player has learned Esbern's location
SetObjectiveCompleted(10)
SetObjectiveCompleted(20)
SetObjectiveDisplayed(30)
; finish MQ201 if necessary
MQ201.SetStage(255)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN CODE
; tell Esbern you're Dragonborn
SetStage(150)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
; player told Esbern the Thalmor had found him
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_41
Function Fragment_41()
;BEGIN CODE
; enable Thalmor ambush outside Ragged Flagon
FlagonAmbushMarker.Enable()
; start Gissur summon scene
GissurSummonThalmorStartScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
; search Ratway objective
SetObjectiveCompleted(10)
SetObjectiveDisplayed(20)
; make sure MQ201 is finished (in case you skipped ahead)
if MQ201.GetStageDone(250) == 0
	MQ201.SetStage(250)
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_54
Function Fragment_54()
;BEGIN CODE
; close Esbern's door behind player
Alias_EsbernsDoor.GetReference().SetOpen(false)
; lock?
;Alias_EsbernsDoor.GetReference().Lock(false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_36
Function Fragment_36()
;BEGIN CODE
SetObjectiveDisplayed(10, 1)

; move Gissur to Riften if he's alive
Actor gissur = Alias_Gissur.GetActorReference()
if gissur != None
	gissur.movetoWhenUnloaded(RaggedFlagonMarker)
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_19
Function Fragment_19()
;BEGIN CODE
; start esbern explanation scene
EsbernOpenDoorScene.Stop()  ; failsafe
EsbernExplainScene.Start()
; transition to MQ203
CompleteAllObjectives()
MQ203.SetStage(10)
MQ203.SetActive()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
; debug.trace("MQ Quickstart " + self)
MQ201.setstage(1)
MQ201.setstage(30)
; free prisoner and Brelas
MQ201.setstage(202)
MQ201.setstage(205)
MQ201.setstage(230)
SetStage(5)
MQ201.SetStage(250)
; debug.trace("MQ Quickstart DONE" + self)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_52
Function Fragment_52()
;BEGIN AUTOCAST TYPE MQ202QuestScript
Quest __temp = self as Quest
MQ202QuestScript kmyQuest = __temp as MQ202QuestScript
;END AUTOCAST
;BEGIN CODE
; Dirge told player about Esbern
kmyQuest.CheckForGissurOverhearing(Alias_Dirge.GetActorReference())
SetStage(55)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
; player has entered Esbern's house
; trigger force-greet
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_43
Function Fragment_43()
;BEGIN CODE
; Gissur becomes hostile
Alias_Gissur.TryToAddToFaction(EnemyofPlayerFaction)
Alias_Gissur.GetActorReference().SetActorValue("Aggression", 1)
GissurSummonThalmorScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_32
Function Fragment_32()
;BEGIN AUTOCAST TYPE MQ202QuestScript
Quest __temp = self as Quest
MQ202QuestScript kmyQuest = __temp as MQ202QuestScript
;END AUTOCAST
;BEGIN CODE
; Vekel told player about Esbern
kmyQuest.CheckForGissurOverhearing(Alias_Vekel.GetActorReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_45
Function Fragment_45()
;BEGIN CODE
; player has triggered the main ambush in Ratway02
; (they can stop holding position)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
; silently start quest when player escapes from Thalmor Embassy
; to allow you to find Esbern without talking to Delphine first
; enable Thalmor ambush
ThalmorAmbushEnableMarker.enable()
; disable normal enemies in Ratway02
Ratway02EnableMarker.Disable()
; enable Shavari
Alias_Shavari.TryToenable()
; enable Shavari trigger
MQ202ShavariTrigger.Enable()
; move Gissur if he's alive
; USKP 2.0 added missing sanity check for Gissur being dead in MQ201
if( Alias_Gissur.GetActorReference() != None )
	if Alias_Gissur.GetActorReference().IsDead() == 0
		Alias_Gissur.TryToMoveTo(Alias_Shavari.GetRef())
		; make him unaggressive
		Alias_Gissur.GetActorReference().SetActorValue("Aggression", 0)
	endif
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_34
Function Fragment_34()
;BEGIN CODE
SetStage(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_56
Function Fragment_56()
;BEGIN CODE
; player has spoken to Esbern
SetStage(50)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property MQ201  Auto  

Scene Property EsbernOpenDoorScene  Auto  

ObjectReference Property ThalmorAmbushEnableMarker  Auto  
{turns on thalmor ambush in Ratway Ghetto}

Scene Property EsbernExplainScene  Auto  

Quest Property MQ203  Auto  

Quest Property MQ00  Auto  

ObjectReference Property RaggedFlagonMarker  Auto  

Scene Property GissurSummonThalmorScene  Auto  

ObjectReference Property FlagonAmbushMarker  Auto  

Faction Property EnemyofPlayerFaction  Auto  

ObjectReference Property FinalAmbushEnableMarker  Auto  

ObjectReference Property EsbernVaultMoveMarker  Auto  

ObjectReference Property Ratway02EnableMarker  Auto  

ObjectReference Property MQ202ShavariTrigger  Auto  

Scene Property GissurSummonThalmorStartScene  Auto  
