Scriptname TestHeaderSubfolder extends Form

Event OnPlayerLoadGame()
    RegisterForModEvent("TestHeaderSubfolderEvent", "OnTestHeaderSubfolderEvent")
EndEvent

Event OnTestHeaderSubfolderEvent(string eventName, string strArg, float numArg, Form sender)
EndEvent
