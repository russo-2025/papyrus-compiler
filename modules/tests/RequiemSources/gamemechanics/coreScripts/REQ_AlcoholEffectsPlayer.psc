ScriptName REQ_AlcoholEffectsPlayer Extends REQ_CoreScript
{manages player-specific alcohol effects like blurry vision}

GlobalVariable Property AlcoholLevelStorage Auto

ImageSpaceModifier Property DrunkISM Auto

Keyword Property ResistAlcoholBlur Auto

Function initScript(Int currentVersion, Int nevVersion)
    UpdatePlayerAlcoholPenalties()
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
    DrunkISM.Remove()
    UnregisterForUpdate()
EndFunction

Function UpdatePlayerAlcoholPenalties()
    Float Intensity = AlcoholLevelStorage.GetValue() / 50.0
    If Intensity > 0.0 && !player.HasMagicEffectWithKeyword(ResistAlcoholBlur)
        DrunkISM.Apply(Intensity)
        RegisterForUpdate(5.0)
    Else
        DrunkISM.Remove()
        UnregisterForUpdate()
    EndIf
EndFunction

Event OnUpdate()
    Float AlcoholLevel = AlcoholLevelStorage.GetValue()
    Float Health = player.GetBaseActorValue("Health")
    Float Chance = AlcoholLevel / Health - 1.0
    If Chance >= 1.0 || (Chance > 0.0 && Utility.RandomFloat() < Chance)
        player.PushActorAway(player, 1.0)
    EndIf
EndEvent
