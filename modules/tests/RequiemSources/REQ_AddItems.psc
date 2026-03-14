Scriptname REQ_AddItems extends ObjectReference
{Adds items to a container or NPC reference}

Form[] Property Items Auto
{array of item objects}
Int[] Property Amount Auto
{array of quantity for each corresponding item; without this array, all items will be added by an amount of 1}

Bool InitDone = False ; prevents items from being added again

Event OnLoad()
	If !InitDone
		int i = 0
		If !Amount
			While i < Items.Length
				Self.Additem(Items[i], 1, True)
				i += 1
			EndWhile
		Else
			While i < Items.Length
				Self.Additem(Items[i], Amount[i], True)
				i += 1
			EndWhile
		EndIf
		InitDone = True
	EndIf
EndEvent