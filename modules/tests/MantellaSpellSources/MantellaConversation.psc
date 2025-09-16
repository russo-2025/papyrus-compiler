Scriptname MantellaConversation extends Quest hidden

Import SKSE_HTTP
Import Utility

Topic property MantellaDialogueLine1 auto
Topic property MantellaDialogueLine2 auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
Faction Property MantellaConversationParticipantsFaction Auto
FormList Property Participants auto
Quest Property MantellaConversationParticipantsQuest auto
SPELL Property MantellaIsTalkingSpell Auto
MantellaEquipmentDescriber Property EquipmentDescriber auto
Actor Property PlayerRef Auto
VoiceType Property MantellaVoice00  Auto  
MantellaInterface property EventInterface Auto
ReferenceAlias Property Narrator Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Globals           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String[] _ingameEvents
String[] _extraRequestActions
int[] _actorHandles = None
bool _actorsUpdated = false
int _contextHandle = 0
bool _does_accept_player_input = false
bool _isTalking = false
bool _hasBeenStopped = true
Actor _lastNpcToSpeak = None
string _lastSpeakerName = ""
string _repeatingMessage = ""
string _location = ""
int _initialTime = 0
bool _useNarrator = False
int _lastTopicInfo = 0
float httpReceivedTime = 0.0
string lineToSpeakError = "Error: No line transmitted for actor to speak"
bool microphoneEnabledLastKnownStatus = false

event OnInit()
    RegisterForConversationEvents()
EndEvent

event OnPlayerLoadGame()
    RegisterForConversationEvents()
endEvent

Function RegisterForConversationEvents()
    RegisterForModEvent("SKSE_HTTP_OnHttpReplyReceived","OnHttpReplyReceived")
    RegisterForModEvent("SKSE_HTTP_OnHttpErrorReceived","OnHttpErrorReceived")
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_RELOADCONVERSATION,"OnReloadConversationActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_ENDCONVERSATION,"OnEndConversationActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_REMOVECHARACTER,"OnRemoveCharacterActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADD_EVENT,"OnAddEventReceived")
EndFunction

event OnUpdate()
    If (_repeatingMessage != "")
        Debug.Notification(_repeatingMessage)
        RegisterForSingleUpdate(10)
    EndIf
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Start new conversation   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function StartConversation(Actor[] actorsToStartConversationWith)
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_INIT)
    ; send request to initialize Mantella settings (set LLM connection, start up TTS service, load character_df etc) 
    ; while waiting for actor info and context to be prepared below
    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
    
    AddActors(actorsToStartConversationWith)

    if(actorsToStartConversationWith.Length < 2)
        Debug.Notification("Not enough characters to start a conversation.")
        return
    endIf
    
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_STARTCONVERSATION)
    SKSE_HTTP.setString(handle, mConsts.KEY_STARTCONVERSATION_WORLDID, PlayerRef.GetDisplayName() + repository.worldID)
    BuildContext(true)
    AddCurrentActorsAndContext(handle, true)

    if repository.microphoneEnabled
        if repository.useHotkeyToStartMic
            SKSE_HTTP.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_PTT)
        else
            SKSE_HTTP.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_MIC)
        endIf
    Else
        SKSE_HTTP.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_TEXT)
    endIf
    microphoneEnabledLastKnownStatus = repository.microphoneEnabled

    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
    ; string address = "http://localhost:" + mConsts.HTTP_PORT + "/" + mConsts.HTTP_ROUTE_MAIN
    ; Debug.Notification("Sent StartConversation http request to " + address)
    int eventHandle = ModEvent.Create(EventInterface.EVENT_CONVERSATION_STARTED)
    if (eventHandle)        
        ModEvent.Send(eventHandle)
    endIf 
    MantellaVanillaDialogue.notifyConversationStart()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Continue conversation    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddActorsToConversation(Actor[] actorsToAdd)
    AddActors(actorsToAdd)    
EndFunction

Function RemoveActorsFromConversation(Actor[] actorsToRemove)
    RemoveActors(actorsToRemove)  
EndFunction

Function SetIsTalking(bool isTalking)
    _isTalking = isTalking
EndFunction

bool Function GetIsTalking()
    return _isTalking
EndFunction

int Function GetNextTopicID()
    If (_lastTopicInfo == 0 || _lastTopicInfo == 2)
        return 1
    Else
        return 2
    EndIf
EndFunction

Topic Function GetTopicToUse(int transmittedID)
    If (transmittedID == 2)
        return MantellaDialogueLine2
    Else
        return MantellaDialogueLine1
    EndIf
EndFunction

event OnHttpReplyReceived(int typedDictionaryHandle)
    ; httpReceivedTime = Utility.GetCurrentRealTime()
    ; NOTE: When testing run times, remember to factor in the time it takes to trace a message (noted below) and subtract this number to get the "true" operation run time
    ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to trace a message", 2)
    string replyType = SKSE_HTTP.getString(typedDictionaryHandle, mConsts.KEY_REPLYTYPE ,"error")
    ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to determine reply type", 2)
    IF replyType == mConsts.KEY_REPLYTTYPE_INITCOMPLETED
        None
    ElseIf (replyType != "error")
        ContinueConversation(replyType, typedDictionaryHandle)        
    Else
        string errorMessage = SKSE_HTTP.getString(typedDictionaryHandle, "mantella_message","Error: Received an error reply from MantellaSoftware but there was no error message attached.")
        Debug.Notification(errorMessage)
        CleanupConversation()
    EndIf
endEvent

function ContinueConversation(string nextAction, int handle)
    ; Debug.Notification(nextAction)
    if(nextAction == mConsts.KEY_REPLYTTYPE_STARTCONVERSATIONCOMPLETED)
        _hasBeenStopped = false
        if(SKSE_HTTP.hasKey(handle,mConsts.KEY_STARTCONVERSATION_USENARRATOR))
            _useNarrator = SKSE_HTTP.getBool(handle, mConsts.KEY_STARTCONVERSATION_USENARRATOR, false)
        endif
        ;Debug.Notification("Conversation started.")
        RequestContinueConversation()
    elseIf(nextAction == mConsts.KEY_REPLYTYPE_NPCTALK)
        ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to realise NPC needs to respond", 2)
        int npcTalkHandle = SKSE_HTTP.getNestedDictionary(handle, mConsts.KEY_REPLYTYPE_NPCTALK)
        ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to get NPC talk handle", 2)
        ProcessNpcSpeak(npcTalkHandle)
        RequestContinueConversation()
    elseIf(nextAction == mConsts.KEY_REPLYTYPE_PLAYERTALK)
        _does_accept_player_input = True
        If (repository.microphoneEnabled && !repository.useHotkeyToStartMic)
            sendRequestForVoiceTranscribe()
        Else
            ShowRepeatingMessage("Awaiting player input...")
        EndIf
    elseIf (nextAction == mConsts.KEY_REQUESTTYPE_TTS)
        ClearRepeatingMessage()
        string transcribe = SKSE_HTTP.getString(handle, mConsts.KEY_TRANSCRIBE, "*Complete gibberish*")
        sendRequestForPlayerInput(transcribe, updateContext=True)
    elseIf(nextAction == mConsts.KEY_REPLYTYPE_NPCACTION)
        int npcActionHandle = SKSE_HTTP.getNestedDictionary(handle, mConsts.KEY_REPLYTYPE_NPCACTION)
        ProcessNpcSpeak(npcActionHandle)
        RequestContinueConversation()
    elseIf(nextAction == mConsts.KEY_REPLYTYPE_ENDCONVERSATION)
        CleanupConversation()
    endIf
endFunction

function RequestContinueConversation()
    if(!_hasBeenStopped)    
        int handle = SKSE_HTTP.createDictionary()
        SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_CONTINUECONVERSATION)

        int nextTopicInfo = GetNextTopicID()
        SKSE_HTTP.setInt(handle, mConsts.KEY_CONTINUECONVERSATION_TOPICINFOFILE, nextTopicInfo)
        _lastTopicInfo = nextTopicInfo

        if(_extraRequestActions && _extraRequestActions.Length > 0)
            ;Debug.Notification("_extraRequestActions contains items. Sending them along with continue!")
            SKSE_HTTP.setStringArray(handle, mConsts.KEY_REQUEST_EXTRA_ACTIONS, _extraRequestActions)
            ClearExtraRequestAction()
            ;Debug.Notification("_extraRequestActions got cleared. Remaining items: " + _extraRequestActions.Length)
        endif

        if _actorsUpdated
            SKSE_HTTP.setNestedDictionariesArray(handle, mConsts.KEY_ACTORS, _actorHandles)
            _actorsUpdated = false
        endIf

        if repository.microphoneEnabled != microphoneEnabledLastKnownStatus
            if repository.microphoneEnabled
                if repository.useHotkeyToStartMic
                    SKSE_HTTP.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_PTT)
                else
                    SKSE_HTTP.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_MIC)
                endIf
            Else
                SKSE_HTTP.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_TEXT)
            endIf
            microphoneEnabledLastKnownStatus = repository.microphoneEnabled
        endIf

        SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
    EndIf
endFunction

function ProcessNpcSpeak(int handle)
    string speakerName = SKSE_HTTP.getString(handle, mConsts.KEY_ACTOR_SPEAKER, "Error: No speaker transmitted for action 'NPC talk'")
    ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to get speaker name", 2)
    ;Debug.Notification("Transmitted speaker name: "+ speakerName)
    Actor speaker = None
    bool isNarration = False
    float lineDuration = 0
    if _useNarrator
        isNarration = SKSE_HTTP.getBool(handle, mConsts.KEY_ACTOR_ISNARRATION, false)
    endIf
    if isNarration
        speaker = Narrator.GetReference() as Actor
        speakerName = "MantellaNarrator"
        lineDuration = SKSE_HTTP.getFloat(handle, mConsts.KEY_ACTOR_DURATION, 0)
        ;Debug.Notification("Using Narrator.")
    ; If actor is already loaded, do not load again from actors list
    elseif speakerName == _lastSpeakerName
        speaker = _lastNpcToSpeak
    else
        speaker = GetActorInConversation(speakerName)
    endIf
    
    ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " to get actor based on speaker name", 2)
    ;Debug.Notification("Chosen Actor: "+ speaker.GetDisplayName())

    if speaker != none
        WaitForNpcToFinishSpeaking(speaker, _lastNpcToSpeak)
        ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to wait for last NPC to finish speaking", 2)
        string lineToSpeak = SKSE_HTTP.getString(handle, mConsts.KEY_ACTOR_LINETOSPEAK, lineToSpeakError)
        ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to prepare response data", 2)
        int topicID = SKSE_HTTP.getInt(handle, mConsts.KEY_CONTINUECONVERSATION_TOPICINFOFILE, 1)

        if lineToSpeak != lineToSpeakError
            Topic topicToUse = GetTopicToUse(topicID)
            bool isPlayer = speaker == PlayerRef
            if isPlayer
                VoiceType orgRaceDefaultVoice = SKSE_HTTP.GetRaceDefaultVoiceType(speaker)
                SKSE_HTTP.SetRaceDefaultVoiceType(speaker,MantellaVoice00)

                NpcSpeak(speaker, lineToSpeak, topicToUse, false, lineDuration)
                SKSE_HTTP.SetRaceDefaultVoiceType(speaker,orgRaceDefaultVoice)
            else
                VoiceType orgVoice = SKSE_HTTP.GetVoiceType(speaker)
                ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to get orinal voice type", 2)
                SKSE_HTTP.SetVoiceType(speaker, MantellaVoice00)
                ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to set voice type", 2)

                NpcSpeak(speaker, lineToSpeak, topicToUse, isNarration, lineDuration)
                SKSE_HTTP.SetVoiceType(speaker, orgVoice)
            endif
            _lastNpcToSpeak = speaker
            _lastSpeakerName = speakerName
        endIf
        ; Get actions only after the NPC starts speaking to improve response times
        string[] actions = SKSE_HTTP.getStringArray(handle, mConsts.KEY_ACTOR_ACTIONS)
        RaiseActionEvent(speaker, actions)
    endIf
endFunction

function WaitForVoiceAssignment(Actor speaker, bool isPlayer)
    bool hasVoiceChanged = false
    float totalWaitTime = 0
    VoiceType currentVoice
    while hasVoiceChanged == false
        if isPlayer
            currentVoice = SKSE_HTTP.GetRaceDefaultVoiceType(speaker)
        else
            currentVoice = SKSE_HTTP.GetVoiceType(speaker)
        endIf

        if currentVoice == MantellaVoice00
            hasVoiceChanged = true
        elseIf totalWaitTime > 5
            Debug.Notification("Could not assign voiceline to NPC")
            hasVoiceChanged = true
        else
            Utility.Wait(0.01)
            totalWaitTime += 0.01
        endIf
    endWhile
endFunction

function NpcSpeak(Actor actorSpeaking, string lineToSay, Topic topicToUse, bool isSpokenByNarrator, float lineDuration)
    MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(actorSpeaking, topicToUse, lineToSay)
    actorSpeaking.Say(topicToUse, abSpeakInPlayersHead=isSpokenByNarrator)
    ; Debug.Trace((Utility.GetCurrentRealTime() - httpReceivedTime) + " seconds to start speaking", 2)
    If (!isSpokenByNarrator)
        Actor NpcToLookAt = GetNpcToLookAt(actorSpeaking, _lastNpcToSpeak)
        actorSpeaking.SetLookAt(NpcToLookAt)
        NpcToLookAt.SetLookAt(actorSpeaking)
    Else
        ; Narrations do not have an actor to apply the IsTalking spell to, so a wait time needs to be forced here
        Utility.Wait(lineDuration)
    EndIf
    actorSpeaking.AddSpell(MantellaIsTalkingSpell, False)
endfunction

string function GetActorName(actor actorToGetName)
    string actorName = actorToGetName.GetDisplayName()
    int actorID = actorToGetName.GetFactionRank(MantellaConversationParticipantsFaction)
    if actorID > 0
        actorName = actorName + " " + actorID
    endIf
    return actorName
endFunction

Actor function GetActorInConversation(string actorName)
    int i = 0
    While i < Participants.GetSize()
        Actor currentActor = Participants.GetAt(i) as Actor
        if GetActorName(currentActor) == actorName
            return currentActor
        endIf
        i += 1
    EndWhile
    return none
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       End conversation      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnEndConversationActionReceived(Form speaker, string sentence)
    EndConversation()
endEvent

Function EndConversation()
    _hasBeenStopped = true
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE,mConsts.KEY_REQUESTTYPE_ENDCONVERSATION)
    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
EndFunction

Function CleanupConversation()
    int i = 0
    ClearParticipants()
    ClearRepeatingMessage()
    _ingameEvents = None
    _does_accept_player_input = false
    _isTalking = false
    _lastNpcToSpeak = None
    _lastTopicInfo = 0
    ;SKSE_HTTP.clearAllDictionaries()
    If (MantellaConversationParticipantsQuest.IsRunning())
        MantellaConversationParticipantsQuest.Stop()
    EndIf
    int handle = ModEvent.Create(EventInterface.EVENT_CONVERSATION_ENDED)
    if (handle)        
        ModEvent.Send(handle)
    endIf 
    MantellaVanillaDialogue.notifyConversationEnd()
    Debug.Notification("Conversation ended.")  
    Stop()
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      Remove character       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnRemoveCharacterActionReceived(Form speaker, string sentence)
    Actor[] actors = new Actor[2]
    actors[0] = speaker as Actor
    RemoveActors(actors)
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Handle player speaking    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function sendRequestForPlayerInput(string playerInput, bool updateContext)
    if(!_hasBeenStopped)
        int handle = SKSE_HTTP.createDictionary()
        SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_PLAYERINPUT)
        SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE_PLAYERINPUT, playerinput)

        if repository.targetTrackingAngerState ; only the anger state of the NPCs is updated by UpdateNpcsInConversationArray()
            UpdateNpcsInConversationArray()
        endIf
        SKSE_HTTP.setNestedDictionariesArray(handle, mConsts.KEY_ACTORS, _actorHandles)

        if updateContext ; if context has not been refreshed recently
            BuildContext()
        endIf
        SKSE_HTTP.setNestedDictionary(handle, mConsts.KEY_CONTEXT, _contextHandle)

        SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
    EndIf
endFunction

function sendRequestForVoiceTranscribe()
    if(!_does_accept_player_input)
        return
    Else
        _does_accept_player_input = False
    endif

    sendRequestForPlayerInput("", updateContext=True)
    ShowRepeatingMessage("Listening...")
endFunction

function GetPlayerTextInput()
    if(!_does_accept_player_input)
        return
    endif

    ; Sneak in context refresh before textbox opens
    ; As of writing, BuildContext() takes ~0.3 seconds to run,
    ; but if this runtime increases in the future the delay may become noticeable
    BuildContext()

    UIExtensions.InitMenu("UITextEntryMenu")
    UIExtensions.OpenMenu("UITextEntryMenu")

    string result = UIExtensions.GetMenuResultString("UITextEntryMenu")
    if (result && result != "")
        sendRequestForPlayerInput(result, updateContext=False)
        _does_accept_player_input = False
        ClearRepeatingMessage()
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     Handle NPC speaking     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor function GetNpcToLookAt(Actor speaker, Actor lastNpcToSpeak)
    Actor NpcToLookAt = None
    if (lastNpcToSpeak != speaker)
        if (lastNpcToSpeak != None)
            NpcToLookAt = lastNpcToSpeak
        else
            lastNpcToSpeak = speaker
            int i = 0
            while i < CountActorsInConversation()
                Actor tmpActor = GetActorInConversationByIndex(i)
                if GetActorName(tmpActor) != GetActorName(speaker)
                    NpcToLookAt = tmpActor
                endIf
                i += 1
            endWhile
            if IsPlayerInConversation()
                NpcToLookAt = PlayerRef
            endIf
        endIf
    elseIf IsPlayerInConversation()
        NpcToLookAt = PlayerRef
    endIf
    return NpcToLookAt
endFunction

function WaitForNpcToFinishSpeaking(Actor speaker, Actor lastNpcToSpeak)
    ; if this is the start of the conversation there is no need to wait, so skip this function entirely
    if lastNpcToSpeak != None
        ; if the current NPC did not speak last in a multi-NPC conversation, 
        ; wait for the last NPC to finish speaking to avoid interrupting
        ; and then cast the IsTalking spell on the current NPC (mainly to check that they are not speaking non-Mantella voicelines)
        if speaker != lastNpcToSpeak 
            WaitForSpecificNpcToFinishSpeaking(lastNpcToSpeak)
            speaker.AddSpell(MantellaIsTalkingSpell, False)
            Utility.Wait(0.01) ; allow time for _isTalking to be set
        endIf
        ; wait for the current NPC to finish speaking before starting the next voiceline
        WaitForSpecificNpcToFinishSpeaking(speaker)
    endIf
endFunction

function WaitForSpecificNpcToFinishSpeaking(Actor selectedNpc)
    float waitTime = 0.01
    float totalWaitTime = 0
    while _isTalking == true ; wait until the NPC has finished speaking
        Utility.Wait(waitTime)
        totalWaitTime += waitTime
        if totalWaitTime > 10 ; note that this isn't really in seconds due to the overhead of the loop running
            Debug.Notification("NPC speaking too long, ending wait...")
            _isTalking = false
        endIf
    endWhile
    selectedNpc.RemoveSpell(MantellaIsTalkingSpell)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Action handler        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function RaiseActionEvent(Actor speaker, string[] actions)
    if(!actions || actions.Length == 0)
        return ;dont send out an action event if there are no actions to act upon
    endIf
    
    int i = 0
    While i < actions.Length
        string extraAction = actions[i]
        ;AddIngameEvent("Recieved action " + extraAction + ". Sending out event!")
        ; if the action is to open the inventory menu, wait for the speaker to finish their voiceline first before the menu forces the game to pause
        if extraAction == mConsts.ACTION_NPC_INVENTORY
            Utility.Wait(0.5)
            WaitForNpcToFinishSpeaking(speaker, _lastNpcToSpeak)
        endIf

        if extraAction == mConsts.KEY_REQUESTTYPE_ENDCONVERSATION
            EndConversation()
        else
            int handle = ModEvent.Create(EventInterface.EVENT_ACTIONS_PREFIX + extraAction)
            if (handle)
                ModEvent.PushForm(handle, speaker)
                ModEvent.Send(handle)
            endIf 
        endIf
        i += 1
    EndWhile
    ;AddIngameEvent("All Events sent out!")
EndFunction

Function AddExtraRequestAction(string extraAction)
    if(!_extraRequestActions)
        _extraRequestActions = Utility.CreateStringArray(1)
    Else
        _extraRequestActions = Utility.ResizeStringArray(_extraRequestActions, _extraRequestActions.Length + 1)
    endif
    _extraRequestActions[_extraRequestActions.Length - 1] = extraAction
EndFunction

Function ClearExtraRequestAction()
    _extraRequestActions = Utility.CreateStringArray(0)
EndFunction

Function SendActorAddedEvents(Form[] actorsAdded)
    int index = 0
    While (index < actorsAdded.Length)
        Actor speaker = actorsAdded[index] as Actor
        If (speaker)
            int handle = ModEvent.Create(EventInterface.EVENT_CONVERSATION_NPC_ADDED)
            if (handle)
                ModEvent.PushForm(handle, speaker)
                ModEvent.Send(handle)
            endIf 
        EndIf
        index += 1
    EndWhile
    MantellaVanillaDialogue.notifyNpcAdded(actorsAdded)
EndFunction

Function SendActorRemovedEvents(Form[] actorsRemoved)
    int index = 0
    While (index < actorsRemoved.Length)
        Actor speaker = actorsRemoved[index] as Actor
        int handle = ModEvent.Create(EventInterface.EVENT_CONVERSATION_NPC_REMOVED)
        if (handle)
            ModEvent.PushForm(handle, speaker)
            ModEvent.Send(handle)
        endIf 
        index += 1
    EndWhile
    MantellaVanillaDialogue.notifyNpcRemoved(actorsRemoved)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Ingame events        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddIngameEvent(string eventText)
    if (eventText != "")
        if(!_ingameEvents)
            _ingameEvents = Utility.CreateStringArray(1)
        Else
            _ingameEvents = Utility.ResizeStringArray(_ingameEvents, _ingameEvents.Length + 1)
        endif
        _ingameEvents[_ingameEvents.Length - 1] = eventText
    endIf
EndFunction

Function ClearIngameEvent()
    _ingameEvents = Utility.CreateStringArray(0)
EndFunction

event OnAddEventReceived(string text)
    AddIngameEvent(text)
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Action: Reload conversation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnReloadConversationActionReceived(Form speaker, string sentence)
    ; Debug.Notification("OnReloadConversationActionReceived triggered")
    AddExtraRequestAction(mConsts.ACTION_RELOADCONVERSATION)
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Error handling        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnHttpErrorReceived(int typedDictionaryHandle)
    string errorMessage = SKSE_HTTP.getString(typedDictionaryHandle, mConsts.HTTP_ERROR ,"error")
    If (errorMessage != "error")
        Debug.Notification("Received SKSE_HTTP error: " + errorMessage)        
        CleanupConversation()
    Else
        Debug.Notification("Error: Received an error event from SKSE_HTTP but did not receive an error message.")
        CleanupConversation()
    EndIf
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Access           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Utils            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool Function IsPlayerInConversation()
    int i = 0
    While i < Participants.GetSize()
        if (Participants.GetAt(i) == PlayerRef)
            return true
        endif
        i += 1
    EndWhile
    return false    
EndFunction

Function CauseReassignmentOfParticipantAlias()
    If (MantellaConversationParticipantsQuest.IsRunning())
        ;Debug.Notification("Stopping MantellaConversationParticipantsQuest")
        MantellaConversationParticipantsQuest.Stop()
    EndIf
    ;Debug.Notification("Starting MantellaConversationParticipantsQuest to asign QuestAlias")
    MantellaConversationParticipantsQuest.Start()
EndFunction

Function AddActors(Actor[] actorsToAdd)
    int i = 0
    Form[] actorsAdded = Utility.CreateFormArray(0)
    While i < actorsToAdd.Length
        Actor possibleNewActor = actorsToAdd[i]
        int pos = Participants.Find(possibleNewActor)
        if(pos < 0)
            Participants.AddForm(possibleNewActor)
            possibleNewActor.AddToFaction(MantellaConversationParticipantsFaction)
            actorsAdded = Utility.ResizeFormArray(actorsAdded, actorsAdded.Length + 1)
            actorsAdded[actorsAdded.Length - 1] = possibleNewActor

            ; check if there are multiple actors with the same name
            int nameCount = 0
            int j = 0
            bool break = false
            if (possibleNewActor != PlayerRef) ; ignore the player having the same name as an actor
                While (j < Participants.GetSize()) && (break==false)
                    Actor currentActor = Participants.GetAt(j) as Actor
                    if (currentActor.GetDisplayName() == possibleNewActor.GetDisplayName())
                        nameCount += 1
                        if (currentActor == possibleNewActor) ; stop counting when the exact actor is found (not just the same name)
                            break = true
                        endIf
                    endIf
                    j += 1
                EndWhile

                if (nameCount > 1)
                    ; set an ID to this non-uniquely-named actor in the form of a faction rank
                    ; these uniquely ID'd names can be called via the GetActorName() function
                    possibleNewActor.SetFactionRank(MantellaConversationParticipantsFaction, nameCount)
                endIf
            endIf
        endIf
        i += 1
    EndWhile
    If (actorsAdded.Length > 0)
        CauseReassignmentOfParticipantAlias()
        BuildNpcsInConversationArray()
        SendActorAddedEvents(actorsAdded)
    EndIf
    
    ;PrintActorsInConversation()
EndFunction

Function RemoveActors(Actor[] actorsToRemove)
    PrintActorsArray("Actors to remove: ",actorsToRemove)
    Form[] actorsRemoved = Utility.CreateFormArray(0)
    int i = 0
    While (i < actorsToRemove.Length)
        Actor actorInQuestion = actorsToRemove[i]
        If (Participants.HasForm(actorInQuestion))
            actorsRemoved = Utility.ResizeFormArray(actorsRemoved, actorsRemoved.Length + 1)
            actorsRemoved[actorsRemoved.Length - 1] = actorInQuestion
            Participants.RemoveAddedForm(actorInQuestion)
            actorInQuestion.RemoveFromFaction(MantellaConversationParticipantsFaction)
            Debug.Notification(actorInQuestion.GetDisplayName()+" left the conversation.")
        EndIf
        i += 1
    EndWhile
    if (Participants.GetSize() < 2)
        EndConversation()
    ElseIf (actorsRemoved.Length > 0)
        CauseReassignmentOfParticipantAlias()
        BuildNpcsInConversationArray()
        SendActorRemovedEvents(actorsRemoved)
    endIf
    ;PrintActorsInConversation()
EndFunction

Function ClearParticipants()
    int i = 0
    While i < Participants.GetSize()
        (Participants.GetAt(i) as Actor).RemoveFromFaction(MantellaConversationParticipantsFaction)
        i += 1
    EndWhile
    Participants.Revert()
EndFunction

bool Function ContainsActor(Actor[] arrayToCheck, Actor actorCheckFor)
    int i = 0
    While i < arrayToCheck.Length
        If (arrayToCheck[i] == actorCheckFor)
            return True
        EndIf
        i += 1
    EndWhile
    return False
EndFunction

Function PrintActorsArray(string prefix, Actor[] actors)
    int i = 0
    string actor_message = ""
    While i < actors.Length
        actor_message += GetActorName(actors[i]) + ", "
        i += 1
    EndWhile
    ;Debug.Notification(prefix + actor_message)
EndFunction

Function PrintActorsInConversation()
    int i = 0
    string actor_message = ""
    While i < Participants.GetSize()
        actor_message += GetActorName(Participants.GetAt(i) as Actor) + ", "
        i += 1
    EndWhile
    Debug.Notification(actor_message)
EndFunction

int Function CountActorsInConversation()
    return Participants.GetSize()
EndFunction

Actor Function GetActorInConversationByIndex(int indexOfActor) 
    If (indexOfActor >= 0 && indexOfActor < Participants.getSize())
        return Participants.GetAt(indexOfActor) as Actor
    EndIf
    return none
EndFunction

Function AddCurrentActorsAndContext(int handleToAddTo, bool isConversationStart = false)
    ;Add Actors
    SKSE_HTTP.setNestedDictionariesArray(handleToAddTo, mConsts.KEY_ACTORS, _actorHandles)
    ;add context
    SKSE_HTTP.setNestedDictionary(handleToAddTo, mConsts.KEY_CONTEXT, _contextHandle)
EndFunction

int[] function BuildNpcsInConversationArray()
    _actorHandles =  Utility.CreateIntArray(Participants.GetSize())
    int i = 0
    While i < Participants.GetSize()
        _actorHandles[i] = buildActorSetting(Participants.GetAt(i) as Actor)
        i += 1
    EndWhile
    _actorsUpdated = true
endFunction

int[] function UpdateNpcsInConversationArray()
    ; Update NPC details where variables are dynamic
    int i = 0
    While i < Participants.GetSize()
        Actor actorToBuild = Participants.GetAt(i) as Actor
        SKSE_HTTP.setBool(_actorHandles[i], mConsts.KEY_ACTOR_ISINCOMBAT, actorToBuild.IsInCombat())
        i += 1
    EndWhile
endFunction

int function buildActorSetting(Actor actorToBuild)  
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_BASEID, (actorToBuild.getactorbase() as form).getformid())
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_REFID, (actorToBuild as form).getformid())
    SKSE_HTTP.setString(handle, mConsts.KEY_ACTOR_NAME, GetActorName(actorToBuild))
    bool isPlayerCharacter = actorToBuild == PlayerRef
    SKSE_HTTP.setBool(handle, mConsts.KEY_ACTOR_ISPLAYER, isPlayerCharacter)
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_GENDER, actorToBuild.getleveledactorbase().getsex())
    SKSE_HTTP.setString(handle, mConsts.KEY_ACTOR_RACE, actorToBuild.getrace())
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_RELATIONSHIPRANK, actorToBuild.getrelationshiprank(PlayerRef))
    SKSE_HTTP.setString(handle, mConsts.KEY_ACTOR_VOICETYPE, actorToBuild.GetVoiceType())
    SKSE_HTTP.setBool(handle, mConsts.KEY_ACTOR_ISINCOMBAT, actorToBuild.IsInCombat())
    SKSE_HTTP.setBool(handle, mConsts.KEY_ACTOR_ISENEMY, actorToBuild.getcombattarget() == PlayerRef)
    EquipmentDescriber.AddEquipmentDescription(handle, actorToBuild, isPlayerCharacter, repository)
    int customActorValuesHandle = SKSE_HTTP.createDictionary()
    If (isPlayerCharacter)
        AddCustomPCValues(customActorValuesHandle, actorToBuild)
    EndIf
    SKSE_HTTP.setNestedDictionary(handle, mConsts.KEY_ACTOR_CUSTOMVALUES, customActorValuesHandle)
    return handle
endFunction

Function AddCustomPCValues(int customActorValuesHandle, Actor actorToBuildCustomValuesFor)
    if(!repository.IsVR())
        string description = repository.playerCharacterDescription1
        If (repository.playerCharacterUsePlayerDescription2)
            description = repository.playerCharacterDescription2
        EndIf
        SKSE_HTTP.setString(customActorValuesHandle, mConsts.KEY_ACTOR_PC_DESCRIPTION, description)
        SKSE_HTTP.setBool(customActorValuesHandle, mConsts.KEY_ACTOR_PC_VOICEPLAYERINPUT, repository.playerCharacterVoicePlayerInput)
        If (repository.playerCharacterVoicePlayerInput)
            SKSE_HTTP.setString(customActorValuesHandle, mConsts.KEY_ACTOR_PC_VOICEMODEL, repository.playerCharacterVoiceModel)
        EndIf
    endIf
EndFunction

int function BuildContext(bool isConversationStart = false)
    _contextHandle = SKSE_HTTP.createDictionary()
    if (isConversationStart)
        _location = ((Participants.GetAt(0) as Actor).GetCurrentLocation() as Form).getName()
        if _location == ""
            _location = "Skyrim"
        endIf
        SKSE_HTTP.setString(_contextHandle, mConsts.KEY_CONTEXT_LOCATION, _location)
    endIf

    if (isConversationStart || repository.playerTrackingOnWeatherChange)
        AddCurrentWeather(_contextHandle)
    endIf

    if (isConversationStart || repository.playerTrackingOnTimeChange)
        _initialTime = GetCurrentHourOfDay()
    endIf
    SKSE_HTTP.setInt(_contextHandle, mConsts.KEY_CONTEXT_TIME, _initialTime)

    string[] past_events = deepcopy(_ingameEvents)
    SKSE_HTTP.setStringArray(_contextHandle, mConsts.KEY_CONTEXT_INGAMEEVENTS, past_events)
    ClearIngameEvent()
endFunction

int function AddCurrentWeather(int contextHandle)
    If (!PlayerRef.IsInInterior())
        int handle = SKSE_HTTP.createDictionary()
        Weather currentWeather = Weather.GetCurrentWeather()
        SKSE_HTTP.setString(handle, mConsts.KEY_CONTEXT_WEATHER_ID, currentWeather.GetFormID())
        SKSE_HTTP.setInt(handle, mConsts.KEY_CONTEXT_WEATHER_CLASSIFICATION, currentWeather.GetClassification())
        SKSE_HTTP.setNestedDictionary(contextHandle, mConsts.KEY_CONTEXT_WEATHER, handle)
    EndIf
endFunction

int function GetCurrentHourOfDay()
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	int Hour = Math.Floor(Time) ; Get whole hour
	return Hour
endFunction

string[] function deepcopy(string[] array_to_copy)
    string[] result = Utility.CreateStringArray(array_to_copy.Length)
    int i = 0
    While i < array_to_copy.Length
        result[i] = array_to_copy[i]
        i += 1
    EndWhile
    return result
endFunction

Function ShowRepeatingMessage(string messageToShow)
    _repeatingMessage = messageToShow
    if repository.showReminderMessages
        Debug.Notification(_repeatingMessage)
    else
        RegisterForSingleUpdate(0)
    endIf
EndFunction

Function ClearRepeatingMessage()
    _repeatingMessage = ""
EndFunction
