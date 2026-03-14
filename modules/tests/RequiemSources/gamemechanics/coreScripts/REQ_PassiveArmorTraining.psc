Scriptname REQ_PassiveArmorTraining extends REQ_CoreScript
{increase heavy armor and evasion skills by moving in armor or clothes}

Int[] Property contributions Auto
{all biped slots which contribute to skillgain}
Float[] Property Skillgain Auto
{skillgain per interval for given contributing slot while running, sprinting is *2}

Float Property UpdateInterval Auto
{time between consecutive skill increment checks}

GlobalVariable Property ArmorDebug Auto
{enable debug notifications for armor increments}

Float gain_light
Float gain_heavy
Armor[] slots
Formlist Property worn Auto
{an empty formlist, contains the currently worn equipment at runtime to evaluate equipment mass}

Bool working = False
Bool updating = True

Function initScript(Int currentVersion, Int nevVersion)
	slots = new Armor[32]
	Adjust_Values()
	RegisterForSingleUpdate(UpdateInterval)
	updating = False
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
	updating = True
	While working
		Utility.Wait(0.5)
	EndWhile
	UnregisterForUpdate()
EndFunction

Event OnUpdate()
	If Player.IsRunning()
		If (gain_light > 0)
			Game.AdvanceSkill("Lightarmor" , gain_light)
		EndIf
		If (gain_heavy > 0)
			Game.AdvanceSkill("Heavyarmor" , gain_heavy)
		EndIf	
	ElseIf Player.IsSprinting()
		If (gain_light > 0)
			Game.AdvanceSkill("Lightarmor" , gain_light*2)
		EndIf
		If (gain_heavy > 0)
			Game.AdvanceSkill("Heavyarmor" , gain_heavy*2)
		EndIf
	EndIf
	RegisterForSingleUpdate(UpdateInterval)
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	If ( akBaseObject as Armor != None )
        GoToState("StartEvaluation")
	EndIf
EndEvent

Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	If ( akBaseObject as Armor != None )
        GoToState("StartEvaluation")
	EndIf
EndEvent

State StartEvaluation

	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent

	Event OnUpdate()
		If !(working || updating)
			GoToState("EvaluateArmor")
		Else
			RegisterForSingleUpdate(0.5)
		EndIf
	EndEvent
	
	Event OnBeginState()
		UnregisterForUpdate()
		RegisterForSingleUpdate(0.5)
	EndEvent

EndState

State EvaluateArmor

	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
		GoToState("StartEvaluation")
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		GoToState("StartEvaluation")
	EndEvent
	
	Event OnBeginState()
		working = True
		UnregisterForUpdate()
		Float valheavy = gain_heavy
		Float vallight = gain_light
		Adjust_Values()
		If ( ArmorDebug.GetValue() == 1 )
			Debug.Messagebox("Light armor: "+vallight+" -> "+gain_light+"\nHeavy armor: "+valheavy+" -> "+gain_heavy)
		EndIf
		If ( GetState() == "EvaluateArmor" )
			GoToState("")
			RegisterForSingleUpdate(UpdateInterval)
		EndIf
		working = False
	EndEvent
	
EndState

Function Adjust_Values()
	Int i = 30
	Int type = -1
	Int pos = -1
	gain_heavy = 0
	gain_light = 0
	worn.Revert()
	While (i < 62)
		slots[i - 30] = Player.GetWornForm(Armor.GetMaskForSlot(i)) as Armor
		worn.AddForm(slots[i - 30])
		pos = contributions.find(i)
		If ( pos >= 0 && slots[i - 30] != None )
			type = slots[i - 30].GetWeightClass()
			If ( type == 1 )
				gain_heavy += Skillgain[pos]
			ElseIf ( type == 0 )
				gain_light += Skillgain[pos]
			ElseIf ( type == 2 )
				gain_light += Skillgain[pos] / 2
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction
