Scriptname REQ_DeathHandler extends REQ_CoreScript
{fade out the game and block automated reload when the player dies}

GlobalVariable Property Disabled Auto
{if this Global is set to true, no special handling of death situations occurs}
ImageSpaceModifier Property fadeout Auto
{the image space modifier to apply when the player died}
Message Property DeathNote Auto
{the message to display to the Player after he died}

Event OnPlayerLoadGame()
    parent.OnPlayerLoadGame()
	If (!Disabled.GetValueInt() as Bool)
		Game.SetGameSettingfloat("fPlayerDeathReloadTime", 3600)
	EndIf
EndEvent

Event OnDeath(Actor akKiller)
	If Disabled.GetValueInt() == 0
		fadeout.ApplyCrossFade(5.0)
		Utility.Wait(4.0)
		Deathnote.Show()
	EndIf
EndEvent

Function initScript(Int currentVersion, Int nevVersion)
	If (!Disabled.GetValueInt() as Bool)
		Game.SetGameSettingfloat("fPlayerDeathReloadTime", 3600)
	EndIf
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
EndFunction
