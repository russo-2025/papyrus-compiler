ScriptName REQ_CW02_RalofWarhammer Extends Actor
{Prevent Ralof from receiving a warhammer during The Jagged Crown}

Quest Property CW02A Auto
Quest Property CW02B Auto

Weapon Property RalofWarhammer Auto


Event OnInit()
	AddInventoryEventFilter(RalofWarhammer)
EndEvent


Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If (CW02A.IsRunning() || CW02B.IsRunning())
		RemoveItem(akBaseItem)
		RemoveAllInventoryEventFilters()
	EndIf
EndEvent
