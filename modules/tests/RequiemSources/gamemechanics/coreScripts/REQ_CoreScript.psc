Scriptname REQ_CoreScript extends ReferenceAlias
{template for Requiem core scripts that need to be updated when a new Requiem version is installed}

Actor Property Player Auto
{will be filled automatically on start-up}

Event OnInit()
	Player = Game.GetPlayer()
	RegisterForModEvent("Requiem_ScriptShutDown", "OnScriptShutDown")
    RegisterForModEvent("Requiem_ScriptInit", "OnScriptInit")
EndEvent

Event OnPlayerLoadGame()
	RegisterForModEvent("Requiem_ScriptShutDown", "OnScriptShutDown")
    RegisterForModEvent("Requiem_ScriptInit", "OnScriptInit")
EndEvent

; overwrite this function with the code the script need to perform on start up
Function initScript(Int currentVersion, Int newVersion)
    Debug.Messagebox("abstract function initScript not overwritten in Requiem core script!")
EndFunction

; overwrite this function with all the clean up code necessary before the script can safely be removed from the player
Function shutdownScript(Int currentVersion, Int newVersion)
    Debug.Messagebox("abstract function shutdownScript not overwritten in Requiem core script!")
EndFunction

Event OnScriptShutDown(Int currentVersion, Int newVersion)
    shutdownScript(currentVersion, newVersion)
    int handle = ModEvent.Create("Requiem_ScriptShutdownFinished")
    ModEvent.PushForm(handle, self.getOwningQuest())
    ModEvent.Send(handle)
EndEvent

Event OnScriptInit(Int currentVersion, Int newVersion)
    initScript(currentVersion, newVersion)
    int handle = ModEvent.Create("Requiem_ScriptInitFinished")
    ModEvent.PushForm(handle, self.getOwningQuest())
    ModEvent.Send(handle)
EndEvent
