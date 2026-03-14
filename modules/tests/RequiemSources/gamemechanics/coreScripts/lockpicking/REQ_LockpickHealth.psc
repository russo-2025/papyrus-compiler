Scriptname REQ_LockpickHealth extends REQ_CoreScript


Event OnPlayerLoadGame()
  UpdateLockpickingHealth()
endEvent

Function UpdateLockpickingHealth()
    Float Value = 1.0 + Player.GetActorValue("LockpickingPowerMod") / 100.0
    Game.SetGameSettingFloat("fLockpickBreakSkillBase", Value)
EndFunction

Function ResetLockpickingHealth()
    Game.SetGameSettingFloat("fLockpickBreakSkillBase", 1.0)
EndFunction

Function initScript(Int currentVersion, Int nevVersion)
    UpdateLockpickingHealth()
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
    ResetLockpickingHealth()
EndFunction
