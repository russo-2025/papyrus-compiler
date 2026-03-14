Scriptname REQ_SwapTo Extends ObjectReference

Form Property Remove Auto
{item to be removed (must be the same item the script is attached to; a stupid redundancy but unfortunately Self doesn't work in this case)}
Form[] Property Add Auto
{item(s) to be added}


Event OnContainerChanged(ObjectReference NewContainer, ObjectReference OldContainer)
	NewContainer.RemoveItem(Remove, 1, True)
	Int i = 0
	While i < Add.Length
		If i == 0
			NewContainer.AddItem(Add[i], 1, True) ; hide the receiving notification for the first item (the notification is already displayed for the item the script is attached to)
		Else
			NewContainer.AddItem(Add[i], 1, False)
		EndIf
		i += 1
	EndWhile
EndEvent