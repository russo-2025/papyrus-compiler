ScriptName REQ_Debug_MCMScript Extends SKI_ConfigBase
{MCM for Requiem's test cell}

Actor Property Dummy Auto
Actor Property PlayerREF Auto

FormList Property REQ_List_Alchemy Auto
FormList Property REQ_List_Alteration Auto
FormList Property REQ_List_Block Auto
FormList Property REQ_List_Conjuration Auto
FormList Property REQ_List_Destruction Auto
FormList Property REQ_List_Enchanting Auto
FormList Property REQ_List_Evasion Auto
FormList Property REQ_List_HeavyArmor Auto
FormList Property REQ_List_Illusion Auto
FormList Property REQ_List_Lockpicking Auto
FormList Property REQ_List_Marksmanship Auto
FormList Property REQ_List_OneHanded Auto
FormList Property REQ_List_Pickpocket Auto
FormList Property REQ_List_Restoration Auto
FormList Property REQ_List_Smithing Auto
FormList Property REQ_List_Sneak Auto
FormList Property REQ_List_Speech Auto
FormList Property REQ_List_TwoHanded Auto

GlobalVariable Property GlobalUpdateInterval Auto
GlobalVariable Property GlobalDummyAI Auto
GlobalVariable Property GlobalDummyMovement Auto
GlobalVariable Property GlobalXPTrackerUpdateInterval Auto

Outfit[] Property DummyOutfits Auto

ReferenceAlias Property XPTrackerAlias Auto

String[] Property DummyOutfitNames Auto

Bool ToggleAlchemy
Bool ToggleAlteration
Bool ToggleBlock
Bool ToggleConjuration
Bool ToggleDestruction
Bool ToggleEnchanting
Bool ToggleEvasion
Bool ToggleHeavyArmor
Bool ToggleIllusion
Bool ToggleLockpicking
Bool ToggleMarksmanship
Bool ToggleOneHanded
Bool TogglePickpocket
Bool ToggleRestoration
Bool ToggleSmithing
Bool ToggleSneak
Bool ToggleSpeech
Bool ToggleTwoHanded
Bool ToggleDummyAI = True
Bool ToggleDummyMovement
Bool ToggleXPTracker

Float DefaultValue_XPTrackerUpdateInterval
Float DefaultValue_HealthMonitorUpdateInterval

Int OIDAlchemy
Int OIDAlteration
Int OIDBlock
Int OIDConjuration
Int OIDDestruction
Int OIDEnchanting
Int OIDEvasion
Int OIDHeavyArmor
Int OIDIllusion
Int OIDLockpicking
Int OIDMarksmanship
Int OIDOneHanded
Int OIDPickpocket
Int OIDRestoration
Int OIDSmithing
Int OIDSneak
Int OIDSpeech
Int OIDTwoHanded
Int OIDUpdateInterval
Int OIDDummyAI
Int OIDDummyMovement
Int OIDDummyOutfit
Int OIDXPTracker
Int OIDXPTrackerUpdateInterval
Int DummyOutfitSelection


Event OnConfigInit()
	Pages = new String[3]
	Pages[0] = "Skill"
	Pages[1] = "Debug"
	Pages[2] = "Test Cell"
	ToggleDummyMovement = GlobalDummyMovement.GetValue()
	ToggleDummyAI = GlobalDummyAI.GetValue()
	DefaultValue_XPTrackerUpdateInterval = GlobalXPTrackerUpdateInterval.GetValue()
	DefaultValue_HealthMonitorUpdateInterval = GlobalUpdateInterval.GetValue()
EndEvent


Event OnPageReset(String Page)
	If (Page == "Skill")
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("Master Skill")
		OIDAlchemy = AddToggleOption("Alchemy", ToggleAlchemy)
		OIDAlteration = AddToggleOption("Alteration", ToggleAlteration)
		OIDBlock = AddToggleOption("Block", ToggleBlock)
		OIDConjuration = AddToggleOption("Conjuration", ToggleConjuration)
		OIDDestruction = AddToggleOption("Destruction", ToggleDestruction)
		OIDEnchanting = AddToggleOption("Enchanting", ToggleEnchanting)
		OIDEvasion = AddToggleOption("Evasion", ToggleEvasion)
		OIDHeavyArmor = AddToggleOption("Heavy Armor", ToggleHeavyArmor)
		OIDIllusion = AddToggleOption("Illusion", ToggleIllusion)
		SetCursorPosition(1)
		AddEmptyOption()
		OIDLockpicking = AddToggleOption("Lockpicking", ToggleLockpicking)
		OIDMarksmanship = AddToggleOption("Marksmanship", ToggleMarksmanship)
		OIDOneHanded = AddToggleOption("One Handed", ToggleOneHanded)
		OIDPickpocket = AddToggleOption("Pickpocket", TogglePickpocket)
		OIDRestoration = AddToggleOption("Restoration", ToggleRestoration)
		OIDSmithing = AddToggleOption("Smithing", ToggleSmithing)
		OIDSneak = AddToggleOption("Sneak", ToggleSneak)
		OIDSpeech = AddToggleOption("Speech", ToggleSpeech)
		OIDTwoHanded = AddToggleOption("Two Handed", ToggleTwoHanded)
	ElseIf (Page == "Debug")
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("Health Monitor")
		OIDUpdateInterval = AddSliderOption("Update Interval", GlobalUpdateInterval.GetValue(), "{1}")
		AddHeaderOption("Experience Tracker")
		OIDXPTracker = AddToggleOption("Track Experience", ToggleXPTracker)
		OIDXPTrackerUpdateInterval = AddSliderOption("Update Interval", GlobalXPTrackerUpdateInterval.GetValue(), "{1}")
	ElseIf (Page == "Test Cell")
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("Dummy")
		OIDDummyAI = AddToggleOption("Dummy AI", ToggleDummyAI)
		OIDDummyMovement = AddToggleOption("Dummy Movement", ToggleDummyMovement)
		OIDDummyOutfit = AddMenuOption("Outfit", DummyOutfitNames[DummyOutfitSelection])
	EndIf
EndEvent


Event OnOptionSelect(Int Option)
	If (Option == OIDAlchemy)
		ToggleAlchemy = !ToggleAlchemy
		SetToggleOptionValue(OIDAlchemy, ToggleAlchemy)
		AddPerks(REQ_List_Alchemy)
		PlayerREF.SetActorValue("Alchemy", 100)
	ElseIf (Option == OIDAlteration)
		ToggleAlteration = !ToggleAlteration
		SetToggleOptionValue(OIDAlteration, ToggleAlteration)
		AddPerks(REQ_List_Alteration)
		PlayerREF.SetActorValue("Alteration", 100)
	ElseIf (Option == OIDBlock)
		ToggleBlock = !ToggleBlock
		SetToggleOptionValue(OIDBlock, ToggleBlock)
		AddPerks(REQ_List_Block)
		PlayerREF.SetActorValue("Block", 100)
	ElseIf (Option == OIDConjuration)
		ToggleConjuration = !ToggleConjuration
		SetToggleOptionValue(OIDConjuration, ToggleConjuration)
		AddPerks(REQ_List_Conjuration)
		PlayerREF.SetActorValue("Conjuration", 100)
	ElseIf (Option == OIDDestruction)
		ToggleDestruction = !ToggleDestruction
		SetToggleOptionValue(OIDDestruction, ToggleDestruction)
		AddPerks(REQ_List_Destruction)
		PlayerREF.SetActorValue("Destruction", 100)
	ElseIf (Option == OIDEnchanting)
		ToggleEnchanting = !ToggleEnchanting
		SetToggleOptionValue(OIDEnchanting, ToggleEnchanting)
		AddPerks(REQ_List_Enchanting)
		PlayerREF.SetActorValue("Enchanting", 100)
	ElseIf (Option == OIDEvasion)
		ToggleEvasion = !ToggleEvasion
		SetToggleOptionValue(OIDEvasion, ToggleEvasion)
		AddPerks(REQ_List_Evasion)
		PlayerREF.SetActorValue("lightArmor", 100)
	ElseIf (Option == OIDHeavyArmor)
		ToggleHeavyArmor = !ToggleHeavyArmor
		SetToggleOptionValue(OIDHeavyArmor, ToggleHeavyArmor)
		AddPerks(REQ_List_HeavyArmor)
		PlayerREF.SetActorValue("HeavyArmor", 100)
	ElseIf (Option == OIDIllusion)
		ToggleIllusion = !ToggleIllusion
		SetToggleOptionValue(OIDIllusion, ToggleIllusion)
		AddPerks(REQ_List_Illusion)
		PlayerREF.SetActorValue("Illusion", 100)
	ElseIf (Option == OIDLockpicking)
		ToggleLockpicking = !ToggleLockpicking
		SetToggleOptionValue(OIDLockpicking, ToggleLockpicking)
		AddPerks(REQ_List_Lockpicking)
		PlayerREF.SetActorValue("Lockpicking", 100)
	ElseIf (Option == OIDMarksmanship)
		ToggleMarksmanship = !ToggleMarksmanship
		SetToggleOptionValue(OIDMarksmanship, ToggleMarksmanship)
		AddPerks(REQ_List_Marksmanship)
		PlayerREF.SetActorValue("Marksman", 100)
	ElseIf (Option == OIDOneHanded)
		ToggleOneHanded = !ToggleOneHanded
		SetToggleOptionValue(OIDOneHanded, ToggleOneHanded)
		AddPerks(REQ_List_OneHanded)
		PlayerREF.SetActorValue("OneHanded", 100)
	ElseIf (Option == OIDpickpocket)
		TogglePickpocket = !TogglePickpocket
		SetToggleOptionValue(OIDpickpocket, TogglePickpocket)
		AddPerks(REQ_List_Pickpocket)
		PlayerREF.SetActorValue("Pickpocket", 100)
	ElseIf (Option == OIDRestoration)
		ToggleRestoration = !ToggleRestoration
		SetToggleOptionValue(OIDRestoration, ToggleRestoration)
		AddPerks(REQ_List_Restoration)
		PlayerREF.SetActorValue("Restoration", 100)
	ElseIf (Option == OIDSmithing)
		ToggleSmithing = !ToggleSmithing
		SetToggleOptionValue(OIDSmithing, ToggleSmithing)
		AddPerks(REQ_List_Smithing)
		PlayerREF.SetActorValue("Smithing", 100)
	ElseIf (Option == OIDSneak)
		ToggleSneak = !ToggleSneak
		SetToggleOptionValue(OIDSneak, ToggleSneak)
		AddPerks(REQ_List_Sneak)
		PlayerREF.SetActorValue("Sneak", 100)
	ElseIf (Option == OIDSpeech)
		ToggleSpeech = !ToggleSpeech
		SetToggleOptionValue(OIDSpeech, ToggleSpeech)
		AddPerks(REQ_List_Speech)
		PlayerREF.SetActorValue("Speechchraft", 100)
	ElseIf (Option == OIDTwoHanded)
		ToggleTwoHanded = !ToggleTwoHanded
		SetToggleOptionValue(OIDTwoHanded, ToggleTwoHanded)
		AddPerks(REQ_List_TwoHanded)
		PlayerREF.SetActorValue("TwoHanded", 100)
	ElseIf (Option == OIDDummyAI)
		ToggleDummyAI = !ToggleDummyAI
		SetToggleOptionValue(OIDDummyAI, ToggleDummyAI)
		If (ToggleDummyAI)
			GlobalDummyAI.SetValue(1.0)
		Else
			GlobalDummyAI.SetValue(0.0)
		EndIf
		(Dummy as REQ_Debug_HealthMonitor).ResetDummy()
	ElseIf (Option == OIDDummyMovement)
		ToggleDummyMovement = !ToggleDummyMovement
		SetToggleOptionValue(OIDDummyMovement, ToggleDummyMovement)
		If (ToggleDummyMovement)
			GlobalDummyMovement.SetValue(1.0)
		Else
			GlobalDummyMovement.SetValue(0.0)
		EndIf
		(Dummy as REQ_Debug_HealthMonitor).ResetDummy()
	ElseIf (Option == OIDXPTracker)
		ToggleXPTracker = !ToggleXPTracker
		SetToggleOptionValue(OIDXPTracker, ToggleXPTracker)
		If (ToggleXPTracker)
			(XPTrackerAlias As REQ_Debug_ExperienceTracker).GoToState("Active")
		Else
			(XPTrackerAlias As REQ_Debug_ExperienceTracker).GoToState("")
		EndIf
	EndIf
EndEvent


Event OnoptionSliderOpen(Int Option)
	If (Option == OIDUpdateInterval)
		SetSliderDialogDefaultValue(DefaultValue_HealthMonitorUpdateInterval)
		SetSliderDialogStartValue(GlobalUpdateInterval.GetValue())
		SetSliderDialogRange(0.5, 10.0)
		SetSliderDialogInterval(0.1)
	ElseIf (Option == OIDXPTrackerUpdateInterval)
		SetSliderDialogDefaultValue(DefaultValue_XPTrackerUpdateInterval)
		SetSliderDialogStartValue(GlobalXPTrackerUpdateInterval.GetValue())
		SetSliderDialogRange(0.0, 60.0)
		SetSliderDialogInterval(1.0)
	EndIf
EndEvent


Event OnOptionSliderAccept(Int Option, Float Value)
	If (Option == OIDUpdateInterval)
		SetSliderOptionValue(OIDUpdateInterval, Value)
		GlobalUpdateInterval.SetValue(Value)
	ElseIf (Option == OIDXPTrackerUpdateInterval)
		SetSliderOptionValue(OIDXPTrackerUpdateInterval, Value)
		GlobalXPTrackerUpdateInterval.SetValue(Value)
	EndIf
EndEvent


Event OnOptionMenuOpen(Int Option)
	If (Option == OIDDummyOutfit)
		SetMenuDialogOptions(DummyOutfitNames)
		SetMenuDialogStartIndex(DummyOutfitSelection)
		SetMenuDialogDefaultIndex(0)
	EndIf
EndEvent


Event OnOptionMenuAccept(Int Option, Int Index)
	If (Option == OIDDummyOutfit)
		DummyOutfitSelection = Index
		SetMenuOptionValue(OIDDummyOutfit, DummyOutfitNames[Index])
		Dummy.SetOutfit(DummyOutfits[Index])
	EndIf
EndEvent


Event OnOptionHighlight(Int Option)
	If (Option == OIDDummyMovement)
		SetInfoText("Enable/Disable movement")
	ElseIf (Option == OIDDummyAI)
		SetInfoText("Enable/Disable AI processing of the dummy. This includes any kind of animation (moving, paralyze) and havok processing.")
	ElseIf (Option == OIDDummyAI)
		SetInfoText("Set how many seconds pass before damage taken is calculated after the target has been hit.")
	ElseIf (Option == OIDDummyOutfit)
		SetInfoText("Set the dummy's outfit.")
	EndIf
EndEvent


Function AddPerks(Formlist PerkList)
	Int i = 0
	While (i < PerkList.GetSize())
		PlayerREF.AddPerk(PerkList.GetAt(i) as Perk)
		i += 1
	EndWhile
EndFunction
