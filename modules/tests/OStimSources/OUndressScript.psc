ScriptName OUndressScript Extends Quest

; TODO: Ammo unequip?
OsexIntegrationMain OStim


form[] Property DomEquipmentForms Auto ;in-inventory versions
form[] Property SubEquipmentForms Auto
form[] Property ThirdEquipmentForms Auto


ObjectReference[] Property DomEquipmentDrops Auto ; on-the-ground versions
ObjectReference[] Property SubEquipmentDrops Auto
ObjectReference[] Property ThirdEquipmentDrops Auto


Armor Property FakeArmor Auto

Actor PlayerRef

Actor[] actors

Event OnInit()
	OStim = (Self as Quest) as OsexIntegrationMain
	;FakeArmor = (Game.GetFormFromFile(0x000800, "Ostim.esp")) as Armor


	OnGameLoad()
	PlayerRef = Game.GetPlayer()
EndEvent


Function Strip(Actor Target) ; if you do a strip mid scene, you MUST disable free cam or else! 
	bool bRestoreFreecam = false
	if (target == PlayerRef)
		if OSANative.IsFreeCam()
			bRestoreFreecam = true
			ostim.ToggleFreeCam(false)
			Console("Locking freecam")
		endif 

		outils.lock("mtx_tfc") ; lock free cam, nobody can change it until we say so
	endif 

	If (OStim.TossClothesOntoGround)
		StripAndToss(Target)
	Else
		form[] Things = StoreEquipmentForms(Target)
		if target == actors[0]
			DomEquipmentForms = things 
		elseif target == actors[1]
			SubEquipmentForms = things 
		else 
			ThirdEquipmentForms = things
		endif 
		UnequipForms(Target, Things)
	Endif
	if ostim.AnimationRunning()
		Debug.SendAnimationEvent(Target, "sosfasterect")
	endif 

	if (Target == PlayerRef)
		OSANative.Unlock("mtx_tfc"); now you may change it again.

		if bRestoreFreecam
			console("unlocking freecam")
			ostim.ToggleFreeCam(true)
		endif 
	endif 
EndFunction

Function Redress(Actor Target)
	If Target.IsDead()
		Return
	Endif

	If (OStim.TossClothesOntoGround)
		ObjectReference[] Things
		things = getdrops(target)

		If (OStim.FullyAnimateRedress && (Target != PlayerRef) && !OStim.IsSceneAggressiveThemed()) && !(Target.IsInCombat())
			Form[] Stuff = AddDroppedThingsToInv(Target, Things)
			FullyAnimateRedress(Target, Stuff)
		Else
			PickUpThings(Target, Things)
		EndIf
	Else
		form[] Things
		things = getstuff(target)

		If (OStim.FullyAnimateRedress && (Target != PlayerRef) && !OStim.IsSceneAggressiveThemed()) && !(Target.IsInCombat())
			FullyAnimateRedress(Target, Things)
		Else
			EquipForms(Target, Things)
		EndIf
	endif
EndFunction

ObjectReference[] Function GetDrops(actor target)
	If (Target == actors[0])
		return DomEquipmentDrops
	ElseIf (Target == actors[1])
		return SubEquipmentDrops
	ElseIf (actors.length > 2 && Target == actors[2])
		return ThirdEquipmentDrops
	EndIf
endfunction

Form[] Function GetStuff(actor target)
	If (Target == actors[0])
		return DomEquipmentforms
	ElseIf (Target == actors[1])
		return SubEquipmentforms
	ElseIf (actors.length > 2 && Target == actors[2])
		return ThirdEquipmentforms
	EndIf
endfunction

Function UnequipForms(Actor Target, Form[] Items)
	Int i = 0
	While (i < Items.Length)
		Form Item = Items[i]
		If (Item)
			Target.UnequipItem(Item, False, True)
		EndIf
		i += 1
	EndWhile
EndFunction

Form[] Function StoreEquipmentForms(Actor Target, bool returnOnly = false)
	form[] equipment = PapyrusUtil.FormArray(0)
	int actorID = ostim.getactors().find(target)
	if (actorID != -1) && !returnOnly
		equipment = GetStuff(target)
	endif

	Int i = 0
	Int len = OStim.StrippingSlots.Length
	While (i < len)
		Form Thing = Target.GetEquippedArmorInSlot(OStim.StrippingSlots[i]) as Form ; SE exclusive function
		equipment = PapyrusUtil.PushForm(equipment, thing)
		i += 1
	EndWhile

	equipment = PapyrusUtil.PushForm(equipment, Target.GetEquippedObject(0))
	equipment = PapyrusUtil.PushForm(equipment, Target.GetEquippedObject(1))
	equipment = PapyrusUtil.PushForm(equipment, osanative.GetEquippedAmmo(target)[0])


	return PapyrusUtil.RemoveForm(equipment, none)
EndFunction

Function StripAndToss(Actor Target)
	Int ArrayID = actors.find(target)


	Int i = 0
	Int len = OStim.StrippingSlots.Length
	While (i < len)
		Form Item = Target.GetEquippedArmorInSlot(OStim.Strippingslots[i]) as Form ; SE exclusive function
		if(Item)
			StripAndTossItem(Target, Item, ArrayID)
		endIf
		i += 1
	EndWhile

	Form Obj0 = Target.GetEquippedObject(0)
	If (Obj0)
		StripAndTossItem(Target, Obj0, ArrayID)
	EndIf

	Form Obj1 = Target.GetEquippedObject(1)
	If (Obj1)
		StripAndTossItem(Target, Obj1, ArrayID)
	EndIf

	Form Arrows = osanative.GetEquippedAmmo(target)[0]
	If (arrows)
		StripAndTossItem(Target, arrows, ArrayID)
	EndIf
EndFunction

Function StripAndTossItem(Actor Target, Form Item, Int ArrayID, Bool DoImpulse = True)
	int dropCount = 1
	if item as ammo 
		dropCount = target.GetItemCount(item)
	endif 

	ObjectReference Thing = Target.DropObject(Item, dropCount)

	float offset = 64.0
	;Thing.SetPosition(thingCoords[0] + OSANative.RandomFloat(-offset, offset), thingCoords[1] + OSANative.RandomFloat(-offset, offset), thingCoords[2] + (offset * 1.5))
	thing.MoveTo(target, afXOffset = OSANative.RandomFloat(-offset, offset), afYOffset = OSANative.RandomFloat(-offset, offset),  afZOffset = (offset * 1.5),  abMatchRotation = false)

	If (DoImpulse)
		Thing.ApplyHavokImpulse(osanative.RandomFloat(-2.0, 2.0), osanative.RandomFloat(-2.0, 2.0), osanative.RandomFloat(0.2, 1.8), osanative.RandomFloat(5, 25))
	EndIf

	If (ArrayID == 0) ; store the item for lter
		DomEquipmentDrops = PapyrusUtil.PushObjRef(DomEquipmentDrops, Thing)
	ElseIf (ArrayID == 1)
		SubEquipmentDrops = PapyrusUtil.PushObjRef(SubEquipmentDrops, Thing)
	ElseIf (ArrayID == 2)
		ThirdEquipmentDrops = PapyrusUtil.PushObjRef(ThirdEquipmentDrops, Thing)
	EndIf
EndFunction

Function PickUpThings(Actor Target, ObjectReference[] Items)
	Int i = 0
	While (i < Items.Length)
		ObjectReference Item = Items[i]
		If (Item)
			If (PlayerRef.GetItemCount(Item) < 1)
				Target.AddItem(Item, 1, True)
				Target.EquipItem(Item.GetBaseObject(), False, True)
			endif
		EndIf
		i += 1
	EndWhile
EndFunction

Form[] Function AddDroppedThingsToInv(Actor Target, ObjectReference[] Items)
	Form[] Forms = new Form[1]
	Int i = 0
	While (i < Items.Length)
		ObjectReference Item = Items[i]
		If (Item)
			If (PlayerRef.GetItemCount(Item) < 1)
				Target.AddItem(Item, 1, True)
				Forms = PapyrusUtil.PushForm(Forms, Item.GetBaseObject())
			EndIf
		EndIf
		i += 1
	EndWhile

	Return Forms
EndFunction

Function EquipForms(Actor Target, Form[] Items)
	Int i = 0
	While (i < Items.Length)
		Form Item = Items[i]
		If (Item)
			Target.EquipItem(Item, False, True)
		EndIf
		i += 1
	EndWhile
EndFunction



Event OStimEnd(String EventName, String StrArg, Float NumArg, Form Sender)
	;Console("undresss: " + ostim.ForceCloseOStimThread)
	if ostim.ForceCloseOStimThread
		return 
	endif 
	Console("Redressing...")

	Redress(actors[0])
	If actors.length > 1
		Redress(actors[1])
	EndIf
	If (actors.length > 2)
		Redress( actors[2])
	EndIf
	
	SendModEvent("ostim_redresscomplete")
EndEvent

Event OStimPreStart(String EventName, String StrArg, Float NumArg, Form Sender)
	Console("Stripping actors...")
	actors = Ostim.GetActors()

	DomEquipmentDrops = new ObjectReference[1]
	SubEquipmentDrops = new ObjectReference[1]
	ThirdEquipmentDrops = new ObjectReference[1]

	DomEquipmentForms = new Form[1]
	SubEquipmentForms = new Form[1]
	ThirdEquipmentForms = new Form[1]

	If (OStim.AlwaysUndressAtAnimStart)
		OStim.UndressDom = True
		OStim.UndressSub = True
	EndIf

	If (OStim.AlwaysAnimateUndress)
		OStim.AnimateUndress = True
	EndIf

	If (OStim.UndressDom) ; animate undress, and chest-only strip not yet supported	
		Strip(actors[0])
	EndIf

	If (OStim.GetSubActor() && OStim.UndressSub)
		Strip(actors[1])
	EndIf

	; Assume if sub is to be undressed, third actor should also be provided ThirdActor exists.
	
	If (OStim.UndressSub && actors.length > 2)
		Strip(actors[2])		
	EndIf

	

	Console("Stripped.")
	SendModEvent("ostim_undresscomplete")
EndEvent

Event OstimChange(String eventName, String strArg, Float numArg, Form sender)
	Bool DidToggle = False

	If (OStim.AutoUndressIfNeeded && OStim.AnimationRunning())
		Bool DomNaked = OStim.IsNaked(actors[0])
		Bool SubNaked = True
		Bool ThirdNaked = True

		If actors.length > 1
			SubNaked = OStim.IsNaked(actors[1])
			If actors.length > 2
				ThirdNaked = OStim.IsNaked(actors[2])
			EndIf
		EndIf

		String CClass = OStim.GetCurrentAnimationClass()
		If (!DomNaked)
			If (CClass == "Sx") || (CClass == "Po") || (CClass == "HhPo") || (CClass == "ApPJ") || (CClass == "HhPJ") || (CClass == "HJ") || (CClass == "ApHJ") || (CClass == "DHJ") || (CClass == "SJ")|| (CClass == "An")|| (CClass == "BoJ")|| (CClass == "FJ")
				If OStim.IsInFreeCam() && (actors[0] == playerref)
					DidToggle = True
					OStim.ToggleFreeCam()
				EndIf
				Strip(actors[0])
				SendModEvent("ostim_midsceneundress_dom")
			EndIf
		EndIf
		If (!SubNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If OStim.IsInFreeCam() && (actors[1] == playerref)
					DidToggle = True
					OStim.ToggleFreeCam()
				EndIf
				Strip(actors[1])
				SendModEvent("ostim_midsceneundress_sub")
			EndIf
		EndIf
		If (!ThirdNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If OStim.IsInFreeCam() && (actors[2] == playerref)
					DidToggle = True
					OStim.ToggleFreeCam()
				EndIf
				Strip(actors[2])
				SendModEvent("ostim_midsceneundress_third")
			EndIf
		EndIf
	EndIf

	If (DidToggle)
		OStim.ToggleFreeCam()
	EndIf
EndEvent

Event OstimThirdJoin(String EventName, String StrArg, Float NumArg, Form Sender)
	SyncActors()
	If (OStim.AlwaysUndressAtAnimStart)
		Console("Stripping third actor")

		Bool DidToggle = False
		If (OStim.IsInFreeCam())
			DidToggle = True
			OStim.ToggleFreeCam()
		EndIf

		Strip(actors[2])

		If (DidToggle)
			OStim.ToggleFreeCam()
		EndIf
	EndIf	
EndEvent

Event OstimThirdLeave(String EventName, String StrArg, float NumArg, Form Sender)
	Console("Redressing third actor")
	Redress(actors[2])
	SyncActors()
EndEvent
bool syncing = false

Function SyncActors()
	if(syncing == false)
		syncing = true
		Actor[] newActors = Ostim.GetActors()
		ObjectReference[] originalDomEquipmentDrops = DomEquipmentDrops
		ObjectReference[] originalSubEquipmentDrops = SubEquipmentDrops
		ObjectReference[] originalThirdEquipmentDrops = ThirdEquipmentDrops

		form[] originalDomEquipmentForms = DomEquipmentForms
		form[] originalSubEquipmentForms = SubEquipmentForms
		form[] originalThirdEquipmentForms = ThirdEquipmentForms

		int i = 0
		while(i < actors.length)
			if(actors[i] == newActors[0])
			

				if(i == 0)
					DomEquipmentDrops = originalDomEquipmentDrops
					DomEquipmentForms = originalDomEquipmentForms				
				elseif(i == 1)
					DomEquipmentDrops = originalSubEquipmentDrops
					DomEquipmentForms = originalSubEquipmentForms
				elseif(i == 2)
					DomEquipmentDrops = originalThirdEquipmentDrops
					DomEquipmentForms = originalThirdEquipmentForms
				endif
			elseif(actors[i] == newActors[1])
				if(i == 0)
					SubEquipmentDrops = originalDomEquipmentDrops	
					SubEquipmentForms = originalDomEquipmentForms			
				elseif(i == 1)
					SubEquipmentDrops = originalSubEquipmentDrops
					SubEquipmentForms = originalSubEquipmentForms
				elseif(i == 2)
					SubEquipmentDrops = originalThirdEquipmentDrops
					SubEquipmentForms = originalThirdEquipmentForms
				endif
				
			elseif(actors[i] == newActors[2])
				if(i == 0)
					ThirdEquipmentDrops = originalDomEquipmentDrops	
					ThirdEquipmentForms = originalDomEquipmentforms			
				elseif(i == 1)
					ThirdEquipmentDrops = originalSubEquipmentDrops
					ThirdEquipmentForms = originalSubEquipmentForms
				elseif(i == 2)
					ThirdEquipmentDrops = originalThirdEquipmentDrops
					ThirdEquipmentForms = originalThirdEquipmentForms
				endif			
			endif
			i = i+1
		endWhile


		syncing = false

		actors = newActors
	else
		while(syncing)
			Utility.Wait(0.1)
		endWhile
	endif
endFunction

Event OstimActorPositions(String EventName, String StrArg, float NumArg, Form Sender)
	SyncActors()
endEvent

Form[] Set1
Form[] Set2
Form[] Set3

Actor Act1
Actor Act2
Actor Act3

Event AnimatedRedressThread(String EventName, String StrArg, float NumArg, Form Sender)
	Form[] Items
	Actor Target

	If (NumArg == 1.0)
		Items = Set1
		Target = Act1
	ElseIf (NumArg == 2.0)
		Items = Set2
		Target = Act2
	ElseIf (NumArg == 3.0)
		Items = Set3
		Target = Act3
	EndIf

	;items = PapyrusUtil.
	Bool Female = OStim.AppearsFemale(Target)

	Float StartingHealth = Target.GetAV("Health")

	Utility.Wait(Utility.RandomFloat(0.45, 0.65))

	Int i = 0
	While (i < Items.Length)
		If (Items[i])
			Bool Loaded = Target.Is3DLoaded()
			If OStim.IsActorActive(Target) || Target.IsDead() || (Target.GetAV("Health") < StartingHealth) || (Target.getparentcell() != playerref.getparentcell()) || target.IsInCombat()
				Loaded = False
			EndIf

			Armor ArmorPiece = (Items[i] as Armor)
			Int SlotMask = ArmorPiece.GetSlotMask()

			String UndressAnim = ""
			Float AnimLen = 0
			Float DressPoint = 0

			If ArmorPiece.IsCuirass() || ArmorPiece.IsClothingBody()
				If (Female)
					UndressAnim = "0Eq0ER_F_ST_D_cuirass_0"
					AnimLen = 9
					DressPoint = 4.5
				Else
					UndressAnim = "0Eq0ER_M_ST_D_cuirass_0"
					AnimLen = 8
					DressPoint = 5
				EndIf
			ElseIf ArmorPiece.IsBoots() || ArmorPiece.IsClothingFeet()
				If (Female)
					UndressAnim = "0Eq0ER_F_SI_D_boots_0"
					AnimLen = 17
					DressPoint = 4.5
				Else
					UndressAnim = "0Eq0ER_M_ST_D_boots_0"
					AnimLen = 8
					DressPoint = 5
				EndIf
			ElseIf ArmorPiece.IsHelmet() || ArmorPiece.IsClothingHead()
				If (Female)
					UndressAnim = "0Eq0ER_F_ST_D_helmet_0"
					AnimLen = 12.5
					DressPoint = 9.5
				Else
					UndressAnim = "0Eq0ER_M_ST_D_helmet_0"
					AnimLen = 5
					DressPoint = 3
				EndIf
			ElseIf ArmorPiece.IsGauntlets() || ArmorPiece.IsClothingHands()
				If (Female)
					UndressAnim = "0Eq0ER_F_ST_D_gloves_0"
					AnimLen = 12
					DressPoint = 3
				Else
					UndressAnim = "0Eq0ER_M_ST_D_gloves_0"
					AnimLen = 8
					DressPoint = 6.5
				EndIf
			EndIf

			If (UndressAnim != "" && Loaded)
				Debug.SendAnimationEvent(Target, UndressAnim)
			EndIf
			If (Loaded)
				Utility.Wait(DressPoint)
			EndIf
			If (!Target.IsDead() && !OStim.IsActorActive(Target))
				Target.EquipItem(items[i], false, true)
			EndIf
			If (Loaded)
				Utility.Wait(AnimLen - DressPoint)
			EndIf
		EndIf
		i += 1
	EndWhile

	If !OStim.IsActorActive(Target)
		Debug.SendAnimationEvent(Target, "IdleForceDefaultState")
	endif

	If (NumArg == 1.0)
		Act1 = None
		Set1 = new Form[1]
	ElseIf (NumArg == 2.0)
		Act2 = None
		Set2 = new Form[1]
	ElseIf (NumArg == 3.0)
		Act3 = None
		Set3 = new Form[1]
	EndIf
EndEvent

Function FullyAnimateRedress(Actor Target, Form[] Items)
	Float Arg
	If (Act1 == None)
		Arg = 1.0
		Act1 = Target
		Set1 = Items
	Elseif (Act2 == None)
		Arg = 2.0
		Act2 = Target
		Set2 = Items
	Elseif (Act3 == None)
		Arg = 3.0
		Act3 = Target
		Set3 = Items
	endif

	SendModEvent("ostim_redressthread", numArg = Arg)
EndFunction

Function Console(String In)
	MiscUtil.PrintConsole("OStim: " + in)
EndFunction

Function OnGameLoad()
	RegisterForModEvent("ostim_prestart", "OStimPreStart")
	RegisterForModEvent("ostim_end", "OstimEnd")

	RegisterForModEvent("ostim_animationchanged", "OstimChange")

	RegisterForModEvent("ostim_thirdactor_join", "OstimThirdJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OstimThirdLeave")

	RegisterForModEvent("ostim_redressthread", "AnimatedRedressThread")
	RegisterForModEvent("ostim_actorpositionschanged", "OstimActorPositions")
EndFunction
