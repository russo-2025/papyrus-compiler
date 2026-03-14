Scriptname BYOHHouseBuildingScript extends Quest  Conditional
{script for BYOHHouseBuilding quest}

int Property activeHouseLocation  Auto  Conditional
{current house location (set by scripts on workbenches)
0 = Falkreath
1 = The Pale
2 = Hjaalmarch
}

int Property activeRoomID Auto
{ current room ID - used for interior workbenches
(set by script on workbenches)
}

string Property activeVariantID Auto
{ current room variant ID - used for interior workbenches
(set by script on workbenches)
format is "A", "B", etc.
}


;ADOPTION SYSTEM CROSS-DLC TRANSFER
;The following objects and lists in this DLC need to send or receive data from other DLCs.
Formlist property BYOHRelationshipAdoptionPlayerGiftChildMale Auto
Formlist property BYOHRelationshipAdoptionPlayerGiftChildFemale Auto
Formlist property BYOHRelationshipAdoption_PetAllowedRacesList Auto
Formlist property BYOHRelationshipAdoption_PetDogsList Auto

String Property sDLC01Filename = "Dawnguard.esm" Auto
{ name of DLC01 esm }

function SetActiveHouseLocation(ObjectReference workbench, int newRoomID, string newVariantID)
	;debug.trace(self + "SetActiveHouseLocation: workbench=" + workbench + ", newRoomID=" + newRoomID + ", newVariantID=" + newVariantID)
	;debug.trace(self + "workbench location=" + workbench.GetCurrentLocation())
;	activeHouseLocation = newHouseLocation
	activeRoomID = newRoomID
	activeVariantID = newVariantID

	; get current location
	int locIndex = 0
	while locIndex < HouseLocations.Length
		if workbench.GetCurrentLocation().IsSameLocation(HouseLocations[locIndex], BYOHHouseLocationKeyword)
			;debug.trace(self + "SetActiveHouseLocation: current location = " + houselocations[locIndex])
			activeHouseLocation = locIndex
			locIndex = HouseLocations.Length
		endif
		locIndex = locIndex + 1
	endWhile

	; SPECIAL HANDLING
	; swap deerhide02 for deerhide (to avoid duplicating recipes in crafting menu)
	;UHFP 2.0.6 - This special handling has been disabled because there are recipes in HF that make use of DeerHide02 which makes stealing it from you rather stupid.
	;In addition, this is needlessly used even when using the benches outside that don't care about deer and elk hides.
	;actor player = Game.GetPlayer()
	;int deerhide02Count = player.GetItemCount(DeerHide02)
	;if deerhide02Count > 0
	;	player.removeItem(deerhide02, deerhide02Count, true)
	;	player.additem(deerhide, deerhide02Count, true)
	;endif
endFunction

; call this function when the player buys the house property (called from the House quest script)
function BuyProperty(int newHouseLocation)
	houseOwned[newHouseLocation] = true
endFunction

; specialized function for when the player remodels starting cabin into entry room of main hall
function RemodelEntryRoom(int partHouseLocation, int partID)
	(HouseQuests[partHouseLocation] as BYOHHouseScript).RemodelEntryRoom(partID)
endFunction

; called by trophy base to set current trophy base marker
function SetTrophyBase(ObjectReference newTrophyBase, ObjectReference newTrophyBuildMarker, ObjectReference newTrophyIdleMarker = None)
	TrophyBase = newTrophyBase
	TrophyBuildMarker = newTrophyBuildMarker
	TrophyIdleMarker = newTrophyIdleMarker
endfunction

; called when "trophy" is crafted by player from trophy base workbench (trophy = posed stuffed animal for Trophy Room)
function BuildTrophy(int partID)
	; get index of this part from trophy master list
	int newHousePartIndex = GetFormListIndex(BYOHHouseBuildingTrophyMasterList, partID)
	if newHousePartIndex > -1
		;debug.trace(self + "BuildTrophy - found index = " + newHousePartIndex)
		if TrophyBuildMarker
			; place trophy at build marker
			TrophyBuildMarker.PlaceAtMe(BYOHHouseBuildingTrophyPlaceList.GetAt(newHousePartIndex))
			; mark workbench as destroyed so it can't be used again
			TrophyBase.SetDestroyed(true)
			; enable idle marker
			if TrophyIdleMarker
				TrophyIdleMarker.enableNoWait()
			endif
		else
			;debug.trace(self + "BuildTrophy: NO TROPHY MARKER")
		endif
	else
		;debug.trace(self + "BuildTrophy: UNKNOWN HOUSE PART")
	endif
	; in case logs were used (inventory events don't fire when items are removed but not dropped into the world)
	UpdateLogCount()
endFunction

; this function is for building stuff in the exterior, not the house itself (stable, animal pens, etc.)
function BuildHouseExteriorPart(int partHouseLocation, int partID, form part)
	;debug.trace(self + "BuildHousExteriorPart " + partID + " " + part)

	FormList foundList
;	if activeHouseLocation >=0 && activeHouseLocation <=2
		; get index of this part from exterior master list
		int newHousePartIndex = GetFormListIndex(ExteriorMasterList, partID, part)
		if newHousePartIndex > -1
			;debug.trace(self + "BuildHouseExteriorPart - found index = " + newHousePartIndex)
			(HouseQuests[partHouseLocation] as BYOHHouseScript).BuildHouseExteriorPart(newHousePartIndex)
		else
			;debug.trace(self + "BuildHouseExteriorPart : UNKNOWN HOUSE PART")
		endif
;	endif
	; in case logs were used (inventory events don't fire when items are removed but not dropped into the world)
	UpdateLogCount()
endFunction


function BuildHouseInteriorPart(int partHouseLocation, int partID, form part, int roomID)
	;debug.trace(self + "BuildHouseInteriorPart roomID=" + roomID + ", partID=" + partID)
	; what is it right now?
	string currentVariantID = activeVariantID

	FormList foundList
	if roomID ==1
		if currentVariantID == "A"
			foundList = RoomMasterLists[0]
		elseif currentVariantID == "B"
			foundList = RoomMasterLists[1]
		endif
	else
		foundList = RoomMasterLists[roomID]
	endif

	if foundList == None
		;debug.trace(self + "BuildHouseInteriorPart: FAILED TO FIND MATCHING MASTER LIST")
		return
	endif

	; get index of this part from correct master list
	int newHousePartIndex = GetFormListIndex(foundList, partID, part)
	if newHousePartIndex > -1
		;debug.trace(self + "BuildHouseInteriorPart - found index = " + newHousePartIndex)
		(HouseQuests[partHouseLocation] as BYOHHouseScript).BuildHouseInteriorPart(roomID, currentVariantID, newHousePartIndex)
		; check if parts of the house have been completed (e.g. for children, spouse, etc.)
		UpdateCompletionStatus( (HouseQuests[partHouseLocation] as BYOHHouseScript), roomID, partID )
	else
		;debug.trace(self + "BuildHouseInteriorPart: UNKNOWN HOUSE PART")
	endif
	; in case logs were used (inventory events don't fire when items are removed but not dropped into the world)
	UpdateLogCount()
endFunction

function UpdateCompletionStatus (BYOHHouseScript houseQuest, int roomID, int partID)
	; check for spouse
	if houseQuest.bAllowSpouse == false
		if roomID == 1
			;debug.trace(self + " checking for Room 1 spouse items")
			; is this one of the needed IDs?
			if CheckCompletionStatus(SpouseIDsRoom1, SpouseIDsRoom1Count, partID)
				;debug.trace(self + " Room 1 spouse items COMPLETE")
				houseQuest.bAllowSpouse = true
				; tell adoption to update
				RelationshipAdoptable.UpdateHouseStatus()
			endif
		elseif roomID == 2
			;debug.trace(self + " checking for Room 2 spouse items")
			; is this one of the needed IDs?
			if CheckCompletionStatus(SpouseIDsRoom2, SpouseIDsRoom2Count, partID)
				;debug.trace(self + " Room 2 spouse items COMPLETE")
				houseQuest.bAllowSpouse = true
				; tell adoption to update
				RelationshipAdoptable.UpdateHouseStatus()
			endif
		elseif roomID == 3
			;debug.trace(self + " checking for Room 3 spouse items")
			; is this one of the needed IDs?
			if CheckCompletionStatus(SpouseIDsRoom3, SpouseIDsRoom3Count, partID)
				;debug.trace(self + " Room 3 spouse items COMPLETE")
				houseQuest.bAllowSpouse = true
				; tell adoption to update
				RelationshipAdoptable.UpdateHouseStatus()
			endif
		endif
	endif
	; check for children
	if houseQuest.bAllowChildren == false
		if roomID == 2
			;debug.trace(self + " checking for Room 2 child items")
			; is this one of the needed IDs?
			if CheckCompletionStatus(ChildIDsRoom2, ChildIDsRoom2Count, partID)
				;debug.trace(self + " Room 2 child items COMPLETE")
				houseQuest.bAllowChildren = true
				; tell adoption to update
				RelationshipAdoptable.UpdateHouseStatus()
				; update adoption scheduler
				RelationshipAdoption.QueueMoveFamily(RelationshipAdoption.currentHome, true)
			endif
		endif
	endif

	; check for children moving to room 3
	if houseQuest.bAllowChildren == false || houseQuest.bChildrenRoom3 == false
		if roomID == 3
			;debug.trace(self + " checking for Room 3 child items")
			; is this one of the needed IDs?
			if CheckCompletionStatus(ChildIDsRoom3, ChildIDsRoom3Count, partID)
				;debug.trace(self + " Room 3 child items COMPLETE")
				houseQuest.bAllowChildren = true
				houseQuest.bChildrenRoom3 = true
				; disable room 2 bed markers
				houseQuest.ChildBedRefsRoom2[0].DisableNoWait()
				houseQuest.ChildBedRefsRoom2[1].DisableNoWait()
				; swap child chest in room 2 if enabled
				if houseQuest.ChildChestRoom2.IsDisabled() == false
					houseQuest.ChildChestRoom2.DisableNoWait()
					; enable normal chest in room 2
					houseQuest.ChildChestRoom2Replacement.EnableNoWait()
				endif
				; move everything into the new chest, keeping ownership
				houseQuest.childChestRoom2.RemoveAllItems(houseQuest.ChildChestRoom2Replacement, true)
				; tell adoption to update
				RelationshipAdoptable.UpdateHouseStatus()
				; update adoption scheduler
				RelationshipAdoption.QueueMoveFamily(RelationshipAdoption.currentHome, true)
			endif
		endif
	endif
endFunction

; check for partID in arrayToCheck, increment countValue if found, return TRUE if countValue is same as array length
bool function CheckCompletionStatus(int[] arrayToCheck, int[] countValue,  int partID)
	if FindArrayIndex(arrayToCheck, partID) > -1
		countValue[0] = countValue[0] + 1
		;debug.trace(self + "CheckCompletionStatus: found partID=" + partID + ", countValue=" + countValue[0])
		if countValue[0] >= arrayToCheck.length
			return true
		endif
	endif
	return false
endFunction

int function FindArrayIndex(int[] myArray, int searchValue)
	return myArray.Find(searchValue)
;	int currentElement = 0
;	while (currentElement < myArray.Length)
;		if myArray[currentElement] == searchValue
;			; found - return index
;			return currentElement
;		endif
;		currentElement += 1
;	endWhile
;	; not found:
;	return -1
endFunction

bool bBuildHousePart ; blocking variable for BuildHousePart function

; called when a "house part" is added to player's inventory (pieces of the house itself - floor, walls, roof, etc.)
; (pass in houseLocation rather than using "activeHouseLocation" because this might change before the function finishes)
function BuildHousePart(int partHouseLocation, int newHousePartID, form newHousePart, int finishRoomID, int startRoomID, bool bDisableAdditionLayouts)
	; is someone else using this function?
	while bBuildHousePart
		utility.wait(1.0)
	endWhile

	; set blocking variable
	bBuildHousePart = true

	;debug.trace(self + "BuildHousePart " + newHousePartID + " START")
	BYOHHouseScript myHouse = (HouseQuests[partHouseLocation] as BYOHHouseScript)

	; disable layout pieces?
	if bDisableAdditionLayouts
		myHouse.DisableAdditionLayout()
		actor player = Game.GetPlayer()

		;debug.trace(self + "BuildHousePart: " + newHousePartID + ": give player matching token")
		; find matching item - do this first so we minimize the time the player has neither item ("real" object or token object)
		; give player token that matches the current item
		; NOTE: do it this way to make sure player ends up with only 1 layout token in cases where multiple items are built quickly
		int iCurrentIndex = 0
		Form layoutToken 			; this will be the matching token

		; get index of the layout part from layout list
		int layoutIndex = GetFormListIndex(BYOHHouseBuildingAdditionLayoutList, newHousePartID, newHousePart)
		; save the matching token
		layoutToken = BYOHHouseBuildingAdditionLayoutTOKENList.GetAt(layoutIndex)
		;debug.trace(self + "BuildHousePart: token=" + layoutToken)

;		while iCurrentIndex < BYOHHouseBuildingAdditionLayoutList.GetSize()
;			Form listForm = BYOHHouseBuildingAdditionLayoutList.GetAt(iCurrentIndex )
;			BYOHBuildingObjectScript listObject = listForm as BYOHBuildingObjectScript
;			if listObject.ID == newHousePartID
;				; save the matching token
;				layoutToken = BYOHHouseBuildingAdditionLayoutTOKENList.GetAt(iCurrentIndex)
;				; break out of loop
;				iCurrentIndex = BYOHHouseBuildingAdditionLayoutList.GetSize()
;				debug.trace(self + "BuildHousePart: token=" + layoutToken)
;			endif
;			iCurrentIndex = iCurrentIndex + 1
;		endWhile

		; in case player has left the trigger, remove from the appropriate holding chest
		;debug.trace(self + "BuildHousePart: removing items...")
		myHouse.HouseHoldingChest.RemoveItem(BYOHHouseBuildingAdditionLayoutList, 99, true) ; remove silently
		myHouse.HouseHoldingChest.RemoveItem(BYOHHouseBuildingAdditionLayoutTOKENList, 99, true) ; remove silently
		; then remove everything in the layout lists from the player's inventory - do this second to minimize the time that the player has neither
		player.RemoveItem(BYOHHouseBuildingAdditionLayoutList, 99, true) ; remove silently
		player.RemoveItem(BYOHHouseBuildingAdditionLayoutTOKENList, 99, true) ; remove silently
		;debug.trace(self + "BuildHousePart: removing items...DONE")

		; give player token
		;debug.trace(self + "BuildHousePart: adding token...")
		myHouse.AddBuildingItemToPlayer(layoutToken)
;		if myHouse.HouseCraftingTrigger.bPlayerInTrigger
;			player.AddItem(layoutToken, 1, true) ; give token item silently
;		else
;			; if player has left trigger, put token in holding chest
;			myHouse.HouseHoldingChest.AddItem(layoutToken, 1, true) ; give token item silently
;		endif
		;debug.trace(self + "BuildHousePart: adding token...DONE")

	endif

	; get index of this part from master list
	int newHousePartIndex = GetFormListIndex(BuildingMasterList, newHousePartID, newHousePart)
	if newHousePartIndex > -1
		;debug.trace(self + "BuildHousePart " + newHousePartID + " - found index = " + newHousePartIndex)
		myHouse.BuildHousePart(newHousePartIndex, finishRoomID, startRoomID)
		
		; special cases
		if startRoomID == 2
			;debug.trace(self + "BuildHousePart " + newHousePartID + "- starting room 2 with part = " + newHousePartID)
			; if we're starting room 2, set the styleIndex on the house quest
			if newHousePartID == iRoom2StyleID[0]
				myHouse.iStyleIndex = 0
			elseif newHousePartID == iRoom2StyleID[1]
				myHouse.iStyleIndex = 1
			elseif newHousePartID == iRoom2StyleID[2]
				myHouse.iStyleIndex = 2
			endif
		endif

		if finishRoomID > 0
			; if this finishes a room, update the scheduler if this is current home
			if RelationshipAdoption.currentHome == partHouseLocation + 6	; BYOH houses are 6-8 in RelationshipAdoption script
				; update adoption scheduler
				RelationshipAdoption.QueueMoveFamily(RelationshipAdoption.currentHome, true)
			endif
			; award achievements if appropriate
			if myHouse.numRoomsCompleted >= 5
				; check if 3 wings have been completed
				if IsHouseComplete(myHouse)
					Game.AddAchievement(63)	; build 3 wings on a house
				endif
				; check to see if all houses are done
				int iHouseIndex = 0
				int iHouseCompleteCount = 0
				while iHouseIndex < HouseQuests.Length
					if IsHouseComplete(HouseQuests[iHouseIndex] as BYOHHouseScript)
						iHouseCompleteCount = iHouseCompleteCount + 1
					endif
					iHouseIndex = iHouseIndex + 1
				endWhile
				; if all houses complete, award achievement 65
				if iHouseCompleteCount >= HouseQuests.Length
					Game.AddAchievement(65)	; build 3 complete houses (all wings)
				endif
			endif
		endif

	else
		debug.trace(self + "BuildHousePart " + newHousePartID + ": UNKNOWN HOUSE PART")
	endif

	; in case logs were used (inventory events don't fire when items are removed but not dropped into the world)
	UpdateLogCount()

	; clear blocking variable
	bBuildHousePart = false
endFunction

; function checks if 3 additions have been built at the specified house - used to check for awarding achievements
; returns true if all 3 have been built (not counting basement)
bool function IsHouseComplete(BYOHHouseScript myHouse)
	FormList roomFlags = myHouse.RoomDoneFlags
	; count how many additions have been completed
	int iAdditionsCompleted = 0

	int iCurrentRoom = 3 		; room 3 is the first addition
	while iCurrentRoom < 12		; room 12 is the basement (which we aren't counting)
		if (roomFlags.GetAt(iCurrentRoom) as GlobalVariable).GetValueInt() >= 1
			iAdditionsCompleted += 1
		endif
		iCurrentRoom = iCurrentRoom + 1
	endWhile

	; house counts as "complete" if 3 addition rooms have been built
	return (iAdditionsCompleted >= 3)
endfunction

; check if time to send a courier at startup
function InitializeDLC()
	actor player = Game.GetPlayer()
	; INITIALIZE CRIME FACTIONS
	; add new crime factions to werewolf hate list
	int iArrayIndex = 0
	while iArrayIndex < CrimeFactions.Length
		WerewolfHateFactions.AddForm(CrimeFactions[iArrayIndex])
		CrimeFactionsList.AddForm(CrimeFactions[iArrayIndex])
		iArrayIndex = iArrayIndex + 1
	endWhile
	
	; turn off dragon attacks on house locations
	int iCurrentLoc = 0
	while iCurrentLoc < HouseLocations.length
		HouseLocations[iCurrentLoc].SetKeywordData(WIDragonsToggle, -1.0)
		iCurrentLoc = iCurrentLoc + 1
	endWhile


	; enable housecarls if appropriate
	; NOTE: Housecarls are granted at Thane level (rank 3)
	; House can be bought at rank 2
	if JarlFalkreath.GetActorRef().GetRelationshipRank(player) >= 3
		HousecarlFalkreath.Enable()
	elseif Favor258Falkreath.IsRunning()
		PlayerHousecarlFalkreath.ForceRefTo(HousecarlFalkreath)
	endif

	if JarlHjaalmarch.GetActorRef().GetRelationshipRank(player) >= 3
		HousecarlHjaalmarch.Enable()
	elseif Favor255Hjaalmarch.IsRunning()
		PlayerHousecarlHjaalmarch.ForceRefTo(HousecarlHjaalmarch)
	endif

	if JarlPale.GetActorRef().GetRelationshipRank(player) >= 3
		HousecarlPale.Enable()
	elseif Favor256Pale.IsRunning()
		PlayerHousecarlPale.ForceRefTo(HousecarlPale)
	endif


endFunction

; this function is called by the player alias script's OnLoad until it finds the vampire hate list from sDLC01Filename
; returns true when the form list is found
function InitializeOtherDLC()
	FormList vampireHateList = (Game.GetFormFromFile(0x0000989F, sDLC01Filename) as FormList)
	if vampireHateList
		;debug.trace(self + " " + sDLC01Filename + " found - Initializing vampire hate list")
		bInitializedOtherDLC = true
		int iArrayIndex = 0
		while iArrayIndex < CrimeFactions.Length
			vampireHateList.AddForm(CrimeFactions[iArrayIndex])
			iArrayIndex = iArrayIndex + 1
		endWhile
		
		;----------------------------------
		;| DLC01 -> Adoption System Setup  | 
		;----------------------------------
		;Add the DLC01 Daggers to the childrens' gift lists.
		Form BYOHDragonboneDagger = Game.GetFormFromFile(0x00014FCB, sDLC01Filename)
		Form BYOHPrelateDagger = Game.GetFormFromFile(0x0001681F, sDLC01Filename)
		BYOHRelationshipAdoptionPlayerGiftChildMale.AddForm(BYOHDragonboneDagger)
		BYOHRelationshipAdoptionPlayerGiftChildFemale.AddForm(BYOHDragonboneDagger)
		BYOHRelationshipAdoptionPlayerGiftChildMale.AddForm(BYOHPrelateDagger)
		BYOHRelationshipAdoptionPlayerGiftChildFemale.AddForm(BYOHPrelateDagger)
		;Add the DLC01 Dawnguard Dogs to the potential pet lists.
		Form BYOHHuskyBareCompanionRace = Game.GetFormFromFile(0x000122B7, sDLC01Filename)
		;Debug.Trace("Adding: " + BYOHHuskyBareCompanionRace)
		BYOHRelationshipAdoption_PetAllowedRacesList.AddForm(BYOHHuskyBareCompanionRace)
		BYOHRelationshipAdoption_PetDogsList.AddForm(BYOHHuskyBareCompanionRace)
		Form BYOHHuskyArmoredCompanionRace = Game.GetFormFromFile(0x00003D01, sDLC01Filename)
		;Debug.Trace("Adding: " + BYOHHuskyArmoredCompanionRace)
		BYOHRelationshipAdoption_PetAllowedRacesList.AddForm(BYOHHuskyArmoredCompanionRace)
		BYOHRelationshipAdoption_PetDogsList.AddForm(BYOHHuskyArmoredCompanionRace)
		
	endif
endfunction

; update amount of player's logs
function UpdateLogCount()
	;debug.trace(self + " UpdateLogCount")
	int logCount = Game.GetPlayer().GetItemCount(BYOHMaterialLog)
	BYOHHouseLogCount.SetValue(logCount)
	UpdateCurrentInstanceGlobal(BYOHHouseLogCount)
	;debug.trace(self + " logcount=" + logcount)
	; enable/disable log piles as appropriate
	int currentElement = 0
	while (currentElement < LogPiles.Length)
		if houseOwned[currentElement]
			if logCount > 0
				if LogPiles[currentElement].IsDisabled()
					;debug.trace(self + " enabling logpile " + LogPiles[currentElement])
				endif
				LogPiles[currentElement].EnableNoWait()
			else
				if LogPiles[currentElement].IsDisabled() == false
					;debug.trace(self + " disabling logpile " + LogPiles[currentElement])
				endif
				LogPiles[currentElement].DisableNoWait()
			endif
		endif
		currentElement += 1
	endWhile
endFunction

; called by startup stage to add lumber vendors to faction
function InitializeLumberVendorFaction()
	; add lumber vendors to faction (for dialogue conditions)
	int currentElement = 0
	while (currentElement < LumberVendors.Length)
		(LumberVendors[currentElement] as Actor).AddToFaction(BYOHLumberVendorFaction)
		currentElement = currentElement + 1
	endWhile

endfunction

function SetLumbermillOperator(ObjectReference NPC)
	; find lumbermill index for this NPC
	int lumbermillIndex = LumberVendors.Find(NPC)
	if lumbermillIndex >= 0
		;ObjectReference marker = 	Game.FindClosestReferenceOfTypeFromRef(ResourceObjectSawmill, NPC, 5000)
		LumbermillMarker.ForceRefTo(Lumbermills[lumbermillIndex])
		LumbermillOperator.ForceRefTo(NPC)
		;debug.trace(self + "LumbermillMarker = " + LumbermillMarker.GetRef() )
		;debug.trace(self + "LumbermillMarker location = " + LumbermillMarker.GetRef().GetEditorLocation() )
		;debug.trace(self + "LumbermillMarker current location = " + LumbermillMarker.GetRef().GetCurrentLocation() )
		LumbermillLocation.ForceLocationTo(LumbermillMarker.GetRef().GetEditorLocation())
		(NPC as actor).EvaluatePackage()
		; register for animation event of log being cut
		RegisterForAnimationEvent(Lumbermills[lumbermillIndex], "MillLogIdleReset")			; log cutting animation complete
	endif
endFunction

function ClearLumbermillOperator()
	;UHFP 2.0.1 - Moved the unregister call up. For obvious reasons one cannot call GetReference() on an alias that's just been cleared.
	UnregisterForAnimationEvent(LumbermillMarker.GetReference(), "MillLogIdleReset")
	LumbermillMarker.Clear()
	LumbermillOperator.Clear()
	LumbermillLocation.Clear()
endFunction


; ************
; Steward functions

function HireSteward(int houseIndex, Actor akNewSteward)
	HouseStewards[houseIndex].ForceRefTo(akNewSteward)
	(HouseQuests[houseIndex] as BYOHhouseScript).bHaveSteward = true
	; dismiss the follower
	; But ONLY if they're actually following you! (sheesh) - UHFP 1.0.3
	if( akNewSteward.IsInFaction(CurrentHireling) )
		DialogueFollower.DismissFollower(0, 0)
	EndIf
endFunction

function DismissSteward(int houseIndex, Actor akSteward)
	; first, check if this actor is currently the steward
	if HouseStewards[houseIndex].GetActorRef() == akSteward
		HouseStewards[houseIndex].Clear()
		(HouseQuests[houseIndex] as BYOHhouseScript).bHaveSteward = false
	endif
endFunction

function HireCarriageDriver(Actor akSteward)
	int houseIndex = GetStewardIndex(akSteward)
	if houseIndex > -1
		(HouseQuests[houseIndex] as BYOHhouseScript).HireCarriageDriver()
	endif
endFunction

function HireBard(Actor akSteward)
	int houseIndex = GetStewardIndex(akSteward)
	if houseIndex > -1
		(HouseQuests[houseIndex] as BYOHhouseScript).HireBard()
	endif
endFunction

;UHFP 1.1.1 - The steward isn't handling dismissing the bard, so we can't actually check the steward, but we still have to know which house this is in.
function DismissBard(Actor akSteward)
	Location PlayerLoc = Game.GetPlayer().GetCurrentLocation()
	int houseIndex = -1
	
	if( PlayerLoc == BYOHHouse1LocationInterior ) ; Lakeview Manor - HouseFalkreath
		houseIndex = 0
	elseif( PlayerLoc == BYOHHouse2LocationInterior ) ; Windstad Manor - HouseHjaalmarch
		houseIndex = 1
	elseif( PlayerLoc == BYOHHouse3LocationInterior ) ; Heljarchen Hall - HousePale
		houseIndex = 2
	Else
		debug.TraceStack( "UHFP: Invalid house location while dismissing bard. Aborting." )
		Return
	EndIf
	
	(HouseQuests[houseIndex] as BYOHhouseScript).bBoughtBard = false
	BardSongs.StopAllSongs() ; UHFP 1.1.1 - Also need to make the BardSongs quest let go, or they'll stick around anyway.
	akSteward.EvaluatePackage() ; UHFP 1.1.1 - This is correct, "akSteward" is actually the bard.
endFunction


function BuyGarden(Actor akSteward)
	int houseIndex = GetStewardIndex(akSteward)
	if houseIndex > -1
		(HouseQuests[houseIndex] as BYOHhouseScript).BuyGarden()
	endif
endFunction

function BuyCow(Actor akSteward)
	int houseIndex = GetStewardIndex(akSteward)
	if houseIndex > -1
		(HouseQuests[houseIndex] as BYOHhouseScript).BuyCow()
	endif
endFunction

function BuyChicken(Actor akSteward)
	int houseIndex = GetStewardIndex(akSteward)
	if houseIndex > -1
		(HouseQuests[houseIndex] as BYOHhouseScript).BuyChicken()
	endif
endFunction

function BuyHorse(Actor akSteward)
	int houseIndex = GetStewardIndex(akSteward)
	if houseIndex > -1
		(HouseQuests[houseIndex] as BYOHhouseScript).BuyHorse()
	endif
endFunction

function BuyBuildingMaterial(Actor akSteward, int iMaterialType)
	; iMaterialType: 0 = Logs, 1 = stone, 2 = clay
	int houseIndex = GetStewardIndex(akSteward)
	;debug.trace(self + " BuyBuildingMaterial from " + akSteward + " for houseIndex=" + houseIndex)
	if iMaterialType == 0
		; remove player's gold
		Game.GetPlayer().RemoveItem(Gold001, BYOHHPCostLogs.GetValueInt())
		; add logs directly to player
		Game.GetPlayer().AddItem(BYOHMaterialLog, BYOHHPAmountLogs.GetValueInt(), true)
	elseif iMaterialType == 1
		; remove player's gold
		Game.GetPlayer().RemoveItem(Gold001, BYOHHPCostStone.GetValueInt())
		; add stone to chest
		;debug.trace(self + " BuyBuildingMaterial: add " + BYOHHPAmountStone + " stone")
		(HouseQuests[houseIndex] as BYOHhouseScript).StewardChest.AddItem(BYOHMaterialStoneBlock, BYOHHPAmountStone.GetValueInt())
	elseif iMaterialType == 2
		; remove player's gold
		Game.GetPlayer().RemoveItem(Gold001, BYOHHPCostClay.GetValueInt())
		; add clay to chest
		;debug.trace(self + " BuyBuildingMaterial: add " + BYOHHPAmountClay + " clay")
		(HouseQuests[houseIndex] as BYOHhouseScript).StewardChest.AddItem(BYOHMaterialClay, BYOHHPAmountClay.GetValueInt())
	endif

endFunction

function BuyRoomFurniture(Actor akSteward, int iRoomID)
	int houseIndex = GetStewardIndex(akSteward)
	;debug.trace(self + " BuyRoomFurniture from " + akSteward + " for roomID=" + iRoomID + ", houseIndex=" + houseIndex)

	BYOHHouseScript myHouseQuest = (HouseQuests[houseIndex] as BYOHhouseScript)
	; get room globals for this house
	FormList roomFlags = myHouseQuest.RoomDoneFlags
	GlobalVariable roomFlag = roomFlags.GetAt(iRoomID) as GlobalVariable
	if roomFlag.GetValueInt() == 1
		; take money
		Game.GetPlayer().RemoveItem(Gold001, (BYOHHouseRoomCostList.GetAt(iRoomID) as GlobalVariable).GetValueInt())
		; set to 2 - room furniture will get enabled OnChangeLocation using EnableRoomFurniture function
		roomFlag.SetValue(2.0)
	endif
endFunction

; call this function to enable a new piece of furniture in each room that is being furnished by the steward
function EnableRoomFurniture(int iHouseIndex)
	;debug.trace(self + "EnableRoomFurniture - checking house index " + iHouseIndex)
	BYOHHouseScript myHouseQuest = (HouseQuests[iHouseIndex] as BYOHhouseScript)
	; get room globals for this house
	FormList roomFlags = myHouseQuest.RoomDoneFlags

	; how many days has player been away? 
	float fLastVisit = 0
	if iHouseIndex == 0
		fLastVisit = BYOHHouse1LastVisit.GetValue()
	elseif iHouseIndex == 1
		fLastVisit = BYOHHouse2LastVisit.GetValue()
	elseif iHouseIndex == 2
		fLastVisit = BYOHHouse3LastVisit.GetValue()
	endif
	;debug.trace(self + "EnableRoomFurniture - last visit = " + fLastVisit)

	float fDaysAway = (GameDaysPassed.GetValue() - fLastVisit)
	;debug.trace(self + "EnableRoomFurniture - days since last visit = " + fDaysAway)

	; loop through room flags, if any are 2 (being worked on), run through that room's enable list and enable one ref
	int iCurrentRoom = 0
	while iCurrentRoom < roomFlags.GetSize()
		float fEnableCount = fDaysAway
		if (roomFlags.GetAt(iCurrentRoom) as GlobalVariable).GetValueInt() == 2
			;debug.trace(self + "EnableRoomFurniture - room " + iCurrentRoom + " being worked on")
			ObjectReference[] roomEnableList = GetRoomEnableList(myHouseQuest, iCurrentRoom)
;			ObjectReference[] roomDisableList = GetRoomDisableList(myHouseQuest, iCurrentRoom)
			FormList roomMasterList = RoomMasterLists[iCurrentRoom]

			; loop through room enable list - if we find anything disabled, enable it
			int iCurrentArrayIndex = 0
			bool bFound = false
			while iCurrentArrayIndex < roomEnableList.length
				if roomEnableList[iCurrentArrayIndex].IsDisabled()
					;debug.trace(self + "EnableRoomFurniture - enabling " + roomEnableList[iCurrentArrayIndex])
					bFound = true
					; enable furniture
					roomEnableList[iCurrentArrayIndex].EnableNoWait()
					; disable from disable list if necessary
;					if roomDisableList && roomDisableList[iCurrentArrayIndex]
;						roomDisableList[iCurrentArrayIndex].Disable()
;					endif
					; need to get this item from the master list so we can get its ID
					BYOHBuildingObjectScript baseObject = roomMasterList.GetAt(iCurrentArrayIndex) as BYOHBuildingObjectScript
					
					; add to room chest so recipe won't be valid any more
					;debug.trace(self + "EnableRoomFurniture - adding " + baseObject + " to " + myHouseQuest.RoomHoldingChests[iCurrentRoom])
					myHouseQuest.RoomHoldingChests[iCurrentRoom].AddItem(baseObject)

					; check if parts of the house have been completed (e.g. for children, spouse, etc.)
					; need check here because UpdateCompletionStatus takes roomID
					if iCurrentRoom < 2
						UpdateCompletionStatus( myHouseQuest, 1, baseObject.ID )
					else
						UpdateCompletionStatus( myHouseQuest, iCurrentRoom, baseObject.ID )
					endif
					; decrement fEnableCount
					fEnableCount = fEnableCount - 1
					if fEnableCount <= 0
						; break out of loop
						iCurrentArrayIndex = roomEnableList.length
					endif
				endif
				iCurrentArrayIndex = iCurrentArrayIndex + 1
			endWhile
			; if we didn't find anything to enable, set global for this room to 3 - done
			if !bFound
				;debug.trace(self + "EnableRoomFurniture - everything in room is enabled. Room is done!")
				(roomFlags.GetAt(iCurrentRoom) as GlobalVariable).SetValue(3.0)
			endif
		endif

		iCurrentRoom = iCurrentRoom + 1
	endWhile
	
endFunction

; call this function to enable all furniture in a specified house
function EnableAllFurniture(int iHouseIndex)
	;debug.trace(self + "EnableAllFurniture - house index " + iHouseIndex)
	BYOHHouseScript myHouseQuest = (HouseQuests[iHouseIndex] as BYOHhouseScript)
	; get room globals for this house
	FormList roomFlags = myHouseQuest.RoomDoneFlags
	; loop through room flags, if any are 1 or 2 (being worked on), run through that room's enable list and enable all refs
	int iCurrentRoom = 1 ; skip small house
	while iCurrentRoom < roomFlags.GetSize()
		if (roomFlags.GetAt(iCurrentRoom) as GlobalVariable).GetValueInt() >= 1
			;debug.trace(self + "EnableRoomFurniture - room " + iCurrentRoom)
			ObjectReference[] roomEnableList = GetRoomEnableList(myHouseQuest, iCurrentRoom)
			FormList roomMasterList = RoomMasterLists[iCurrentRoom]

			; loop through room enable list - if we find anything disabled, enable it
			int iCurrentArrayIndex = 0
			while iCurrentArrayIndex < roomEnableList.length
				if roomEnableList[iCurrentArrayIndex].IsDisabled()
					;debug.trace(self + "EnableRoomFurniture - enabling " + roomEnableList[iCurrentArrayIndex])
					roomEnableList[iCurrentArrayIndex].EnableNoWait()
					; need to get this item from the master list so we can get its ID
					BYOHBuildingObjectScript baseObject = roomMasterList.GetAt(iCurrentArrayIndex) as BYOHBuildingObjectScript
					
					; add to room chest so recipe won't be valid any more

					;debug.trace(self + "EnableRoomFurniture - adding " + baseObject + " to " + myHouseQuest.RoomHoldingChests[iCurrentRoom])
					myHouseQuest.RoomHoldingChests[iCurrentRoom].AddItem(baseObject)

					; check if parts of the house have been completed (e.g. for children, spouse, etc.)
					; need check here because UpdateCompletionStatus takes roomID
					if iCurrentRoom < 2
						UpdateCompletionStatus( myHouseQuest, 1, baseObject.ID )
					else
						UpdateCompletionStatus( myHouseQuest, iCurrentRoom, baseObject.ID )
					endif
				endif
				iCurrentArrayIndex = iCurrentArrayIndex + 1
			endWhile
			;debug.trace(self + "EnableRoomFurniture - everything in room is enabled. Room is done!")
			(roomFlags.GetAt(iCurrentRoom) as GlobalVariable).SetValue(3.0)
		endif

		iCurrentRoom = iCurrentRoom + 1
	endWhile
	
endFunction

ObjectReference[] function GetRoomEnableList(BYOHhouseScript houseQuest, int iRoomID)
	if iRoomID == 0
		; room 1A
		return houseQuest.Room01AEnableList
	elseif iRoomID == 1
		; room 1B
		return houseQuest.Room01BEnableList
	elseif iRoomID == 2
		; room 2
		return houseQuest.Room02EnableList
	elseif iRoomID == 3
		; room 3
		return houseQuest.Room03EnableList
	elseif iRoomID == 4
			; room 4
		return houseQuest.Room04EnableList
	elseif iRoomID == 5
			; room 5
		return houseQuest.Room05EnableList
	elseif iRoomID == 6
			; room 6
		return houseQuest.Room06EnableList
	elseif iRoomID == 7
			; room 7
		return houseQuest.Room07EnableList
	elseif iRoomID == 8
			; room 8
		return houseQuest.Room08EnableList
	elseif iRoomID == 9
			; room 9
		return houseQuest.Room09EnableList
	elseif iRoomID == 10
			; room 10
		return houseQuest.Room10EnableList
	elseif iRoomID == 11
			; room 11
		return houseQuest.Room11EnableList
	elseif iRoomID == 12
			; room 12
		return houseQuest.Room12EnableList
	endif
endFunction

;/
; REMOVED - disable lists aren't being used at all in the interiors
ObjectReference[] function GetRoomDisableList(BYOHhouseScript houseQuest, int iRoomID)
	if iRoomID == 0
		; room 1A
		return houseQuest.Room01ADisableList
	elseif iRoomID == 1
		; room 1B
		return houseQuest.Room01BDisableList
	elseif iRoomID == 2
		; room 2
		return houseQuest.Room02DisableList
	elseif iRoomID == 3
		; room 3
		return houseQuest.Room03DisableList
	elseif iRoomID == 4
			; room 4
		return houseQuest.Room04DisableList
	elseif iRoomID == 5
			; room 5
		return houseQuest.Room05DisableList
	elseif iRoomID == 6
			; room 6
		return houseQuest.Room06DisableList
	elseif iRoomID == 7
			; room 7
		return houseQuest.Room07DisableList
	elseif iRoomID == 8
			; room 8
		return houseQuest.Room08DisableList
	elseif iRoomID == 9
			; room 9
		return houseQuest.Room09DisableList
	elseif iRoomID == 10
			; room 10
		return houseQuest.Room10DisableList
	elseif iRoomID == 11
			; room 11
		return houseQuest.Room11DisableList
	elseif iRoomID == 12
			; room 12
		return houseQuest.Room12DisableList
	endif
endFunction
/;

int function GetStewardIndex(Actor akSteward)
	int houseIndex = 0
	while houseIndex <= HouseQuests.length
		if HouseStewards[houseIndex].GetActorRef() == akSteward
			return houseIndex
		endif
		houseIndex = houseIndex + 1
	endwhile
endFunction


; *****************
; BARD functions

; if asNewInstrument is passed in, change the sInstrument property on the bard; otherwise use the current instrument
function BardPlayInstrumental(Actor akBard, String asNewInstrument = "" )
	if asNewInstrument != ""
		(akBard as BYOHHouseBardScript).sInstrument = asNewInstrument
	endif

	BardSongs.PlaySong(akBard, (akBard as BYOHHouseBardScript).sInstrument )

endFunction

function BardRegisterLocationOwner(Actor akBard)
	if Game.GetPlayer().IsInFaction(CWSonsFaction)
		BardSongs.RegisterLocationOwner(UlfricRef)
	elseif Game.GetPlayer().IsInFaction(CWImperialFaction)
		BardSongs.RegisterLocationOwner(GeneralTulliusRef)
	else
		BardSongs.RegisterLocationOwner(akBard)
	endif
endfunction


; *****************

; helper function to get index that matches form
int function GetFormListIndex(FormList myList, int myID, form myForm = None)
	int currentIndex = 0
;	debug.trace("GetFormListIndex: " + myList + ".GetSize()=" + mylist.getsize())
;	debug.trace("GetFormListIndex: " + myID)
	if myForm && (myForm as BYOHBuildingObjectScript).ID == myID

		; search the fast way
		currentIndex = myList.Find(myForm)
		if currentIndex >= 0
			;debug.trace("GetFormListIndex: FAST SEARCH - FOUND in " + myList + " at " + currentIndex)
			return currentIndex
		endif
	else
		; search the slow way if we only have ID
		while currentIndex < myList.GetSize()
			Form listForm = myList.GetAt(currentIndex)
	;		debug.trace("GetFormListIndex: currentIndex=" + currentIndex + ", form=" + listForm)
			BYOHBuildingObjectScript listObject = listForm as BYOHBuildingObjectScript
	;		debug.trace("GetFormListIndex: currentIndex=" + currentIndex + ", form=" + listObject + ", ID=" + listObject.ID)
			if listObject.ID == myID
				;debug.trace("GetFormListIndex: FOUND in " + myList + " at " + currentIndex)
				return currentIndex
			else
				currentIndex = currentIndex + 1
			endif
		endWhile
	endif
	;debug.trace("GetFormListIndex: " + myID + " NOT FOUND in " + myList)
	return -1
endFunction


; player's script calls this anytime player changes location
function PlayerChangeLocation(Location akOldLoc, Location akNewLoc)
	;debug.trace(self + " PlayerChangeLocation: oldloc=" + akOldLoc + ", newloc=" + akNewLoc)

	; don't trigger two events with same change location
	bool bTriggeredEvent = false

	; what location are we at?
	int iOldLoc = -1
	int iNewLoc = -1

	int iCurrentLoc = 0
	while iCurrentLoc < HouseLocations.length
		if akNewLoc == HouseLocations[iCurrentLoc]
			iNewLoc = iCurrentLoc
		endif
		if akOldLoc == HouseLocations[iCurrentLoc]
			iOldLoc = iCurrentLoc
		endif
		iCurrentLoc = iCurrentLoc + 1
	endWhile

; when player enters interior, make sure swap triggers are disabled
	if akNewLoc == BYOHHouse1LocationInterior
		(HouseQuests[0] as BYOHHouseScript).DisableInteriorSwapTriggers()
	elseif akNewLoc == BYOHHouse2LocationInterior
		(HouseQuests[1] as BYOHHouseScript).DisableInteriorSwapTriggers()
	elseif akNewLoc == BYOHHouse3LocationInterior
		(HouseQuests[2] as BYOHHouseScript).DisableInteriorSwapTriggers()
	endif

	; trigger bandit attacks sometimes when player isn't at home
	if !bTriggeredEvent && iOldLoc == -1 && iNewLoc == -1
		if utility.RandomInt(1, 100) < iBanditAttackPercent && GameDaysPassed.GetValue() > (BYOHLastAttack.GetValue() + fNextAttackDays)
			;debug.trace(self + " sending story event " + BYOHHouseBanditAttackKeyword)
			BYOHHouseBanditAttackKeyword.SendStoryEvent()
			bTriggeredEvent = true
		endif
	endif

	; if Lumbermill alias are filled, check to see if player leaves lumbermill location
	if LumbermillOperator.GetRef()
		;debug.trace(self + " clear lumbermill aliases?")
		; if player goes to no location, or the new location is not the lumbermill location and not a child of it, clear lumbermill aliases
		if !akNewLoc || ( akNewLoc != LumbermillLocation.GetLocation() && !LumbermillLocation.GetLocation().IsChild(akNewLoc) )
			;debug.trace(self + "akNewLoc.IsChild of " + LumbermillLocation.GetLocation() + "? " + LumbermillLocation.GetLocation().IsChild(akNewLoc) )
			;debug.trace(self + " clearing lumbermill aliases - player moved to " + akNewLoc + ", lumbermill loc = " + LumbermillLocation.GetLocation())
			ClearLumbermillOperator()
		else
			; reregister for the lumbermill anim event since this only works if it's loaded
			RegisterForAnimationEvent(LumbermillMarker.GetRef(), "MillLogIdleReset")			; log cutting animation complete
		endif
	endif

	; enable furniture each time player returns to the house
;	if akNewLoc
;		debug.trace(self + " Is " + akNewLoc + " same location as " + akOldLoc + "?" + akNewLoc.IsSameLocation(akOldLoc, BYOHHouseLocationKeyword))
;	endif
;	if akOldLoc
;		debug.trace(self + " Is " + akOldLoc + " same location as " + akNewLoc + "?" + akOldLoc.IsSameLocation(akNewLoc, BYOHHouseLocationKeyword))
;	endif
	if akNewLoc && (!akOldLoc || !akOldLoc.HasKeyword(BYOHHouseLocationKeyword)) && iNewLoc > -1
		EnableRoomFurniture(iNewLoc)

		; trigger skeever infestation sometimes when player returns to house
		if !bTriggeredEvent && utility.RandomInt(1, 100) < iSkeeverInfestPercent
			;debug.trace(self + " sending story event " + BYOHHouseSkeeverInfestationKeyword)
			BYOHHouseSkeeverInfestationKeyword.SendStoryEvent()
			bTriggeredEvent = true
		endif

	endif

	if bSentIntroLetter == false && Game.QueryStat("People Killed") >= iMinIntroLetterLevel
		Actor player = Game.GetPlayer()
		; if player is not friends with any of the jarls AND has zero crimegold, send intro letter
		if JarlFalkreath.GetActorRef().GetRelationshipRank(player) < 2 && JarlHjaalmarch.GetActorRef().GetRelationshipRank(player) < 2 && JarlPale.GetActorRef().GetRelationshipRank(player) < 2
			; send intro letter from Falkreath if player has 0 crimegold with Falkreath
			if JarlFalkreath.GetActorRef().GetCrimeFaction().GetCrimeGold() == 0
				bSentIntroLetter = true
				HouseQuests[0].SetStage(iIntroLetterStage)
			endif
		endif
	endif

	if iNewLoc == 0 || iOldLoc == 0
		; timestamp when player was at house 1
		BYOHHouse1LastVisit.SetValue(GameDaysPassed.GetValue())
	elseif iNewLoc == 1 || iOldLoc == 1
		; timestamp when player was at house 2
		BYOHHouse2LastVisit.SetValue(GameDaysPassed.GetValue())
	elseif iNewLoc == 2 || iOldLoc == 2
		; timestamp when player was at house 3
		BYOHHouse3LastVisit.SetValue(GameDaysPassed.GetValue())
	endif

endFunction

Quest[] Property HouseQuests  Auto  
{array of house quests}

FormList Property BuildingMasterList Auto
{master list of building parts}

FormList Property ExteriorMasterList Auto
{master list of exterior parts}


ObjectReference[] Property LogPiles  Auto  
{array of log piles - enable when player has logs available
}

Bool[] Property houseOwned  Auto  
{array of flags
true for that index = player has bought the property
}

Bool Property bBuildingEnabled  Auto  Conditional
{set to true when the player has bought at least one property
(for simplicity in dialogue conditions)
check houseOwned array for specific houses
}

ReferenceAlias Property LumbermillOperator  Auto  

ReferenceAlias Property LumbermillMarker  Auto  

LocationAlias Property LumbermillLocation  Auto  

Furniture Property ResourceObjectSawmill  Auto 

int Property iLumbermillSawnLogCount = 10 Auto


FormList[] Property RoomMasterLists Auto
{ array of master lists for interior rooms, indexed by room # - except for room 1 special case }

ReferenceAlias Property JarlFalkreath  Auto  

ReferenceAlias Property JarlHjaalmarch  Auto  

ReferenceAlias Property JarlPale  Auto  

; ****************************************************************
; radiant quest stuff:
Location Property BYOHHouse1Location  Auto  
Location Property BYOHHouse2Location  Auto  
Location Property BYOHHouse3Location  Auto  

Location[] Property HouseLocations Auto

Location Property BYOHHouse1LocationInterior  Auto  
Location Property BYOHHouse2LocationInterior  Auto  
Location Property BYOHHouse3LocationInterior  Auto  

Keyword Property BYOHHouseBanditAttackKeyword  Auto  
Keyword Property BYOHHouseSkeeverInfestationKeyword Auto
Keyword Property BYOHHouseLocationKeyword  Auto  

ObjectReference Property HousecarlFalkreath  Auto  
ObjectReference Property HousecarlHjaalmarch  Auto  
ObjectReference Property HousecarlPale  Auto  

ReferenceAlias Property PlayerHousecarlFalkreath  Auto  

ReferenceAlias Property PlayerHousecarlHjaalmarch  Auto  

ReferenceAlias Property PlayerHousecarlPale  Auto  

Quest Property Favor255Hjaalmarch  Auto  

Quest Property Favor256Pale  Auto  

Quest Property Favor258Falkreath  Auto  

; tracking for when house is ready for spouse, children
Int[] Property ChildIDsRoom2  Auto  
{array of interior IDs that must be built for bAllowChildren to be set true on house quest
}

int[] property ChildIDsRoom2Count Auto
{ how many of the required items have been built
NOTE: an array only so it can be passed by ref - deliberately a single element array }

Int[] Property ChildIDsRoom3  Auto  
{array of IDs to trigger move to Room 3}

int[] property ChildIDsRoom3Count Auto
{ how many of the required items have been built
NOTE: an array only so it can be passed by ref - deliberately a single element array }

Int[] Property SpouseIDsRoom1  Auto  
{array of IDs needed to set bAllowSpouse to true on house quest}

int[] property SpouseIDsRoom1Count Auto
{ how many of the required items have been built
NOTE: an array only so it can be passed by ref - deliberately a single element array }

Int[] Property SpouseIDsRoom2  Auto  
{array of IDs needed to set bAllowSpouse to true on house quest}

int[] property SpouseIDsRoom2Count Auto
{ how many of the required items have been built
NOTE: an array only so it can be passed by ref - deliberately a single element array }

Int[] Property SpouseIDsRoom3  Auto  
{array of IDs needed to set bAllowSpouse to true on house quest}

int[] property SpouseIDsRoom3Count Auto
{ how many of the required items have been built
NOTE: an array only so it can be passed by ref - deliberately a single element array }


BYOHRelationshipAdoptableScript Property RelationshipAdoptable  Auto  
BYOHRelationshipAdoptionScript Property RelationshipAdoption  Auto  

GlobalVariable Property BYOHHouse1LastVisit  Auto  
GlobalVariable Property BYOHHouse2LastVisit  Auto  
GlobalVariable Property BYOHHouse3LastVisit  Auto  
GlobalVariable Property GameDaysPassed  Auto  


DialogueFollowerScript Property DialogueFollower Auto

ReferenceAlias[] Property HouseStewards  Auto  
{player stewards (index 0-2)}


int[] Property iRoom2StyleID auto
{ IDs of parts that starts room 2 style A - C (0-2) - used to set the style index on the house quest }

; steward building materials
MiscObject Property BYOHMaterialGlass  Auto  

MiscObject Property BYOHMaterialStraw  Auto  

MiscObject Property BYOHMaterialClay Auto

MiscObject Property BYOHMaterialStoneBlock Auto

MiscObject Property BYOHMaterialLog Auto

MiscObject Property Gold001 Auto

MiscObject Property DeerHide Auto
MiscObject Property DeerHide02 Auto

GlobalVariable Property BYOHHPAmountClay Auto
GlobalVariable Property BYOHHPAmountLogs Auto
GlobalVariable Property BYOHHPAmountStone Auto

GlobalVariable Property BYOHHPCostClay Auto
GlobalVariable Property BYOHHPCostLogs Auto
GlobalVariable Property BYOHHPCostStone Auto

GlobalVariable Property BYOHHouseLogCount Auto

ObjectReference Property TrophyBuildMarker Auto
{ set by trophy base - where to place trophies when built }

ObjectReference Property TrophyIdleMarker Auto
{ set by trophy base - idle marker to enable when trophy is built }

FormList Property BYOHHouseBuildingTrophyMasterList Auto
{ master list of trophy inventory objects }

FormList Property BYOHHouseBuildingTrophyPlaceList Auto
{ list of objects to place in the world when trophies are built - order matches TrophyMasterList }

ObjectReference Property TrophyBase  Auto  
{current trophy base, set by trophy base script when activated}

FormList Property BYOHHouseRoomCostList  Auto  
{list of globals of cost of buying room furnishings
indexed by roomID (room1A = 0, room1B = 1, room 2 = 2, etc.)
}

Int Property iHouseStyles = 1 Auto  Conditional
{number of house styles available (determines which layouts show up for main hall)
}

FormList Property BYOHHouseBuildingRoom01RemodelList  Auto  

FormList Property BYOHHouseBuildingAdditionLayoutList Auto
{ master list of layout inventory objects }

FormList Property BYOHHouseBuildingAdditionLayoutTOKENList Auto
{ matching list of inventory tokens - these get placed in inventory by BuildHousePart function
  these are what the room addition recipes look at instead of the crafted layout objects due to threading issues
 }

int Property iMinIntroLetterLevel = 50 Auto  ; Changed to Misc Stat "People Killed" by Requiem
{ min people killed for player to be sent an "intro letter" from one of the jarls }
int Property iIntroLetterStage = 12 Auto
{ quest stage to set to send intro letter}
int Property iFriendLetterStage = 20 Auto
{ quest stage to set to send friend letter}

bool bSentIntroLetter = false	; set to true when intro letter is sent from jarl
bool bSentFriendLetter = false	; set to true when friend letter is sent from jarl

; Bards
BardSongsScript Property BardSongs Auto
{ BardSongs quest }

; factions are used to test which side player prefers (for bard songs)
Faction Property CWSonsFaction  Auto  
Faction Property CWImperialFaction  Auto  
; use these to pass into BardSongs.RegisterLocationOwner (which uses the location of the actor to determine the CW side)
Actor Property GeneralTulliusRef Auto
Actor Property UlfricRef Auto

; Lumber vendors
ObjectReference[] Property LumberVendors Auto
{array of lumber vendor refs (actors)}
ObjectReference[] Property Lumbermills Auto
{array of lumber mills - index matches with Lumber Vendors array}
Faction Property BYOHLumberVendorFaction  Auto  
{faction to add lumber vendors to at quest startup}

Faction[] Property CrimeFactions  Auto  
{array of crime factions that need to be added to 
vampire and werewolf "hate lists"
}

; crime faction lists
FormList Property WerewolfHateFactions  Auto  
FormList Property CrimeFactionsList  Auto  

bool Property bInitializedOtherDLC Auto
{set to TRUE when able to initialize from other DLC}

int Property iBanditAttackPercent = 10 Auto
int Property iSkeeverInfestPercent = 5 Auto

GlobalVariable Property BYOHLastAttack  Auto  
{timestamp for last time a house attack happened}
float Property fNextAttackDays = 21.0 Auto
{ how many days before another house attack can be triggered}

bool Property bCraftingTriggerBusy Auto
{ set to true when a crafting trigger is giving/removing items to avoid overlapping }
Keyword Property WIDragonsToggle  Auto  

Faction Property CurrentHireling Auto ;Added by UHFP 1.0.3
