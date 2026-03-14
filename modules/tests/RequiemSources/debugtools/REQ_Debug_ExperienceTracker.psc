ScriptName REQ_Debug_ExperienceTracker Extends ReferenceAlias
{Display experience gains in periodic intervals}

GlobalVariable Property UpdateInterval Auto

Actor Player
Int[] SkillLevel
Float[] SkillXP
String[] ActorValue


Event OnInit()
	Player = Game.GetPlayer()
	ActorValue = New String[18]
	ActorValue[0] = "Alchemy"
	ActorValue[1] = "Alteration"
	ActorValue[2] = "Block"
	ActorValue[3] = "Conjuration"
	ActorValue[4] = "Destruction"
	ActorValue[5] = "Enchanting"
	ActorValue[7] = "HeavyArmor"
	ActorValue[8] = "Illusion"
	ActorValue[6] = "LightArmor"
	ActorValue[9] = "Lockpicking"
	ActorValue[10] = "Marksman"
	ActorValue[11] = "OneHanded"
	ActorValue[12] = "Pickpocket"
	ActorValue[13] = "Restoration"
	ActorValue[14] = "Smithing"
	ActorValue[15] = "Sneak"
	ActorValue[16] = "Speechcraft"
	ActorValue[17] = "TwoHanded"
	SkillLevel = New Int[18]
	SkillXP = New Float[18]
EndEvent

Event OnUpdate()
	; Inactive
EndEvent


State Active

	Event OnBeginState()
		Int i = 0
		While (i < ActorValue.Length)
			SkillLevel[i] = Player.GetBaseActorValue(ActorValue[i]) As Int
			SkillXP[i] = ActorValueInfo.GetActorValueInfoByName(ActorValue[i]).GetSkillExperience()
			i += 1 
		EndWhile
		RegisterForSingleUpdate(UpdateInterval.GetValue())
	EndEvent

	Event OnUpdate()
		Int i = 0
		While (i < ActorValue.Length)
			ActorValueInfo SkillInfo = ActorValueInfo.GetActorValueInfoByName(ActorValue[i])
			Int NewSkillLevel = Player.GetBaseActorValue(ActorValue[i]) As Int
			Float NewSkillXP = SkillInfo.GetSkillExperience()
			If (SkillLevel[i] != NewSkillLevel || SkillXP[i] != NewSkillXP)
				Float XPGained = 0.0
				If (SkillLevel[i] == NewSkillLevel)
					XPGained = NewSkillXP - SkillXP[i]
				Else
					XPGained = SkillInfo.GetExperienceForLevel(SkillLevel[i]) - SkillXP[i]
					Int ItrSkillLevel = SkillLevel[i] + 1
					While (ItrSkillLevel < NewSkillLevel)
						XPGained += SkillInfo.GetExperienceForLevel(ItrSkillLevel)
						ItrSkillLevel += 1
					EndWhile
					XPGained += NewSkillXP
				EndIf
				Debug.Notification(ActorValue[i] + " XP increased by " + XPGained)
				SkillLevel[i] = NewSkillLevel
				SkillXP[i] = NewSkillXP
			EndIf
			i += 1 
		EndWhile
		RegisterForSingleUpdate(UpdateInterval.GetValue())
	EndEvent

EndState
