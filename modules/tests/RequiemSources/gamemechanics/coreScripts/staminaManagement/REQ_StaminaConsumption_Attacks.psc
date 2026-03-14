Scriptname REQ_StaminaConsumption_Attacks extends REQ_CoreScript
{This script is responsible for the stamina drain for normal attacks for ALL actors}

Spell Property StaminaDrain Auto

Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	akActor.AddSpell(StaminaDrain, False)
EndEvent

Event OnPlayerLoadGame()
    parent.OnPlayerLoadGame()
	RegisterForActorAction(5)
	RegisterForActorAction(0)
EndEvent

Function initScript(Int currentVersion, Int nevVersion)
	RegisterForActorAction(5)
	RegisterForActorAction(0)
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
EndFunction