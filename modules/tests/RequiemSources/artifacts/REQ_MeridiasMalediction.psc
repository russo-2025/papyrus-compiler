ScriptName REQ_MeridiasMalediction Extends ActiveMagicEffect
{Burns vampires who dare to put their hands on Meridia's Beacon. This effect is
used by the vampirism ability to catch vampires who already have the beacon
before turning into a vampire.}

Keyword Property ActorTypeUndead Auto

MiscObject Property Beacon Auto

Spell Property Vampirism Auto
Spell Property Malediction Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    If akTarget.GetItemCount(Beacon) > 0
        akTarget.AddSpell(Malediction, False)
    EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    Utility.Wait(1.0)
    If !akTarget.HasKeyword(ActorTypeUndead)
        akTarget.RemoveSpell(Malediction)
    EndIf
EndEvent
