Scriptname REQ_MassEffectArmor Extends ActiveMagicEffect

Actor Target

Bool Update
Bool Finish

Float ActiveMass
Float ActivePenalty


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Target = akTarget
	If Target == Game.GetPlayer()
		RegisterForMenu("StatsMenu")
	EndIf
	UpdateMassEffect()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Finish = True
	UpdateMassEffect()
EndEvent

Event OnMenuClose(String MenuName)
	UpdateMassEffect()
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	If akBaseObject As Armor
		UpdateMassEffect()
	EndIf
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	If akBaseObject As Armor
		UpdateMassEffect()
	EndIf
EndEvent

Armor[] Function GetEquippedArmors()
	Armor[] Equipped = New Armor[5]
	Equipped[0] = Target.GetEquippedArmorInSlot(32)  ; Body
	Equipped[1] = Target.GetEquippedArmorInSlot(31)  ; Hair
	Equipped[2] = Target.GetEquippedArmorInSlot(33)  ; Hands
	Equipped[3] = Target.GetEquippedArmorInSlot(37)  ; Feet
	Equipped[4] = Target.GetEquippedArmorInSlot(39)  ; Shield
	; Discard duplicates
	Int i = 0
	While i < Equipped.Length
		If Equipped[i] != None
			Int j = i + 1
			While j < Equipped.Length
				If Equipped[j] == Equipped[i]
					Equipped[j] = None
				EndIf
				j += 1
			EndWhile
		EndIf
		i += 1
	EndWhile
	Return Equipped
EndFunction

Float Function ClampTo(Float Value, Float Min, Float Max)
	If Value < Min
		Return Min
	ElseIf Value > Max
		Return Max
	Else
		Return Value
	EndIf
EndFunction

Float[] Function GetWeightClassFactors()
	Float[] WeightClassFactors = New Float[3]
	Float HeavyArmorMod = ClampTo(Target.GetActorValue("HeavyArmorMod"), 0.0, 100.0)
	Float LightArmorMod = ClampTo(Target.GetActorValue("LightArmorMod"), 0.0, 100.0)
	WeightClassFactors[0] = 1.0 - LightArmorMod * 0.01
	WeightClassFactors[1] = 1.0 - HeavyArmorMod * 0.01
	WeightClassFactors[2] = 1.0 - LightArmorMod * 0.01
	Return WeightClassFactors
EndFunction

Function UpdateMassEffect()
	GoToState("Busy")
	Update = False
	If Finish
		UpdateMass(0.0)
		UpdatePenalty(0.0)
		Return
	EndIf
	Armor[] Equipped = GetEquippedArmors()
	Float[] WeightClassFactors = GetWeightClassFactors()
	Float NewMass = 0.0
	Float NewPenalty = 0.0
	Int i = 0
	While i < Equipped.Length
		If Equipped[i] != None
			Int WeightClass = Equipped[i].GetWeightClass()
			Float Mass = Equipped[i].GetWeight() * 0.01
			NewMass += Mass
			NewPenalty += WeightClassFactors[WeightClass] * Mass
		EndIf
		i += 1
	EndWhile
	UpdateMass(NewMass)
	UpdatePenalty(NewPenalty)
	GoToState("")
	If Update
		UpdateMassEffect()
	EndIf
EndFunction

Function UpdateMass(Float NewMass)
	If NewMass != ActiveMass
		Float DiffMass = NewMass - ActiveMass
		Target.ModActorValue("Mass", DiffMass)
		Target.SetActorValue("AlterationSkillAdvance", 100.0 * NewMass)
		ActiveMass = NewMass
	EndIf
EndFunction

Function UpdatePenalty(Float NewPenalty)
	If NewPenalty != ActivePenalty
		Float DiffPenalty = NewPenalty - ActivePenalty
		Target.ModActorValue("Infamy", DiffPenalty)
		Target.ModActorValue("MovementNoiseMult", DiffPenalty)
		Target.ModActorValue("SpeedMult", -50.0 * DiffPenalty)
		ActivePenalty = NewPenalty
	EndIf
EndFunction

State Busy
	Function UpdateMassEffect()
		Update = True
	EndFunction
EndState
