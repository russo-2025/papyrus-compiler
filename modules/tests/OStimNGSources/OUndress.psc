;/* OUndress
* * bunch of papyrus functions that can be invoked instead of the C++ undressing code
* * so that other mods can overwrite them if they want to modify undressing behavior
* * by default all undressing is done in C++ and this script is useless
*/;
ScriptName OUndress

;/* UsePapyrusUndressing
* * if you change the return value of this function to true OStim will invoke the papyrus undressing functions of this script
* * this function is invoked once at game load and the value will be cached for the rest of the session
* * the value will not get serialized, it is gathered again at every savegame load
* * the value is also automically written to the OStimUsePapyrusUndressing global variable, but changing the global directly has no effect
*/;
bool Function UsePapyrusUndressing() Global
	Return false
EndFunction

;/* AnimateRedress
* * starts an animated redress sequence
* * this is the only function that gets called even when Papyrus Undressing is not enabled
* * this function is expected to redress every single item in the Armors and Weapons arrays
* * the armor array has variable size (can even be size 0) and will never contain None entries
* * the weapon array is always of size 3, 0 - main hand, 1 - off hand, 2 - ammo, some (or even all) of these can be None
* * 
* * @param: Act, the actor to perform the animated redress on
* * @param: Armors, the armors that got fully undressed of the actor
* * @param: Weapons, the weapons that got removed from the actor
*/;
Function AnimateRedress(Actor Act, bool IsFemale, Armor[] Armors, Form[] Weapons) Global
	int TotalSlotMask = 0
	int i = Armors.Length
	While i
		i -= 1
		TotalSlotMask = Math.LogicalOr(TotalSlotMask, Armors[i].GetSlotMask())
	EndWhile

	int bodyMask = 0x04C90004
	int footMask = 0x00000080
	int handMask = 0x00000008
	int headMask = 0x02004001

	int animatedMask = Math.LogicalOr(Math.LogicalOr(bodyMask, footMask), Math.LogicalOr(handMask, headMask))

	; TODO: OpenSex 1.18 is going to contain individual redress animations for male and female
	; so when that goes public on the nexus this part will need to get updated
	If Math.LogicalAnd(TotalSlotMask, bodyMask) != 0
		If IsFemale
			PlayRedressAnimation(Act, "OStimRedressTorsoF", 3, 1.5, Armors, bodyMask)
		Else
			PlayRedressAnimation(Act, "OStimRedressTorsoM", 3, 1.5, Armors, bodyMask)
		EndIf
	EndIf

	If Math.LogicalAnd(TotalSlotMask, footMask) != 0
		If IsFemale
			PlayRedressAnimation(Act, "OStimRedressFeetF", 3, 2.9, Armors, footMask)
		Else
			PlayRedressAnimation(Act, "OStimRedressFeetM", 3, 2.9, Armors, footMask)
		EndIf
	EndIf

	If Math.LogicalAnd(TotalSlotMask, handMask) != 0
		If IsFemale
			PlayRedressAnimation(Act, "OStimRedressHandsF", 2, 1.6, Armors, handMask)
		Else
			PlayRedressAnimation(Act, "OStimRedressHandsM", 2, 1.6, Armors, handMask)
		EndIf
	EndIf

	If Math.LogicalAnd(TotalSlotMask, headMask) != 0
		If IsFemale
			PlayRedressAnimation(Act, "OStimRedressHeadF", 2, 1.9, Armors, headMask)
		Else
			PlayRedressAnimation(Act, "OStimRedressHeadM", 2, 1.9, Armors, headMask)
		EndIf
	EndIf

	i = Armors.Length
	While i
		i -= 1
		If Math.LogicalAnd(Armors[i].GetSlotMask(), animatedMask) == 0
			Act.EquipItemEx(Armors[i])
		EndIf
	EndWhile

	If Weapons[0]
		Act.EquipItemEx(Weapons[0], 1)
	EndIf
	If Weapons[1]
		Act.EquipItemEx(Weapons[1], 2)
	EndIf
	If Weapons[2]
		Act.EquipItemEx(Weapons[2])
	EndIf

	If Act.Is3DLoaded()
		Debug.SendAnimationEvent(Act, "IdleForceDefaultState")
	EndIf
EndFunction

;/* PlayRedressAnimation
* * gets invoked by AnimateRedress to avoid code duplication
*/;
Function PlayRedressAnimation(Actor Act, String Animation, float AnimationLength, float DressPoint, Armor[] Armors, int SlotMask) Global
	Bool Loaded = Act.Is3DLoaded()
	If Act.IsDead() || Act.IsInCombat() || (Act.getparentcell() != Game.GetPlayer().GetParentCell()) || Act.IsInCombat()
		Loaded = False
	EndIf

	If Loaded
		Debug.SendAnimationEvent(Act, Animation)
		Utility.Wait(DressPoint)
	EndIf

	If !Act.IsDead()
		int i = Armors.Length
		While i
			i -= 1
			If Math.LogicalAnd(Armors[i].GetSlotMask(), SlotMask) != 0
				Act.EquipItemEx(Armors[i])
			EndIf
		EndWhile
	EndIf

	If Loaded
		Utility.Wait(AnimationLength - DressPoint)
	EndIf
EndFunction

;/* Undress
* * undresses the actor
* *
* * @param: ThreadId, the id of the thread this is happening in, to used be with the OThread script
* * @param: Act, the actor to undress
* *
* * @return: an array of items that have beenn undressed, these will be cached by OStim and passed to the redress functions
* * OStim will automatically sort out duplicates, but not None entries, before passing it to the redress functions
*/;
Armor[] Function Undress(int ThreadId, Actor Act) Global
	Armor[] WornItems = GetWornItems(Act)

	int i = WornItems.Length
	While i
		i -= 1
		If CanUndress(WornItems[i]) && !IsWig(Act, WornItems[i])
			Act.UnequipItemEx(WornItems[i])
		Else
			WornItems[i] = None
		EndIf
	EndWhile
	
	WornItems = TrimArmorArray(WornItems)

	Return WornItems
EndFunction

;/* Redress
* * redresses the actor
* *
* * @param: ThreadId, the id of the thread this is happening in, to used be with the OThread script
* * @param: Act, the actor to redress
* * @param: UndressedItems, an array of items that have been undressed by the undress functions
* *
* * @return: an array of items that have been redressed, these will be removed from the cache of undressed items
*/;
Armor[] Function Redress(int ThreadId, Actor Act, Armor[] UndressedItems) Global
	int i = UndressedItems.Length
	While i
		i -= 1
		Act.EquipItemEx(UndressedItems[i])
	EndWHile
	Return UndressedItems
EndFunction

;/* UndressPartial
* * undresses the given slots on the actor
* * see https://www.creationkit.com/index.php?title=Slot_Masks_-_Armor for reference of how slotmasks are constructed
* *
* * @param: ThreadId, the id of the thread this is happening in, to used be with the OThread script
* * @param: Act, the actor to undress
* * @param: SlotMask, the slot mask of the slots to undress
* *
* * @return: an array of items that have beenn undressed, these will be cached by OStim and passed to the redress functions
* * OStim will automatically sort out duplicates, but not None entries, before passing it to the redress functions
*/;
Armor[] Function UndressPartial(int ThreadId, Actor Act, int SlotMask) Global
	Armor[] WornItems = GetWornItems(Act)

	int i = WornItems.Length
	While i
		i -= 1
		If Math.LogicalAnd(SlotMask, WornItems[i].GetSlotMask()) != 0 && CanUndress(WornItems[i]) && !IsWig(Act, WornItems[i])
			Act.UnequipItemEx(WornItems[i])
		Else
			WornItems[i] = None
		EndIf
	EndWhile

	Return WornItems
EndFunction

;/* RedressPartial
* * redresses the given slots on the actor
* * see https://www.creationkit.com/index.php?title=Slot_Masks_-_Armor for reference of how slotmasks are constructed
* *
* * @param: ThreadId, the id of the thread this is happening in, to used be with the OThread script
* * @param: Act, the actor to redress
* * @param: UndressedItems, an array of all items that have been undressed by the undress functions (all, not just the ones matching the slot mask)
* * @param: SlotMask, the slot mask of the slots to redress
* *
* * @return: an array of items that have been redressed, these will be removed from the cache of undressed items
*/;
Armor[] Function RedressPartial(int ThreadId, Actor Act, Armor[] UndressedItems, int SlotMask) Global
	int i = UndressedItems.Length
	While i
		i -= 1
		If Math.LogicalAnd(SlotMask, UndressedItems[i].GetSlotMask()) != 0
			Act.EquipItemEx(UndressedItems[i])
		Else
			UndressedItems[i] = None
		EndIf
	EndWHile

	UndressedItems = TrimArmorArray(UndressedItems)
	Return UndressedItems
EndFunction

; ███╗   ██╗ █████╗ ████████╗██╗██╗   ██╗███████╗
; ████╗  ██║██╔══██╗╚══██╔══╝██║██║   ██║██╔════╝
; ██╔██╗ ██║███████║   ██║   ██║██║   ██║█████╗  
; ██║╚██╗██║██╔══██║   ██║   ██║╚██╗ ██╔╝██╔══╝  
; ██║ ╚████║██║  ██║   ██║   ██║ ╚████╔╝ ███████╗
; ╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝  ╚══════╝

;/* CanUndress
* * checks if an item can be undressed
* *
* * @param: Item, the item to check
* *
* * @return: true if the item can be undressed, returns false if at least one of the following is true:
* * - the item has the OStimNoStrip keyword
* * - SexLab is installed and the item has the SexLabNoStrip keyword
* * - the item does not match any of the undressing slots checked in the MCM
*/;
bool Function CanUndress(Form Item) Global Native

;/* IsWig
* * checks if an item is a wig
* * technically: checks if one of the armor addons currently visible on the actor has the shader type HairTint and belongs to the item
* * also checks if the item uses slot 31
* * so anything that uses slot 31 and adapts to the actors hair color is considered a wig
* *
* * @param: Act, the actor to check on
* * @param: Item, the armor piece to check
* *
* * @return: true if the item is considered a wig by the above definition
*/;
bool Function IsWig(Actor Act, Armor Item) Global Native

;/* GetWornItems
* * returns all armor pieces the actor currently has equipped
* *
* * @param: Act, the actor to get the equipment from
* *
* * @return: an array of all worn armor pieces
*/;
Armor[] Function GetWornItems(Actor Act) Global Native

;/* TrimArmorArray
* * removes all None entries from the array and cuts down the size
* *
* * @param: Items, the array to trim
* *
* * @return: a new array without None entries
*/;
Armor[] Function TrimArmorArray(Armor[] Items) Global Native