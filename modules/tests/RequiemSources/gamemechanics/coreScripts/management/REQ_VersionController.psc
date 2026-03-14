Scriptname REQ_VersionController extends Quest
{script state manager for Requiem's core scripts}

REQ_SetupValidation Property validator Auto

GlobalVariable Property VersionSavegame Auto
GlobalVariable Property VersionPlugin Auto
GlobalVariable Property VersionSkyProcPatch Auto

Message Property InstallationBegins Auto
Message Property InstallationDone Auto

Message Property UpdateBegins Auto
Message Property UpdateDone Auto
Message Property UpdateFailed Auto

ReferenceAlias Property AutoUpdater Auto
{ref alias with AutoUpdater script attached}

ImageSpaceModifier Property Fadeout Auto
{the blackout effect during initialization or update}
Sound Property InstallationSoundEffect Auto
{the effect used in the blackout effect as described in the init/update messages}

Function triggerUpdateIfNeeded()
    If ( VersionSavegame.GetValue() != VersionPlugin.GetValue() )
        If (AutoUpdater as REQ_AutoUpdater).shutdownScripts(VersionSavegame.getValueInt(), VersionPlugin.getValueInt())
            upgradeVersion()
        Else
            UpdateFailed.show()
            Game.QuitToMainMenu()
        EndIf
    EndIf
EndFunction

Function checkSetup()
    If (!validator.validateSetup(VersionPlugin.getValueInt(), VersionSkyProcPatch.getValueInt()))
        Utility.Wait(1)
        Game.QuitToMainMenu()
    EndIf
EndFunction

Function upgradeVersion()
    startUpdate()
    If (!validator.checkVersionCompatibility(VersionPlugin.getValueInt(), VersionSavegame.getValueInt()) \
            || !validator.validateSetup(VersionPlugin.getValueInt(), VersionSkyProcPatch.getValueInt()))
        Utility.Wait(1)
        Game.QuitToMainMenu()
    EndIf
	Self.Stop()
	Utility.Wait(1)
	Self.Start()
	Utility.Wait(1)
	If (AutoUpdater as REQ_AutoUpdater).initScripts(VersionSavegame.getValueInt(), VersionPlugin.getValueInt())
        completeUpdate()
    Else
        UpdateFailed.show()
        Game.QuitToMainMenu()
    EndIf
EndFunction

Function startUpdate()
    If (versionSavegame.getValueInt() == 0)
        InstallationBegins.show()
    Else
        UpdateBegins.show()
    EndIf
    ; disable saving & controls during update
    Game.SetInChargen(true, true, false)
    Fadeout.ApplyCrossFade()
    Int SoundInstance = InstallationSoundEffect.Play(Game.GetPlayer())
    Sound.SetInstanceVolume(SoundInstance, 1.0)
EndFunction

Function completeUpdate()
	String version = validator.formatVersion(versionPlugin.getValueInt())
    If (versionSavegame.getValueInt() == 0)
        InstallationDone.show()
    Else
        UpdateDone.show()
    EndIf
	ImageSpaceModifier.RemoveCrossFade()
	Game.SetInChargen(false, false, false) ; enable saving & controls again
	versionSavegame.setValueInt(versionPlugin.getValueInt())
	Utility.Wait(1)
	Game.SaveGame("Requiem " + version + " - " + Game.GetPlayer().GetDisplayName())
EndFunction