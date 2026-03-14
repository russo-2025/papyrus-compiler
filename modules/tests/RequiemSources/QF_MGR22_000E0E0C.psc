;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname QF_MGR22_000E0E0C Extends Quest Hidden

;BEGIN ALIAS PROPERTY Urag
;ALIAS PROPERTY TYPE referencealias
referencealias Property Alias_Urag Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN AUTOCAST TYPE MGR22QuestScript
Quest __temp = self as Quest
MGR22QuestScript kmyQuest = __temp as MGR22QuestScript
;END AUTOCAST
;BEGIN CODE
kmyQuest.RegisterforUpdateGameTime(3)
SetStage(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
MGR21.Start()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN AUTOCAST TYPE MGR22QuestScript
Quest __temp = self as Quest
MGR22QuestScript kmyQuest = __temp as MGR22QuestScript
;END AUTOCAST
;BEGIN CODE
; REQ-189 - Player gets all scrolls & Shalidor's Mirror, but no skill increase
Game.GetPlayer().AddItem(MGR21ScrollAlteration, 1)
Game.GetPlayer().AddItem(MGR21ScrollConjuration, 1)
Game.GetPlayer().AddItem(MGR21ScrollDestruction, 1)
Game.GetPlayer().AddItem(MGR21ScrollIllusion, 1)
Game.GetPlayer().AddItem(MGR21ScrollRestoration, 1)
Game.GetPlayer().AddItem(ShalidorsMirror, 1)
kmyQuest.RegisterforUpdateGameTime(6)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN AUTOCAST TYPE MGR22QuestScript
Quest __temp = self as Quest
MGR22QuestScript kmyQuest = __temp as MGR22QuestScript
;END AUTOCAST
;BEGIN CODE
kmyQuest.MGR22RunReward()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

quest Property MGR21  Auto  

Scroll Property MGR21ScrollAlteration Auto  

Scroll Property MGR21ScrollConjuration Auto

Scroll Property MGR21ScrollDestruction Auto

Scroll Property MGR21ScrollIllusion Auto

Scroll Property MGR21ScrollRestoration Auto

Book Property ShalidorsMirror Auto

int Property RewardSuggested  Auto  

Int Property RewardPicked  Auto  

int Property LastReward  Auto  

int Property LastReward2  Auto  

Int Property SkillSuggested  Auto  

int Property SkillPicked  Auto  

Int Property MaxRewardInt  Auto  
