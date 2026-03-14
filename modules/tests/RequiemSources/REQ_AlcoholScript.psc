ScriptName REQ_AlcoholScript Extends ActiveMagicEffect  

REQ_AlcoholEffectsPlayer Property Controller Auto

GlobalVariable Property AlcoholLevelStorage Auto

Float Mag

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer()
		Mag = GetMagnitude()
		AlcoholLevelStorage.Mod(Mag)
		; Due to Papyrus' asynchronous nature there is a high chance that the
		; penalties are updated before the alcohol storage is modified. As a
		; workaround, we just update the penalties a second time.
		Controller.UpdatePlayerAlcoholPenalties()
		Controller.UpdatePlayerAlcoholPenalties()
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer()
		AlcoholLevelStorage.Mod(-Mag)
		; Due to Papyrus' asynchronous nature there is a high chance that the
		; penalties are updated before the alcohol storage is modified. As a
		; workaround, we just update the penalties a second time.
		Controller.UpdatePlayerAlcoholPenalties()
		Controller.UpdatePlayerAlcoholPenalties()
	EndIf
EndEvent
