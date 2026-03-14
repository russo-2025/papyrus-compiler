Scriptname REQ_AutoUpdater extends ReferenceAlias
{auto-update routine for Requiem core scripts}

Quest[] Property coreScripts Auto
{a list of all quests hosting core scripts managed by this Update-Manager (one core script per quest)}

Bool[] InitFinished
Bool[] ShutdownFinished

Event OnInit()
    ShutdownFinished = Utility.createBoolArray(coreScripts.length, false)
    InitFinished = Utility.createBoolArray(coreScripts.length, false)
	RegisterForModEvent("Requiem_ScriptShutDownFinished", "OnScriptShutdownFinished")
    RegisterForModEvent("Requiem_ScriptInitFinished", "OnScriptInitFinished")
EndEvent

Event OnScriptInitFinished(Form changedQuest)
    Int index = CoreScripts.find(changedQuest as Quest)
    If (index >= 0)
        InitFinished[index] = true
    EndIf
EndEvent

Event OnScriptShutdownFinished(Form changedQuest)
    Int index = CoreScripts.find(changedQuest as Quest)
    If (index >= 0)
        ShutdownFinished[index] = true
    EndIf
EndEvent

Bool Function initScripts(Int currentVersion, Int newVersion)
    Int count = 0
    While (count < coreScripts.Length)
        coreScripts[count].start()
        count += 1
    EndWhile
    Utility.Wait(1.0)
    int handle = ModEvent.Create("Requiem_ScriptInit")
    ModEvent.PushInt(handle, currentVersion)
    ModEvent.PushInt(handle, newVersion)
    ModEvent.Send(handle)
    Int checkCounter = 0
    While (checkCounter < 40)
        If ( InitFinished.find(False) < 0 )
    		return true
    	Else
    		Utility.Wait(1.0)
    		checkCounter += 1
    	EndIf
    EndWhile
    LogFailingScripts("Init")
    return false
EndFunction

Bool Function shutdownScripts(Int currentVersion, Int newVersion)
    Utility.Wait(1.0)
    int handle = ModEvent.Create("Requiem_ScriptShutdown")
    ModEvent.PushInt(handle, currentVersion)
    ModEvent.PushInt(handle, newVersion)
    ModEvent.Send(handle)
    Int checkCounter = 0
    While (checkCounter < 40)
        If ( ShutdownFinished.find(False) < 0 )
            Int count = 0
            While (count < coreScripts.Length)
                coreScripts[count].stop()
                count += 1
            EndWhile
            return true
        Else
            Utility.Wait(1.0)
            checkCounter += 1
        EndIf
    EndWhile
    LogFailingScripts("Shutdown")
    return false
EndFunction

Function LogFailingScripts(String operation)
    Debug.Trace("[REQ] ERROR: Script " + operation + " Failed! Dumping Script States!")
    Bool[] states
    If (operation == "Init")
        states = InitFinished
    Else
        states = ShutDownFinished
    EndIf

	int count = 0
    While count < coreScripts.Length
        Debug.Trace("[REQ] ERROR: Script " + coreScripts[count].getName() + " - ready: " + states[count])
        count += 1
    EndWhile
EndFunction

Event OnPlayerLoadGame()
    RegisterForModEvent("Requiem_ScriptShutDownFinished", "OnScriptShutdownFinished")
    RegisterForModEvent("Requiem_ScriptInitFinished", "OnScriptInitFinished")
    (GetOwningQuest() as REQ_VersionController).checkSetup()
	(GetOwningQuest() as REQ_VersionController).triggerUpdateIfNeeded()
EndEvent
