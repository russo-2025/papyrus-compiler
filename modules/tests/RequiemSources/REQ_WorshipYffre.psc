ScriptName REQ_WorshipYffre Extends ActiveMagicEffect

Message Property WorshipPrompt Auto

GlobalVariable Property FollowsGreenPact Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Int Choice = WorshipPrompt.Show()
	If Choice == 0
		FollowsGreenPact.SetValue(1.0)
	Else
		FollowsGreenPact.SetValue(0.0)
	EndIf
EndEvent
