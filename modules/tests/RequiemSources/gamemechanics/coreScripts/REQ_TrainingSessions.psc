Scriptname REQ_TrainingSessions extends REQ_CoreScript
{sets the global flag that disables experience-rate rescaling effects during training sessions}

GlobalVariable Property REQ_Player_Is_Training Auto

Event OnMenuOpen(String menuName)
    REQ_Player_Is_Training.SetValueInt(1)
EndEvent

Event OnMenuClose(String menuName)
    REQ_Player_Is_Training.SetValueInt(0)
EndEvent

Function initScript(Int currentVersion, Int nevVersion)
    RegisterForMenu("Training Menu")
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
    UnregisterForAllMenus()
EndFunction