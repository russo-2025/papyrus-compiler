ScriptName OSexIntegrationMain Extends Quest


;		What is this? Am I in the right place? How do I use this???

; This script is the core of OStim. If you want to start OStim scenes and/or manipulate them, you are in the right place

;	Structure of this script
; At the very top here, are the Properties. They are the settings you see in the MCM. You can toggle these at will on this script and it
; will update the MCM and everything. Below that are the OStim local variables, you can safely ignore those. Below those variables,
; you will find OStim's main loop and the StartScene() function. OStim's core logic runs in there, I recommend giving it a read.
; Below that is the UTILITIES area. These functions are going to be very useful to you and will let you access data in OStim as
; well as manipulate the currently running scene. Below the utilities area are some more specific groups of functions.

; Some parts of code, including undressing, on-screen bar, and animation data lookups, are in other scripts to make this script easier to
; read. You can call functions in the below utilities area to return those script objects.

; Want a list of all Events you can register with? CTRL + F this script for "SendModEvent" and you can see them all as well as the exact point they fire
; With the exception of the sound event, OStim events do not include data with them. They only let you know when something has happened. You can access
; OStim and get all of the data you need through the normal API here

;			 ██████╗ ███████╗████████╗██╗███╗   ███╗
;			██╔═══██╗██╔════╝╚══██╔══╝██║████╗ ████║
;			██║   ██║███████╗   ██║   ██║██╔████╔██║
;			██║   ██║╚════██║   ██║   ██║██║╚██╔╝██║
;			╚██████╔╝███████║   ██║   ██║██║ ╚═╝ ██║
;			 ╚═════╝ ╚══════╝   ╚═╝   ╚═╝╚═╝     ╚═╝

; -------------------------------------------------------------------------------------------------
; CONSTANTS  --------------------------------------------------------------------------------------

string[] Property POSITION_TAGS Auto

; -------------------------------------------------------------------------------------------------
; PROPERTIES  -------------------------------------------------------------------------------------


Faction Property OStimNoFacialExpressionsFaction Auto
Faction Property OStimExcitementFaction Auto

GlobalVariable Property OStimImprovedCamSupport Auto
bool Property EnableImprovedCamSupport
	bool Function Get()
		Return OStimImprovedCamSupport.value != 0
	EndFunction
EndProperty


; -------------------------------------------------------------------------------------------------
; SETTINGS  ---------------------------------------------------------------------------------------

int Property InstalledVersion Auto

; -------------------------------------------------------------------------------------------------
; GENERAL SETTINGS  -------------------------------------------------------------------------------

GlobalVariable Property OStimResetPosition Auto
Bool Property ResetPosAfterSceneEnd
	bool Function Get()
		Return OStimResetPosition.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimResetPosition.value = 1
		Else
			OStimResetPosition.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimCustomTimeScale Auto
Int Property CustomTimescale
	int Function Get()
		Return OStimCustomTimeScale.value As int
	EndFunction
	Function Set(int Value)
		OStimCustomTimeScale.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimUseFades Auto
bool Property UseFades
	bool Function Get()
		Return OStimUseFades.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseFades.value = 1
		Else
			OStimUseFades.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseIntroScenes Auto
bool Property UseIntroScenes
	bool Function Get()
		Return OStimUseIntroScenes.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseIntroScenes.value = 1
		Else
			OStimUseIntroScenes.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAddActorsAtStart Auto
bool Property AddActorsAtStart
	bool Function Get()
		Return OStimAddActorsAtStart.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAddActorsAtStart.value = 1
		Else
			OStimAddActorsAtStart.value = 0
		EndIf
	EndFunction
EndProperty


GlobalVariable Property OStimOnlyLightInDark Auto
bool Property LowLightLevelLightsOnly
	bool Function Get()
		Return OStimOnlyLightInDark.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimOnlyLightInDark.value = 1
		Else
			OStimOnlyLightInDark.value = 0
		EndIf
	EndFunction
EndProperty


GlobalVariable Property OStimAutoExportSettings Auto
bool Property AutoExportSettings
	bool Function Get()
		Return OStimAutoExportSettings.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAutoExportSettings.value = 1
		Else
			OStimAutoExportSettings.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoImportSettings Auto
bool Property AutoImportSettings
	bool Function Get()
		Return OStimAutoImportSettings.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAutoImportSettings.value = 1
		Else
			OStimAutoImportSettings.value = 0
		EndIf
	EndFunction
EndProperty



; -------------------------------------------------------------------------------------------------
; CONTROLS SETTINGS  ------------------------------------------------------------------------------

GlobalVariable Property OStimKeyUp Auto
int Property KeyUp
	int Function Get()
		Return OStimKeyUp.value As int
	EndFunction
	Function Set(int Value)
		OstimKeyUp.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyDown Auto
int Property KeyDown
	int Function Get()
		Return OStimKeyDown.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyDown.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyLeft Auto
int Property KeyLeft
	int Function Get()
		Return OStimKeyLeft.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyLeft.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyRight Auto
int Property KeyRight
	int Function Get()
		Return OStimKeyRight.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyRight.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyYes Auto
int Property KeyYes
	int Function Get()
		Return OStimKeyYes.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyYes.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyEnd Auto
int Property KeyEnd
	int Function Get()
		Return OStimKeyEnd.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyEnd.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyToggle Auto
int Property KeyToggle
	int Function Get()
		Return OStimKeyToggle.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyToggle.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeySceneStart Auto
int Property KeyMap
	int Function Get()
		Return OStimKeySceneStart.value As int
	EndFunction
	Function Set(int Value)
		UnregisterForKey(OStimKeySceneStart.value As int)
		OStimKeySceneStart.value = Value
		If Value != 1
			RegisterForKey(Value)
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimKeyNPCStart Auto
int Property KeyNPCStart
	int Function Get()
		Return OStimKeyNPCStart.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyNPCStart.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeySpeedUp Auto
Int Property SpeedUpKey
	int Function Get()
		Return OStimKeySpeedUp.value As int
	EndFunction
	Function Set(int Value)
		OStimKeySpeedUp.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeySpeedDown Auto
Int Property SpeedDownKey
	int Function Get()
		Return OStimKeySpeedDown.value As int
	EndFunction
	Function Set(int Value)
		OStimKeySpeedDown.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyPullOut Auto
Int Property PullOutKey
	int Function Get()
		Return OStimKeyPullOut.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyPullOut.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyAutoMode Auto
Int Property ControlToggleKey
	int Function Get()
		Return OStimKeyAutoMode.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyAutoMode.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyFreeCam Auto
int property FreecamKey
	int Function Get()
		Return OStimKeyFreeCam.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyFreeCam.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeySearch Auto
int Property SearchKey
	int Function Get()
		Return OStimKeySearch.value As int
	EndFunction
	Function Set(int Value)
		OStimKeySearch.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyAlignment Auto
int Property AlignmentKey
	int Function Get()
		Return OStimKeyAlignment.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyAlignment.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimKeyHideUI Auto
int Property HideUIKey
	int Function Get()
		Return OStimKeyHideUI.value As int
	EndFunction
	Function Set(int Value)
		OStimKeyHideUI.value = Value
	EndFunction
EndProperty


GlobalVariable Property OStimUseRumble Auto
Bool Property UseRumble
	bool Function Get()
		Return OStimUseRumble.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseRumble.value = 1
		Else
			OStimUseRumble.value = 0
		EndIf
	EndFunction
EndProperty


; -------------------------------------------------------------------------------------------------
; AUTO CONTROL SETTINGS  --------------------------------------------------------------------------

GlobalVariable Property OStimAutoSpeedControl Auto
Bool Property EnableActorSpeedControl
	bool Function Get()
		Return OStimAutoSpeedControl.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAutoSpeedControl.value = 1
		Else
			OStimAutoSpeedControl.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoSpeedControlIntervalMin Auto
int Property AutoSpeedControlIntervalMin
	int Function Get()
		Return OStimAutoSpeedControlIntervalMin.value As int
	EndFunction
	Function Set(int Value)
		If AutoSpeedControlIntervalMax < Value
			OStimAutoSpeedControlIntervalMin.value = OStimAutoSpeedControlIntervalMax.value
			OStimAutoSpeedControlIntervalMax.value = Value
		Else
			OStimAutoSpeedControlIntervalMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoSpeedControlIntervalMax Auto
int Property AutoSpeedControlIntervalMax
	int Function Get()
		Return OStimAutoSpeedControlIntervalMax.value As int
	EndFunction
	Function Set(int Value)
		If AutoSpeedControlIntervalMin > Value
			OStimAutoSpeedControlIntervalMax.value = OStimAutoSpeedControlIntervalMin.value
			OStimAutoSpeedControlIntervalMin.value = Value
		Else
			OStimAutoSpeedControlIntervalMax.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoSpeedControlExcitementMin Auto
int Property AutoSpeedControlExcitementMin
	int Function Get()
		Return OStimAutoSpeedControlExcitementMin.value As int
	EndFunction
	Function Set(int Value)
		If AutoSpeedControlExcitementMax < Value
			OStimAutoSpeedControlExcitementMin.value = OStimAutoSpeedControlExcitementMax.value
			OStimAutoSpeedControlExcitementMax.value = Value
		Else
			OStimAutoSpeedControlExcitementMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoSpeedControlExcitementMax Auto
int Property AutoSpeedControlExcitementMax
	int Function Get()
		Return OStimAutoSpeedControlExcitementMax.value As int
	EndFunction
	Function Set(int Value)
		If AutoSpeedControlExcitementMin > Value
			OStimAutoSpeedControlExcitementMax.value = OStimAutoSpeedControlExcitementMin.value
			OStimAutoSpeedControlExcitementMin.value = Value
		Else
			OStimAutoSpeedControlExcitementMax.value = Value
		EndIf
	EndFunction
EndProperty


GlobalVariable Property OStimNPCSceneDuration Auto
int Property NPCSceneDuration
	int Function Get()
		Return OStimNPCSceneDuration.value As int
	EndFunction
	Function Set(int Value)
		OStimNPCSceneDuration.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimEndNPCSceneOnOrgasm Auto
Bool Property EndNPCSceneOnOrgasm
	bool Function Get()
		Return OStimEndNPCSceneOnOrgasm.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimEndNPCSceneOnOrgasm.value = 1
		Else
			OStimEndNPCSceneOnOrgasm.value = 0
		EndIf
	EndFunction
EndProperty


GlobalVariable Property OStimNavigationDistanceMax Auto
int Property NavigationDistanceMax
	int Function Get()
		Return OStimNavigationDistanceMax.value As int
	EndFunction
	Function Set(int Value)
		OStimNavigationDistanceMax.value = Value
	EndFunction
EndProperty


GlobalVariable Property OStimUseAutoModeAlways Auto
Bool Property UseAIControl
	bool Function Get()
		Return OStimUseAutoModeAlways.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseAutoModeAlways.value = 1
		Else
			OStimUseAutoModeAlways.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseAutoModeSolo Auto
Bool Property UseAIMasturbation
	bool Function Get()
		Return OStimUseAutoModeSolo.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseAutoModeSolo.value = 1
		Else
			OStimUseAutoModeSolo.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseAutoModeDominant Auto
Bool Property UseAIPlayerAggressor
	bool Function Get()
		Return OStimUseAutoModeDominant.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseAutoModeDominant.value = 1
		Else
			OStimUseAutoModeDominant.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseAutoModeSubmissive Auto
Bool Property UseAIPlayerAggressed
	bool Function Get()
		Return OStimUseAutoModeSubmissive.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseAutoModeSubmissive.value = 1
		Else
			OStimUseAutoModeSubmissive.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseAutoModeVanilla Auto
Bool Property UseAINonAggressive
	bool Function Get()
		Return OStimUseAutoModeVanilla.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseAutoModeVanilla.value = 1
		Else
			OStimUseAutoModeVanilla.value = 0
		EndIf
	EndFunction
EndProperty


GlobalVariable Property OStimAutoModeLimitToNavigationDistance Auto
Bool Property AutoModeLimitToNavigationDistance
	bool Function Get()
		Return OStimAutoModeLimitToNavigationDistance.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAutoModeLimitToNavigationDistance.value = 1
		Else
			OStimAutoModeLimitToNavigationDistance.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseAutoModeFades Auto
Bool Property UseAutoFades
	bool Function Get()
		Return OStimUseAutoModeFades.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseAutoModeFades.value = 1
		Else
			OStimUseAutoModeFades.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModeAnimDurationMin Auto
int Property AutoModeAnimDurationMin
	int Function Get()
		Return OStimAutoModeAnimDurationMin.value As int
	EndFunction
	Function Set(int Value)
		If AutoModeAnimDurationMax < Value
			OStimAutoModeAnimDurationMin.value = OStimAutoModeAnimDurationMax.value
			OStimAutoModeAnimDurationMax.value = Value
		Else
			OStimAutoModeAnimDurationMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModeAnimDurationMax Auto
int Property AutoModeAnimDurationMax
	int Function Get()
		Return OStimAutoModeAnimDurationMax.value As int
	EndFunction
	Function Set(int Value)
		If AutoModeAnimDurationMin > Value
			OStimAutoModeAnimDurationMax.value = OStimAutoModeAnimDurationMin.value
			OStimAutoModeAnimDurationMin.value = Value
		Else
			OStimAutoModeAnimDurationMax.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModeForeplayChance Auto
int Property AutoModeForeplayChance
	int Function Get()
		Return OStimAutoModeForeplayChance.value As int
	EndFunction
	Function Set(int Value)
		OStimAutoModeForeplayChance.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModeForeplayThresholdMin Auto
int Property AutoModeForeplayThresholdMin
	int Function Get()
		Return OStimAutoModeForeplayThresholdMin.value As int
	EndFunction
	Function Set(int Value)
		If AutoModeForeplayThresholdMax < Value
			OStimAutoModeForeplayThresholdMin.value = OStimAutoModeForeplayThresholdMax.value
			OStimAutoModeForeplayThresholdMax.value = Value
		Else
			OStimAutoModeForeplayThresholdMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModeForeplayThresholdMax Auto
int Property AutoModeForeplayThresholdMax
	int Function Get()
		Return OStimAutoModeForeplayThresholdMax.value As int
	EndFunction
	Function Set(int Value)
		If AutoModeForeplayThresholdMin > Value
			OStimAutoModeForeplayThresholdMax.value = OStimAutoModeForeplayThresholdMin.value
			OStimAutoModeForeplayThresholdMin.value = Value
		Else
			OStimAutoModeForeplayThresholdMax.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModePulloutChance Auto
int Property AutoModePulloutChance
	int Function Get()
		Return OStimAutoModePulloutChance.value As int
	EndFunction
	Function Set(int Value)
		OStimAutoModePulloutChance.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModePulloutThresholdMin Auto
int Property AutoModePulloutThresholdMin
	int Function Get()
		Return OStimAutoModePulloutThresholdMin.value As int
	EndFunction
	Function Set(int Value)
		If AutoModePulloutThresholdMax < Value
			OStimAutoModePulloutThresholdMin.value = OStimAutoModePulloutThresholdMax.value
			OStimAutoModePulloutThresholdMax.value = Value
		Else
			OStimAutoModePulloutThresholdMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoModePulloutThresholdMax Auto
int Property AutoModePulloutThresholdMax
	int Function Get()
		Return OStimAutoModePulloutThresholdMax.value As int
	EndFunction
	Function Set(int Value)
		If AutoModePulloutThresholdMin > Value
			OStimAutoModePulloutThresholdMax.value = OStimAutoModePulloutThresholdMin.value
			OStimAutoModePulloutThresholdMin.value = Value
		Else
			OStimAutoModePulloutThresholdMax.value = Value
		EndIf
	EndFunction
EndProperty


; -------------------------------------------------------------------------------------------------
; CAMERA SETTINGS  --------------------------------------------------------------------------------

GlobalVariable Property OStimUseFreeCam Auto
bool Property UseFreeCam
	bool Function Get()
		Return OStimUseFreeCam.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseFreeCam.value = 1
		Else
			OStimUseFreeCam.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFreeCamFOV Auto
int Property FreecamFOV
	int Function Get()
		Return OStimFreeCamFOV.value As int
	EndFunction
	Function Set(int Value)
		OStimFreeCamFOV.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimFreeCamSpeed Auto
float Property FreecamSpeed
	float Function Get()
		Return OStimFreeCamSpeed.value
	EndFunction
	Function Set(float Value)
		OStimFreeCamSpeed.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimForceFirstPersonOnEnd Auto
Bool Property ForceFirstPersonAfter
	bool Function Get()
		Return OStimForceFirstPersonOnEnd.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimForceFirstPersonOnEnd.value = 1
		Else
			OStimForceFirstPersonOnEnd.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseScreenShake Auto
Bool Property UseScreenShake
	bool Function Get()
		Return OStimUseScreenShake.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseScreenShake.value = 1
		Else
			OStimUseScreenShake.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; EXCITEMENT SETTINGS  ----------------------------------------------------------------------------

GlobalVariable Property OStimMaleSexExcitementMult Auto
float Property MaleSexExcitementMult
	float Function Get()
		Return OStimMaleSexExcitementMult.value
	EndFunction
	Function Set(float value)
		OStimMaleSexExcitementMult.value = value
	EndFunction
EndProperty

GlobalVariable Property OStimFemaleSexExcitementMult Auto
float Property FemaleSexExcitementMult
	float Function Get()
		Return OStimFemaleSexExcitementMult.value
	EndFunction
	Function Set(float value)
		OStimFemaleSexExcitementMult.value = value
	EndFunction
EndProperty

GlobalVariable Property OStimExcitementDecayRate Auto
float Property ExcitementDecayRate
	float Function Get()
		Return OStimExcitementDecayRate.value
	EndFunction
	Function Set(float Value)
		OStimExcitementDecayRate.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimExcitementDecayGracePeriod Auto
int Property ExcitementDecayGracePeriod
	int Function Get()
		Return OStimExcitementDecayGracePeriod.value as int
	EndFunction
	Function Set(int Value)
		OStimExcitementDecayGracePeriod.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimPostOrgasmExcitement Auto
int Property PostOrgasmExcitement
	int Function Get()
		return OStimPostOrgasmExcitement.value as int
	EndFunction
	Function Set(int Value)
		OStimPostOrgasmExcitement.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimPostOrgasmExcitementMax Auto
int Property PostOrgasmExcitementMax
	int Function Get()
		return OStimPostOrgasmExcitementMax.value as int
	EndFunction
	Function Set(int Value)
		OStimPostOrgasmExcitementMax.value = Value
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; EXCITEMENT BAR SETTINGS  ------------------------------------------------------------------------

GlobalVariable Property OStimEnablePlayerBar Auto
bool Property EnablePlayerBar
	bool Function Get()
		Return OStimEnablePlayerBar.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimEnablePlayerBar.value = 1
		Else
			OStimEnablePlayerBar.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimEnableNpcBar Auto
bool Property EnableNpcBar
	bool Function Get()
		Return OStimEnableNpcBar.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimEnableNpcBar.value = 1
		Else
			OStimEnableNpcBar.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoHideBars Auto
Bool Property AutoHideBars
	bool Function Get()
		Return OStimAutoHideBars.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAutoHideBars.value = 1
		Else
			OStimAutoHideBars.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimMatchBarColorToGender Auto
Bool Property MatchBarColorToGender
	bool Function Get()
		Return OStimMatchBarColorToGender.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimMatchBarColorToGender.value = 1
		Else
			OStimMatchBarColorToGender.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; ORGASM SETTINGS  --------------------------------------------------------------------------------

GlobalVariable Property OStimEndOnPlayerOrgasm Auto
Bool Property EndOnPlayerOrgasm
	bool Function Get()
		Return OStimEndOnPlayerOrgasm.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimEndOnPlayerOrgasm.value = 1
		Else
			OStimEndOnPlayerOrgasm.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimEndOnMaleOrgasm Auto
Bool Property EndOnMaleOrgasm
	bool Function Get()
		Return OStimEndOnMaleOrgasm.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimEndOnMaleOrgasm.value = 1
		Else
			OStimEndOnMaleOrgasm.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimEndOnFemaleOrgasm Auto
Bool Property EndOnFemaleOrgasm
	bool Function Get()
		Return OStimEndOnFemaleOrgasm.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimEndOnFemaleOrgasm.value = 1
		Else
			OStimEndOnFemaleOrgasm.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimEndOnAllOrgasm Auto
Bool Property EndOnAllOrgasm
	bool Function Get()
		Return OStimEndOnAllOrgasm.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimEndOnAllOrgasm.value = 1
		Else
			OStimEndOnAllOrgasm.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimSlowMotionOnOrgasm Auto
Bool Property SlowMoOnOrgasm
	bool Function Get()
		Return OStimSlowMotionOnOrgasm.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimSlowMotionOnOrgasm.value = 1
		Else
			OStimSlowMotionOnOrgasm.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimBlurOnOrgasm Auto
Bool Property BlurOnOrgasm
	bool Function Get()
		Return OStimBlurOnOrgasm.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimBlurOnOrgasm.value = 1
		Else
			OStimBlurOnOrgasm.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAutoClimaxAnimations Auto
bool Property AutoClimaxAnimations
	bool Function Get()
		Return OStimAutoClimaxAnimations.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAutoClimaxAnimations.value = 1
		Else
			OStimAutoClimaxAnimations.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; UNDRESSING SETTINGS  ----------------------------------------------------------------------------

GlobalVariable Property OStimUndressAtStart Auto
Bool Property AlwaysUndressAtAnimStart
	bool Function Get()
		Return OStimUndressAtStart.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUndressAtStart.value = 1
		Else
			OStimUndressAtStart.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimRemoveWeaponsAtStart Auto
Bool Property RemoveWeaponsAtStart
	bool Function Get()
		Return OStimRemoveWeaponsAtStart.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimRemoveWeaponsAtStart.value = 1
		Else
			OStimRemoveWeaponsAtStart.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUndressMidScene Auto
Bool Property AutoUndressIfNeeded
	bool Function Get()
		Return OStimUndressMidScene.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUndressMidScene.value = 1
		Else
			OStimUndressMidScene.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPartialUndressing Auto
Bool Property PartialUndressing
	bool Function Get()
		Return OStimPartialUndressing.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPartialUndressing.value = 1
		Else
			OStimPartialUndressing.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimRemoveWeaponsWithSlot Auto
int Property RemoveWeaponsWithSlot
	int Function Get()
		Return OStimRemoveWeaponsWithSlot.value as int
	EndFunction
	Function Set(int Value)
		OStimRemoveWeaponsWithSlot.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimAnimateRedress Auto
Bool Property FullyAnimateRedress
	bool Function Get()
		Return OStimAnimateRedress.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAnimateRedress.value = 1
		Else
			OStimAnimateRedress.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUndressWigs Auto
Bool Property UndressWigs
	bool Function Get()
		Return OStimUndressWigs.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUndressWigs.value = 1
		Else
			OStimUndressWigs.value = 0
		EndIf
	EndFunction
EndProperty

; changing the value of this global does not change the undressing behavior
; to change the undressing behavior you need to change the return value of OUndress.UsePapyrusUndressing()
; this global has a purely informative purpose, so consider it to be read only
GlobalVariable Property OStimUsePapyrusUndressing Auto
Bool Property UsePapyrusUndressing
	bool Function Get()
		Return OStimUsePapyrusUndressing.value != 0
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; GENDER ROLE SETTINGS  ---------------------------------------------------------------------------

GlobalVariable Property OStimIntendedSexOnly Auto
Bool Property IntendedSexOnly
	bool Function Get()
		Return OStimIntendedSexOnly.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimIntendedSexOnly.value = 1
		Else
			OStimIntendedSexOnly.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerAlwaysDomStraight Auto
Bool Property PlayerAlwaysDomStraight
	bool Function Get()
		Return OStimPlayerAlwaysDomStraight.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerAlwaysDomStraight.value = 1
		Else
			OStimPlayerAlwaysDomStraight.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerAlwaysSubStraight Auto
Bool Property PlayerAlwaysSubStraight
	bool Function Get()
		Return OStimPlayerAlwaysSubStraight.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerAlwaysSubStraight.value = 1
		Else
			OStimPlayerAlwaysSubStraight.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerAlwaysDomGay Auto
Bool Property PlayerAlwaysDomGay
	bool Function Get()
		Return OStimPlayerAlwaysDomGay.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerAlwaysDomGay.value = 1
		Else
			OStimPlayerAlwaysDomGay.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerAlwaysSubGay Auto
Bool Property PlayerAlwaysSubGay
	bool Function Get()
		Return OStimPlayerAlwaysSubGay.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerAlwaysSubGay.value = 1
		Else
			OStimPlayerAlwaysSubGay.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerSelectRoleStraight Auto
Bool Property PlayerSelectRoleStraight
	bool Function Get()
		Return OStimPlayerSelectRoleStraight.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerSelectRoleStraight.value = 1
		Else
			OStimPlayerSelectRoleStraight.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerSelectRoleGay Auto
Bool Property PlayerSelectRoleGay
	bool Function Get()
		Return OStimPlayerSelectRoleGay.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerSelectRoleGay.value = 1
		Else
			OStimPlayerSelectRoleGay.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerSelectRoleThreesome Auto
Bool Property PlayerSelectRoleThreesome
	bool Function Get()
		Return OStimPlayerSelectRoleThreesome.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerSelectRoleThreesome.value = 1
		Else
			OStimPlayerSelectRoleThreesome.value = 0
		EndIf
	EndFunction
EndProperty

Message Property OStimRoleSelectionMessage Auto
GlobalVariable Property OStimRoleSelectionCount Auto

; -------------------------------------------------------------------------------------------------
; STRAP-ON SETTINGS  ------------------------------------------------------------------------------

GlobalVariable Property OStimUnequipStrapOnIfNotNeeded Auto
bool Property UnequipStrapOnIfNotNeeded
	bool Function Get()
		Return OStimUnequipStrapOnIfNotNeeded.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUnequipStrapOnIfNotNeeded.value = 1
		Else
			OStimUnequipStrapOnIfNotNeeded.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; FUTANARI SETTINGS  ------------------------------------------------------------------------------

GlobalVariable Property OStimUseSoSSex Auto
bool Property UseSoSSex
	bool Function Get()
		Return OStimUseSoSSex.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseSoSSex.value = 1
		Else
			OStimUseSoSSex.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimUseTNGSex Auto
bool Property UseTNGSex
	bool Function Get()
		Return OStimUseTNGSex.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseTNGSex.value = 1
		Else
			OStimUseTNGSex.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFutaUseMaleRole Auto
bool Property FutaUseMaleRole
	bool Function Get()
		Return OStimFutaUseMaleRole.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimFutaUseMaleRole.value = 1
		Else
			OStimFutaUseMaleRole.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFutaUseMaleExcitement Auto
bool Property FutaUseMaleExcitement
	bool Function Get()
		Return OStimFutaUseMaleExcitement.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimFutaUseMaleExcitement.value = 1
		Else
			OStimFutaUseMaleExcitement.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFutaUseMaleClimax Auto
bool Property FutaUseMaleClimax
	bool Function Get()
		Return OStimFutaUseMaleClimax.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimFutaUseMaleClimax.value = 1
		Else
			OStimFutaUseMaleClimax.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; ALIGNMENT SETTINGS  -----------------------------------------------------------------------------

GlobalVariable Property OStimDisableScaling Auto
bool Property DisableScaling
	bool Function Get()
		Return OStimDisableScaling.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimDisableScaling.value = 1
		Else
			OStimDisableScaling.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimDisableSchlongBending Auto
bool Property DisableSchlongBending
	bool Function Get()
		Return OStimDisableSchlongBending.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimDisableSchlongBending.value = 1
		Else
			OStimDisableSchlongBending.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAlignmentGroupBySex Auto
bool Property AlignmentGroupBySex
	bool Function Get()
		Return OStimAlignmentGroupBySex.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAlignmentGroupBySex.value = 1
		Else
			OStimAlignmentGroupBySex.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAlignmentGroupByHeight Auto
bool Property AlignmentGroupByHeight
	bool Function Get()
		Return OStimAlignmentGroupByHeight.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAlignmentGroupByHeight.value = 1
		Else
			OStimAlignmentGroupByHeight.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimAlignmentGroupByHeels Auto
bool Property AlignmentGroupByHeels
	bool Function Get()
		Return OStimAlignmentGroupByHeels.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimAlignmentGroupByHeels.value = 1
		Else
			OStimAlignmentGroupByHeels.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; FURNITURE SETTINGS  -----------------------------------------------------------------------------

GlobalVariable Property OStimUseFurniture Auto
bool Property UseFurniture
	bool Function Get()
		Return OStimUseFurniture.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUseFurniture.value = 1
		Else
			OStimUseFurniture.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimSelectFurniture Auto
bool Property SelectFurniture
	bool Function Get()
		Return OStimSelectFurniture.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimSelectFurniture.value = 1
		Else
			OStimSelectFurniture.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFurnitureSearchDistance Auto
int Property FurnitureSearchDistance
	int Function Get()
		Return OStimFurnitureSearchDistance.value As int
	EndFunction
	Function Set(int Value)
		OStimFurnitureSearchDistance.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimResetClutter Auto
bool Property ResetClutter
	bool Function Get()
		Return OStimResetClutter.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimResetClutter.value = 1
		Else
			OStimResetClutter.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimResetClutterRadius Auto
int Property ResetClutterRadius
	int Function Get()
		Return OStimResetClutterRadius.value As int
	EndFunction
	Function Set(int Value)
		OStimResetClutterRadius.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimBedRealignment Auto
float Property BedRealignment
	float Function Get()
		Return OStimBedRealignment.value
	EndFunction
	Function Set(float Value)
		OStimBedRealignment.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimBedOffset Auto
float Property BedOffset
	float Function Get()
		Return OStimBedOffset.value
	EndFunction
	Function Set(float Value)
		OStimBedOffset.value = Value
	EndFunction
EndProperty

Message Property OStimBedConfirmationMessage Auto
Message Property OStimFurnitureSelectionMessage Auto
GlobalVariable[] Property OStimFurnitureSelectionButtons Auto

; -------------------------------------------------------------------------------------------------
; EXPRESSION SETTINGS  ----------------------------------------------------------------------------

GlobalVariable Property OStimExpressionDurationMin Auto
int Property ExpressionDurationMin
	int Function Get()
		Return OStimExpressionDurationMin.value As int
	EndFunction
	Function Set(int Value)
		If ExpressionDurationMax < Value
			OStimExpressionDurationMin.value = OStimExpressionDurationMax.value
			OStimExpressionDurationMax.value = Value
		Else
			OStimExpressionDurationMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimExpressionDurationMax Auto
int Property ExpressionDurationMax
	int Function Get()
		Return OStimExpressionDurationMax.value As int
	EndFunction
	Function Set(int Value)
		If ExpressionDurationMin > Value
			OStimExpressionDurationMax.value = OStimExpressionDurationMin.value
			OStimExpressionDurationMin.value = Value
		Else
			OStimExpressionDurationMax.value = Value
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; SOUND SETTINGS  ---------------------------------------------------------------------------------

GlobalVariable Property OStimMoanIntervalMin Auto
int Property MoanIntervalMin
	int Function Get()
		Return OStimMoanIntervalMin.value As int
	EndFunction
	Function Set(int Value)
		If MoanIntervalMax < Value
			OStimMoanIntervalMin.value = OStimMoanIntervalMax.value
			OStimMoanIntervalMax.value = Value
		Else
			OStimMoanIntervalMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimMoanIntervalMax Auto
int Property MoanIntervalMax
	int Function Get()
		Return OStimMoanIntervalMax.value As int
	EndFunction
	Function Set(int Value)
		If MoanIntervalMin > Value
			OStimMoanIntervalMax.value = OStimMoanIntervalMin.value
			OStimMoanIntervalMin.value = Value
		Else
			OStimMoanIntervalMax.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimMoanVolume Auto
float Property MoanVolume
	float Function Get()
		Return OStimMoanVolume.value
	EndFunction
	Function Set(float Value)
		OStimMoanVolume.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimMaleDialogueCountdownMin Auto
int Property MaleDialogueCountdownMin
	int Function Get()
		Return OStimMaleDialogueCountdownMin.value As int
	EndFunction
	Function Set(int Value)
		If MaleDialogueCountdownMax < Value
			OStimMaleDialogueCountdownMin.value = OStimMaleDialogueCountdownMax.value
			OStimMaleDialogueCountdownMax.value = Value
		Else
			OStimMaleDialogueCountdownMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimMaleDialogueCountdownMax Auto
int Property MaleDialogueCountdownMax
	int Function Get()
		Return OStimMaleDialogueCountdownMax.value As int
	EndFunction
	Function Set(int Value)
		If MaleDialogueCountdownMin > Value
			OStimMaleDialogueCountdownMax.value = OStimMaleDialogueCountdownMin.value
			OStimMaleDialogueCountdownMin.value = Value
		Else
			OStimMaleDialogueCountdownMax.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFemaleDialogueCountdownMin Auto
int Property FemaleDialogueCountdownMin
	int Function Get()
		Return OStimFemaleDialogueCountdownMin.value As int
	EndFunction
	Function Set(int Value)
		If FemaleDialogueCountdownMax < Value
			OStimFemaleDialogueCountdownMin.value = OStimFemaleDialogueCountdownMax.value
			OStimFemaleDialogueCountdownMax.value = Value
		Else
			OStimFemaleDialogueCountdownMin.value = Value
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFemaleDialogueCountdownMax Auto
int Property FemaleDialogueCountdownMax
	int Function Get()
		Return OStimFemaleDialogueCountdownMax.value As int
	EndFunction
	Function Set(int Value)
		If FemaleDialogueCountdownMin > Value
			OStimFemaleDialogueCountdownMax.value = OStimFemaleDialogueCountdownMin.value
			OStimFemaleDialogueCountdownMin.value = Value
		Else
			OStimFemaleDialogueCountdownMax.value = Value
		EndIf
	EndFunction
EndProperty


GlobalVariable Property OStimSoundVolume Auto
float Property SoundVolume
	float Function Get()
		Return OStimSoundVolume.value
	EndFunction
	Function Set(float Value)
		OStimSoundVolume.value = Value
	EndFunction
EndProperty

GlobalVariable Property OStimPlayerDialogue Auto
bool Property PlayerDialogue
	bool Function Get()
		Return OStimPlayerDialogue.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimPlayerDialogue.value = 1
		Else
			OStimPlayerDialogue.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; DEBUG SETTINGS  ---------------------------------------------------------------------------------

GlobalVariable Property OStimUnrestrictedNavigation Auto
bool Property UnrestrictedNavigation
	bool Function Get()
		Return OStimUnrestrictedNavigation.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimUnrestrictedNavigation.value = 1
		Else
			OStimUnrestrictedNavigation.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimNoFacialExpressions Auto
bool Property NoFacialExpressions
	bool Function Get()
		Return OStimNoFacialExpressions.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimNoFacialExpressions.value = 1
		Else
			OStimNoFacialExpressions.value = 0
		EndIf
	EndFunction
EndProperty

GlobalVariable Property OStimFixDarkFace Auto
bool Property FixDarkFace
	bool Function Get()
		Return OStimFixDarkFace.value != 0
	EndFunction
	Function Set(bool Value)
		If Value
			OStimFixDarkFace.value = 1
		Else
			OStimFixDarkFace.value = 0
		EndIf
	EndFunction
EndProperty

; -------------------------------------------------------------------------------------------------
; SCRIPTWIDE VARIABLES ----------------------------------------------------------------------------

Perk Property OStimNPCCondition Auto

String[] CurrScene

Actor Property PlayerRef Auto

Bool Property UndressDom Auto
Bool Property UndressSub Auto

OBarsScript Property OBars Auto

;--------- ID shortcuts

quest property subthreadquest auto 


; -------------------------------------------------------------------------------------------------
; BBLS/Migal mods stuff so we don't apply FaceLight over his actors who already have it -----------

Faction BBLS_FaceLightFaction
ActorBase Vayne
ActorBase Coralyn


; -------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------


Event OnInit()
	Console("OStim initializing")
	Startup() ; OStim install script
EndEvent


;
;			██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝


OBarsScript Function GetBarScript()
	return obars
EndFunction

Bool Function ActorHasFacelight(Actor Act)
	{Checks if Actor already has FaceLight. Currently we only check BBLS NPCs and Vayne}
	If (BBLS_FaceLightFaction && Act.GetFactionRank(BBLS_FaceLightFaction) >= 0)
		return true
	EndIf
	
	If (Vayne && Act.GetActorBase() == Vayne)
		; Vayne's facelight can be turned on or off in her MCM menu
		; The below GlobalVariable tells us if Vayne's facelight is currently on or off
		return (Game.GetFormFromFile(0x0004B26B, "CS_Vayne.esp") as GlobalVariable).GetValueInt() == 1
	EndIf

	If (Coralyn && Act.GetActorBase() == Coralyn)
		; Coralyn's facelight can be turned on or off in her MCM menu
		; The below GlobalVariable tells us if Coralyn's facelight is currently on or off
		return (Game.GetFormFromFile(0x0004D91E, "CS_Coralyn.esp") as GlobalVariable).GetValueInt() == 1
	EndIf

	return false
EndFunction

Function LightActor(Actor Act, Int Pos, Int Brightness) ; pos 1 - ass, pos 2 - face | brightness - 0 = dim
	If (Pos == 0)
		Return
	EndIf

	String Which
	If (Pos == 1) ; ass
		If (Brightness == 0)
			Which = "AssDim"
		Else
			Which = "AssBright"
		EndIf
	ElseIf (Pos == 2) ;face
		If (!ActorHasFacelight(Act))
			If (Brightness == 0)
				Which = "FaceDim"
			Else
				Which = "FaceBright"
			EndIf
		Else
			Console(Act.GetActorBase().GetName() + " already has facelight, not applying it")
			return
		EndIf
	EndIf
EndFunction

Bool Function IsSceneAggressiveThemed() ; if the entire situation should be themed aggressively
	String SceneID = OThread.GetScene(0)

	int i = OMetadata.GetActorCount(SceneID)
	While i
		i -= 1
		If OMetadata.HasActorTag(SceneID, i, "dominant")
			Return true
		EndIf
	EndWhile

	Return false
EndFunction

Actor Function GetAggressiveActor()
	String SceneID = OThread.GetScene(0)
	int Count = OMetadata.GetActorCount(SceneID)
	int i = 0
	While i < Count
		If OMetadata.HasActorTag(SceneID, i, "dominant")
			Return OThread.GetActor(0, i)
		EndIf
		i += 1
	EndWhile

	Return None
EndFunction

bool Function IsVictim(actor act)
	If !IsSceneAggressiveThemed()
		Return False
	EndIf

	Return !OMetadata.HasActorTag(OThread.GetScene(0), OThread.GetActorPosition(0, Act), "dominant")
endfunction 

Actor Function GetSexPartner(Actor Char)
	Actor[] Actors = OThread.GetActors(0)
	If Actors.Length == 1
		Return Actors[0]
	EndIf
	If (Char == Actors[0])
		Return Actors[1]
	EndIf
	Return Actors[0]
EndFunction

; Warps to all of the scene IDs in the array.
; Does not do any waiting on it's own. To do that, you can add in numbers into the list, 
; and the function will wait that amount of time
; i.e. [sceneID, sceneID, "3", sceneID]
Function PlayAnimationSequence(String[] list)
	; TODO
EndFunction

function FadeFromBlack(float time = 4.0)
	Game.FadeOutGame(False, True, 0.0, time) ; welcome back
EndFunction

function FadeToBlack(float time = 1.25)
		Game.FadeOutGame(True, True, 0.0, Time)
		Utility.Wait(Time * 0.70)
		Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
EndFunction

Bool Function IsFemale(Actor Act)
	{genitalia based / has a vagina and not a penis}
	If !Act
		Return False
	EndIf

	Return !OActor.HasSchlong(Act)
EndFunction

Bool Function AppearsFemale(Actor Act) 
	{gender based / looks like a woman but can have a penis}
	Return OSANative.GetSex(OSANative.GetLeveledActorBase(act)) == 1
EndFunction

String[] Function GetScene()
	{this is not the sceneID, this is an internal osex thing}
	Return CurrScene
EndFunction

Function HideAllSkyUIWidgets() ; DEPRECIATED
	outils.SetSkyUIWidgetsVisible(false)
EndFunction

Function ShowAllSkyUIWidgets()
	outils.SetSkyUIWidgetsVisible(true)
EndFunction


Function ModifyStimMult(actor act, float by)
	{thread-safe stimulation modification. Highly recomended you use this over Set.}
	OUtils.lock("mtx_stimmult")
	SetStimMult(act, GetStimMult(act) + by)
	osanative.unlock("mtx_stimmult")
endfunction

bool Function IsBeingStimulated(Actor act)
	return (GetCurrentStimulation(act) * GetStimMult(act)) > 0.01
EndFunction

;
;			██████╗ ███████╗██████╗ ███████╗
;			██╔══██╗██╔════╝██╔══██╗██╔════╝
;			██████╔╝█████╗  ██║  ██║███████╗
;			██╔══██╗██╔══╝  ██║  ██║╚════██║
;			██████╔╝███████╗██████╔╝███████║
;			╚═════╝ ╚══════╝╚═════╝ ╚══════╝
;
;				Code related to beds

ObjectReference Function FindBed(ObjectReference CenterRef, Float Radius = 0.0)
	If !(Radius > 0.0)
		; we are searching from the center of the bed
		; center to edge of the bed is about 1 meter / 100 units
		Radius = (FurnitureSearchDistance + 1) * 100.0
	EndIf

	ObjectReference[] Beds = OSANative.FindBed(CenterRef, Radius, 96.0)

	ObjectReference NearRef = None

	Int i = 0
	Int L = Beds.Length

	While (i < L)
		ObjectReference Bed = Beds[i]
		If (!Bed.IsFurnitureInUse())
			NearRef = Bed
			i = L
		Else
			i += 1
		EndIf
	EndWhile

	If (NearRef)
		Return NearRef
	EndIf

	Return None
EndFunction

Bool Function SameFloor(ObjectReference BedRef, Float Z, Float Tolerance = 128.0)
	Return (Math.Abs(Z - BedRef.GetPositionZ())) <= Tolerance
EndFunction

Bool Function CheckBed(ObjectReference BedRef, Bool IgnoreUsed = True)
	Return BedRef && BedRef.IsEnabled() && BedRef.Is3DLoaded()
EndFunction


;
;			 ██████╗ ███████╗███████╗██╗  ██╗     ██████╗ ███████╗██╗      █████╗ ████████╗███████╗██████╗     ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
;			██╔═══██╗██╔════╝██╔════╝╚██╗██╔╝     ██╔══██╗██╔════╝██║     ██╔══██╗╚══██╔══╝██╔════╝██╔══██╗    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
;			██║   ██║███████╗█████╗   ╚███╔╝█████╗██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
;			██║   ██║╚════██║██╔══╝   ██╔██╗╚════╝██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
;			╚██████╔╝███████║███████╗██╔╝ ██╗     ██║  ██║███████╗███████╗██║  ██║   ██║   ███████╗██████╔╝    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
;			 ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝     ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
;
;				Event hooks that receive data from OSA

;
;			███████╗████████╗██╗███╗   ███╗██╗   ██╗██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
;			██╔════╝╚══██╔══╝██║████╗ ████║██║   ██║██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
;			███████╗   ██║   ██║██╔████╔██║██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
;			╚════██║   ██║   ██║██║╚██╔╝██║██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
;			███████║   ██║   ██║██║ ╚═╝ ██║╚██████╔╝███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
;			╚══════╝   ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
;
;				All code related to the stimulation simulation


Float Function GetCurrentStimulation(Actor Act) ; how much an Actor is being stimulated in the current animation
	;TODO: Return this from c++?
	return 0
EndFunction

float Function GetHighestExcitement()
	float Highest = 0

	Actor[] Actors = OThread.GetActors(0)
	int i = Actors.Length
	While i
		i -= 1
		float Excitement = GetActorExcitement(Actors[i])
		If Excitement > Highest
			Highest = Excitement
		EndIf
	EndWhile

	return Highest
EndFunction


Event OStimStart(String EventName, String sceneId, Float index, Form Sender)
	_Actors = OThread.GetActors(0)
	MostRecentOrgasmedActor = None
	StartTime = Utility.GetCurrentRealTime()
EndEvent

Event OStimEnd(String EventName, String sceneId, Float index, Form Sender)
	OSANative.EndPlayerDialogue()
EndEvent

Event OStimOrgasm(String EventName, String sceneId, Float index, Form Sender)
	Actor Act = Sender As Actor
	MostRecentOrgasmedActor = Act

	; Fertility Mode compatibility
	int actionIndex = OMetadata.FindActionForActor(sceneId, index as int, "vaginalsex")
	If  actionIndex != -1
		Actor impregnated = GetActor(OMetadata.GetActionTarget(sceneId, actionIndex))
		If impregnated
			int handle = ModEvent.Create("FertilityModeAddSperm")
			If handle
				ModEvent.PushForm(handle, impregnated)
				ModEvent.PushString(handle, Act.GetDisplayName())
				ModEvent.PushForm(handle, Act)
				ModEvent.Send(handle)
			EndIf
		EndIf
	EndIf
EndEvent

; Faces

Function MuteFaceData(Actor Act)
	Act.AddToFaction(OstimNoFacialExpressionsFaction)
EndFunction

Function UnMuteFaceData(Actor Act)
	Act.RemoveFromFaction(OstimNoFacialExpressionsFaction)
EndFunction

Bool Function FaceDataIsMuted(Actor Act)
	Return Act.IsInFaction(OstimNoFacialExpressionsFaction)
EndFunction


;			███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗
;			██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
;			███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
;			╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
;			███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
;			╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝
;
;				Code related to Sound

;/* SendExpressionEvent
* * plays the event expression and if it is valid resets the expression when it's over
* * contains a Utility::Wait call, so best only call this from event listeners
*/;
Function SendExpressionEvent(Actor Act, string EventName)
	int Position = OThread.GetActorPosition(0, Act)
	If Position < 0
		Return
	EndIf

	float Duration = OActor.PlayExpression(Act, EventName)
	If Duration != -1
		Utility.Wait(Duration)
		OActor.ClearExpression(Act)
	EndIf
EndFunction




;			 ██████╗ ████████╗██╗  ██╗███████╗██████╗
;			██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
;			██║   ██║   ██║   ███████║█████╗  ██████╔╝
;			██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
;			╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
;			 ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
;
;				Misc stuff
;				https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=ANSI%20Shadow&text=Other


Function Console(String In) Global
	MiscUtil.PrintConsole("OStim: " + In)
EndFunction

Bool Function ChanceRoll(Int Chance) ; input 60: 60% of returning true ;DEPRECIATED - moving to outils in future ver


	return OUtils.ChanceRoll(chance)

EndFunction

Function ShakeController(Float Power, Float Duration = 0.1)
	If UseRumble
		Game.ShakeController(Power, Power, Duration)
	EndIf
EndFunction

Function DisplayToastAsync(string txt, float lengthOftime)

	RegisterForModEvent("ostim_toast", "DisplayToastEvent")

	int handle = ModEvent.Create("ostim_toast")
	ModEvent.PushString(handle, txt)
	ModEvent.Pushfloat(handle, lengthOftime)

	ModEvent.send(handle)
endfunction

Event DisplayToastEvent(string txt, float time)
	outils.DisplayToastText(txt, time)
EndEvent

Bool Function GetGameIsVR()
	Return (PapyrusUtil.GetScriptVersion() == 36) ;obviously this no guarantee but it's the best we've got for now
EndFunction

Float ProfileTime 
Function Profile(String Name = "")
	{Call Profile() to start. Call Profile("any string") to pring out the time since profiler started in console. Most accurate at 60fps}
	If (Name == "")
		ProfileTime = Game.GetRealHoursPassed() * 60 * 60
	Else
		float seconds = ((Game.GetRealHoursPassed() * 60 * 60) - ProfileTime - 0.016)
		float ms = seconds * 1000
		If seconds < 0.0
			Console(Name + ": Too fast to measure")
			Debug.Trace("Ostim: "+Name+" : Too fast to measure")
		else 
			Console(Name + ": " + seconds + " seconds (" + ms + " milliseconds)")
			Debug.Trace("Ostim: "+Name+": " + seconds + " seconds (" + ms + " milliseconds)")
		endif 
	EndIf
EndFunction

Bool Property SoSInstalled Auto
Bool Property TNGInstalled Auto

int rnd_s1
int rnd_s2
int rnd_s3


int Function RandomInt(int min = 0, int max = 100) ;DEPRECIATED - moving to osanative in future ver
	return OSANative.RandomInt(min, max)
EndFunction

Function Startup()
	InstalledVersion = GetAPIVersion()

	OnLoadGame()

	OUtils.DisplayTextBanner("OStim installed.")
EndFunction

Function OnLoadGame()
	int PluginVersion = SKSE.GetPluginVersion("OStim")
	If PluginVersion == 0
		Debug.MessageBox("OStim Standalone: The OStim.dll isn't loaded. Make sure to run the game through SKSE.")
	ElseIf PluginVersion != 0x07030054
		Debug.MessageBox("OStim Standalone: Your OStim.dll or OSexIntegraionMain.pex is being overwritten with an old version. OStim and its addons will NOT work properly. If you are using the OStim VR add-on make sure to use matching version numbers. Please don't report any other bugs while this issue persists.")
	EndIf

	SoSInstalled = Game.GetModByName("Schlongs of Skyrim.esp") != 0xFF
	TNGInstalled = Game.GetLightModByName("TheNewGentleman.esp") != 0xFFFF

	If SKSE.GetPluginVersion("ImprovedCameraSE") != -1
		OStimImprovedCamSupport.value = 1
	Else
		OStimImprovedCamSupport.value = 0
	EndIf
		
	DisableOSAControls = false
	OBars.OnGameLoad()

	BBLS_FaceLightFaction = Game.GetFormFromFile(0x00755331, "BBLS_SKSE64_Patch.esp") as Faction
	Vayne = Game.GetFormFromFile(0x0000083D, "CS_Vayne.esp") as ActorBase
	Coralyn = Game.GetFormFromFile(0x0000080A, "CS_Coralyn.esp") as ActorBase

	POSITION_TAGS = new string[16]
	POSITION_TAGS[0]  = "allfours"
	POSITION_TAGS[1]  = "bendover"
	POSITION_TAGS[2]  = "facingaway"
	POSITION_TAGS[3]  = "handstanding"
	POSITION_TAGS[4]  = "kneeling"
	POSITION_TAGS[5]  = "lyingback"
	POSITION_TAGS[6]  = "facingaway"
	POSITION_TAGS[7]  = "lyingfront"
	POSITION_TAGS[8]  = "lyingside"
	POSITION_TAGS[9]  = "onbottom"
	POSITION_TAGS[10] = "ontop"
	POSITION_TAGS[11] = "sitting"
	POSITION_TAGS[12] = "spreadlegs"
	POSITION_TAGS[13] = "squatting"
	POSITION_TAGS[14] = "standing"
	POSITION_TAGS[15] = "suspended"

	RegisterForModEvent("ostim_start", "OStimStart")
	RegisterForModEvent("ostim_end", "OStimEnd")
	RegisterForModEvent("ostim_orgasm", "OStimOrgasm")

	If AutoImportSettings
		Console("Loading Ostim settings.")
		OData.ImportSettings()
		Console("Loaded Ostim settings.")
	EndIf

	(Game.GetFormFromFile(0xE3E, "OStim.esp") As OSexIntegrationMCM).SetupPages()
EndFunction


; ██████╗ ███████╗██████╗ ██████╗ ███████╗ ██████╗ █████╗ ████████╗███████╗██████╗ 
; ██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
; ██║  ██║█████╗  ██████╔╝██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║
; ██║  ██║██╔══╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║
; ██████╔╝███████╗██║     ██║  ██║███████╗╚██████╗██║  ██║   ██║   ███████╗██████╔╝
; ╚═════╝ ╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝ 

; all of these are only here to not break old addons, don't use them in new addons, use whatever they're calling instead

float StartTime = 0.0

Faction Property NVCustomOrgasmFaction Auto

bool Property UseAINPConNPC
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property ShowTutorials
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

int Property DefaultFOV
	int Function Get()
		Return 85
	EndFunction
	Function Set(int Value)
	EndFunction
EndProperty

bool Property HideBarsInNPCScenes
	bool Function Get()
		return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property UseStrongerUnequipMethod
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property TossClothesOntoGround
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property OrgasmIncreasesRelationship
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property UseNativeFunctions
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

float Property SexExcitementMult
	float Function Get()
		Return MaleSexExcitementMult
	EndFunction
	Function Set(float Value)
		MaleSexExcitementMult = Value
	EndFunction
EndProperty

bool Property UseBed
	bool Function Get()
		Return UseFurniture
	EndFunction
	Function Set(bool Value)
		UseFurniture = Value
	EndFunction
EndProperty

bool Property AllowUnlimitedSpanking
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property OnlyGayAnimsInGayScenes
	bool Function Get()
		Return IntendedSexOnly
	EndFunction
	Function Set(bool Value)
		IntendedSexOnly = Value
	EndFunction
EndProperty

bool Property EndOnDomOrgasm
	bool Function Get()
		Return EndOnMaleOrgasm
	EndFunction
	Function Set(bool Value)
		EndOnMaleOrgasm = Value
	EndFunction
EndProperty

bool Property EndOnSubOrgasm
	bool Function Get()
		Return EndOnFemaleOrgasm
	EndFunction
	Function Set(bool Value)
		EndOnFemaleOrgasm = Value
	EndFunction
EndProperty

bool Property RequireBothOrgasmsToFinish
	bool Function Get()
		Return EndOnAllOrgasm
	EndFunction
	Function Set(bool Value)
		EndOnAllOrgasm = Value
	EndFunction
EndProperty

Bool Property EnableDomBar
	bool Function Get()
		Return EnablePlayerBar
	EndFunction
	Function Set(bool Value)
		EnablePlayerBar = Value
	EndFunction
EndProperty

Bool Property EnableSubBar
	bool Function Get()
		Return EnableNpcBar
	EndFunction
	Function Set(bool Value)
		EnableNpcBar = Value
	EndFunction
EndProperty

Bool Property EnableThirdBar
	bool Function Get()
		Return EnableNpcBar
	EndFunction
	Function Set(bool Value)
		EnableNpcBar = Value
	EndFunction
EndProperty

Bool Property UseBrokenCosaveWorkaround
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

Bool Property EndAfterActorHit
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

int Property AiSwitchChance
	int Function Get()
		Return 0
	EndFunction
	Function Set(int Value)
	EndFunction
EndProperty

Bool property ForceCloseOStimThread
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
		If Value
			EndAnimation(false)
		EndIf
	EndFunction
EndProperty

bool Property SkipEndingFadein
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property Installed
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

Bool Property BlockVRInstalls
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

Bool Property DisableStimulationCalculation
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

Bool Property PauseAI
	bool Function Get()
		Return OThread.IsInAutoMode(0)
	EndFunction
	Function Set(bool Value)
		If Value
			OThread.StartAutoMode(0)
		Else
			OThread.StopAutoMode(0)
		EndIf
	EndFunction
EndProperty

bool Property GetInBedAfterBedScene
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

Bool property EndedProper
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

int Property DomLightPos = 0 Auto
int Property SubLightPos = 0 Auto
int Property DomLightBrightness = 0 Auto
int Property SubLightBrightness = 0 Auto

Bool Property MuteOSA
	bool Function Get()
		Return false
	EndFunction
	Function Set(bool Value)
		If !AnimationRunning()
			Return
		EndIf

		; NV used this together with a whitelist to only mute the female moans
		; so we will do exactly that here
		If Value
			Actor[] Actors = OThread.GetActors(0)
			int i = Actors.Length
			While i
				i -= 1
				If AppearsFemale(Actors[i])
					OActor.Mute(Actors[i])
				EndIf
			EndWhile
		EndIf
	EndFunction
EndProperty

bool Property DisableOSAControls = false Auto

bool Property EquipStrapOnIfNeeded
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

bool Property UnequipStrapOnIfInWay
	bool Function Get()
		Return true
	EndFunction
	Function Set(bool Value)
	EndFunction
EndProperty

;/* GetAPIVersion
* * returns the current API version
* * read "Data/SKSE/plugins/OStim/API version README.txt" for further information
* *
* * @return: the version of the current API
*/;
Int Function GetAPIVersion()
	Return SKSE.GetPluginVersion("OStim")
EndFunction

Actor Function GetDomActor()
	Return GetActor(0)
EndFunction

Actor Function GetSubActor()
	Return GetActor(1)
EndFunction

Actor Function GetThirdActor()
	Return GetActor(2)
EndFunction

ObjectReference Function GetBed()
	Return OThread.GetFurniture(0)
EndFunction

bool Function SoloAnimsInstalled()
	Actor[] Actors = new Actor[1]
	Actors[0] = None
	return OLibrary.GetRandomScene(Actors) != ""
EndFunction

bool Function ThreesomeAnimsInstalled()
	Actor[] Actors = new Actor[3]
	Actors[0] = None
	Actors[1] = None
	Actors[2] = None
	return OLibrary.GetRandomScene(Actors) != ""
EndFunction

Bool Function IsVaginal()
	Return OMetadata.FindAction(OThread.GetScene(0), "vaginalsex") != -1
EndFunction

Bool Function IsOral()
	; this method did not check for animation class VJ, so to keep it working as it was we don't check for cunnilingus
	Return OMetadata.FindAction(OThread.GetScene(0), "blowjob") != -1
EndFunction

Actor Function GetCurrentLeadingActor()
	int actorIndex = 0
	If OMetadata.HasActions(OThread.GetScene(0))
		actorIndex = OMetadata.GetActionPerformer(OThread.GetScene(0), 0)
	EndIf
	Return GetActor(actorIndex)
EndFunction

Bool Function GetCurrentAnimIsAggressive()
	string SceneID = OThread.GetScene(0)
	int i = OMetadata.GetActorCount(SceneID)
	While i
		i -= 1
		If OMetadata.HasActorTag(SceneID, i, "aggressor")
			Return true
		EndIf
	EndWhile

	Return false
EndFunction

Actor MostRecentOrgasmedActor
Actor Function GetMostRecentOrgasmedActor()
	; use (sender As Actor) in the ostim_orgasm event instead
	Return MostRecentOrgasmedActor
EndFunction

Bool Function IsNaked(Actor NPC)
	; now that there's partial stripping there isn't really a dedicated being naked condition
	Return (!(NPC.GetWornForm(0x00000004) as Bool))
EndFunction

Function PrintBedInfo(ObjectReference Bed)
	Console("--------------------------------------------")
	Console("BED - Name: " + Bed.GetDisplayName())
	Console("BED - Enabled: " + Bed.IsEnabled())
	Console("BED - 3D loaded: " + Bed.Is3DLoaded())
	Console("BED - Bed roll: " + IsBedRoll(Bed))
	Console("--------------------------------------------")
EndFunction

Bool Function IsPlayerInvolved()
	; NPC scenes no longer run on main thread ever. They will always run in subthreads
	; Some addons might still use this function, so we'll keep it here for now
	return True
EndFunction

Bool Function IsNPCScene()
	; NPC scenes no longer run on main thread ever. They will always run in subthreads
	; Some addons might still use this function, so we'll keep it here for now
	return False
EndFunction

Int Function GetMaxSpanksAllowed()  
	Return 0
EndFunction

Function ToggleFreeCam(Bool On = True)
EndFunction

Function RemapStartKey(Int zKey)
	KeyMap = zKey
EndFunction

Function RemapFreecamKey(Int zKey)
	FreecamKey = zKey
EndFunction

Function RemapControlToggleKey(Int zKey)
	ControlToggleKey = zKey
EndFunction

Function RemapSpeedUpKey(Int zKey)
	speedUpKey = zKey
EndFunction

Function RemapSpeedDownKey(Int zKey)
	speedDownKey = zKey
EndFunction

Function RemapPullOutKey(Int zKey)
	PullOutKey = zKey
EndFunction

Bool Function IntArrayContainsValue(Int[] Arr, Int Val)
	return outils.IntArrayContainsValue(arr, val)
EndFunction

Bool Function StringArrayContainsValue(String[] Arr, String Val)
	return outils.StringArrayContainsValue(arr, val)
EndFunction

bool Function StringContains(string str, string contains)
	return outils.StringContains(str, contains)
EndFunction

bool Function IsModLoaded(string ESPFile)
	return outils.IsModLoaded(ESPFile)
Endfunction

bool Function IsChild(actor act)
	return OUtils.IsChild(Act)
EndFunction

Int Function GetSpankCount() ; 
	Return 0
EndFunction

Function SetGameSpeed(String In)
	; the body was left in in case some addons call this
	; but we will not list ConsoleUtil as a requirement
	ConsoleUtil.ExecuteCommand("sgtm " + In)
EndFunction

Int Function GetTimesOrgasm(Actor Act)
	Return OActor.GetTimesClimaxed(Act)
EndFunction

Int Function GetTimeScale()
	Return (Game.GetFormFromFile(0x00003A, "Skyrim.esm") as GlobalVariable).GetValue() as Int
EndFunction

Function SetTimeScale(Int Time)
	(Game.GetFormFromFile(0x00003A, "Skyrim.esm") as GlobalVariable).SetValue(Time as Float)
EndFunction

; I will remove these again in the future, don't call them!
Function ShowBars()
	int Count = GetActors().Length
	If (AutoHideBars)
		If (!OBars.IsBarVisible(OBars.DomBar))
			OBars.SetBarVisible(OBars.DomBar, True)
		EndIf
		If (Count >= 2 && !OBars.IsBarVisible(OBars.SubBar))
			OBars.SetBarVisible(OBars.SubBar, True)
		EndIf
		If (Count >= 3 && !OBars.IsBarVisible(OBars.ThirdBar))
			OBars.SetBarVisible(OBars.ThirdBar, True)
		EndIf
	EndIf
EndFunction

Float Function GetActorExcitement(Actor Act)
	Return OActor.GetExcitement(Act)
EndFunction

Function SetActorExcitement(Actor Act, Float Value)
	OActor.SetExcitement(Act, Value)
EndFunction

Function AddActorExcitement(Actor Act, Float Value)
	OActor.ModifyExcitement(Act, Value)
EndFunction

bool function IsInFreeCam()
	Return false
endfunction

int Function GetScenePassword()
	return 0
endfunction

Bool Function IsActorActive(Actor Act)
	Return OActor.IsInOStim(Act)
EndFunction

Bool Function AnimationRunning()
	Return OThread.IsRunning(0)
EndFunction

Bool Function IsSoloScene()
	Return OThread.GetActors(0).Length == 1
EndFunction 

Bool Function IsThreesome()
	; did only check for existence of third actor before
	Return OThread.GetActors(0).Length >= 3
EndFunction

Int Function GetCurrentAnimationSpeed()
	Return OThread.GetSpeed(0)
EndFunction

Bool Function AnimationIsAtMaxSpeed()
	Return OThread.GetSpeed(0) == OMetadata.GetMaxSpeed(OThread.GetScene(0))
EndFunction

Int Function GetCurrentAnimationMaxSpeed()
	Return OMetadata.GetMaxSpeed(OThread.GetScene(0))
EndFunction

Function IncreaseAnimationSpeed()
	OThread.SetSpeed(0, OThread.GetSpeed(0) + 1)
EndFunction

Function DecreaseAnimationSpeed()
	OThread.SetSpeed(0, OThread.GetSpeed(0) - 1)
EndFunction

String Function GetCurrentAnimation()
	Return ""
EndFunction

string function GetCurrentAnimationSceneID() 
	Return OThread.GetScene(0)
endfunction

Function TravelToAnimationIfPossible(String Animation)
	OThread.NavigateTo(0, Animation)
EndFunction

Function TravelToAnimation(String Animation)
	OThread.NavigateTo(0, Animation)
EndFunction

Function WarpToAnimation(String Animation) 
	OThread.WarpTo(0, Animation)
EndFunction

Bool Function IsActorInvolved(actor act)
	if act == none 
		return false 
	endif

	Return OThread.GetActors(0).Find(act) >= 0
EndFunction

Function ForceStop()
	OThread.Stop(0)
EndFunction

Bool Function IsBed(ObjectReference Bed)
	If (OSANative.GetDisplayName(bed) == "Bed") || (Bed.Haskeyword(Keyword.GetKeyword("FurnitureBedRoll"))) || (OSANative.GetDisplayName(bed) == "Bed (Owned)")
		Return True
	EndIf
	Return False
EndFunction

Bool Function IsBedRoll(objectReference Bed)
	Return (Bed.Haskeyword(Keyword.GetKeyword("FurnitureBedRoll")))
EndFunction

Function AdjustAnimationSpeed(float amount)
	OThread.SetSpeed(0, OThread.GetSpeed(0) + (amount As int))
EndFunction

Function SetCurrentAnimationSpeed(Int InSpeed)
	OThread.SetSpeed(0, InSpeed)
EndFunction

Function SetDefaultSettings()
	OData.ResetSettings()
EndFunction

Function Climax(Actor Act)
	OActor.Climax(Act, false)
EndFunction

Function Orgasm(Actor Act)
	OActor.Climax(Act, false)
EndFunction

Actor[] _Actors
Actor[] Function GetActors()
	Return _Actors
EndFunction

Actor Function GetActor(int Index)
	Return OThread.GetActor(0, Index)
EndFunction

Bool Function UsingBed()
	string FurnitureType = OThread.GetFurnitureType(0)
	Return FurnitureType == "bedroll" || FurnitureType == "singlebed" || FurnitureType == "doublebed"
EndFunction

Bool Function UsingFurniture()
	Return OThread.GetFurniture(0)
EndFunction

string Function GetFurnitureType()
	Return OThread.GetFurnitureType(0)
EndFunction

ObjectReference Function GetFurniture()
	Return OThread.GetFurniture(0)
EndFunction

float Function GetStimMult(Actor Act)
	Return OActor.GetExcitementMultiplier(Act)
EndFunction

Function SetStimMult(Actor Act, Float Value)
	OActor.SetExcitementMultiplier(Act, Value)
EndFunction

Function AddSceneMetadata(string MetaTag)
	OThread.AddMetadata(0, MetaTag)
EndFunction

bool Function HasSceneMetadata(string MetaTag)
	Return OThread.HasMetadata(0, MetaTag)
EndFunction

string[] Function GetAllSceneMetadata()
	return OThread.GetMetadata(0)
EndFunction

Float Function GetTimeSinceLastPlayerInteraction()
	Return 0
EndFunction

float Function GetTimeSinceStart()
	return Utility.GetCurrentRealTime() - StartTime
EndFunction

Function SetOrgasmStall(Bool Set)
	If Set
		OThread.StallClimax(0)
	Else
		OThread.PermitClimax(0)
	EndIf
EndFunction

Bool Function GetOrgasmStall()
	Return OThread.IsClimaxStalled(0)
EndFunction

bool Function AutoTransitionForActor(Actor Act, string Type)
	Return OActor.AutoTransition(Act, Type)
EndFunction

bool Function AutoTransitionForPosition(int Position, string Type)
	Return OThread.AutoTransitionForActor(0, Position, Type)
EndFunction

Function EndAnimation(Bool SmoothEnding = True)
	OThread.Stop(0)
EndFunction

; don't use the subthread script, use OThread instead
OStimSubthread Function GetUnusedSubthread()
	int i = 0
	int max = subthreadquest.GetNumAliases()
	while i < max 
		OStimSubthread thread = subthreadquest.GetNthAlias(i) as OStimSubthread

		if !thread.IsInUse()
			return thread 
		endif 

		i += 1
	endwhile
EndFunction

; don't use the subthread script, use OThread instead
OStimSubthread Function GetSubthread(int id)
	OStimSubthread ret = subthreadquest.GetNthAlias(id) as OStimSubthread
	if !ret 
		Console("Subthread not found")
	endif 
	return ret
EndFunction

; You probably want to call OThread.QuickStart, a Builder is only needed for more complex parameters
Bool Function StartScene(Actor Dom, Actor Sub, Bool zUndressDom = False, Bool zUndressSub = False, Bool zAnimateUndress = False, String zStartingAnimation = "", Actor zThirdActor = None, ObjectReference Bed = None, Bool Aggressive = False, Actor AggressingActor = None)
	Console("Requesting scene start")

	int BuilderID = OThreadBuilder.Create(OActorUtil.ToArray(dom, sub, zThirdActor))
	OThreadBuilder.SetFurniture(BuilderID, Bed)
	OThreadBuilder.SetStartingAnimation(BuilderID, zStartingAnimation)

	If zUndressDom || zUndressSub
		OThreadBuilder.UndressActors(BuilderID)
	EndIf

	If aggressingActor
		Actor[] DominantActors = new Actor[1]
		DominantActors[0] = aggressingActor
		OThreadBuilder.SetDominantActors(BuilderID, DominantActors)
	EndIf

	If DisableOSAControls && (Dom == PlayerRef || Sub == PlayerRef || zThirdActor == PlayerRef)
		OThreadBuilder.NoPlayerControl(BuilderID)
		DisableOSAControls = false
	EndIf

	Return OThreadBuilder.Start(BuilderID) >= 0
EndFunction

; You probably want to call OThread.QuickStart, a Builder is only needed for more complex parameters
Function Masturbate(Actor Masturbator, Bool zUndress = False, Bool zAnimUndress = False, ObjectReference MBed = None)
	int BuilderID = OThreadBuilder.Create(OActorUtil.ToArray(Masturbator))
	OThreadBuilder.SetFurniture(BuilderID, MBed)

	If zUndress
		OThreadBuilder.UndressActors(BuilderID)
	EndIf

	OThreadBuilder.Start(BuilderID) >= 0
EndFunction