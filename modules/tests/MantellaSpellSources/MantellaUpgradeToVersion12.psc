Scriptname MantellaUpgradeToVersion12 extends Quest hidden

event OnInit()
    MantellaMCM mantellaMCMQuest = Quest.GetQuest("MantellaMCM") as MantellaMCM
    MantellaMCMQuest.Stop()
    MantellaMCMQuest.Start()
    MantellaMCMQuest.OnConfigInit()
    MantellaRepository repository = Quest.GetQuest("MantellaQuest") as MantellaRepository
    repository.assignDefaultSettings(0,true)
endEvent

; event OnInit()
;     Debug.MessageBox("Detecting old version of Mantella in this save. MCM settings will be reset once.")

;     string[] questsToStop = new string[9]
;     questsToStop[0] = "MantellaActorList"
;     questsToStop[1] = "MantellaEvents"
;     questsToStop[2] = "MantellaRadiantDialogue"
;     questsToStop[3] = "MantellaRadiantDialogueActorPicker"
;     questsToStop[4] = "MantellaConversation"
;     questsToStop[5] = "MantellaConversationParticipantsQuest"
;     questsToStop[6] = "MantellaDialogue"
;     questsToStop[7] = "MantellaMCM"
;     questsToStop[8] = "MantellaQuest"

;     int index = 0
;     While (index < questsToStop.Length)
;         string questName = questsToStop[index]
;         Quest questToClose = Quest.GetQuest(questName)
;         if(questToClose.IsRunning())
;             Debug.MessageBox("Detecting " + questName + ". Stoppping quest.")
;             questToClose.Stop()
;         endif
;         index += 1
;     EndWhile

;     string[] questsToRestart = new string[2]
;     questsToRestart[0] = "MantellaQuest"
;     questsToRestart[1] = "MantellaDialogue"
    
;     index = 0
;     While (index < questsToRestart.Length)
;         string questName = questsToRestart[index]
;         Quest questToRestart = Quest.GetQuest(questName)
;         if(!questToRestart.IsRunning())
;             Debug.MessageBox("Starting " + questName)
;             questToRestart.Start()
;         endif
;         index += 1
;     EndWhile

;     ;restart MCM separately because of required OnConfigInit call
;     MantellaMCM mantellaMCMQuest = Quest.GetQuest("MantellaMCM") as MantellaMCM
;     mantellaMCMQuest.Start()
;     mantellaMCMQuest.OnConfigInit()
;     Debug.MessageBox("Starting MantellaMCM")
; endEvent