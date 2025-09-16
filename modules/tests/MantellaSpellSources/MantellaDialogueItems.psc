;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname MantellaDialogueItems Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE

;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
	if (TriggeredDialogueItem == "mantella_start_add")
        Actor[] actors = new Actor[2]
        actors[0] = game.getplayer()
        actors[1] = akspeaker
        if(!conversation.IsRunning())
            conversation.Start()
            (conversation as MantellaConversation).StartConversation(actors)
        Else
            (conversation as MantellaConversation).AddActorsToConversation(actors)
        EndIf   
    ElseIf (TriggeredDialogueItem == "mantella_remove_character")
        Actor[] actors = new Actor[1]
        actors[0] = akspeaker
        if(conversation.IsRunning())
            (conversation as MantellaConversation).RemoveActorsFromConversation(actors)
        EndIf
	endif	
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

string Property TriggeredDialogueItem  Auto
Quest property conversation Auto