ScriptName OsexIntegrationMCM Extends SKI_ConfigBase

; sex settings
Int SetActorSpeedControl
Int SetsexExcitementMult
Int SetClipinglessFirstPerson
Int SetDisableHitbox
Int SetEndAfterActorHit
Int SetUseRumble
Int SetUseScreenShake
int SetScaling
int SetResetPosition
int SetOnlyGayAnimsInGayScenes

; clothes settings
Int SetUndressIfNeed
Int SetAlwaysAnimateUndress
Int SetAlwaysUndressAtStart
Int SetonlyUndressChest
Int SetDropClothes
int SetAnimateRedress
Int SetStrongerUnequip

; actor role settings
Int setPlayerAlwaysDomStraight
Int setPlayerAlwaysSubStraight
Int setPlayerAlwaysDomGay
Int setPlayerAlwaysSubGay

; bar settings
Int SetSubBar
Int SetDomBar
Int SetThirdBar
Int SetAutoHideBar
Int SetMatchColorToGender
int SetHideNPCOnNPCBars

; orgasm settings
Int SetSlowMoOrgasms
Int SetOrgasmBoostsRel
Int SetEndOnOrgasm
Int SetEndOnSubOrgasm
Int SetEndOnBothOrgasm

; light settings
Int SetDomLightMode
Int SetSubLightMode
Int SetSubLightBrightness
Int SetDomLightBrightness
Int SetOnlyLightInDark

Int SetResetState
Int SetRebuildDatabase

; keymapping settings
Int SetKeymap
Int SetKeyUp
Int SetKeyDown
Int SetPullOut

Int SetThanks

; light settings
String[] DomLightModeList
String[] SubLightModeList

String[] SubLightBrightList
String[] DomLightBrightList

; bed settings
Int SetEnableBeds
Int SetBedSearchDistance
Int SetBedReallignment
int SetBedAlgo

; ai control settings
Int SetAIControl
Int SetControlToggle
Int SetAIChangeChance

Int SetForceAIIfAttacking
Int SetForceAIIfAttacked
Int SetForceAIInConsensualScenes
Int SetForceAIForMasturbation

; misc settings afaik
Int SetCustomTimescale
int SetTutorialMessages

Int SetMisallignmentOption
Int SetFlipFix

Int SetUseFades
Int SetUseAutoFades

Int SetMute

; camera settings
Int SetUseFreeCam
Int SetFreeCamFOV
Int SetDefaultFOV
Int SetCameraSpeed
Int SetForceFirstPerson
int SetFreecamToggleKey

Int SetUseCosaveWorkaround

; mcm save/load settings
Int ExportSettings
Int ImportSettings
Int ImportDefaultSettings

int SetUpdate

OsexIntegrationMain Main


string currPage
int[] SlotSets

actor playerref

int SetUndressingAbout

;ORomance 
int SetORDifficulty
int SetORSexuality
int SetORKey
int SetORColorblind
int SetORStationary
int SetORLeft
int SetORRight
int SetORNakadashi

string ORomance = "ORomance.esp"
int GVORDifficulty = 0x0063A4
int GVORSexuality = 0x0063A5
int GVORKey = 0x006E6A
int GVORLeft = 0x73D2
int GVORRight = 0x73D3
int GVORColorblind = 0x73D0
int GVORStationaryMode = 0x73D1
int GVORNakadashi = 0x73D4

string ONights = "ONights.esp"
int GVONFreqMult = 0x000D65
int GVONStopWhenFound = 0x000D64

string OBody = "OBody.esp"
int GVOBorefit = 0x001802
int GVOBNippleRand = 0x001803
int GVOBGenitalRand = 0x001804
int GVOBPrestKey = 0x001805

string OCum = "OCum.esp"
int SetOCumKey
string SUOCumKey = "ocum.key"
int GVOCRegenMod = 0x000822
int SetOCRegenMod
int GVOCDisableInflation = 0x000823
int SetOCDisableInflation
int GVOCDisableCumshot = 0x000824
int SetOCDisableCumshot
int GVOCDisableCumMesh = 0x000837
int SetOCDisableCumMesh
int GVOCDisableCumDecal = 0x000838
int SetOCDisableCumDecal


int SetOBRefit
int SetOBNippleRand
int SetOBGenitalRand
int SetOBPresetKey

int SetONStopWhenFound
int SetONFreqMult

string OCrime = "ocrime.esp"
int SetOCBounty
string SUOCBounty = "ocrime.bounty"

string OAroused = "OAroused.esp"
int SetOAKey 
string SUOAKey = "oaroused.key"
int SetOARequireLowArousalBeforeEnd
string SUOALowArousalReq = "oaroused.emptybeforeend"
int SetOAStatBuffs
string SUOAStatBuffs = "oaroused.modifystats"
int SetOANudityBroadcast
string SUOANudityBroadcast = "oaroused.EnableNudityBroadcast"

string OSearch = "OSearch.esp"
int SetOSKey
string SUOSKey = "osearch.key"
int SetOSAllowHub
string SUOSAllowHub = "osearch.allowhub"
int SetOSAllowTransitory
string SUOSAllowTransitory = "osearch.allowTransitory"
int SetOSAllowSex
string SUOSAllowSex = "osearch.allowSex"

string ovirginity = "OVirginity.esp"
int SetOVShowEffects
string SUOVShowEffects = "ovirginity.showhymen"
int SetOVVirginChance
string SUOVVirginChance = "ovirginity.virginityChance"

string OProstitution = "OProstitution.esp"
int SetOPFreq
string SUOPFreq = "oprostitution.freqmod"

Event OnInit()
	Init()
EndEvent

Function Init()
	Parent.OnGameReload()
	Main = (Self as Quest) as OsexIntegrationMain

	DomLightModeList = new String[3]
	DomLightModeList[0] = "$ostim_light_mode_none"
	DomLightModeList[1] = "$ostim_light_mode_rear"
	DomLightModeList[2] = "$ostim_light_mode_face"

	SubLightModeList = new String[3]
	SubLightModeList[0] = "$ostim_light_mode_none"
	SubLightModeList[1] = "$ostim_light_mode_rear"
	SubLightModeList[2] = "$ostim_light_mode_face"

	SubLightBrightList = new String[2]
	SubLightBrightList[0] = "$ostim_light_type_dim"
	SubLightBrightList[1] = "Bright"

	DomLightBrightList = new String[2]
	DomLightBrightList[0] = "$ostim_light_type_dim"
	DomLightBrightList[1] = "$ostim_light_type_bright"

	playerref = game.getplayer()

	string[] pagearr = PapyrusUtil.StringArray(0)
	pagearr = PapyrusUtil.PushString(pagearr, "$ostim_page_configuration")
	pagearr = PapyrusUtil.PushString(pagearr, "$ostim_page_undress")
	pagearr = PapyrusUtil.PushString(pagearr, "$ostim_page_addons")
	pagearr = PapyrusUtil.PushString(pagearr, "$ostim_page_about")

	Pages = pagearr

	Utility.Wait(2)
	ImportSettings()
EndFunction

Event OnPageReset(String Page)
	{Called when a new page is selected, including the initial empty page}
	currPage = page

	If (Page == "")
		LoadCustomContent("Ostim/logo.dds", 184, 31)
	ElseIf (Page == "$ostim_page_configuration")
		If (!Main)
			Init()
			If (!Main.EndOnDomOrgasm)
				Main.Startup()
			EndIf
			Debug.MessageBox("$ostim_message_main_not_initialized")
		EndIf

		UnloadCustomContent()
		SetInfoText(" ")
		Main.playTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetThanks = AddTextOption("$ostim_thanks", "")
		SetCursorPosition(1)
		AddTextOption("$ostim_config_text", "")
		SetCursorPosition(2)

		;=============================================================================================
		AddColoredHeader("$ostim_header_sex_scenes")
		SetActorSpeedControl = AddToggleOption("$ostim_speed_control", Main.EnableActorSpeedControl)
		SetsexExcitementMult = AddSliderOption("$ostim_excitement_mult", Main.SexExcitementMult, "{2} x")
		SetClipinglessFirstPerson = AddToggleOption("$ostim_clippingless", Main.EnableImprovedCamSupport)
		SetDisableHitbox = AddToggleOption("$ostim_disable_hitbox", Main.disableplayerhitbox)
		SetCustomTimescale = AddSliderOption("$ostim_timescale", Main.CustomTimescale, "{0}")
		SetMisallignmentOption = AddToggleOption("$ostim_misallignment", Main.MisallignmentProtection)
		SetFlipFix = AddToggleOption("$ostim_flip_fix", Main.FixFlippedAnimations)
		SetUseFades = AddToggleOption("$ostim_use_fades", Main.UseFades)
		SetEndAfterActorHit = AddToggleOption("$ostim_end_on_hit", Main.EndAfterActorHit)
		SetUseRumble = AddToggleOption("$ostim_use_rumble", Main.UseRumble)
		SetUseScreenShake = AddToggleOption("$ostim_screenshake", Main.UseScreenShake)
		SetForceFirstPerson = AddToggleOption("$ostim_force_first", Main.ForceFirstPersonAfter)
		SetScaling = AddToggleOption("$ostim_scaling", Main.DisableScaling)
		SetResetPosition = AddToggleOption("$ostim_reset_position", Main.ResetPosAfterSceneEnd) 		
		AddEmptyOption()

		AddColoredHeader("$ostim_header_player_roles")
		SetOnlyGayAnimsInGayScenes = AddToggleOption("$ostim_force_gay_anims", Main.OnlyGayAnimsInGayScenes)
		setPlayerAlwaysDomStraight = AddToggleOption("$ostim_always_dom_straight", Main.PlayerAlwaysDomStraight)
		setPlayerAlwaysSubStraight = AddToggleOption("$ostim_always_sub_straight", Main.PlayerAlwaysSubStraight)
		setPlayerAlwaysDomGay = AddToggleOption("$ostim_always_dom_gay", Main.PlayerAlwaysDomGay)
		setPlayerAlwaysSubGay = AddToggleOption("$ostim_always_sub_gay", Main.PlayerAlwaysSubGay)
		AddEmptyOption()

		AddColoredHeader("$ostim_header_orgasms")
		SetEndOnOrgasm = AddToggleOption("$ostim_orgasm_end_dom", Main.EndOnDomOrgasm)
		SetEndOnSubOrgasm = AddToggleOption("$ostim_orgasm_end_sub", Main.EndOnSubOrgasm)
		SetEndOnBothOrgasm = AddToggleOption("$ostim_orgasm_end_both", Main.RequireBothOrgasmsToFinish)
		SetSlowMoOrgasms = AddToggleOption("$ostim_slowmo_orgasm", Main.SlowMoOnOrgasm)
		SetOrgasmBoostsRel = AddToggleOption("$ostim_orgasm_boost_rel", Main.OrgasmIncreasesRelationship)
		AddEmptyOption()

		AddColoredHeader("$ostim_header_beds")
		SetEnableBeds = AddToggleOption("$ostim_use_beds", Main.UseBed)
		SetBedSearchDistance = AddSliderOption("$ostim_bed_search_rad", Main.BedSearchDistance, "{0} meters")
		SetBedReallignment = AddSliderOption("$ostim_bed_reallignment", Main.BedReallignment, "{0} units")
		SetBedAlgo = AddToggleOption("$ostim_bed_algo", Main.UseAlternateBedSearch)
		AddEmptyOption()

		AddColoredHeader("$ostim_header_excitement_bars")
		SetDomBar = AddToggleOption("$ostim_dom_bar", Main.EnableDomBar)
		SetSubBar = AddToggleOption("$ostim_sub_bar", Main.EnableSubBar)
		SetThirdBar = AddToggleOption("$ostim_third_bar", Main.EnableThirdBar)
		SetAutoHideBar = AddToggleOption("$ostim_auto_hide_bar", Main.AutoHideBars)
		SetMatchColorToGender = AddToggleOption("$ostim_match_color_gender", Main.MatchBarColorToGender)
		SetHideNPCOnNPCBars = AddToggleOption("$ostim_hide_npc_bars", Main.HideBarsInNPCScenes)
		AddEmptyOption()

		AddColoredHeader("$ostim_header_system")
		SetResetState = AddTextOption("$ostim_reset_state", "")
		SetRebuildDatabase = AddTextOption("$ostim_rebuild_database", "")
		SetUpdate = AddTextOption("$ostim_update", "")
		SetMute = AddToggleOption("$ostim_mute_osa", Main.MuteOSA)
		SetTutorialMessages = AddToggleOption("$ostim_tutorial", Main.ShowTutorials)
		;SetUseCosaveWorkaround = AddToggleOption("$ostim_cosave", Main.useBrokenCosaveWorkaround)
		AddEmptyOption()

		;=============================================================================================

		SetCursorPosition(3)
		AddColoredHeader("$ostim_header_undressing")
		SetAlwaysUndressAtStart = AddToggleOption("$ostim_undress_start", Main.AlwaysUndressAtAnimStart)
		SetUndressIfneed = AddToggleOption("$ostim_undress_need", Main.AutoUndressIfNeeded)
		SetDropClothes = AddToggleOption("$ostim_drop_clothes", Main.TossClothesOntoGround)
		;SetStrongerUnequip = AddToggleOption("$ostim_stronger_unequip", Main.UseStrongerUnequipMethod) Likely redundant 
		SetAnimateRedress= AddToggleOption("$ostim_animate_redress", Main.FullyAnimateRedress)
		;SetAlwaysAnimateUndress = AddToggleOption("$ostim_always_animate_undress", Main.AlwaysAnimateUndress) Removed in 4.0, may be reimplemented but it was bugged
		;SetonlyUndressChest = AddToggleOption("$ostim_only_chest", Main.OnlyUndressChest) REMOVED in 4.0
		AddEmptyOption()

		AddColoredHeader("$ostim_header_ai_control")
		SetAIControl = AddToggleOption("$ostim_full_auto", Main.UseAIControl)
		SetForceAIIfAttacking = AddToggleOption("$ostim_force_auto_attacking", Main.UseAIPlayerAggressor)
		SetForceAIIfAttacked = AddToggleOption("$ostim_force_auto_attacked", Main.UseAIPlayerAggressed)
		SetForceAIInConsensualScenes = AddToggleOption("$ostim_force_auto_consentual", Main.UseAINonAggressive)
		SetForceAIForMasturbation = AddToggleOption("$ostim_force_auto_masturbation", Main.UseAIMasturbation)
		SetUseAutoFades = AddToggleOption("$ostim_auto_fades", Main.UseAutoFades)
		SetAIChangeChance = AddSliderOption("$ostim_ai_change_chance", Main.AiSwitchChance, "{0}")
		AddEmptyOption()

		AddColoredHeader("$ostim_header_freecam")
		SetUseFreeCam = AddToggleOption("$ostim_freecam", Main.UseFreeCam)
		SetFreeCamFOV = AddSliderOption("$ostim_freecam_fov", Main.FreecamFOV, "{0}")
		SetDefaultFOV = AddSliderOption("$ostim_default_fov", Main.DefaultFOV, "{0}")
		SetCameraSpeed = AddSliderOption("$ostim_freecam_speed", Main.FreecamSpeed, "{0}")
		AddEmptyOption()

		AddColoredHeader("$ostim_header_keys")
		SetKeymap = AddKeyMapOption("$ostim_main_key", Main.KeyMap)
		SetKeyup = AddKeyMapOption("$ostim_speed_up_key", Main.SpeedUpKey)
		SetKeydown = AddKeyMapOption("$ostim_speed_down_key", Main.SpeedDownKey)
		SetPullOut = AddKeyMapOption("$ostim_pullout_key", Main.PullOutKey)
		SetControlToggle = AddKeyMapOption("$ostim_control_toggle_key", Main.ControlToggleKey)
		SetFreecamToggleKey = AddKeyMapOption("$ostim_tfc_key", Main.FreecamKey)
		AddEmptyOption()

		AddColoredHeader("$ostim_header_lights")
		SetDomLightMode = AddMenuOption("$ostim_dom_light_mode", DomLightModeList[Main.DomLightPos])
		SetSubLightMode = AddMenuOption("$ostim_sub_light_mode", SubLightModeList[Main.SubLightPos])
		SetDomLightBrightness = AddMenuOption("$ostim_dom_light_brightness", DomLightBrightList[Main.DomLightBrightness])
		SetSubLightBrightness = AddMenuOption("$ostim_sub_light_brightness", SubLightBrightList[Main.SubLightBrightness])
		SetOnlyLightInDark = AddToggleOption("$ostim_dark_light", Main.LowLightLevelLightsOnly)
		AddEmptyOption()

		AddColoredHeader("$ostim_header_save_load")
		ExportSettings = AddTextOption("$ostim_export", "$ostim_done")
		ImportSettings = AddTextOption("$ostim_import", "$ostim_done")
		ImportDefaultSettings = AddTextOption("$ostim_import_default", "$ostim_done")
		AddEmptyOption()
	ElseIf (Page == "$ostim_page_addons")
		SetInfoText(" ")
		Main.playTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		UnloadCustomContent()
		SetThanks = AddTextOption("", "")
		SetCursorPosition(1)
		AddTextOption("$ostim_addon_settings_text", "")
		SetCursorPosition(2)

		if main.IsModLoaded(ORomance)
			AddColoredHeader("ORomance")
			SetORSexuality = AddToggleOption("$ostim_addon_or_npc_sexualities", GetExternalBool(ORomance, GVORSexuality))
			SetORDifficulty = AddSliderOption("$ostim_addon_or_difficulty", GetExternalInt(ORomance, GVORDifficulty), "{0}")
			SetORKey = AddKeyMapOption("$ostim_addon_or_mainkey", GetExternalInt(oromance, gvorkey))
			SetORColorblind = AddToggleOption("$ostim_addon_or_colorblind", GetExternalBool(ORomance, GVORColorblind))
			;SetORStationary = AddToggleOption("$ostim_addon_or_stationary", GetExternalBool(ORomance, GVORStationaryMode))
			SetORLeft = AddKeyMapOption("$ostim_addon_or_left_key", GetExternalInt(oromance, GVORLeft))
			SetORRight = AddKeyMapOption("$ostim_addon_or_right_key", GetExternalInt(oromance, GVORRight))
			SetORNakadashi = AddToggleOption("$ostim_addon_or_nakadashi", GetExternalBool(ORomance, GVORNakadashi))
		endif 

		if main.IsModLoaded(ONights)
			AddColoredHeader("ONights")
			SetONStopWhenFound = AddToggleOption("$ostim_addon_on_stop", GetExternalBool(ONights, GVONStopWhenFound))
			SetONFreqMult = AddSliderOption("$ostim_addon_on_freq_mult", GetExternalFloat(ONights, GVONFreqMult), "{2} x")
			
		endif 

		if main.IsModLoaded(OSearch)
			AddColoredHeader("OSearch")
			SetOSKey = AddKeyMapOption("$ostim_addon_os_key", StorageUtil.GetIntValue(none, SUOSKey))
			SetOSAllowSex = AddToggleOption("$ostim_addon_os_sex", StorageUtil.GetIntValue(none, SUOSAllowSex))
			SetOSAllowHub = AddToggleOption("$ostim_addon_os_hub", StorageUtil.GetIntValue(none, SUOSAllowHub))
			SetOSAllowTransitory = AddToggleOption("$ostim_addon_os_transitory", StorageUtil.GetIntValue(none, SUOSAllowTransitory))
		endif 

		if main.IsModLoaded(ovirginity)
			AddColoredHeader("OVirginity")
			SetOVShowEffects = AddToggleOption("$ostim_addon_ov_fx", StorageUtil.GetIntValue(none, SUOVShowEffects))
			SetOVVirginChance = AddSliderOption("$ostim_addon_ov_chance", StorageUtil.GetIntValue(none, SUOVVirginChance), "{0} %")
		endif 

		if main.IsModLoaded(OProstitution)
			AddColoredHeader("OProstitution")

			SetOPFreq = AddSliderOption("$ostim_addon_op_freq", StorageUtil.GetIntValue(none, SUOPFreq), "{0}")
		endif 

		;===================================

		SetCursorPosition(3)

		if main.IsModLoaded(OBody)
			AddColoredHeader("OBody")
			SetOBRefit = AddToggleOption("$ostim_addon_ob_refit", GetExternalBool(OBody, GVOBorefit))
			SetOBNippleRand = AddToggleOption("$ostim_addon_ob_nipples", GetExternalBool(OBody, GVOBNippleRand))
			SetOBGenitalRand = AddToggleOption("$ostim_addon_ob_genitals", GetExternalBool(OBody, GVOBGenitalRand))
			SetOBPresetKey = AddKeyMapOption("$ostim_addon_ob_preset_key", GetExternalInt(OBody, GVOBPrestKey))
			
		endif 

		if main.IsModLoaded(OCrime)
			AddColoredHeader("OCrime")
			SetOCBounty = AddSliderOption("$ostim_addon_oc_bounty", StorageUtil.GetIntValue(none, suocbounty), "{0} Gold")
		endif 

		if main.IsModLoaded(OAroused)
			AddColoredHeader("OAroused")
			SetOAKey = AddKeyMapOption("$ostim_addon_oa_key", StorageUtil.GetIntValue(none, SUOAKey))
			SetOARequireLowArousalBeforeEnd = AddToggleOption("$ostim_addon_oa_low_arousal_end", StorageUtil.GetIntValue(none, SUOALowArousalReq))
			SetOAStatBuffs = AddToggleOption("$ostim_addon_oa_stat_buffs", StorageUtil.GetIntValue(none, SUOAStatBuffs))
			SetOANudityBroadcast = AddToggleOption("$ostim_addon_oa_nudity_bc", StorageUtil.GetIntValue(none, SUOANudityBroadcast))

		endif 

		if main.IsModLoaded(OCum)
			AddColoredHeader("OCum")
			SetOCumKey = AddKeyMapOption("$ostim_addon_ocum_key", StorageUtil.GetIntValue(none, SUOCumKey, 157))
			SetOCRegenMod = AddSliderOption("$ostim_addon_ocum_RegenMod", GetExternalFloat(ocum, GVOCRegenMod), "{1}")
			SetOCDisableInflation = AddToggleOption("$ostim_addon_ocum_DisableInflation", GetExternalBool(ocum, GVOCDisableInflation))
			SetOCDisableCumshot = AddToggleOption("$ostim_addon_ocum_DisableCumshot", GetExternalBool(ocum, GVOCDisableCumshot))
			SetOCDisableCumMesh = AddToggleOption("$ostim_addon_ocum_DisableCumMesh", GetExternalBool(ocum, GVOCDisableCumMesh))
			SetOCDisableCumDecal = AddToggleOption("$ostim_addon_ocum_DisableCumDecal", GetExternalBool(ocum, GVOCDisableCumDecal))
		endIf

	ElseIf (Page == "$ostim_page_undress")
		LoadCustomContent("Ostim/logo.dds", 184, 31)
		Main.PlayTickBig()
		UnloadCustomContent()
		SetInfoText(" ")
		Main.playTickBig()
		SetCursorFillMode(LEFT_TO_RIGHT)
		SetUndressingAbout = AddTextOption("$ostim_undress_about", "")
		SetCursorPosition(1)
		AddTextOption("$ostim_undress_text{OStim}", "")
		SetCursorPosition(2)
		AddColoredHeader("$ostim_undress_slots_header")
		AddColoredHeader("")

		DrawSlotPage()
	ElseIf (Page == "$ostim_page_about")
		UnloadCustomContent()
		SetInfoText(" ")
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)

		AddTextOption("OStim ", "-")
		
		AddTextOption("", "")
		AddColoredHeader("$ostim_authors")
		AddTextOption("OStim ", "$ostim_by{Sairion}")
		AddTextOption("OSA + OSex", "$ostim_by{CE0}")

		SetCursorPosition(1)
		AddTextOption("OSex Overhaul & API", "")

		AddTextOption("", "")
		AddColoredHeader("$ostim_links")
		AddTextOption("patreon.com/ostim", "")
		AddTextOption("discord.gg/RECvhVaRcU", "")

		Main.PlayDing()
	EndIf
EndEvent

bool Function GetExternalBool(string modesp, int id)
	;osexintegrationmain.console((game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt())

	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() == 1

endfunction

Function SetExternalBool(string modesp, int id, bool val)
	int set = 0
	if val
		set = 1
	endif 

	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(set)
endfunction

Function SetExternalInt(string modesp, int id, int val)
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(val)
endfunction
int Function GetExternalInt(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() 
endfunction

Function SetExternalfloat(string modesp, int id, float val)
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValue(val)
endfunction
float Function GetExternalfloat(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValue() 
endfunction

Event OnOptionSelect(Int Option)
	Main.PlayTickBig()
	if currPage == "$ostim_page_undress"
		OnSlotSelect(option)
	elseif currPage == "$ostim_page_addons"
		if option == SetORSexuality
			SetExternalBool(oromance, GVORSexuality, !GetExternalBool(oromance, GVORSexuality))
			SetToggleOptionValue(SetORSexuality, GetExternalBool(oromance, GVORSexuality))
		elseif option == SetORColorblind
			SetExternalBool(oromance, GVORColorblind, !GetExternalBool(oromance, GVORColorblind))
			SetToggleOptionValue(SetORColorblind, GetExternalBool(oromance, GVORColorblind))
		elseif option == SetORNakadashi
			SetExternalBool(oromance, GVORNakadashi, !GetExternalBool(oromance, GVORNakadashi))
			SetToggleOptionValue(SetORNakadashi, GetExternalBool(oromance, GVORNakadashi))
		elseif option == SetORStationary
			SetExternalBool(oromance, GVORStationaryMode, !GetExternalBool(oromance, GVORStationaryMode))
			SetToggleOptionValue(SetORStationary, GetExternalBool(oromance, GVORStationaryMode))
		elseif option == SetONStopWhenFound
			SetExternalBool(ONights, GVONStopWhenFound, !GetExternalBool(ONights, GVONStopWhenFound))
			SetToggleOptionValue(SetONStopWhenFound, GetExternalBool(ONights, GVONStopWhenFound))
		elseif option == SetOBRefit
			SetExternalBool(OBody, GVOBorefit, !GetExternalBool(OBody, GVOBorefit))
			SetToggleOptionValue(SetOBRefit, GetExternalBool(OBody, GVOBorefit))
		elseif option == SetOBNippleRand
			SetExternalBool(OBody, GVOBNippleRand, !GetExternalBool(OBody, GVOBNippleRand))
			SetToggleOptionValue(SetOBNippleRand, GetExternalBool(OBody, GVOBNippleRand))
		elseif option == SetOBGenitalRand
			SetExternalBool(OBody, GVOBGenitalRand, !GetExternalBool(OBody, GVOBGenitalRand))
			SetToggleOptionValue(SetOBGenitalRand, GetExternalBool(OBody, GVOBGenitalRand))
		elseif option == SetOSAllowSex
			StorageUtil.SetIntValue(none, SUOSAllowSex, (!(StorageUtil.GetIntValue(none, SUOSAllowSex) as bool)) as int)
			SetToggleOptionValue(SetOSAllowSex, StorageUtil.GetIntValue(none, SUOSAllowSex))
		elseif option == SetOSAllowTransitory
			StorageUtil.SetIntValue(none, SUOSAllowTransitory, (!(StorageUtil.GetIntValue(none, SUOSAllowTransitory) as bool)) as int)
			SetToggleOptionValue(SetOSAllowTransitory, StorageUtil.GetIntValue(none, SUOSAllowTransitory))
		elseif option == SetOARequireLowArousalBeforeEnd
			StorageUtil.SetIntValue(none, SUOALowArousalReq, (!(StorageUtil.GetIntValue(none, SUOALowArousalReq) as bool)) as int)
			SetToggleOptionValue(SetOARequireLowArousalBeforeEnd, StorageUtil.GetIntValue(none, SUOALowArousalReq))
		elseif option == SetOSAllowHub
			StorageUtil.SetIntValue(none, SUOSAllowHub, (!(StorageUtil.GetIntValue(none, SUOSAllowHub) as bool)) as int)
			SetToggleOptionValue(SetOSAllowHub, StorageUtil.GetIntValue(none, SUOSAllowHub))
		elseif option == SetOVShowEffects
			StorageUtil.SetIntValue(none, SUOVShowEffects, (!(StorageUtil.GetIntValue(none, SUOVShowEffects) as bool)) as int)
			SetToggleOptionValue(SetOVShowEffects, StorageUtil.GetIntValue(none, SUOVShowEffects))
		elseif option == SetOAStatBuffs
			StorageUtil.SetIntValue(none, SUOAStatBuffs, (!(StorageUtil.GetIntValue(none, SUOAStatBuffs) as bool)) as int)
			SetToggleOptionValue(SetOAStatBuffs, StorageUtil.GetIntValue(none, SUOAStatBuffs))
		elseif option == SetOANudityBroadcast
			StorageUtil.SetIntValue(none, SUOANudityBroadcast, (!(StorageUtil.GetIntValue(none, SUOANudityBroadcast) as bool)) as int)
			SetToggleOptionValue(SetOANudityBroadcast, StorageUtil.GetIntValue(none, SUOANudityBroadcast))
		elseif option == SetOCDisableInflation
			SetExternalBool(ocum, GVOCDisableInflation, !GetExternalBool(ocum, GVOCDisableInflation))
			SetToggleOptionValue(SetOCDisableInflation, GetExternalBool(ocum, GVOCDisableInflation))
		elseif option == SetOCDisableCumshot
			SetExternalBool(ocum, GVOCDisableCumshot, !GetExternalBool(ocum, GVOCDisableCumshot))
			SetToggleOptionValue(SetOCDisableCumshot, GetExternalBool(ocum, GVOCDisableCumshot))
		elseif option == SetOCDisableCumMesh
			SetExternalBool(ocum, GVOCDisableCumMesh, !GetExternalBool(ocum, GVOCDisableCumMesh))
			SetToggleOptionValue(SetOCDisableCumMesh, GetExternalBool(ocum, GVOCDisableCumMesh))
		elseif option == SetOCDisableCumDecal
			SetExternalBool(ocum, GVOCDisableCumDecal, !GetExternalBool(ocum, GVOCDisableCumDecal))
			SetToggleOptionValue(SetOCDisableCumDecal, GetExternalBool(ocum, GVOCDisableCumDecal))
		endif
		return
	EndIf

	If (Option == SetEndOnOrgasm)
		Main.EndOnDomOrgasm = !Main.EndOnDomOrgasm
		SetToggleOptionValue(SetEndOnOrgasm, Main.EndOnDomOrgasm)
	ElseIf (Option == SetEndOnSubOrgasm)
		Main.EndOnSubOrgasm = !Main.EndOnSubOrgasm
		SetToggleOptionValue(SetEndOnSubOrgasm, Main.EndOnSubOrgasm)
	ElseIf (Option == SetDisableHitbox)
		Main.DisablePlayerHitbox = !Main.DisablePlayerHitbox
		SetToggleOptionValue(SetDisableHitbox, Main.DisablePlayerHitbox)
	ElseIf (Option == SetEndOnBothOrgasm)
		Main.RequireBothOrgasmsToFinish = !Main.RequireBothOrgasmsToFinish
		SetToggleOptionValue(SetEndOnBothOrgasm, Main.RequireBothOrgasmsToFinish)
	ElseIf (Option == SetResetState)
		Main.ResetState()
		ShowMessage("$ostim_message_reset_state", false)
	ElseIf (Option == SetUpdate)
		ShowMessage("$ostim_message_update_close_menus", false)
		OUtils.ForceOUpdate()
	ElseIf (Option == SetRebuildDatabase)
		ShowMessage("$ostim_message_rebuild_database", false)
		Main.GetODatabase().InitDatabase()
	ElseIf (Option == SetActorSpeedControl)
		Main.EnableActorSpeedControl = !Main.EnableActorSpeedControl
		SetToggleOptionValue(Option, Main.EnableActorSpeedControl)
	ElseIf (Option == SetResetPosition)
		Main.ResetPosAfterSceneEnd = !Main.ResetPosAfterSceneEnd
		SetToggleOptionValue(Option, Main.ResetPosAfterSceneEnd)
	ElseIf (Option == SetEnableBeds)
		Main.UseBed = !Main.UseBed
		SetToggleOptionValue(Option, Main.UseBed)
	ElseIf (Option == SetTutorialMessages)
		Main.ShowTutorials = !Main.ShowTutorials
		SetToggleOptionValue(Option, Main.ShowTutorials)
	ElseIf (Option == SetScaling)
		Main.DisableScaling = !Main.DisableScaling
		SetToggleOptionValue(Option, Main.DisableScaling)
	ElseIf (Option == SetUseRumble)
		Main.UseRumble = !Main.UseRumble
		SetToggleOptionValue(Option, Main.UseRumble)
	ElseIf (Option == SetStrongerUnequip)
		Main.UseStrongerUnequipMethod = !Main.UseStrongerUnequipMethod
		SetToggleOptionValue(Option, Main.UseStrongerUnequipMethod)
	ElseIf (Option == SetFlipFix)
		Main.FixFlippedAnimations = !Main.FixFlippedAnimations
		SetToggleOptionValue(Option, Main.FixFlippedAnimations)
	ElseIf (Option == SetUseScreenShake)
		Main.UseScreenShake = !Main.UseScreenShake
		SetToggleOptionValue(Option, Main.UseScreenShake)
	ElseIf (Option == SetForceAIInConsensualScenes)
		Main.UseAINonAggressive = !Main.UseAINonAggressive
		SetToggleOptionValue(Option, Main.UseAINonAggressive)
	ElseIf (Option == SetForceAIForMasturbation)
		Main.UseAIMasturbation = !Main.UseAIMasturbation
		SetToggleOptionValue(Option, Main.UseAIMasturbation)
	ElseIf (Option == SetDropClothes)
		Main.TossClothesOntoGround = !Main.TossClothesOntoGround
		SetToggleOptionValue(Option, Main.TossClothesOntoGround)
	ElseIf (Option == SetForceAIIfAttacked)
		Main.UseAIPlayerAggressed = !Main.UseAIPlayerAggressed
		SetToggleOptionValue(Option, Main.UseAIPlayerAggressed)
	ElseIf (Option == SetForceFirstPerson)
		Main.ForceFirstPersonAfter = !Main.ForceFirstPersonAfter
		SetToggleOptionValue(Option, Main.ForceFirstPersonAfter)
	ElseIf (Option == SetUseAutoFades)
		Main.UseAutoFades = !Main.UseAutoFades
		SetToggleOptionValue(Option, Main.UseAutoFades)
	ElseIf (Option == SetMatchColorToGender)
		Main.MatchBarColorToGender = !Main.MatchBarColorToGender
		SetToggleOptionValue(Option, Main.MatchBarColorToGender)
	ElseIf (Option == SetHideNPCOnNPCBars)
		Main.HideBarsInNPCScenes = !Main.HideBarsInNPCScenes
		SetToggleOptionValue(Option, Main.HideBarsInNPCScenes)
	ElseIf (Option == SetMute)
		Main.MuteOSA = !Main.MuteOSA
		SetToggleOptionValue(Option, Main.MuteOSA)
	ElseIf (Option == SetEndAfterActorHit)
		Main.EndAfterActorHit = !Main.EndAfterActorHit
		SetToggleOptionValue(Option, Main.EndAfterActorHit)
	ElseIf (Option == SetUseFreeCam)
		Main.UseFreeCam = !Main.UseFreeCam
		SetToggleOptionValue(Option, Main.UseFreeCam)
	ElseIf (Option == SetUseCosaveWorkaround)
		Main.UseBrokenCosaveWorkaround = !Main.UseBrokenCosaveWorkaround
		SetToggleOptionValue(Option, Main.UseBrokenCosaveWorkaround)
	ElseIf (Option == SetForceAIIfAttacking)
		Main.UseAIPlayerAggressor = !Main.UseAIPlayerAggressor
		SetToggleOptionValue(Option, Main.UseAIPlayerAggressor)
	ElseIf (Option == SetUndressIfneed)
		Main.AutoUndressIfNeeded = !Main.AutoUndressIfNeeded
		SetToggleOptionValue(Option, Main.AutoUndressIfNeeded)
	ElseIf (Option == SetBedAlgo)
		Main.UseAlternateBedSearch = !Main.UseAlternateBedSearch
		SetToggleOptionValue(Option, Main.UseAlternateBedSearch)
	ElseIf (Option == SetClipinglessFirstPerson)
		Main.EnableImprovedCamSupport = !Main.EnableImprovedCamSupport
		SetToggleOptionValue(Option, Main.EnableImprovedCamSupport)
	ElseIf (Option == SetAlwaysUndressAtStart)
		Main.AlwaysUndressAtAnimStart = !Main.AlwaysUndressAtAnimStart
		SetToggleOptionValue(Option, Main.AlwaysUndressAtAnimStart)
	ElseIf (Option == SetAIControl)
		Main.UseAIControl = !Main.UseAIControl
		SetToggleOptionValue(Option, Main.UseAIControl)
	ElseIf (Option == SetAlwaysAnimateUndress)
		Main.AlwaysAnimateUndress = !Main.AlwaysAnimateUndress
		SetToggleOptionValue(Option, Main.AlwaysAnimateUndress)
	;ElseIf (Option == SetonlyUndressChest)
	;	Main.OnlyUndressChest = !Main.OnlyUndressChest
	;	SetToggleOptionValue(Option, Main.OnlyUndressChest)
	ElseIf (Option == SetDomBar)
		Main.EnableDomBar = !Main.EnableDomBar
		SetToggleOptionValue(Option, Main.EnableDomBar)
	ElseIf (Option == SetThirdBar)
		Main.EnableThirdBar = !Main.EnableThirdBar
		SetToggleOptionValue(Option, Main.EnableThirdBar)
	ElseIf (Option == SetAnimateRedress)
		Main.FullyAnimateRedress = !Main.FullyAnimateRedress
		SetToggleOptionValue(Option, Main.FullyAnimateRedress)
	ElseIf (Option == SetMisallignmentOption)
		Main.MisallignmentProtection = !Main.MisallignmentProtection
		SetToggleOptionValue(Option, Main.MisallignmentProtection)
	ElseIf (Option == SetSubBar)
		Main.EnableSubBar = !Main.EnableSubBar
		SetToggleOptionValue(Option, Main.EnableSubBar)
	ElseIf (Option == SetAutoHideBar)
		Main.AutoHideBars = !Main.AutoHideBars
		SetToggleOptionValue(Option, Main.AutoHideBars)
	ElseIf (Option == SetSlowMoOrgasms)
		Main.SlowMoOnOrgasm = !Main.SlowMoOnOrgasm
		SetToggleOptionValue(Option, Main.SlowMoOnOrgasm)
	ElseIf (Option == SetOrgasmBoostsRel)
		Main.OrgasmIncreasesRelationship = !Main.OrgasmIncreasesRelationship
		SetToggleOptionValue(Option, Main.OrgasmIncreasesRelationship)
	ElseIf (Option == SetUseFades)
		Main.UseFades = !Main.UseFades
		SetToggleOptionValue(Option, Main.UseFades)
	ElseIf (Option == SetOnlyLightInDark)
		Main.LowLightLevelLightsOnly = !Main.LowLightLevelLightsOnly
		SetToggleOptionValue(Option, Main.LowLightLevelLightsOnly)
	ElseIf (Option == SetPlayerAlwaysSubStraight)
		Main.PlayerAlwaysSubStraight = !Main.PlayerAlwaysSubStraight
		SetToggleOptionValue(Option, Main.PlayerAlwaysSubStraight)
	ElseIf (Option == SetPlayerAlwaysSubGay)
		Main.PlayerAlwaysSubGay = !Main.PlayerAlwaysSubGay
		SetToggleOptionValue(Option, Main.PlayerAlwaysSubGay)
	ElseIf (Option == SetPlayerAlwaysDomStraight)
		Main.PlayerAlwaysDomStraight = !Main.PlayerAlwaysDomStraight
		SetToggleOptionValue(Option, Main.PlayerAlwaysDomStraight)
	ElseIf (Option == SetPlayerAlwaysDomGay)
		Main.PlayerAlwaysDomGay = !Main.PlayerAlwaysDomGay
		SetToggleOptionValue(Option, Main.PlayerAlwaysDomGay)
	ElseIf (Option == SetOnlyGayAnimsInGayScenes)
		Main.OnlyGayAnimsInGayScenes = !Main.OnlyGayAnimsInGayScenes
		SetToggleOptionValue(Option, Main.OnlyGayAnimsInGayScenes)
	ElseIf (Option == ExportSettings)
		If ShowMessage("$ostim_message_export_confirm", true)
			ExportSettings()
		EndIf
	ElseIf (Option == ImportSettings)
		If ShowMessage("$ostim_message_import_confirm")
			ImportSettings()
		EndIf
	ElseIf (Option == ImportDefaultSettings)
		If ShowMessage("$ostim_message_import_confirm")
			ImportSettings(true)
		EndIf
	EndIf
EndEvent

Event OnOptionHighlight(Int Option)
	;Main.playTickSmall()
	if currPage == "$ostim_page_undress"
		OnSlotMouseOver(option)
	elseif currPage == "$ostim_page_addons"
		If (Option == SetORKey)
			SetInfoText("$ostim_tooltip_or_mainkey")
		elseif (option == SetORDifficulty)
			SetInfoText("$ostim_tooltip_or_difficulty")
		elseif (option == SetOAKey)
			SetInfoText("$ostim_tooltip_oa_key")
		elseif (option == SetOSKey)
			SetInfoText("$ostim_tooltip_os_key")
		elseif (option == SetOBPresetKey)
			SetInfoText("$ostim_tooltip_ob_preset_key")
		elseif (option == SetORSexuality)
			SetInfoText("$ostim_tooltip_or_sexuality")
		elseif (option == SetORColorblind)
			SetInfoText("$ostim_tooltip_or_colorblind")
		elseif (option == SetORLeft)
			SetInfoText("$ostim_tooltip_or_left_key")
		elseif (option == SetORRight)
			SetInfoText("$ostim_tooltip_or_right_key")
		elseif (option == SetORNakadashi)
			SetInfoText("$ostim_tooltip_or_nakadashi")
		ElseIf (Option == SetONFreqMult)
			SetInfoText("$ostim_tooltip_on_freq_mult")
		ElseIf (Option == SetOCBounty)
			SetInfoText("$ostim_tooltip_oc_bounty")
		ElseIf (Option == SetOVVirginChance)
			SetInfoText("$ostim_tooltip_ov_chance")
		ElseIf (Option == SetOPFreq)
			SetInfoText("$ostim_tooltip_op_freq")
		Elseif (Option == SetONStopWhenFound)
			SetInfoText("$ostim_tooltip_on_stop")
		Elseif (Option == SetOBRefit)
			SetInfoText("$ostim_tooltip_ob_refit")
		Elseif (Option == SetOBNippleRand)
			SetInfoText("$ostim_tooltip_ob_nipple")
		Elseif (Option == SetOBGenitalRand)
			SetInfoText("$ostim_tooltip_ob_genitals")
		Elseif (Option == SetOARequireLowArousalBeforeEnd)
			SetInfoText("$ostim_tooltip_oa_low_arousal_end")
		Elseif (Option == SetOSAllowHub)
			SetInfoText("$ostim_tooltip_os_hub")
		Elseif (Option == SetOVShowEffects)
			SetInfoText("$ostim_tooltip_ov_fx")
		Elseif (Option == SetOSAllowTransitory)
			SetInfoText("$ostim_tooltip_os_transitory")
		Elseif (Option == SetOSAllowSex)
			SetInfoText("$ostim_tooltip_os_transitory")
		Elseif (Option == SetOANudityBroadcast)
			SetInfoText("$ostim_tooltip_oa_nudity_bc")
		Elseif (Option == SetOAStatBuffs)
			SetInfoText("$ostim_tooltip_oa_stat_buffs")
		ElseIf (Option == SetOCumKey)
			SetInfoText("$ostim_tooltip_ocum_key")
		ElseIf (Option == SetOCRegenMod)
			SetInfoText("$ostim_tooltip_OCRegenMod")
		ElseIf (Option == SetOCDisableInflation)
			SetInfoText("$ostim_tooltip_OCDisableInflation")
		ElseIf (Option == SetOCDisableCumshot)
			SetInfoText("$ostim_tooltip_OCDisableCumshot")
		ElseIf (Option == SetOCDisableCumMesh)
			SetInfoText("$ostim_tooltip_OCDisableCumMesh")
		ElseIf (Option == SetOCDisableCumDecal)
			SetInfoText("$ostim_tooltip_OCDisableCumDecal")
		endif 

		return
	EndIf
	If (Option == SetEndOnOrgasm)
		SetInfoText("$ostim_tooltip_orgasm_end_dom")
	ElseIf (Option == SetEndOnSubOrgasm)
		SetInfoText("$ostim_tooltip_orgasm_end_sub")
	ElseIf (Option == SetEndOnBothOrgasm)
		SetInfoText("$ostim_tooltip_orgasm_end_both")
	ElseIf (Option == SetResetState)
		SetInfoText("$ostim_tooltip_reset")
	ElseIf (Option == SetUndressingAbout)
		SetInfoText("$ostim_tooltip_undressing_about")
	ElseIf (Option == SetForceAIIfAttacked)
		SetInfoText("$ostim_tooltip_ai_attacked")
	ElseIf (Option == SetForceAIIfAttacking)
		SetInfoText("$ostim_tooltip_ai_attacking")
	ElseIf (Option == SetForceAIInConsensualScenes)
		SetInfoText("$ostim_tooltip_ai_consent")
	ElseIf (Option == SetForceAIForMasturbation)
		SetInfoText("$ostim_tooltip_ai_masturbation")
	ElseIf (Option == SetUseFades)
		SetInfoText("$ostim_tooltip_fades")
	ElseIf (Option == SetScaling)
		SetInfoText("$ostim_tooltip_scaling")
	ElseIf (Option == SetUseCosaveWorkaround)
		SetInfoText("$ostim_tooltip_cosave")
	ElseIf (Option == SetFreeCamFOV)
		SetInfoText("$ostim_tooltip_fov")
	ElseIf (Option == SetUseRumble)
		SetInfoText("$ostim_tooltip_rumble")
	ElseIf (Option == SetMatchColorToGender)
		SetInfoText("$ostim_tooltip_gendered_colors")
	ElseIf (Option == SetDisableHitbox)
		SetInfoText("$ostim_tooltip_no_hitbox")
	ElseIf (Option == SetHideNPCOnNPCBars)
		SetInfoText("$ostim_tooltip_npc_bars")
	ElseIf (Option == SetStrongerUnequip)
		SetInfoText("$ostim_tooltip_stronger_unequip")
	ElseIf (Option == SetEndAfterActorHit)
		SetInfoText("$ostim_tooltip_end_on_hit")
	ElseIf (Option == SetAnimateRedress)
		SetInfoText("$ostim_tooltip_animate_redress")
	ElseIf (Option == SetForceFirstPerson)
		SetInfoText("$ostim_tooltip_force_first")
	ElseIf (Option == SetCustomTimescale)
		SetInfoText("$ostim_tooltip_custom_timescale")
	ElseIf (Option == SetClipinglessFirstPerson)
		 SetInfoText("$ostim_tooltip_clippingless")
	ElseIf (Option == SetActorSpeedControl)
		SetInfoText("$ostim_tooltip_speed_control")
	ElseIf (Option == SetResetPosition)
		SetInfoText("$ostim_tooltip_reset_position")
	ElseIf (Option == SetUndressIfNeed)
		SetInfoText("$ostim_tooltip_undress_if_need")
	ElseIf (Option == SetBedSearchDistance)
		SetInfoText("$ostim_tooltip_bed_search_dist")
	ElseIf (Option == SetBedAlgo)
		SetInfoText("$ostim_tooltip_bed_algo")
	ElseIf (Option == SetUseAutoFades)
		SetInfoText("$ostim_tooltip_auto_fades")
	ElseIf (Option == SetAIChangeChance)
		SetInfoText("$ostim_tooltip_ai_change_chance")
	ElseIf (Option == SetFlipFix)
		SetInfoText("$ostim_tooltip_flip_fix")
	ElseIf (Option == SetDropClothes)
		SetInfoText("$ostim_tooltip_drop_clothes")
	ElseIf (Option == SetAlwaysUndressAtStart)
		SetInfoText("$ostim_tooltip_always_undress")
	ElseIf (Option == SetAlwaysAnimateUndress)
		SetInfoText("$ostim_tooltip_always_animate_undress")
	ElseIf (Option == SetonlyUndressChest)
		SetInfoText("$ostim_tooltip_only_chest")
	ElseIf (Option == SetDomBar)
		SetInfoText("$ostim_tooltip_dom_bar")
	ElseIf (Option == SetthirdBar)
		SetInfoText("$ostim_tooltip_third_bar")
	ElseIf (Option == SetSubBar)
		SetInfoText("$ostim_tooltip_sub_bar")
	ElseIf (Option == SetMisallignmentOption)
		SetInfoText("$ostim_tooltip_misalignment")
	ElseIf (Option == SetEnableBeds)
		SetInfoText("$ostim_tooltip_enable_beds")
	ElseIf (Option == SetTutorialMessages)
		SetInfoText("$ostim_tooltip_enable_tutorial")
	ElseIf (Option == setupdate)
		SetInfoText("$ostim_tooltip_update")
	ElseIf (Option == SetAIControl)
		SetInfoText("$ostim_tooltip_enable_ai")
	ElseIf (Option == SetAutoHideBar)
		SetInfoText("$ostim_tooltip_auto_hide_bar")
	ElseIf (Option == SetSlowMoOrgasms)
		SetInfoText("$ostim_tooltip_slowmo_orgasms")
	ElseIf (Option == SetOrgasmBoostsRel)
		SetInfoText("$ostim_tooltip_orgasm_boosts_rel")
	ElseIf (Option == SetDomLightMode)
		SetInfoText("$ostim_tooltip_dom_light")
	ElseIf (Option == SetMute)
		SetInfoText("$ostim_tooltip_mute_osa")
	ElseIf (Option == SetSubLightMode)
		SetInfoText("$ostim_tooltip_sub_light")
	ElseIf (Option == SetCameraSpeed)
		SetInfoText("$ostim_tooltip_fc_speed")
	ElseIf (Option == SetUseFreeCam)
		SetInfoText("$ostim_tooltip_auto_fc")
	ElseIf (Option == SetDefaultFOV)
		SetInfoText("$ostim_tooltip_fc_fov")
	ElseIf (Option == SetDomLightBrightness)
		SetInfoText("$ostim_tooltip_dom_brightness")
	ElseIf (Option == SetSubLightBrightness)
		SetInfoText("$ostim_tooltip_sub_brightness")
	ElseIf (Option == SetFreecamToggleKey)
		SetInfoText("$ostim_tooltip_tfc_key")
	ElseIf (Option == SetControlToggle)
		SetInfoText("$ostim_tooltip_control_toggle_key")
	ElseIf (Option == SetOnlyLightInDark)
		SetInfoText("$ostim_tooltip_dark_light")
	ElseIf (Option == SetRebuildDatabase)
		SetInfoText("$ostim_tooltip_rebuild_database")
	ElseIf (Option == SetsexExcitementMult)
		SetInfoText("$ostim_tooltip_excitement_mult")
	ElseIf (Option == SetKeymap)
		SetInfoText("$ostim_tooltip_main_key")
	ElseIf (Option == SetKeyUp)
		SetInfoText("$ostim_tooltip_speed_up_key")
	ElseIf (Option == SetKeyDown)
		SetInfoText("$ostim_tooltip_speed_down_key")
	ElseIf (Option == SetUseScreenShake)
		SetInfoText("$ostim_tooltip_screen_shake")
	ElseIf (Option == SetBedReallignment)
		SetInfoText("$ostim_tooltip_bed_reallignment")
	ElseIf (Option == SetPullOut)
		SetInfoText("$ostim_tooltip_pullout_key")
	ElseIf (Option == SetThanks)
		SetInfoText("$ostim_tooltip_thanks")
	ElseIf (Option == SetPlayerAlwaysSubStraight)
		SetInfoText("$ostim_tooltip_always_sub_straight")
	ElseIf (Option == SetPlayerAlwaysSubGay)
		SetInfoText("$ostim_tooltip_always_sub_gay")
	ElseIf (Option == SetPlayerAlwaysDomStraight)
		SetInfoText("$ostim_tooltip_always_dom_straight")
	ElseIf (Option == SetPlayerAlwaysDomGay)
		SetInfoText("$ostim_tooltip_always_dom_gay")
	ElseIf (Option == SetOnlyGayAnimsInGayScenes)
		SetInfoText("$ostim_tooltip_force_gay_anims")
	ElseIf (Option == ExportSettings)
		SetInfoText("$ostim_tooltip_export")
	ElseIf (Option == ImportSettings)
		SetInfoText("$ostim_tooltip_import")
	ElseIf (Option == ImportDefaultSettings)
		SetInfoText("$ostim_tooltip_import_default")
	EndIf
EndEvent

Event OnOptionMenuOpen(Int Option)
	Main.PlayTickBig()
	If (Option == SetDomLightmode)
		SetMenuDialogOptions(DomLightModeList)
		;SetMenuDialogStartIndex(DifficultyIndex)
		;SetMenuDialogDefaultIndex(1)
	ElseIf (Option == SetSubLightMode)
		SetMenuDialogOptions(SubLightModeList)
	ElseIf (Option == SetDomLightBrightness)
		SetMenuDialogOptions(DomLightBrightList)
	ElseIf (Option == SetSubLightBrightness)
		SetMenuDialogOptions(SubLightBrightList)
	EndIf
EndEvent

Event OnOptionMenuAccept(Int Option, Int Index)
	Main.PlayTickBig()
	If (Option == SetDomLightMode)
		Main.DomLightPos = Index
		SetMenuOptionValue(SetDomLightMode, DomLightModeList[Index])
	ElseIf (Option == SetSubLightMode)
		Main.SubLightPos = Index
		SetMenuOptionValue(Option, SubLightModeList[Index])
	ElseIf (Option == SetDomLightBrightness)
		Main.DomLightBrightness = Index
		SetMenuOptionValue(Option, DomLightBrightList[Index])
	ElseIf (Option == SetSubLightBrightness)
		Main.SubLightBrightness = Index
		SetMenuOptionValue(Option, SubLightBrightList[Index])
	EndIf
EndEvent

Event OnOptionSliderOpen(Int Option)
	Main.PlayTickBig()
	If (Option == SetSexExcitementMult)
		SetSliderDialogStartValue(Main.SexExcitementMult)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 3.0)
		SetSliderDialogInterval(0.1)
	ElseIf (Option == SetBedSearchDistance)
		SetSliderDialogStartValue(Main.BedSearchDistance)
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(1, 30)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetCustomTimescale)
		SetSliderDialogStartValue(Main.CustomTimescale)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0, 40)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetFreeCamFOV)
		SetSliderDialogStartValue(Main.FreecamFOV)
		SetSliderDialogDefaultValue(45.0)
		SetSliderDialogRange(1, 120)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetDefaultFOV)
		SetSliderDialogStartValue(Main.DefaultFOV)
		SetSliderDialogDefaultValue(85.0)
		SetSliderDialogRange(1, 120)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetCameraSpeed)
		SetSliderDialogStartValue(Main.FreecamSpeed)
		SetSliderDialogDefaultValue(3.0)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetBedReallignment)
		SetSliderDialogStartValue(Main.BedReallignment)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-250, 250)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetAIChangeChance)
		SetSliderDialogStartValue(Main.AiSwitchChance)
		SetSliderDialogDefaultValue(6.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == SetORDifficulty)
		SetSliderDialogStartValue(GetExternalInt(oromance, GVORDifficulty))
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-100, 150)
		SetSliderDialogInterval(1)
	elseif (option == SetONFreqMult)
		SetSliderDialogStartValue(GetExternalFloat(ONights, GVONFreqMult))
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 5.0)
		SetSliderDialogInterval(0.1)
	elseif (option == SetOCBounty)
		SetSliderDialogStartValue(StorageUtil.GetIntValue(none, SUOCBounty))
		SetSliderDialogDefaultValue(200)
		SetSliderDialogRange(1, 2000)
		SetSliderDialogInterval(1)
	elseif (option == SetOVVirginChance)
		SetSliderDialogStartValue(StorageUtil.GetIntValue(none, SUOVVirginChance))
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == SetOPFreq)
		SetSliderDialogStartValue(StorageUtil.GetIntValue(none, SUOPFreq))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-80, 80)
		SetSliderDialogInterval(1)
	elseif (option == SetOCRegenMod)
		GetExternalFloat(ocum, GVOCRegenMod)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 2)
		SetSliderDialogInterval(0.1)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int Option, Float Value)
	Main.PlayTickBig()
	If (Option == SetSexExcitementMult)
		Main.SexExcitementMult = Value
		SetSliderOptionValue(SetsexExcitementMult, Value, "{2} x")
	Elseif (option == SetORDifficulty)
		SetExternalInt(oromance, GVORDifficulty, value as int)
		SetSliderOptionValue(SetORDifficulty, Value as int, "{0}")
	Elseif (option == SetONFreqMult)
		SetExternalFloat(ONights, GVONFreqMult, value)
		SetSliderOptionValue(SetONFreqMult, Value, "{2} x")
	Elseif (option == SetOCBounty)
		StorageUtil.SetIntValue(none, SUOCBounty, value as int)
		SetSliderOptionValue(SetOCBounty, Value, "{0} Gold")
	Elseif (option == SetOVVirginChance)
		StorageUtil.SetIntValue(none, SUOVVirginChance, value as int)
		SetSliderOptionValue(SetOVVirginChance, Value, "{0} %")
	Elseif (option == SetOPFreq)
		StorageUtil.SetIntValue(none, SUOPFreq, value as int)
		SetSliderOptionValue(SetOPFreq, Value, "{0}")
	ElseIf (Option == SetBedSearchDistance)
		Main.BedSearchDistance = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0} Meters")
	ElseIf (Option == SetCustomTimescale)
		Main.CustomTimescale = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetFreeCamFOV)
		Main.FreecamFOV = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetDefaultFOV)
		Main.DefaultFOV = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetCameraSpeed)
		Main.FreecamSpeed = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetBedReallignment)
		Main.BedReallignment = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0} Units")
	ElseIf (Option == SetAIChangeChance)
		Main.AiSwitchChance = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetOCRegenMod)
		SetExternalFloat(ocum, GVOCRegenMod, Value)
		SetSliderOptionValue(SetOCRegenMod, Value, "{1}")
	EndIf
EndEvent

Event OnOptionKeyMapChange(Int Option, Int KeyCode, String ConflictControl, String ConflictName)
	Main.PlayTickBig()
	If (Option == Setkeymap)
		Main.RemapStartKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetKeyUp)
		Main.RemapSpeedUpKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetKeyDown)
		Main.RemapSpeedDownKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetPullOut)
		Main.RemapPulloutKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetControlToggle)
		Main.RemapControlToggleKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetFreecamToggleKey)
		Main.RemapFreecamKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetORKey)
		SetExternalInt(oromance, gvorkey, KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetOBPresetKey)
		SetExternalInt(OBody, GVOBPrestKey, KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetORLeft)
		SetExternalInt(oromance, GVORLeft, KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetOSKey)
		StorageUtil.SetIntValue(none, "osearch.key", keycode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetOAKey)
		StorageUtil.SetIntValue(none, "oaroused.key", keycode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetORRight)
		SetExternalInt(oromance, GVORRight, KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetOCumKey)
		StorageUtil.SetIntValue(none, SUOcumKey, keycode)
		SetKeyMapOptionValue(Option, KeyCode)
	EndIf
EndEvent

function DrawSlotPage()
	SlotSets = new int[128]

	string[] names = new string[128]

	names[30] = "$ostim_slot_30"
	names[31] = "$ostim_slot_31"
	names[32] = "$ostim_slot_32"
	names[33] = "$ostim_slot_33"
	names[34] = "$ostim_slot_34"
	names[35] = "$ostim_slot_35"
	names[36] = "$ostim_slot_36"
	names[37] = "$ostim_slot_37"
	names[38] = "$ostim_slot_38"
	names[39] = "$ostim_slot_39"
	names[40] = "$ostim_slot_40"
	names[41] = "$ostim_slot_41"
	names[42] = "$ostim_slot_42"
	names[43] = "$ostim_slot_43"
	
	names[44] = "$ostim_slot_44"
	names[45] = "$ostim_slot_45"
	names[46] = "$ostim_slot_46"
	names[47] = "$ostim_slot_47"
	names[48] = "$ostim_slot_48"
	names[49] = "$ostim_slot_49"
	names[52] = "$ostim_slot_52"
	names[53] = "$ostim_slot_53"
	names[54] = "$ostim_slot_54"
	names[55] = "$ostim_slot_55"
	names[56] = "$ostim_slot_56"
	names[57] = "$ostim_slot_57"
	names[58] = "$ostim_slot_58"
	names[59] = "$ostim_slot_59"
	names[60] = "$ostim_slot_60"

	int i = 30
	int max = 62

	While i < max
		SlotSets[i] = AddToggleOption(names[i],  Main.IntArrayContainsValue(main.StrippingSlots, i))
		i += 1
	EndWhile

endfunction

Function OnSlotSelect(int option)

	int slot = option - 486

	osexintegrationmain.console(slot)

	if (slot < 0) || slot > 100
		debug.messagebox("$ostim_message_slot_error")
	endif

	if Main.IntArrayContainsValue(main.StrippingSlots, slot)
		; remove this from the array
		main.StrippingSlots = PapyrusUtil.RemoveInt(main.StrippingSlots, slot)
		SetToggleOptionValue(Option, false)
	else 
		;add this to the array
		main.StrippingSlots = PapyrusUtil.PushInt(main.StrippingSlots, slot)
		SetToggleOptionValue(Option, true)
	endif

EndFunction

Function OnSlotMouseOver(int option)
	int slot = option - 486

	armor equipped = playerref.getEquippedArmorInSlot(slot) ; se exclusive

	if equipped
		SetInfoText("$ostim_slot_contains{" + equipped.getname() + "}{" + equipped.GetSlotMask() + "}")
	else
		SetInfoText("$ostim_slots_empty")
	endif
endfunction

Event OnGameReload()
	Parent.OnGameReload()
EndEvent

Bool Color1
Function AddColoredHeader(String In)
	String Blue = "#6699ff"
	String Pink = "#ff3389"
	String Color
	If Color1
		Color = Pink
		Color1 = False
	Else
		Color = Blue
		Color1 = True
	EndIf

	AddHeaderOption("<font color='" + Color +"'>" + In)
EndFunction

Function ExportSettings()
	; Export to file.
	int OstimSettingsFile = JMap.object()
	
	ShowMessage("$ostim_message_export", false)
	
	; Sex settings export.
	JMap.SetInt(OstimSettingsFile, "SetEndOnOrgasm", Main.EndOnDomOrgasm as Int)
	JMap.SetInt(OstimSettingsFile, "SetEndOnSubOrgasm", Main.EndOnSubOrgasm as Int)
	JMap.SetInt(OstimSettingsFile, "SetEndOnBothOrgasm", Main.RequireBothOrgasmsToFinish as Int)
	JMap.SetInt(OstimSettingsFile, "SetDisableHitbox", Main.DisablePlayerHitbox as Int)
	JMap.SetInt(OstimSettingsFile, "SetActorSpeedControl", Main.EnableActorSpeedControl as Int)
	JMap.SetInt(OstimSettingsFile, "SetResetPosition", Main.ResetPosAfterSceneEnd as Int)
	JMap.SetFlt(OstimSettingsFile, "SetsexExcitementMult", Main.SexExcitementMult as Float)
	JMap.SetInt(OstimSettingsFile, "SetClipinglessFirstPerson", Main.EnableImprovedCamSupport as Int)
	JMap.SetInt(OstimSettingsFile, "SetEndAfterActorHit", Main.EndAfterActorHit as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseRumble", Main.UseRumble as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseScreenShake", Main.UseScreenShake as Int)
	JMap.SetInt(OstimSettingsFile, "SetScaling", Main.DisableScaling as Int)
	JMap.SetInt(OstimSettingsFile, "SetOnlyGayAnimsInGayScenes", Main.OnlyGayAnimsInGayScenes as Int)

	; Player roles settings.
	JMap.SetInt(OstimSettingsFile, "PlayerAlwaysSubStraight", main.PlayerAlwaysSubStraight as Int)
	JMap.SetInt(OstimSettingsFile, "PlayerAlwaysSubGay", main.PlayerAlwaysSubGay as Int)
	JMap.SetInt(OstimSettingsFile, "PlayerAlwaysDomStraight", main.PlayerAlwaysDomStraight as Int)
	JMap.SetInt(OstimSettingsFile, "PlayerAlwaysDomGay", main.PlayerAlwaysDomGay as Int)
	
	; Clothes settings export.
	JMap.SetInt(OstimSettingsFile, "SetUndressIfNeed", Main.AutoUndressIfNeeded as Int)
	JMap.SetInt(OstimSettingsFile, "SetAlwaysUndressAtStart", Main.AlwaysUndressAtAnimStart as Int)
	JMap.SetInt(OstimSettingsFile, "SetDropClothes", Main.TossClothesOntoGround as Int)
	JMap.SetInt(OstimSettingsFile, "SetAnimateRedress", Main.FullyAnimateRedress as Int)
	;JMap.SetInt(OstimSettingsFile, "SetStrongerUnequip", Main.UseStrongerUnequipMethod as Int)

	; JMap.SetInt(OstimSettingsFile, "SetAlwaysAnimateUndress", Main.AlwaysAnimateUndress as Int) These have been removed in 4.0
	; JMap.SetInt(OstimSettingsFile, "SetonlyUndressChest", Main.OnlyUndressChest as Int) These have been removed in 4.0

	; Bar settings export.
	JMap.SetInt(OstimSettingsFile, "SetSubBar", Main.EnableSubBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetDomBar", Main.EnableDomBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetThirdBar", Main.EnableThirdBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetAutoHideBar", Main.AutoHideBars as Int)
	JMap.SetInt(OstimSettingsFile, "SetMatchColorToGender", Main.MatchBarColorToGender as Int)
	JMap.SetInt(OstimSettingsFile, "SetHideNPCOnNPCBars", Main.HideBarsInNPCScenes as Int)

	; Orgasm settings export.
	JMap.SetInt(OstimSettingsFile, "SetSlowMoOrgasms", Main.SlowMoOnOrgasm as Int)
	JMap.SetInt(OstimSettingsFile, "SetOrgasmBoostsRel", Main.OrgasmIncreasesRelationship as Int)

	; Light settings export.
	Jmap.SetInt(OstimSettingsFile, "SetDomLightMode", Main.DomLightPos as Int)
	Jmap.SetInt(OstimSettingsFile, "SetSubLightMode", Main.SubLightPos as Int)
	Jmap.SetInt(OstimSettingsFile, "SetSubLightBrightness", Main.SubLightBrightness as Int)
	Jmap.SetInt(OstimSettingsFile, "SetDomLightBrightness", Main.DomLightBrightness as Int)
	Jmap.SetInt(OstimSettingsFile, "SetOnlyLightInDark", Main.LowLightLevelLightsOnly as Int)
	
	; Keys settings export.
	JMap.SetInt(OstimSettingsFile, "SetKeymap", Main.KeyMap as Int)
	JMap.SetInt(OstimSettingsFile, "SetKeyUp", Main.SpeedUpKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetKeyDown", Main.SpeedDownKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetPullOut", Main.PullOutKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetControlToggle", Main.ControlToggleKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetFreecamToggleKey", Main.FreecamKey as Int)

	; Bed settings export.
	JMap.SetInt(OstimSettingsFile, "SetEnableBeds", Main.UseBed as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedSearchDistance", Main.BedSearchDistance as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedReallignment", Main.BedReallignment as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedAlgo", Main.UseAlternateBedSearch as Int)

	; Ai/Control settings export.
	JMap.SetInt(OstimSettingsFile, "SetAIControl", Main.UseAIControl as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIIfAttacking", Main.UseAIPlayerAggressor as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIIfAttacked", Main.UseAIPlayerAggressed as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIInConsensualScenes", Main.UseAINonAggressive as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIForMasturbation", Main.UseAIMasturbation as Int)
	JMap.SetInt(OstimSettingsFile, "SetAIChangeChance", Main.AiSwitchChance as Int)

	; Camera settings export.
	JMap.SetInt(OstimSettingsFile, "SetUseFreeCam", Main.UseFreeCam as Int)
	JMap.SetInt(OstimSettingsFile, "SetFreeCamFOV", Main.FreecamFOV as Int)
	JMap.SetInt(OstimSettingsFile, "SetDefaultFOV", Main.DefaultFOV as Int)
	JMap.SetInt(OstimSettingsFile, "SetCameraSpeed", Main.FreecamSpeed as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceFirstPerson", Main.ForceFirstPersonAfter as Int)

	; Misc settings export.
	JMap.SetInt(OstimSettingsFile, "SetCustomTimescale", Main.CustomTimescale as Int)

	JMap.SetInt(OstimSettingsFile, "SetTutorialMessages", Main.ShowTutorials as Int)

	JMap.SetInt(OstimSettingsFile, "SetMisallignmentOption", Main.MisallignmentProtection as Int)
	JMap.SetInt(OstimSettingsFile, "SetFlipFix", Main.FixFlippedAnimations as Int)

	JMap.SetInt(OstimSettingsFile, "SetUseFades", Main.UseFades as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseAutoFades", Main.UseAutoFades as Int)
	JMap.SetInt(OstimSettingsFile, "SetMute", Main.MuteOSA as Int)

	int clothes = JArray.objectWithInts(main.StrippingSlots)
	JMap.setObj(OstimSettingsFile,"Slots", clothes)

	; addon stuff
	if main.IsModLoaded(ORomance)
		osexintegrationmain.Console("Saving ORomance settings.")
		JMap.setInt(OstimSettingsFile, "savedORomance", 1)
		JMap.setInt(OstimSettingsFile, "SetORSexuality", (GetExternalBool(ORomance, GVORSexuality)) as int)
		JMap.setInt(OstimSettingsFile, "SetORDifficulty", (GetExternalInt(ORomance, GVORDifficulty)) as int)
		JMap.setInt(OstimSettingsFile, "SetORKey", GetExternalInt(oromance, gvorkey))
		JMap.setInt(OstimSettingsFile, "SetORColorblind", GetExternalBool(ORomance, GVORColorblind) as int)
		JMap.setInt(OstimSettingsFile, "SetORLeft",  GetExternalInt(oromance, GVORLeft))
		JMap.setInt(OstimSettingsFile, "SetORRight", GetExternalInt(oromance, GVORRight))
		JMap.setInt(OstimSettingsFile, "SetORNakadashi", GetExternalBool(ORomance, GVORNakadashi) as int)
	Else
		JMap.setInt(OstimSettingsFile, "savedORomance", 0)
	endif

	if main.IsModLoaded(ONights)
		osexintegrationmain.Console("Saving Onights settings.")
		JMap.setInt(OstimSettingsFile, "savedOnights", 1)
		JMap.setInt(OstimSettingsFile, "SetONStopWhenFound", GetExternalBool(ONights, GVONStopWhenFound) as int)
		JMap.setFlt(OstimSettingsFile, "SetONFreqMult", GetExternalFloat(ONights, GVONFreqMult))
	Else
		JMap.setInt(OstimSettingsFile, "savedOnights settings.", 0)
	endif

	if main.IsModLoaded(OSearch)
		osexintegrationmain.Console("Saving OSearch settings.")
		JMap.setInt(OstimSettingsFile, "savedOSearch", 1)
		JMap.setInt(OstimSettingsFile, "SetOSKey", StorageUtil.GetIntValue(none, SUOSKey))
		JMap.setInt(OstimSettingsFile, "SetOSAllowSex", StorageUtil.GetIntValue(none, SUOSAllowSex))
		JMap.setInt(OstimSettingsFile, "SetOSAllowHub", StorageUtil.GetIntValue(none, SUOSAllowHub))
		JMap.setInt(OstimSettingsFile, "SetOSAllowTransitory", StorageUtil.GetIntValue(none, SUOSAllowTransitory))
	else
		JMap.setInt(OstimSettingsFile, "savedOSearch", 0)
	endif

	if main.IsModLoaded(ovirginity)
		osexintegrationmain.Console("Saving oVirginity settings.")
		JMap.setInt(OstimSettingsFile, "savedoVirginity", 1)
		JMap.SetInt(OstimSettingsFile, "SetOVShowEffects", StorageUtil.GetIntValue(none, SUOVShowEffects))
		JMap.SetInt(OstimSettingsFile, "SetOVVirginChance", StorageUtil.GetIntValue(none, SUOVVirginChance))
	Else
		JMap.setInt(OstimSettingsFile, "savedoVirginity", 0)
	endif

	if main.IsModLoaded(OBody)
		osexintegrationmain.Console("Saving OBody settings.")
		JMap.setInt(OstimSettingsFile, "savedOBody", 1)
		JMap.setInt(OstimSettingsFile, "SetOBRefit", GetExternalBool(OBody, GVOBorefit) as Int)
		JMap.setInt(OstimSettingsFile, "SetOBNippleRand", GetExternalBool(OBody, GVOBNippleRand) as Int)
		JMap.setInt(OstimSettingsFile, "SetOBGenitalRand", GetExternalBool(OBody, GVOBGenitalRand) as Int)
		JMap.setInt(OstimSettingsFile, "SetOBPresetKey", GetExternalInt(OBody, GVOBPrestKey) as Int)
	Else
		JMap.setInt(OstimSettingsFile, "savedOBody", 0)
	endif

	if main.IsModLoaded(OCrime)
		osexintegrationmain.Console("Saving OCrime settings.")
		JMap.setInt(OstimSettingsFile, "savedOCrime", 1)
		JMap.setInt(OstimSettingsFile, "SetOCBounty", StorageUtil.GetIntValue(none, suocbounty))
	Else
		JMap.setInt(OstimSettingsFile, "savedOCrime", 0)
	endif

	if main.IsModLoaded(OAroused)
		osexintegrationmain.Console("Saving OAroused settings.")
		JMap.setInt(OstimSettingsFile, "savedOAroused", 1)
		JMap.setInt(OstimSettingsFile, "SetOAKey", StorageUtil.GetIntValue(none, SUOAKey))
		JMap.setInt(OstimSettingsFile, "SetOARequireLowArousalBeforeEnd", StorageUtil.GetIntValue(none, SUOALowArousalReq))
		JMap.setInt(OstimSettingsFile, "SetOAStatBuffs", StorageUtil.GetIntValue(none, SUOAStatBuffs))
		JMap.setInt(OstimSettingsFile, "SetOANudityBroadcast", StorageUtil.GetIntValue(none, SUOANudityBroadcast))
	Else
		JMap.setInt(OstimSettingsFile, "savedOAroused", 0)
	endif

	if main.IsModLoaded(OCum)
		OUtils.Console("Saving OCum settings.")
		JMap.SetInt(OStimSettingsFile, "savedOCum", 1)
		JMap.SetInt(OStimSettingsFile, "SetOCumKey", StorageUtil.GetIntValue(none, SUOCumKey))
		JMap.SetFlt(OStimSettingsFile, "SetOCRegenMod", GetExternalFloat(ocum, GVOCRegenMod))
		JMap.SetInt(OStimSettingsFile, "SetOCDisableInflation", GetExternalBool(ocum, GVOCDisableInflation) as int)
		JMap.SetInt(OStimSettingsFile, "SetOCDisableCumshot", GetExternalBool(ocum, GVOCDisableCumshot) as int)
		JMap.SetInt(OStimSettingsFile, "SetOCDisableCumMesh", GetExternalBool(ocum, GVOCDisableCumMesh) as int)
		JMap.SetInt(OStimSettingsFile, "SetOCDisableCumDecal", GetExternalBool(ocum, GVOCDisableCumDecal) as int)
	else
		JMap.SetInt(OStimSettingsFile, "savedOCum", 0)
	endIf

	; Save to file.
	JMap.SetInt(OstimSettingsFile, "OStimAPIVersion", outils.getostim().getapiversion())
	osexintegrationmain.Console("Saving Ostim settings.")
	Jvalue.WriteToFile(OstimSettingsFile, JContainers.UserDirectory() + "OstimMCMSettings.json")
	
	; Force page reset to show updated changes.
	ForcePageReset()
EndFunction

Function ImportSettings(bool default = false)
	; Import from file.
		int OstimSettingsFile
	if !default
		int OstimSettingsFileAlt

		if (JContainers.FileExistsAtPath(JContainers.UserDirectory() + "OstimMCMSettings.json"))
			OstimSettingsFile = JValue.readFromFile(JContainers.UserDirectory() + "OstimMCMSettings.json")
		endif

		if (JContainers.FileExistsAtPath(".\\Data\\OstimMCMSettings.json"))
			; Tries to import from Data folder as well, this is to allow Modlist creators to package configuration files as mods for mo2 or vortex.
			OstimSettingsFileAlt = JValue.readFromFile(".\\Data\\OstimMCMSettings.json")
		endif

		if (OstimSettingsFile == False && OstimSettingsFileAlt == False)
			osexintegrationmain.Console(osanative.translate("$ostim_import_no_file"))
			return
		ElseIf (OstimSettingsFile == False && OstimSettingsFileAlt == True)
			OstimSettingsFile = OstimSettingsFileAlt
			osexintegrationmain.Console(osanative.translate("$ostim_message_import_ml_settings"))
		Else
			osexintegrationmain.Console(osanative.translate("$ostim_message_import"))
		EndIf

		if (outils.getostim().getapiversion() != JMap.GetInt(OstimSettingsFile, "OStimAPIVersion") && !OstimSettingsFileAlt) ;if api version is different, and didn't load modlist setting file from data folder.
			osexintegrationmain.Console(osanative.translate("$ostim_message_import_old_api"))
			outils.getostim().DisplayToastAsync(osanative.translate("$ostim_message_import_old_api"), 10)
		endif
	Else
		if (JContainers.FileExistsAtPath(".\\Data\\Interface\\Ostim\\DefaultOstimMCMSettings.json"))
			OstimSettingsFile = JValue.readFromFile(".\\Data\\Interface\\Ostim\\DefaultOstimMCMSettings.json")
		Else
			ShowMessage("$ostim_default_missing_error", false)
			return
		endif
	endif
	
	; Sex settings import.
	Main.EndOnDomOrgasm = Jmap.GetInt(OstimSettingsFile, "SetEndOnOrgasm")
	Main.EndOnSubOrgasm = JMap.GetInt(OstimSettingsFile, "SetEndOnSubOrgasm")
	Main.RequireBothOrgasmsToFinish = JMap.GetInt(OstimSettingsFile, "SetEndOnBothOrgasm")
	Main.DisablePlayerHitbox = JMap.GetInt(OstimSettingsFile, "SetDisableHitbox")
	Main.EnableActorSpeedControl = JMap.GetInt(OstimSettingsFile, "SetActorSpeedControl")
	Main.ResetPosAfterSceneEnd = JMap.GetInt(OstimSettingsFile, "SetResetPosition")
	Main.SexExcitementMult = JMap.GetFlt(OstimSettingsFile, "SetsexExcitementMult")
	Main.EnableImprovedCamSupport = JMap.GetInt(OstimSettingsFile, "SetClipinglessFirstPerson")
	Main.EndAfterActorHit = JMap.GetInt(OstimSettingsFile, "SetEndAfterActorHit")
	Main.UseRumble = JMap.GetInt(OstimSettingsFile, "SetUseRumble")
	Main.UseScreenShake = JMap.GetInt(OstimSettingsFile, "SetUseScreenShake")
	Main.DisableScaling = JMap.GetInt(OstimSettingsFile, "SetScaling")
	Main.OnlyGayAnimsInGayScenes = JMap.GetInt(OstimSettingsFile, "SetOnlyGayAnimsInGayScenes")

	;Player Roles settings
	Main.PlayerAlwaysSubStraight = Jmap.GetInt(OstimSettingsFile, "PlayerAlwaysSubStraight")
	Main.PlayerAlwaysSubGay = Jmap.GetInt(OstimSettingsFile, "PlayerAlwaysSubGay")
	Main.PlayerAlwaysDomStraight = Jmap.GetInt(OstimSettingsFile, "PlayerAlwaysDomStraight")
	Main.PlayerAlwaysDomGay = Jmap.GetInt(OstimSettingsFile, "PlayerAlwaysDomGay")
	
	; Clothes settings import.
	Main.AutoUndressIfNeeded = JMap.GetInt(OstimSettingsFile, "SetUndressIfNeed")
	Main.TossClothesOntoGround = JMap.GetInt(OstimSettingsFile, "SetDropClothes")
	Main.FullyAnimateRedress = JMap.GetInt(OstimSettingsFile, "SetAnimateRedress")
	;Main.UseStrongerUnequipMethod = JMap.GetInt(OstimSettingsFile, "SetStrongerUnequip")
	Main.AlwaysUndressAtAnimStart = JMap.GetInt(OstimSettingsFile, "SetAlwaysUndressAtStart")
	
	; Main.AlwaysAnimateUndress = JMap.GetInt(OstimSettingsFile, "SetAlwaysAnimateUndress") These have been removed in 4.0
	; Main.OnlyUndressChest = JMap.GetInt(OstimSettingsFile, "SetonlyUndressChest") These have been removed in 4.0
	
	; Bar settings import.
	Main.EnableSubBar = JMap.GetInt(OstimSettingsFile, "SetSubBar")
	Main.EnableDomBar = JMap.GetInt(OstimSettingsFile, "SetDomBar")
	Main.EnableThirdBar = JMap.GetInt(OstimSettingsFile, "SetThirdBar")
	Main.AutoHideBars = JMap.GetInt(OstimSettingsFile, "SetAutoHideBar")
	Main.MatchBarColorToGender = JMap.GetInt(OstimSettingsFile, "SetMatchColorToGender")
	Main.HideBarsInNPCScenes = JMap.GetInt(OstimSettingsFile, "SetHideNPCOnNPCBars")

	; Light settings export.
	Main.DomLightPos = Jmap.GetInt(OstimSettingsFile, "SetDomLightMode")
	Main.SubLightPos = Jmap.GetInt(OstimSettingsFile, "SetSubLightMode")
	Main.SubLightBrightness = Jmap.GetInt(OstimSettingsFile, "SetSubLightBrightness")
	Main.DomLightBrightness = Jmap.GetInt(OstimSettingsFile, "SetDomLightBrightness")
	Main.LowLightLevelLightsOnly = Jmap.GetInt(OstimSettingsFile, "SetOnlyLightInDark")
	
	; Keys settings import.
	Main.KeyMap = JMap.GetInt(OstimSettingsFile, "SetKeymap")
	Main.RemapStartKey(Main.KeyMap)
	Main.SpeedUpKey = JMap.GetInt(OstimSettingsFile, "SetKeyUp")
	Main.RemapSpeedUpKey(Main.SpeedUpKey)
	Main.SpeedDownKey = JMap.GetInt(OstimSettingsFile, "SetKeyDown")
	Main.RemapSpeedDownKey(Main.SpeedDownKey)
	Main.PullOutKey = JMap.GetInt(OstimSettingsFile, "SetPullOut")
	Main.RemapPullOutKey(Main.PullOutKey)
	Main.ControlToggleKey = JMap.GetInt(OstimSettingsFile, "SetControlToggle")
	Main.RemapControlToggleKey(Main.ControlToggleKey)
	Main.FreecamKey = JMap.GetInt(OstimSettingsFile, "SetFreecamToggleKey")
	main.RemapControlToggleKey(main.FreecamKey)
	
	; Bed settings export.
	Main.UseBed = JMap.GetInt(OstimSettingsFile, "SetEnableBeds")
	Main.BedSearchDistance = JMap.GetInt(OstimSettingsFile, "SetBedSearchDistance")
	Main.BedReallignment = JMap.GetInt(OstimSettingsFile, "SetBedReallignment")
	Main.UseAlternateBedSearch = JMap.GetInt(OstimSettingsFile, "SetBedAlgo")
	Main.AiSwitchChance = JMap.GetInt(OstimSettingsFile, "SetAIChangeChance")
	
	;Orgasm settings
	Main.SlowMoOnOrgasm = JMap.GetInt(OstimSettingsFile, "SetSlowMoOrgasms")
	Main.OrgasmIncreasesRelationship = JMap.GetInt(OstimSettingsFile, "SetOrgasmBoostsRel")
	
	; Ai/Control settings export.
	Main.UseAIControl = JMap.GetInt(OstimSettingsFile, "SetAIControl")
	Main.UseAIPlayerAggressor = JMap.GetInt(OstimSettingsFile, "SetForceAIIfAttacking")
	Main.UseAIPlayerAggressed = JMap.GetInt(OstimSettingsFile, "SetForceAIIfAttacked")
	Main.UseAINonAggressive = JMap.GetInt(OstimSettingsFile, "SetForceAIInConsensualScenes")
	Main.UseAIMasturbation = JMap.GetInt(OstimSettingsFile, "SetForceAIForMasturbation")
	
	; Camera settings export.
	Main.UseFreeCam = JMap.GetInt(OstimSettingsFile, "SetUseFreeCam")
	Main.FreecamFOV = JMap.GetInt(OstimSettingsFile, "SetFreeCamFOV")
	Main.DefaultFOV = JMap.GetInt(OstimSettingsFile, "SetDefaultFOV")
	Main.FreecamSpeed = JMap.GetInt(OstimSettingsFile, "SetCameraSpeed")
	Main.ForceFirstPersonAfter = JMap.GetInt(OstimSettingsFile, "SetForceFirstPerson")

	; Misc settings export.
	Main.CustomTimescale = JMap.GetInt(OstimSettingsFile, "SetCustomTimescale")
	
	Main.MisallignmentProtection = JMap.GetInt(OstimSettingsFile, "SetMisallignmentOption")
	Main.FixFlippedAnimations = JMap.GetInt(OstimSettingsFile, "SetFlipFix")
	
	Main.UseFades = JMap.GetInt(OstimSettingsFile, "SetUseFades")
	Main.UseAutoFades = JMap.GetInt(OstimSettingsFile, "SetUseAutoFades")
	
	Main.MuteOSA = JMap.GetInt(OstimSettingsFile, "SetMute")

	Main.ShowTutorials = JMap.GetInt(OstimSettingsFile, "SetTutorialMessages")
	
	main.StrippingSlots = JArray.asIntArray((jmap.getObj(OstimSettingsFile, "Slots")))

	if !default ; don't load addon settings for reset to default button
	; addon stuff
		if main.IsModLoaded(ORomance) && JMap.getInt(OstimSettingsFile, "savedORomance") == 1
			osexintegrationmain.Console("Loading ORomance settings.")
			SetExternalBool(ORomance, GVORSexuality, JMap.getInt(OstimSettingsFile, "SetORSexuality") as bool)
			SetExternalInt(ORomance, GVORDifficulty, JMap.getInt(OstimSettingsFile, "SetORDifficulty"))
			SetExternalInt(ORomance, gvorkey, JMap.getInt(OstimSettingsFile, "SetORKey"))
			SetExternalBool(ORomance, GVORColorblind, JMap.getInt(OstimSettingsFile, "SetORColorblind") as bool)
			SetExternalInt(ORomance, GVORLeft, JMap.getInt(OstimSettingsFile, "SetORLeft"))
			SetExternalInt(ORomance, GVORRight, JMap.getInt(OstimSettingsFile, "SetORRight"))
			SetExternalBool(ORomance, GVORNakadashi, JMap.getInt(OstimSettingsFile, "SetORNakadashi") as bool)
		endif

		if main.IsModLoaded(ONights) && JMap.getInt(OstimSettingsFile, "savedONights") == 1
			osexintegrationmain.Console("Loading ONights settings.")
			SetExternalBool(ONights, GVONStopWhenFound, JMap.getInt(OstimSettingsFile, "SetONStopWhenFound") as bool)
			SetExternalFloat(ONights, GVONFreqMult, JMap.getFlt(OstimSettingsFile, "SetONFreqMult"))
		endif

		if main.IsModLoaded(OSearch) && JMap.getInt(OstimSettingsFile, "savedOSearch") == 1
			osexintegrationmain.Console("Loading OSearch settings.")
			 StorageUtil.SetIntValue(none, SUOSKey, JMap.getInt(OstimSettingsFile, "SetOSKey"))
			 StorageUtil.SetIntValue(none, SUOSAllowSex, JMap.getInt(OstimSettingsFile, "SetOSAllowSex"))
			 StorageUtil.SetIntValue(none, SUOSAllowHub, JMap.getInt(OstimSettingsFile, "SetOSAllowHub"))
			 StorageUtil.SetIntValue(none, SUOSAllowTransitory, JMap.getInt(OstimSettingsFile, "SetOSAllowTransitory"))
		endif

		if main.IsModLoaded(ovirginity) && JMap.getInt(OstimSettingsFile, "savedovirginity") == 1
			osexintegrationmain.Console("Loading oVirginity settings.")
			StorageUtil.SetIntValue(none, SUOVShowEffects, JMap.GetInt(OstimSettingsFile, "SetOVShowEffects"))
			StorageUtil.SetIntValue(none, SUOVVirginChance, JMap.GetInt(OstimSettingsFile, "SetOVVirginChance"))
		endif

		if main.IsModLoaded(OBody) && JMap.getInt(OstimSettingsFile, "savedOBody") == 1
			osexintegrationmain.Console("Loading OBody settings.")
			SetExternalBool(OBody, GVOBorefit, JMap.getInt(OstimSettingsFile, "SetOBRefit") as bool)
			SetExternalBool(OBody, GVOBNippleRand, JMap.getInt(OstimSettingsFile, "SetOBNippleRand") as bool)
			SetExternalBool(OBody, GVOBGenitalRand, JMap.getInt(OstimSettingsFile, "SetOBGenitalRand") as bool)
			SetExternalInt(OBody, GVOBPrestKey, JMap.getInt(OstimSettingsFile, "SetOBPresetKey"))
		endif

		if main.IsModLoaded(OCrime) && JMap.getInt(OstimSettingsFile, "savedOCrime") == 1
			osexintegrationmain.Console("Loading OCrime settings.")
			StorageUtil.SetIntValue(none, suocbounty, JMap.getInt(OstimSettingsFile, "SetOCBounty"))
		endif

		if main.IsModLoaded(OAroused) && JMap.getInt(OstimSettingsFile, "savedOAroused") == 1
			osexintegrationmain.Console("Loading OAroused settings.")
			StorageUtil.SetIntValue(none, SUOAKey, JMap.getInt(OstimSettingsFile, "SetOAKey"))
			StorageUtil.SetIntValue(none, SUOALowArousalReq, JMap.getInt(OstimSettingsFile, "SetOARequireLowArousalBeforeEnd"))
			StorageUtil.SetIntValue(none, SUOAStatBuffs, JMap.getInt(OstimSettingsFile, "SetOAStatBuffs"))
			StorageUtil.SetIntValue(none, SUOANudityBroadcast, JMap.getInt(OstimSettingsFile, "SetOANudityBroadcast"))
		endif

		if main.IsModLoaded(OCum) && JMap.GetInt(OStimSettingsFile, "savedOCum") == 1
			OUtils.Console("Loading OAroused settings.")
			StorageUtil.SetIntValue(none, SUOCumKey, JMap.GetInt(OStimSettingsFile, "SetOCumKey"))
			SetExternalFloat(OCum, GVOCRegenMod, JMap.GetFlt(OStimSettingsFile, "SetOCRegenMod"))
			SetExternalBool(OCum, GVOCDisableInflation, JMap.GetInt(OStimSettingsFile, "SetOCDisableInflation") as bool)
			SetExternalBool(OCum, GVOCDisableCumshot, JMap.GetInt(OStimSettingsFile, "SetOCDisableCumshot") as bool)
			SetExternalBool(OCum, GVOCDisableCumMesh, JMap.GetInt(OStimSettingsFile, "SetOCDisableCumMesh") as bool)
			SetExternalBool(OCum, GVOCDisableCumDecal, JMap.GetInt(OStimSettingsFile, "SetOCDisableCumDecal") as bool)
		endIf
	endif

	osexintegrationmain.Console("Loading Ostim settings.")
	; Force page reset to show updated changes.
	ForcePageReset()
EndFunction
