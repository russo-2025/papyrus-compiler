Scriptname MantellaRemoveNpcEffect extends activemagiceffect

MantellaConversation property conversation auto

event OnEffectStart(Actor target, Actor caster)
    Actor[] actors = new Actor[1]
    actors[0] = target
    if(conversation.IsRunning())
        conversation.RemoveActorsFromConversation(actors)
    endIf
endEvent