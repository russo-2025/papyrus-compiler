ScriptName REQ_AncientDawnguardWarAxe Extends Quest

Enchantment Property DawnguardRuneWarAxeEnch Auto

GlobalVariable Property UndeadKilled Auto

REQ_ReapplyNonPersistentChanges Property ReapplyNonPersistentChanges Auto


Event OnUpdateGameTime()
	UndeadKilled.SetValue(0.0)
	RescaleEnchantment()
	ReapplyNonPersistentChanges.AncientDawnguardWarAxeScript = None
	Stop()
EndEvent

Function ResetOnDawn()
	ReapplyNonPersistentChanges.AncientDawnguardWarAxeScript = Self
	Float CurrentGameTime = Utility.GetCurrentGameTime()
	Float CurrentTime = (CurrentGameTime - Math.Floor(CurrentGameTime)) * 24
	Float TimeUntilDawn
	If CurrentTime < 5.0
		TimeUntilDawn = 5.0 - CurrentTime
	Else
		TimeUntilDawn = 29.0 - CurrentTime
	EndIf
	RegisterForSingleUpdateGameTime(TimeUntilDawn)
EndFunction

Function ReapplyNonPersistentChanges()
	RescaleEnchantment()
EndFunction

Function RescaleEnchantment()
	Float Magnitude = UndeadKilled.GetValue() * 10.0
	If Magnitude > 100.0
		Magnitude = 100.0
	EndIf
	DawnguardRuneWarAxeEnch.SetNthEffectMagnitude(1, Magnitude)
EndFunction
