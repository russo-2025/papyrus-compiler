;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 144
Scriptname QF_DA16_000242AF Extends Quest Hidden

;BEGIN ALIAS PROPERTY ErandurAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_ErandurAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SkullAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SkullAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY ThorekAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_ThorekAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16NightcallerLocationAlias
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_DA16NightcallerLocationAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16AlchemyTomeAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16AlchemyTomeAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16ThoringAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16ThoringAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16TorporQuestItemAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16TorporQuestItemAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16LibraryMarkerAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16LibraryMarkerAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16SkullPedestal
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16SkullPedestal Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16Spectator04Alias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16Spectator04Alias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16TorporAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16TorporAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16ErandurMarkerAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16ErandurMarkerAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MiasmaLeverAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MiasmaLeverAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16VerenAmbushAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16VerenAmbushAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16PointerAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16PointerAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16Spectator03Alias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16Spectator03Alias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16LabMarkerAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16LabMarkerAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FrukiAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FrukiAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY VerenAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_VerenAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16Spectator01Alias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16Spectator01Alias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16ThorekAmbushAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16ThorekAmbushAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DA16Spectator02Alias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DA16Spectator02Alias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY BarrierGemAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_BarrierGemAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY IrgnirAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_IrgnirAlias Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_124
Function Fragment_124()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
SetObjectiveCompleted (25,1)
SetObjectiveDisplayed (28,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_139
Function Fragment_139()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
CompleteAllObjectives()
AchievementsQuest.IncDaedricQuests()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_99
Function Fragment_99()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Find Vaermina's Torpor
SetObjectiveCompleted (65,1)
SetObjectiveDisplayed(70,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_128
Function Fragment_128()
;BEGIN CODE
;Player declined or backed out of the quest before accepting it
;Start the misc quest pointing here!
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Quest Debug
;Nothing to set up, quest is triggered by scene in Dawnstar
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_113
Function Fragment_113()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Confrontation with Veren and Thorek
Alias_ErandurAlias.GetActorRef().SetPlayerTeammate(false)
SetObjectiveCompleted (140,1)
Game.DisablePlayerControls(true,true,false,false,true,true,true)
kmyQuest.pDA16ConfrontScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_142
Function Fragment_142()
;BEGIN CODE
;Play the scene with Vaermina speaking
pSkullShield.Activate(pErandur)
pDA16InHeadScene.Start()
Alias_ErandurAlias.GetActorRef().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_93
Function Fragment_93()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Find the Alchemical Tome in Library - Erandur Sandbox
SetObjectiveCompleted (50,1)
SetObjectiveDisplayed(55,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_96
Function Fragment_96()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur Escorts to Lab
if IsObjectiveDisplayed(55) == 1
SetObjectiveCompleted(55,1)
endif
SetObjectiveCompleted (57,1)
SetObjectiveDisplayed(60,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
RegisterForSingleUpdate(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur Escorts to Temple
SetObjectiveCompleted (20,1)
SetObjectiveDisplayed (25,1)
Alias_ErandurAlias.GetActorRef().SetPlayerTeammate(abCanDoFavor=false)
Alias_ErandurAlias.GetActorRef().AddToFaction(pDA16ErandurFaction)
pDA16Walk.Value = 1
kmyquest.DA16PreQuestActorEnableMarker.disable(self)
kmyquest.DA16PresentActorEnableMarker.enable(self)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
SetObjectiveDisplayed (20,1)
Alias_DA16TorporQuestItemAlias.ForceRefTo(Alias_DA16TorporAlias.GetRef())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_92
Function Fragment_92()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur Forcegreets
SetObjectiveCompleted(40,1)
SetObjectiveDisplayed(50,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_112
Function Fragment_112()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur Escorts to Skull
pConfrontEnabler.Enable()
SetObjectiveCompleted (130,1)
SetObjectiveDisplayed(140,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_126
Function Fragment_126()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Partway through dream, enable actors near the gas release
kmyQuest.DA16DreamActorEnableMarker02.enable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_104
Function Fragment_104()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Drink the Torpor
Alias_DA16TorporQuestItemAlias.Clear()
if IsObjectiveDisplayed(65) == 1
SetObjectiveCompleted(65,0)
Endif
SetObjectiveCompleted (80,1)
SetObjectiveDisplayed(100,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_131
Function Fragment_131()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Defeat Veren and Thorek
pThorek_Ambush.SetInvulnerable(false)
pVerenDuleri_Ambush.SetInvulnerable(false)
Game.EnablePlayerControls()
SetObjectiveDisplayed(150,1)
Alias_DA16VerenAmbushAlias.GetActorRef().RemoveFromFaction(pDA16Friend)
Alias_DA16VerenAmbushAlias.GetActorRef().AddToFaction(pDA16FoeFaction)
Alias_DA16ThorekAmbushAlias.GetActorRef().RemoveFromFaction(pDA16Friend)
Alias_DA16ThorekAmbushAlias.GetActorRef().AddToFaction(pDA16FoeFaction)
; Modified by Requiem:
; Moved aggresion changes after faction changes to prevent Veren from attacking Thorek
Alias_DA16VerenAmbushAlias.GetActorRef().SetAv("Aggression", 2)
Alias_DA16ThorekAmbushAlias.GetActorRef().SetAv("Aggression", 2)
Alias_DA16VerenAmbushAlias.GetActorRef().StartCombat(Game.GetPlayer())
Alias_DA16ThorekAmbushAlias.GetActorRef().StartCombat(Alias_ErandurAlias.GetActorRef())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_122
Function Fragment_122()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Confrontation Done, Speak to Erandur
pErandurBase.SetInvulnerable()
SetObjectiveCompleted(150,1)
SetObjectiveDisplayed(160,1)
Alias_ErandurAlias.GetActorRef().RemoveFromFaction(pDA16ErandurFaction)
Alias_ErandurAlias.GetActorRef().SetPlayerTeammate(abTeammate = false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_120
Function Fragment_120()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Wake Up From Dreamstate Setup
utility.wait(6.0)
Alias_ErandurAlias.GetActorRef().SetPlayerTeammate(abCanDoFavor=false)
Game.EnablePlayerControls()
Game.SetInChargen(false, false, false)
kmyQuest.pDA16DreamSetup.Disable()
Alias_VerenAlias.GetActorReference().Disable()
Alias_ThorekAlias.GetActorReference().Disable()
Game.GetPlayer().MoveTo(kmyQuest.pDA16PlayerEndDream)
kmyquest.DA16DreamActorEnableMarker.disable(self)
kmyquest.DA16PresentActorEnableMarker.enable(self)
kmyquest.DA16PresentPostDreamActorEnableMarker.enable(self)
imageSpaceModifier.removeCrossfade(1.0)
setstage(160)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Player finished talking to Erandur
SetObjectiveCompleted (28,1)
SetObjectiveDisplayed(30,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_138
Function Fragment_138()
;BEGIN CODE
;Erandur has been killed
SetObjectiveCompleted (170,1)
SetObjectiveDisplayed(180,0)
SetObjectiveDisplayed(190,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur arrives at defensive gates for first time
SetObjectiveCompleted (30,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_129
Function Fragment_129()
;BEGIN CODE
;Scene is done in Windpeak Inn, Free all NPCs!
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_101
Function Fragment_101()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Speak to Erandur with Torpor in hand
SetObjectiveCompleted (70,1)
SetObjectiveDisplayed(80,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_110
Function Fragment_110()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Speak to Erandur after gates are open
SetObjectiveCompleted (120,1)
SetObjectiveDisplayed(130,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_118
Function Fragment_118()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Drinking Torpor Handler Stage and Setup
;It would be good to have something here to force the menu to close
utility.wait(0) ;This is to force it to wait till the player exits the inventory
Alias_ErandurAlias.GetActorRef().SetPlayerTeammate(false)
Game.ForceFirstPerson()
Game.DisablePlayerControls(true,true,true,false,true,true,true,false)
Game.SetInChargen(false, true, false)
kmyQuest.pDA16DreamSetup.Enable()
Alias_VerenAlias.GetActorReference().Enable()
Alias_ThorekAlias.GetActorReference().Enable()
Game.GetPlayer().MoveTo(kmyQuest.pDA16PlayerStartDream)
Alias_ErandurAlias.getActorRef().Moveto(kmyQuest.pDA16ErandurMarker)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
kmyquest.DA16DreamActorEnableMarker.enable(self)
kmyquest.DreamISMD.applyCrossfade(1.0)
kmyquest.DA16PresentActorEnableMarker.disable(self)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_74
Function Fragment_74()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Start the Scene in Windspeak Inn (Trigger)
kmyQuest.pDA16InitScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_94
Function Fragment_94()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Give Tome/Speak to Erandur
SetObjectiveCompleted (55,1)
SetObjectiveDisplayed(57,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_116
Function Fragment_116()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur allowed to live
pSkullPedestal.Disable()
pDA16SkullDestroyed.Value = 1
Alias_ErandurAlias.GetActorRef().EvaluatePackage()
SetObjectiveCompleted (180,1)
SetObjectiveDisplayed(170,0)
SetObjectiveDisplayed(200,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_98
Function Fragment_98()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur Forcegreets
SetObjectiveCompleted (60,1)
SetObjectiveDisplayed(65,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_108
Function Fragment_108()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Lower Barrier (Non-Dream)
SetObjectiveCompleted (110,1)
SetObjectiveDisplayed(120,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_114
Function Fragment_114()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Make the choice!
pRitualScene02.Start()
pSkullCollision.Disable()
kmyQuest.pDA16Erandur.SetEssential(false)
pErandurBase.SetInvulnerable(false)
SetObjectiveCompleted (165,1)
SetObjectiveDisplayed(170,1)
SetObjectiveDisplayed(180,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_141
Function Fragment_141()
;BEGIN CODE
pDA16SkullHandler.SetStage(10)
AchievementsQuest.IncDaedricQuests()
AchievementsQuest.IncDaedricArtifacts()
completeallobjectives()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_137
Function Fragment_137()
;BEGIN CODE
;Allow Barrier to Fall
SetObjectiveCompleted(160,1)
SetObjectiveDisplayed(165,1)
pRitualScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_67
Function Fragment_67()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
Alias_ErandurAlias.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 1)
SetObjectiveCompleted (200,1)
AchievementsQuest.IncDaedricQuests()
completeallobjectives()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_106
Function Fragment_106()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Activate Miasma (in Dream)
SetObjectiveCompleted (100,1)
SetObjectiveDisplayed(110,1)
Alias_VerenAlias.GetActorReference().EvaluatePackage()
Alias_ThorekAlias.GetActorReference().EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_91
Function Fragment_91()
;BEGIN AUTOCAST TYPE DA16QuestScript
Quest __temp = self as Quest
DA16QuestScript kmyQuest = __temp as DA16QuestScript
;END AUTOCAST
;BEGIN CODE
;Erandur to Library
pLDT.Enable()
SetObjectiveDisplayed(40,1)
Alias_ErandurAlias.getActorRef().EvaluatePackage()
RegisterForSingleUpdate(1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ObjectReference Property pDA16ErandurMeetingMarker  Auto
ObjectReference Property pLDT  Auto  
ObjectReference Property pConfrontEnabler  Auto  
Faction Property pDA16Friend  Auto  
Faction Property pDA16FoeFaction  Auto  
DA16QuestScript Property pDA16QS  Auto  
ObjectReference Property pSkullCollision  Auto  
ObjectReference Property pSkullShield  Auto  
ObjectReference Property pErandur  Auto  
ObjectReference Property pSkullPedestal  Auto  
Scene Property pRitualScene  Auto  
Scene Property pRitualScene02  Auto  
GlobalVariable Property pDA16Walk  Auto
GlobalVariable Property pDA16ErandurDead Auto
GlobalVariable Property pDA16SkullDestroyed  Auto  
Scene Property pDA16InHeadScene  Auto  

Quest Property pDA16SkullHandler  Auto  

Faction Property pDA16ErandurFaction  Auto  

ActorBase Property pErandurBase  Auto  

AchievementsScript Property AchievementsQuest  Auto  

ActorBase Property pThorek_Ambush  Auto  

ActorBase Property pVerenDuleri_Ambush  Auto  

GlobalVariable Property pDLC1VampireLordDisallow  Auto  
