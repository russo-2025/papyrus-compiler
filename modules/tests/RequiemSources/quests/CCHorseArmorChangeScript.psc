Scriptname CCHorseArmorChangeScript extends Quest
{Changes horse armors at hostlers and blacksmiths}

;==================
;Properties
;==================

Actor Property PlayerRef Auto
Quest Property Stables Auto
ReferenceAlias Property StablesPlayersHorse Auto
Keyword Property ccDisallowSaddleSwap Auto
ActorBase[] Property DisallowedHorses Auto
Faction Property PlayerHorseFaction Auto
MiscObject Property Gold001 Auto
GlobalVariable Property CCHorseArmorCost Auto
GlobalVariable Property CCHorseArmorCostSwapOnly Auto
Spell Property CCHorseArmorAbEssentialFlag Auto

;Used to remove all armors from the horse and force revert to their default saddle
FormList Property CCHorseArmorList Auto

;Since the armor is non-playable we need to swap between a MISC item and an ARMO item when giving the armor back to the player

Armor[] Property ArrayHorseArmors Auto ;Fixed array of horse armors
Armor[] Property ArrayUnicornArmors Auto ;Fixed array of unicorn armors
MiscObject[] Property ArrayHorseArmorsMisc Auto ;Fixed array of misc items that represent the armors to give to the player

;Messages
Message Property CCHorseArmorMessageArmorCannotUse Auto
Message Property CCHorseArmorMessageArmorChanged Auto
Message Property CCHorseArmorMessageArmorRemoved Auto
Message Property CCHorseArmorMessageNoHorsesOwned Auto
Message Property CCHorseArmorMessageNotEnoughGold Auto
Message Property CCHorseArmorMessageArmorAlreadyEquipped Auto

;/Internal pointers that get switched whether or not we're equipping a regular horse or a unicorn
This was done instead of splitting code paths and doing tons of IF statements, we just divert regular horse or unicorn armor
The misc objets are always the same/;

Armor[] ArrayArmors


;=============================================
;Main Function
;(Called from dialogue script fragments, which just send an ID)
;=============================================

Function ChangeHorseArmor(Int ArmorID)
;PUBLIC, called by dialogue fragments. Logic for using gold or MISC item from inventory done here. Uses pseudo-enum.  ArmorID matches position in ArrayArmors property.

	Actor PlayerHorseREF = GetPlayerHorse()

	If(PlayerHorseREF && !PlayerHorseREF.IsDead())

		;debug.trace("HORSE ARMOR: Player's current horse is " + PlayerHorseREF)

		If(CanChangeHorseArmor(PlayerHorseREF))

			If(IsUnicorn(PlayerHorseREF))
				ArrayArmors = ArrayUnicornArmors
			Else
				ArrayArmors = ArrayHorseArmors
			EndIf

			Armor ArmorToEquip = ArrayArmors[ArmorID]

			If(ArmorToEquip)

				If(PlayerHorseREF.IsEquipped(ArmorToEquip))
					;debug.trace("HORSE ARMOR: Current horse " + PlayerHorseREF + " is already wearing armor " + ArmorToEquip)
					CCHorseArmorMessageArmorAlreadyEquipped.Show()
				Else

					;Check if player has the Horse Armor MISC item in their inventory and give them a discount to just change it
					MiscObject inventoryItem = GetMiscObjectForArmor(ArmorToEquip)
					Bool doEquipArmor = False
					Bool removeMiscItem = False
					Int costGold

					;If the player has the inventory item, only charge them the fee to swap it
					If(PlayerREF.GetItemCount(inventoryItem))
						CostGold = CCHorseArmorCostSwapOnly.GetValueInt() ;service fee only
						removeMiscItem = True
					Else
						costGold = CCHorseArmorCost.GetValueInt() ;service fee plus armor fee
					EndIf

					If(PlayerREF.GetItemCount(Gold001) >= costGold)
						;debug.trace("HORSE ARMOR: Taking gold payment from player")
						doEquipArmor = True
						PlayerREF.RemoveItem(Gold001, costGold) ;Remove gold
						If(removeMiscItem)
							PlayerREF.RemoveItem(inventoryItem, 1) ;Remove armor MISC item
						EndIf
					Else
						;debug.trace("HORSE ARMOR: Player does not have enough gold")
						CCHorseArmorMessageNotEnoughGold.Show()
						doEquipArmor = False
					EndIf

					;EndIf

					If(doEquipArmor)
						EquipHorseArmor(PlayerHorseREF, ArmorToEquip)
					EndIf

				EndIf

			EndIf

		Else
			;debug.trace("HORSE ARMOR: Current horse cannot have armor or saddle changed.")
			CCHorseArmorMessageArmorCannotUse.Show()
		EndIf

	Else
		CCHorseArmorMessageNoHorsesOwned.Show()
	EndIf

EndFunction


;===================
;Utility Functions
;===================

Function EquipHorseArmor(Actor akPlayerHorseRef, Armor akArmorToEquip)
;INTERNAL FUNCTION

	;debug.trace("HORSE ARMOR: Equipping armor " + akArmorToEquip + " on horse " + akPlayerHorseRef)

	SwapArmorForMiscObject(akPlayerHorseRef) ;check if horse is wearing armor, and give a MISC object back to the player
	akPlayerHorseRef.UnequipItemSlot(45) ;we must force unequip the armor if one was equipped previously
	akPlayerHorseRef.EquipItem(akArmorToEquip, 1) ;force equip the armor
	CCHorseArmorMessageArmorChanged.Show()

EndFunction

Bool Function SwapArmorForMiscObject(Actor PlayerHorse)
;Since horse armor is not playable we need to give a MISC item in its place

	Bool RemovedArmor = False

	Int i = 0

	While(i < ArrayArmors.Length)
		If(PlayerHorse.IsEquipped(ArrayArmors[i]))
			;debug.trace("HORSE ARMOR: Horse is currently wearing " + ArrayArmors[i] + ", swap with misc item " + ArrayHorseArmorsMisc[i])
			PlayerRef.AddItem(ArrayHorseArmorsMisc[i])
			PlayerHorse.RemoveItem(ArrayArmors[i])
			RemovedArmor = True
		EndIf
		i += 1
	EndWhile

	Return RemovedArmor

EndFunction

Bool Function CanChangeHorseArmor(Actor PlayerHorse)

	;Get the wild horses keyword to prevent armoring them before they're tamed
	Keyword ccBGSSSE034WildHorseKeyword = Game.GetFormFromFile(0x00000828,"ccBGSSSE034-MntUni.esl") as Keyword

	If(DisallowedHorses.Find(PlayerHorse.GetActorBase()) != -1 || PlayerHorse.HasKeyword(ccDisallowSaddleSwap))
		return False
	ElseIf(PlayerHorse.HasKeyword(ccBGSSSE034WildHorseKeyword) && !PlayerHorse.IsInFaction(PlayerHorseFaction)) ;Un-tamed horses from Wild Horses creation
		return False
	Else
		return True
	EndIf
EndFunction

MiscObject Function GetMiscObjectForArmor(Armor HorseArmor)
;Takes an Armor and finds/returns its equivalent Misc item
	Int arrayPos = ArrayArmors.Find(HorseArmor)
	return ArrayHorseArmorsMisc[arrayPos]
EndFunction

Armor Function GetArmorForMiscObject(MiscObject HorseArmorMisc)
	Int arrayPos = ArrayHorseArmorsMisc.Find(HorseArmorMisc)
	return ArrayArmors[arrayPos]
EndFunction

Function RemoveHorseArmor()
;Called by dialogue and by Wild Horses creation
;/We cannot know what the horse had equipped prior to wearing armor (saddle or bareback)
so to make their inventory reset, we need to remove all other armors from their inventory
which will make the engine equip their default outfit (saddle or bareback)
/;
	
	Actor PlayerHorseREF = GetPlayerHorse()

	If(PlayerHorseREF)
		;debug.trace("HORSE ARMOR: Removing armor from horse " + PlayerHorseREF)
		If(SwapArmorForMiscObject(PlayerHorseREF))
			CCHorseArmorMessageArmorRemoved.Show()
		EndIf
		PlayerHorseREF.RemoveItem(CCHorseArmorList, 999)

		;If the horse has this spell it means they were NOT essential prior to wearing armor, so let's revert it
		If(PlayerHorseREF.HasSpell(CCHorseArmorAbEssentialFlag))
			PlayerHorseREF.GetActorBase().SetEssential(False)
			PlayerHorseREF.RemoveSpell(CCHorseArmorAbEssentialFlag)
		EndIf

	Else
		CCHorseArmorMessageNoHorsesOwned.Show()
	EndIf

EndFunction

Actor Function GetPlayerHorse()
;/Grab the player's last ridden horse. If a player purchased a horse but has never ridden one yet
GetPlayersLastRiddenHorse() is NONE, so also check the stables quest for ownership so the player
can put armor on their horse immediately after purchasing it/;

	If(Game.GetPlayersLastRiddenHorse())
		Return Game.GetPlayersLastRiddenHorse()
	ElseIf(StablesPlayersHorse.GetActorReference())
		Return StablesPlayersHorse.GetActorReference()
	Else
		Return None
	EndIf

EndFunction

Bool Function IsUnicorn(Actor akPlayerHorseRef)
;/If the player is swapping armor on the Creation Club Unicorn, we need to detect and equip alternate armor sets
(The unicorn is not its own race so we cannot rely on Armor AddOn data)/;

	ActorBase Unicorn = Game.GetFormFromFile(0x00000804,"ccBGSSSE034-MntUni.esl") as ActorBase ;Unicorn NPC actorbase
	Return Unicorn && akPlayerHorseRef.GetActorBase() == Unicorn

EndFunction