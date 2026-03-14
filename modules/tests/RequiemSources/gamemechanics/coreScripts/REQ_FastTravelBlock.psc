Scriptname REQ_FastTravelBlock extends REQ_CoreScript
{block fast travel features unless the player is riding a tamed dragon}

GlobalVariable Property FastTravelAllowed Auto
ReferenceAlias Property DLC2TameDragon Auto

Event OnMenuOpen(String MenuName)
	If (!FastTravelAllowed.GetValue())
		Game.EnableFastTravel(False)
        Actor TamedDragon = DLC2TameDragon.GetReference() as Actor
        If (Game.GetPlayer().IsOnMount() && TamedDragon && TamedDragon.IsBeingRidden())
            Game.EnableFastTravel(True) ;the player is riding a dragon
		EndIf
	Else
		Game.EnableFastTravel(True)
	EndIf
EndEvent

Function initScript(Int currentVersion, Int nevVersion)
    Utility.Wait(0.5)
	If (!FastTravelAllowed.GetValue())
		Game.EnableFastTravel(False)
	Else
		Game.EnableFastTravel(True)
	EndIf
	RegisterForMenu("MapMenu")
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
	Game.EnableFastTravel(True)
	UnregisterForAllMenus()
EndFunction
