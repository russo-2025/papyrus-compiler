Scriptname REQ_SetupValidation extends Quest
{helper functions to validate the Requiem setup}

Import StringUtil

Message Property SKSE_missing Auto
{message to display if SKSE is missing at all or too old}
Message Property SKSE_broken Auto
{message if SKSE dll and script versions differ}
Message Property NoNewGame Auto
{message if Requiem was installed into an existing non-Requiem save game}
Message Property UpgradeForbidden Auto
{message if an unsupported upgrade is attempted (major version change)}
Message Property DowngradeForbidden Auto
{message if the current plugin version is older than the one used by the savegame}
Message Property SkyProcMissing Auto
{message if Requiem for the Indifferent is missing and the data is therefore garbage}
Message Property SkyProcOutdated Auto
{message if Requiem for the Indifferent is based on an older Requiem version than installed}
Message Property BashedPatchFailed Auto
{message if (most likely) a bashed patch is used to merge leveled lists}

LeveledItem Property BashedPatch_TestList Auto
{if a bashed patch is used to merge leveled lists, this list will have non-zero entries}

; basic version compatibility checks for Requiem
Bool Function checkVersionCompatibility(Int versionPlugin, Int versionSaveGame)
	Int[] subVersionsPlugin = getSubversions(versionPlugin)
    Int[] subVersionsSave = getSubversions(versionSavegame)

	If VersionSavegame == -2
		NoNewGame.Show()
	ElseIf (subVersionsSave[0] > 0 && subVersionsSave[0] != subVersionsPlugin[0])
	    UpgradeForbidden.Show(subVersionsPlugin[0], subVersionsPlugin[1], \
		        subVersionsPlugin[2], subVersionsSave[0], subVersionsSave[1], \
		        subVersionsSave[2])
    ElseIf (versionPlugin < versionSavegame)
        DowngradeForbidden.Show(subVersionsPlugin[0], subVersionsPlugin[1], \
                subVersionsPlugin[2], subVersionsSave[0], subVersionsSave[1], \
                subVersionsSave[2])
    Else
        return true
	EndIf
	return false
EndFunction

; check whether the current setup is suitable for Requiem, if not it displays a warning
Bool Function validateSetup(Int versionPlugin, Int versionSkyProcPatch)
	Int version_skse = SKSE.GetVersionRelease()
	Int version_script = SKSE.GetScriptVersionRelease()

	Int[] subVersionsPlugin = getSubversions(versionPlugin)
    Int[] subVersionsSkyProc = getSubversions(versionSkyProcPatch)

    BashedPatch_TestList.Revert()

	If (version_script < 48)
		SKSE_missing.Show()
	ElseIf (version_skse != version_script || version_script == 0)
		SKSE_broken.Show(version_skse as Float, version_script as Float)
	ElseIf Game.GetModByName("Requiem for the Indifferent.esp") == 255
		SkyProcMissing.Show()
	ElseIf versionPlugin != versionSkyProcPatch
		SkyProcOutdated.Show(subVersionsPlugin[0], subVersionsPlugin[1], \
                subVersionsPlugin[2], subVersionsSkyProc[0], subVersionsSkyProc[1], \
                subVersionsSkyProc[2])
	ElseIf BashedPatch_TestList.GetNumForms() > 0
		BashedPatchFailed.Show()
    Else
        return true
	EndIf
	return false
EndFunction

Int[] Function getSubversions(Int version)
    Int[] subVersions = new Int[3]
    subVersions[0] = version / 10000
    If (subVersions[0] >= 2)
        subVersions[1] = (version % 10000) / 100
    	subVersions[2] =  (version % 10000) % 100
    Else
        subVersions[1] = (version % 10000) / 1000
        subVersions[2] = ((version % 10000) % 1000) / 100
    EndIf
	return subVersions
EndFunction

String Function formatVersion(Int version)
	Int[] subVersions = getSubversions(version)
    return "" + subVersions[0] + "." + subVersions[1] + "." + subVersions[2]
EndFunction