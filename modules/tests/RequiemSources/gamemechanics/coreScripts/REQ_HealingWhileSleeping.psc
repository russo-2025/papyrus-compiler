Scriptname REQ_HealingWhileSleeping extends REQ_CoreScript
{player only restores health while sleeping if a health regenerating effect is active}

Keyword[] Property healWhileSleeping Auto
{if the player has an active magic effect with any of these keywords, they'll be healed after sleep}

Float missingHealth = 0.0

Event OnSleepStart(Float afSleepStartTime, Float afDesiredSleepEndTime)
    float healthPercentage = player.GetActorValuePercentage("health")
    float maxHealth = player.getActorValue("health") / healthPercentage
    missingHealth = maxHealth - player.getActorValue("health")

    If (healthPercentage >= 0.9)
        ; just some scratches, these will recover without any healing effects
        missingHealth = 0.0
        Return
    EndIf

    Int index = 0
    While (index < healWhileSleeping.length)
        If (player.HasEffectKeyword(healWhileSleeping[index]))
            missingHealth = 0.0
            Return
        EndIf
        index = index + 1
    EndWhile
EndEvent

Event OnSleepStop(bool abInterrupted)
    player.damageActorValue("health", missingHealth)
    missingHealth = 0.0
EndEvent

Function initScript(Int currentVersion, Int nevVersion)
	registerForSleep()
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
    unregisterForSleep()
EndFunction