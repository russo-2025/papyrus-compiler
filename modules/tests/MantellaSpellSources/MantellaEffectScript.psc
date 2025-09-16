Scriptname MantellaEffectScript extends activemagiceffect

MantellaConversation property conversation auto

event OnEffectStart(Actor target, Actor caster)
    ;Utility.Wait(0.5)
    Actor[] actors = new Actor[2]
    actors[0] = caster
    actors[1] = target
    if(!conversation.IsRunning())
        Debug.Notification("Starting conversation...")
        conversation.Start()
        conversation.StartConversation(actors)
    Else
        if conversation.IsPlayerInConversation()
            Debug.Notification("Adding "+actors[1].GetDisplayName()+" to conversation...")
        Else
            ; If player is joining what was previously a radiant conversation
            Debug.Notification("Adding player to conversation...")
        endIf
        conversation.AddActorsToConversation(actors)
    endIf
endEvent
