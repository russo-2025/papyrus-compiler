;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 14
Scriptname QF_FreeformRiftenThane_00065BDF Extends Quest Hidden

;BEGIN ALIAS PROPERTY FFRiftenThaneAnurielStewardAlias
;ALIAS PROPERTY TYPE referencealias
referencealias Property Alias_FFRiftenThaneAnurielStewardAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FFRiftenThaneHemmingStewardAlias
;ALIAS PROPERTY TYPE referencealias
referencealias Property Alias_FFRiftenThaneHemmingStewardAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FFRiftenThaneLailaJarlAlias
;ALIAS PROPERTY TYPE referencealias
referencealias Property Alias_FFRiftenThaneLailaJarlAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FFRiftenThaneMavenJarlAlias
;ALIAS PROPERTY TYPE referencealias
referencealias Property Alias_FFRiftenThaneMavenJarlAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FFRiftenThaneJarlWeaponAlias
;ALIAS PROPERTY TYPE referencealias
referencealias Property Alias_FFRiftenThaneJarlWeaponAlias Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;Quest Completed
;enable Housecarl and guest bedroom
if Alias_FFRiftenThaneLailaJarlAlias.GetActorReference().IsInFaction(pJobJarlFaction)
pFavorJarlsMakeFriends.GetOutofJailCard(Alias_FFRiftenThaneLailaJarlAlias.GetActorRef())
elseif Alias_FFRiftenThaneMavenJarlAlias.GetActorReference().IsInFaction(pJobJarlFaction)
pFavorJarlsMakeFriends.GetOutofJailCard(Alias_FFRiftenThaneMavenJarlAlias.GetActorRef())
endif
Alias_FFRiftenThaneJarlWeaponAlias.GetRef().Enable()
Game.GetPlayer().AddItem(Alias_FFRiftenThaneJarlWeaponAlias.GetRef())
GuestBedroom.Enable()
Housecarl.Enable()
CompleteAllObjectives()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
;Player owns the house
SetObjectiveCompleted(20, 1)
SetObjectiveDisplayed(30,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Quest Startup - Listening for variables from all FFRiftHold and FFRiftenQuests
;To be eligible for this, player has to complete 5 FF Quests + the Skooma Clear (any order)
if Alias_FFRiftenThaneLailaJarlAlias.GetActorReference().IsInFaction(pJobJarlFaction)
Alias_FFRiftenThaneLailaJarlAlias.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 3) ; USSEP 4.2.9 Bug #31736
elseif Alias_FFRiftenThaneMavenJarlAlias.GetActorReference().IsInFaction(pJobJarlFaction)
Alias_FFRiftenThaneMavenJarlAlias.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 3) ; USSEP 4.2.9 Bug #31736
endif
SetObjectiveDisplayed(10,1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;Go purchase house!
SetObjectiveCompleted(10,1)
SetObjectiveDisplayed(20,1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ObjectReference Property GuestBedroom  Auto  

Actor Property Housecarl  Auto  

FavorJarlsMakeFriendsScript Property pFavorJarlsMakeFriends  Auto

Faction Property pJobJarlFaction  Auto  
