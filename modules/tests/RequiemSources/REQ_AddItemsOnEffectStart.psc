ScriptName REQ_AddItemsOnEffectStart Extends ActiveMagicEffect

Form[] Property ItemsToAdd Auto

Int[] Property Amount Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Int i = 0
	While i < ItemsToAdd.Length
		If Amount != None
			akTarget.AddItem(ItemsToAdd[i], Amount[i])
		Else
			akTarget.AddItem(ItemsToAdd[i])
		EndIf
		i += 1
	EndWhile
EndEvent
