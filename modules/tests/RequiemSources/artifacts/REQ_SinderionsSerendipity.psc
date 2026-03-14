ScriptName REQ_SinderionsSerendipity Extends ActiveMagicEffect

Ingredient Property IsAlreadyRescaled Auto
Ingredient Property Nirnroot Auto
Ingredient Property NirnrootRed Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RescaleNirnroot()
EndEvent

Event OnPlayerLoadGame()
	RescaleNirnroot()
EndEvent

Function RescaleNirnroot()
	If IsAlreadyRescaled.GetNthEffectMagnitude(0) != 0.0
		Return
	EndIf
	IsAlreadyRescaled.SetNthEffectMagnitude(0, 1.0)
	ScaleEffectiveness(Nirnroot)
	ScaleEffectiveness(NirnrootRed)
EndFunction

Function ScaleEffectiveness(Ingredient ingredient_)
	Float factor = 1.0 + GetMagnitude() * 0.01
	Int numEffects = ingredient_.GetNumEffects()
	Int i = 0
	While i < numEffects
		MagicEffect effect = ingredient_.GetNthEffectMagicEffect(i)
		If effect.IsEffectFlagSet(0x00200000)
			Float oldMagnitude = ingredient_.GetNthEffectMagnitude(i)
			Float newMagnitude = oldMagnitude * factor
			ingredient_.SetNthEffectMagnitude(i, newMagnitude)
		EndIf
		If effect.IsEffectFlagSet(0x00400000)
			Int oldDuration = ingredient_.GetNthEffectDuration(i)
			Int newDuration = (oldDuration * factor) As Int
			ingredient_.SetNthEffectDuration(i, newDuration)
		EndIf
		i += 1
	EndWhile
EndFunction
