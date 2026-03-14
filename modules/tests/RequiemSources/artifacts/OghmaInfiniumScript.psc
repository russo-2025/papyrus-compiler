Scriptname OghmaInfiniumScript extends ObjectReference  

Quest Property DA04 auto
Message Property ChoiceMessage auto
int Property Advancement auto
bool Property HasBeenRead auto
Book Property MySelf auto

Function ReadOghmaInfinium(bool fromWorld)
    GoToState("Reading")
	Utility.WaitMenuMode(2.0)
	if (HasBeenRead || !DA04.GetStageDone(200)) || ((Game.GetFormFromFile(0x010009DE, "Update.esm") as GlobalVariable).GetValue() >= 1)
    	GoToState("")
		return
	endif

	int choice = ChoiceMessage.Show()
	if     (choice == 0)
		; do nothing
	elseif (choice == 1)
; 		Debug.Trace("DA04: Player chose path of might.")
		Game.GetPlayer().ModActorValue("Health", 200.0)
	elseif (choice == 2)
; 		Debug.Trace("DA04: Player chose path of endurance.")
		Game.GetPlayer().ModActorValue("Stamina", 200.0)
	elseif (choice == 3)
; 		Debug.Trace("DA04: Player chose path of magic.")
		Game.GetPlayer().ModActorValue("Magicka", 200.0)
	else
		; WTF
	endif

	if (choice != 0)
		Game.AddPerkPoints(7)
		HasBeenRead = True
		(Game.GetFormFromFile(0x010009DE, "Update.esm") as GlobalVariable).SetValue(1)
		Utility.Wait(0.1)
		int oghmasInfinium = Game.GetPlayer().GetItemCount(MySelf)
		Game.GetPlayer().RemoveItem(MySelf, oghmasInfinium)
		if (fromWorld && oghmasInfinium == 0) ; this trusts that the book hasn't been duped somehow
			Delete()
		endif
		utility.WaitMenuMode(0)
	endif
	GoToState("")
EndFunction

Event OnEquipped(Actor reader)
	if (reader != Game.GetPlayer())
		return
	endif

; 	Debug.Trace("DA04: Player reading Oghma Infinium from inventory.")
	ReadOghmaInfinium(false)
EndEvent

Event OnActivate(ObjectReference reader)
	if (reader != Game.GetPlayer() || IsActivationBlocked())
		return
	endif

; 	Debug.Trace("DA04: Player reading Oghma Infinium from world.")
	ReadOghmaInfinium(true)
EndEvent

State Reading
    Function ReadOghmaInfinium(Bool fromWorld)
    EndFunction
EndState