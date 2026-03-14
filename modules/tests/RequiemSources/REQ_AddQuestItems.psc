ScriptName REQ_AddQuestItems Extends ObjectReference
{Adds items to a container or NPC reference after a certain quest stage is reached}

Form[] Property Items Auto
{Items that will be added to this container}
Int[] Property Amount Auto
{If empty, all items will be added by an amount of 1}
Int Property Stage Auto
{Items are only added after MyQuest has reached this stage}
Quest Property MyQuest Auto


Bool Done = False


Event OnLoad()
	If !Done && MyQuest.GetStageDone(Stage)
		Int i = 0
		If !Amount
			While i < Items.Length
				Additem(Items[i], 1, True)
				i += 1
			EndWhile
		Else
			While i < Items.Length
				Additem(Items[i], Amount[i], True)
				i += 1
			EndWhile
		EndIf
		Done = True
	EndIf
EndEvent
