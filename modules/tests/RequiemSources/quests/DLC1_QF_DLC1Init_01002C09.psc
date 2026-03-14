;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname DLC1_QF_DLC1Init_01002C09 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE DLC1InitScript
Quest __temp = self as Quest
DLC1InitScript kmyQuest = __temp as DLC1InitScript
;END AUTOCAST
;BEGIN CODE
Debug.Trace("DLC1: Starting DLC1 Initialization quest.")

; Start the NPC stuff
MentalModel.SetStage(0)

; Set up factions and enemy stuff for Vampire Lord
kmyQuest.VampLordFactionSetup()

; werewolf faction fixes
kmyQuest.AddWerewolfCrimeFactions()

; Set up Serana factions
kmyQuest.SetupSerana()

;Do any Trap changes needed.
kmyQuest.SetUpTraps()

;Worldspaces where sun damage shouldn't apply
SunDamageExceptionWorldSpaces.AddForm(DLC1SoulCairn)
SunDamageExceptionWorldSpaces.AddForm(DLC1DarkfallPassageWorld)
SunDamageExceptionWorldSpaces.AddForm(DLC1ForebearsHoldout)
SunDamageExceptionWorldSpaces.AddForm(DLC1AncestorsGlade)
SunDamageExceptionWorldSpaces.AddForm(DLC1Boneyard)

;Weathers that Clear Skies and Storm Call can't change
WeatherExceptionList.AddForm(DLC1Eclipse)
WeatherExceptionList.AddForm(DLC1AurielsBowClearWeather)
WeatherExceptionList.AddForm(DLC1MagicAurielBowCloudyWeather)

;Worldspaces Durnehviir shouldn't be summoned
PreventDurnehviirSummoning.AddForm(DLC1AncestorsGlade)

;Worldspaces Auriel's Bow shouldn't work
PreventAurielsBow.AddForm(DLC1SoulCairn)

; SHUT IT DOWN
Debug.Trace("DLC1: DLC1 Initialization quest done.")
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property MentalModel  Auto  

Race Property DLC1HuskyBareRace  Auto  
Race Property DLC1HuskyArmoredRace  Auto  

Book Property DLC1LD_AetheriumWars  Auto  

LeveledItem Property LItemBookClutter  Auto  

SPELL Property DLC1abCrossbowStagger  Auto  

WorldSpace Property DLC1SoulCairn  Auto  

WorldSpace Property DLC1DarkfallPassageWorld  Auto  

WorldSpace Property DLC1ForebearsHoldout  Auto  

FormList Property SunDamageExceptionWorldSpaces  Auto  

Perk Property DLC1DawnguardItemPerk  Auto  

WorldSpace Property DLC1Boneyard  Auto  

WorldSpace Property DLC1AncestorsGlade  Auto  

Weather Property DLC1AurielsBowClearWeather  Auto  

Weather Property DLC1MagicAurielBowCloudyWeather  Auto  

Weather Property DLC1Eclipse  Auto  

FormList Property WeatherExceptionList  Auto  

FormList Property PreventDurnehviirSummoning  Auto  

FormList Property PreventAurielsBow  Auto  
