Scriptname REQ_MassEffect_PC extends REQ_Corescript
{This script is the master script for the mass effect. It controls the mass effect for the PC and also serves as a data storage for all NPC-clients.}

Spell Property MassEffect Auto
Perk Property MassPerk Auto
Formlist Property worn Auto
{an empty formlist, used to sort out multiple occurences of multi-slot equipment}

;extended mass effect variables
Perk[] Property Perks_light Auto
Float[] Property Factors_light Auto
Perk[] Property Perks_heavy Auto
Float[] Property Factors_heavy Auto
Perk[] Property Perks_onehanded Auto
Float[] Property Factors_onehanded Auto
Perk[] Property Perks_twohanded Auto
Float[] Property Factors_twohanded Auto
Perk[] Property Perks_archery Auto
Float[] Property Factors_archery Auto

Float[] ratios_armor
Float[] ratios_weapon

Float mass = 0.0
Float penalty = 0.0

Float property mod_mass
  Float function get()
    return mass
  endFunction
endProperty

Float property mod_penalty
  Float function get()
    return penalty
  endFunction
endProperty

;note that the stack is cyclic instead of shifting its entries around
Form[] stack_object ;array with all forms to be processed
Bool[] stack_equipped ;denotes if stack_object with same index was unequipped or equipped
int stack_current = -1; current index of stack evalution process
int stack_last = -1; last occupied stack index

Function initScript(Int currentVersion, Int nevVersion)
	stack_object = new Form[68]
	stack_equipped = new Bool[68]
	ratios_armor = new Float[3]
	ratios_weapon = new Float[10]
	Update_Ratios()
	player.RemoveSpell(MassEffect)
	player.modAV("CarryWeight",-0.01)
	player.modAV("CarryWeight",0.01)
	RegisterForMenu("StatsMenu")
	GoToState("full_evaluation_start")
	Full_Evaluation()
	GoToState("")
	Evaluate_Stack()
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
	UnregisterForAllMenus()
	While GetState() == "working"
		Utility.Wait(0.5)
	EndWhile
	player.RemoveSpell(MassEffect)
	player.modav("mass", -mass)
	Player.ModAV("infamy", -penalty)
	UnregisterForUpdate()
    Player.ModAV("movementnoisemult", -penalty)
    Player.ModAV("speedmult", 50.0 * penalty)
EndFunction

Event OnMenuClose(String MenuName)
	Update_Ratios()
	GoToState("full_evaluation_start")
	Full_Evaluation()
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	If GetState() == "" || GetState() == "working"
		Add_to_Stack(akBaseObject, True)
	EndIf
EndEvent

Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	If GetState() == "" || GetState() == "working"
		Add_to_Stack(akBaseObject, False)
	EndIf
EndEvent

State working
	Function Evaluate_Stack()
	EndFunction
EndState

State full_evaluation_start
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Function Evaluate_Stack()
	EndFunction
EndState

State full_evaluation_active
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		GoToState("full_evaluation_start")
	EndEvent
	
	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
		GoToState("full_evaluation_start")
	EndEvent

	Function Evaluate_Stack()
	EndFunction
	
	Function Full_Evaluation()
	EndFunction
EndState

Auto State Init
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
EndState

Function Add_to_Stack(Form object, Bool equipped)
	If !(object as Armor || object as Weapon)
		return
	EndIf
	stack_last = increment_index(stack_last)
	stack_object[stack_last] = object
	stack_equipped[stack_last] = equipped
	; Debug.Trace(GetState() + ": added to stack: "+ object + "[" + equipped + "] at index " + stack_last)
	Evaluate_Stack()
EndFunction

Int Function increment_index(int index)
	If index == stack_object.length - 1
		return 0
	Else 
		return index + 1
	EndIf
EndFunction

Function Full_Evaluation()
	GoToState("full_evaluation_active")
	Form equippeditem
	Form equippeditem2
	int type
	int count = 0
	int slotmask = 0x00000001
	Player.ModAV("mass", -mass)
	Player.ModAV("infamy", -penalty)
		Player.ModActorValue("speedmult", 50.0 * penalty)
		Player.ModActorValue("movementnoisemult", -penalty)
	mass = 0.0
	penalty = 0.0
	stack_current = -1
	stack_last = -1
	worn.Revert()
	While slotmask <= 0x80000000 && slotmask > 0
		worn.AddForm(Player.GetWornForm(slotmask))
		slotmask = Math.LeftShift(slotmask,1)
	EndWhile
	count = worn.GetSize() - 1
	While count >= 0
		Add_to_Stack(worn.GetAt(count), True)
		count -= 1
	EndWhile
	equippeditem = Player.GetEquippedObject(1)
	equippeditem2 = Player.GetEquippedObject(0)
	If equippeditem as Weapon
		Add_to_Stack(equippeditem, True)
	EndIf
	If equippeditem2 as Weapon
		type = (equippeditem2 as Weapon).GetWeaponType()
		If type <= 4 || type == 8
			Add_to_Stack(equippeditem2, True)
		EndIf
	EndIf
	count = stack_last + 1
	While count < stack_object.length
		stack_object[count] = None
		stack_equipped[count] = True
		count += 1
	EndWhile
	If GetState() == "full_evaluation_start"
		Full_Evaluation()
	Else
		GoToState("")
		Evaluate_Stack()
	EndIf
EndFunction

Function Evaluate_Stack()
	GoToState("working")
	; Debug.Trace(">>>Evaluate_Stack started")
	int type
	float modmass
	float itemmass
	Armor item_armor
	Weapon item_weapon
	While stack_current != stack_last
		stack_current = increment_index(stack_current)
		modmass = 0.0
		; Debug.Trace("evaluate stack: "+ stack_object[stack_current] + "[" + stack_equipped[stack_current] + "] at index " + stack_current + ", last index = "+stack_last)
		item_armor = stack_object[stack_current] as Armor
		item_weapon = stack_object[stack_current] as Weapon
		If item_armor
			type = item_armor.GetWeightClass()
			itemmass = item_armor.GetWeight() / 100.0
			modmass = ratios_armor[type] * itemmass
		ElseIf item_weapon
			type = item_weapon.GetWeaponType()
			itemmass = item_weapon.GetWeight() / 100.0
			modmass = ratios_weapon[type] * itemmass
		Else
			; Debug.Trace("Item "+stack_object[stack_current]+" should not be in the stack")
		EndIf
			modmass *= -1.0 + 2.0 * (stack_equipped[stack_current] as Float)
			itemmass *= -1.0 + 2.0 * (stack_equipped[stack_current] as Float)
		mass += itemmass
		penalty += modmass
		; Debug.Trace("Results: itemmass = " + itemmass + "[raw = " + stack_object[stack_current].GetWeight() + "]" + " modmass = " + modmass)
		Player.ModActorValue("mass", itemmass)
		Player.ModActorValue("infamy", modmass)
		Player.ModActorValue("speedmult", -50.0 * modmass)
		Player.ModActorValue("movementnoisemult", modmass)
		stack_object[stack_current] = None
	EndWhile
	GoToState("")
	player.modAV("CarryWeight",-0.01)
	player.modAV("CarryWeight",0.01)
	; player.RemoveSpell(MassEffect)
	; player.AddSpell(MassEffect,False)
	; player.modAV("CarryWeight",-0.01)
	; Utility.Wait(0.1)
	; player.modAV("CarryWeight",0.01)
	; Debug.Trace(">>>Evaluate_Stack finished mass = "+Player.GetAV("mass")+" effmass = "+Player.GetAV("infamy"))
EndFunction

Function Update_Ratios()
	Int count = 0
	Float ratio = 1.0
	While count < Perks_light.Length
		ratio -= (Player.HasPerk(Perks_light[count]) as Float) * Factors_light[count]
		count += 1
	EndWhile
	ratios_armor[0] = ratio
	ratios_armor[2] = ratio
	count = 0
	ratio = 1.0
	While count < Perks_heavy.Length
		ratio -= (Player.HasPerk(Perks_heavy[count]) as Float) * Factors_heavy[count]
		count += 1
	EndWhile
	ratios_armor[1] = ratio
	count = 0
	ratio = 1.0
	While count < Perks_onehanded.Length
		ratio -= (Player.HasPerk(Perks_onehanded[count]) as Float) * Factors_onehanded[count]
		count += 1
	EndWhile
	ratios_weapon[1] = ratio
	ratios_weapon[2] = ratio
	ratios_weapon[3] = ratio
	ratios_weapon[4] = ratio
	ratios_weapon[8] = ratio
	count = 0
	ratio = 1.0
	While count < Perks_twohanded.Length
		ratio -= (Player.HasPerk(Perks_twohanded[count]) as Float) * Factors_twohanded[count]
		count += 1
	EndWhile
	ratios_weapon[5] = ratio
	ratios_weapon[6] = ratio
	count = 0
	ratio = 1.0
	While count < Perks_archery.Length
		ratio -= (Player.HasPerk(Perks_archery[count]) as Float) * Factors_archery[count]
		count += 1
	EndWhile
	ratios_weapon[7] = ratio
	ratios_weapon[9] = ratio
	ratios_weapon[0] = 0.0
EndFunction
