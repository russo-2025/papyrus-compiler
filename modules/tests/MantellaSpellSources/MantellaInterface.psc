Scriptname MantellaInterface extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Mod event identifiers    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prefix for any events raised by Mantella when it receives an action. See example below for usage
string property EVENT_ACTIONS_PREFIX = "MantellaConversation_Action_" auto

; Called when a conversation is started
string property EVENT_CONVERSATION_STARTED = "MantellaConversation_Started" auto
; Called when a conversation is ended
string property EVENT_CONVERSATION_ENDED = "MantellaConversation_Ended" auto
; Called when an actor is added to the conversation, actor is passed to event as Form
string property EVENT_CONVERSATION_NPC_ADDED = "MantellaConversation_NPC_Added" auto
; Called when an actor is removed from the conversation, actor is passed to event as Form
string property EVENT_CONVERSATION_NPC_REMOVED = "MantellaConversation_NPC_Removed" auto

; Mantella itself listens for this event to add ingame events for the next user message. Don't use this directly, use the 'AddMantellaEvent' function below
string property EVENT_ADD_EVENT = "MantellaAddEvent" auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Example           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Scriptname MyExampleMantellaPlugin extends Quest

;MantellaInterface property EventInterface Auto

; Function OnInit()
;     RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + "myActionIdentifier","OnMyActionIdentifierReceived")
; EndFunction

; event OnMyActionIdentifierReceived(Form speaker)
;     Actor acting = speaker as Actor
;     EventInterface.AddMantellaEvent(acting.GetDisplayName() + "just performed MyActionIdentifier"
; endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      Add Mantella Event     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddMantellaEvent(string text)
    int handle = ModEvent.Create(EVENT_ADD_EVENT)
    if (handle)
        ModEvent.PushString(handle, text)
        ModEvent.Send(handle)
    endIf 
EndFunction