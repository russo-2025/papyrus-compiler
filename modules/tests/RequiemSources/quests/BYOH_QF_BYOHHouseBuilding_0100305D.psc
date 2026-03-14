;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 13
Scriptname BYOH_QF_BYOHHouseBuilding_0100305D Extends Quest Hidden

;BEGIN ALIAS PROPERTY House1LumberVendor
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House1LumberVendor Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House3Lumbermill
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House3Lumbermill Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House2LogPileActivator
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House2LogPileActivator Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House2Lumbermill
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House2Lumbermill Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY LumbermillOperator
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_LumbermillOperator Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House1Lumbermill
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House1Lumbermill Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY LumbermillMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_LumbermillMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House3LumberVendor
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House3LumberVendor Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House2Steward
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House2Steward Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MiscVendorChest2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MiscVendorChest2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House2LumberVendor
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House2LumberVendor Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House3Steward
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House3Steward Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House3LogPileActivator
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House3LogPileActivator Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MiscVendorChest1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MiscVendorChest1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MiscVendorChest3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MiscVendorChest3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY LumbermillLocation
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_LumbermillLocation Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House1Steward
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House1Steward Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY House1LogPileActivator
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_House1LogPileActivator Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
; complete lumber objective
SetObjectiveCompleted(100)
; clear lumber vendor aliases
Alias_House1LumberVendor.Clear()
Alias_House2LumberVendor.Clear()
Alias_House3LumberVendor.Clear()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
; lumber mill objective - Hjaalmarch
SetObjectiveDisplayed(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN AUTOCAST TYPE BYOHhousebuildingscript
Quest __temp = self as Quest
BYOHhousebuildingscript kmyQuest = __temp as BYOHhousebuildingscript
;END AUTOCAST
;BEGIN CODE
; enable all furniture in house 1
kmyQuest.EnableAllFurniture(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN AUTOCAST TYPE BYOHhousebuildingscript
Quest __temp = self as Quest
BYOHhousebuildingscript kmyQuest = __temp as BYOHhousebuildingscript
;END AUTOCAST
;BEGIN CODE
; enable all furniture in house 3
kmyQuest.EnableAllFurniture(2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN AUTOCAST TYPE BYOHhousebuildingscript
Quest __temp = self as Quest
BYOHhousebuildingscript kmyQuest = __temp as BYOHhousebuildingscript
;END AUTOCAST
;BEGIN CODE
; enable all furniture in house 2
kmyQuest.EnableAllFurniture(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE BYOHhousebuildingscript
Quest __temp = self as Quest
BYOHhousebuildingscript kmyQuest = __temp as BYOHhousebuildingscript
;END AUTOCAST
;BEGIN CODE
; is player already friends with one of the jarls? If so, send a courier
kmyQuest.InitializeDLC()

; set up faction relations with player
BYOHHouse1Faction.SetAlly(PlayerFaction)
BYOHHouse2Faction.SetAlly(PlayerFaction)
BYOHHouse3Faction.SetAlly(PlayerFaction)

; add inventory filter to player alias
Alias_Player.AddInventoryEventFilter(BYOHMaterialLog)

; Disabled by Requiem
; ; add new items to lists
; LItemMiscVendorMiscItems75.AddForm(BYOHMaterialStraw, 1, 2)
; LItemMiscVendorMiscItems75.AddForm(BYOHMaterialGlass, 1, 2)

; ; add flour to food containers
; LItemBarrelFoodSame70.AddForm(BYOHLItemFoodFlour, 1, 1)
; LItemBarrelFoodSameSmall.AddForm(BYOHLItemFoodFlourSmall, 1, 1)

; ; add flour and milk and butter to food lists
; LItemFoodInnCommon.AddForm(BYOHFoodFlour, 1, 1)
; LItemFoodInnCommon10.AddForm(BYOHFoodFlour, 1, 1)

; LItemFoodInnCommon.AddForm(BYOHFoodMilk, 1, 1)
; LItemFoodInnCommon10.AddForm(BYOHFoodMilk, 1, 1)
; LItemFoodRawNoMeat.AddForm(BYOHFoodMilk, 1, 1)

; LItemFoodInnCommon.AddForm(BYOHFoodButter, 1, 1)
; LItemFoodInnCommon10.AddForm(BYOHFoodButter, 1, 1)
; LItemFoodRawNoMeat.AddForm(BYOHFoodButter, 1, 1)

; ; add new wines to vendor lists
; LItemInnRuralDrink.AddForm(BYOHLItemInnRuralDrinkNewWines, 1, 1)

; add lumber vendors to faction (for dialogue conditions)
kmyQuest.InitializeLumberVendorFaction()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
; lumber mill objective - The Pale
SetObjectiveDisplayed(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
; lumber mill objective - Falkreath
SetObjectiveDisplayed(100)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ReferenceAlias Property JarlFalkreath  Auto  

ReferenceAlias Property JarlHjaalmarch  Auto  

ReferenceAlias Property JarlPale  Auto  

WICourierScript Property WICourier  Auto  

Faction Property PlayerFaction  Auto  

Faction Property BYOHHouse1Faction  Auto  

Faction Property BYOHHouse2Faction  Auto  

Faction Property BYOHHouse3Faction  Auto  

LeveledItem Property LItemMiscVendorMiscItems75  Auto  

MiscObject Property BYOHMaterialGlass  Auto  

MiscObject Property BYOHMaterialStraw  Auto  

Faction Property BYOHLumberVendorFaction  Auto  

MiscObject Property BYOHMaterialLog  Auto  

LeveledItem Property LItemBarrelFoodSame70  Auto  

LeveledItem Property BYOHLItemFoodFlour  Auto  

LeveledItem Property BYOHLItemFoodFlourSmall  Auto  

LeveledItem Property LItemBarrelFoodSameSmall  Auto  

LeveledItem Property LItemFoodInnCommon  Auto  

LeveledItem Property LItemFoodInnCommon10  Auto  

Potion Property BYOHFoodFlour  Auto  

Potion Property BYOHFoodMilk  Auto  

LeveledItem Property LItemFoodRawNoMeat  Auto  

Potion Property BYOHFoodButter  Auto  

Potion Property BYOHFoodWineBottle03  Auto  

Potion Property BYOHFoodWineBottle04  Auto  

LeveledItem Property LItemInnRuralDrink  Auto  

LeveledItem Property BYOHLItemInnRuralDrinkNewWines  Auto  
