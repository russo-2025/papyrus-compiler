Scriptname REQ_MeridiasMaledictionItem extends ObjectReference
{burns vampires who dare to put their hands on Dawnbreaker or Meridia's Beacon}

Spell Property vampirism Auto

Spell Property malediction Auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    Actor oldRef = akOldContainer as Actor
    If (oldRef)
        oldRef.removeSpell(malediction)
    EndIf
    Actor newRef = akNewContainer as Actor
    If (newRef && newRef.HasKeywordString("ActorTypeUndead"))
        newRef.addSpell(malediction, false)
    EndIf
EndEvent
