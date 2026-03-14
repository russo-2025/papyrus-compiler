Scriptname QF_REQ_Quest_Installation Extends Quest Hidden

Function Fragment_0()
    kmyQuest.SetObjectiveDisplayed(0, true)
    (kmyQuest as REQ_Installation).registerForUpdate(30)
EndFunction

Function Fragment_10()
    kmyQuest.completeAllObjectives()
    kmyQuest.completeQuest()
    kmyQuest.stop()
EndFunction

Quest Property kmyQuest Auto