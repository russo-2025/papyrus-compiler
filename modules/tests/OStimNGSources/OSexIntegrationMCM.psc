ScriptName OsexIntegrationMCM Extends SKI_ConfigBase

int[] SlotSets
int UndressingSlotMask

string[] RoleKeys

string[] SynchronizationTypes
string[] ScalingTypes

OsexIntegrationMain Property Main Auto


string currPage

actor playerref

int SetUndressingAbout

Int osaMainMenuKeyDefault = 156 ; numpad ENTER
Int osaUpKeyDefault = 72 ; numpad 8
Int osaDownKeyDefault = 76 ; numpad 5
Int osaLeftKeyDefault = 75 ; numpad 4
Int osaRightKeyDefault = 77 ; numpad 6
Int osaTogKeyDefault = 73 ; numpad 9
Int osaYesKeyDefault = 71 ; numpad 7
Int osaEndKeyDefault = 83 ; numpad .

Event OnInit()
	Init()
EndEvent

Function Init()
	Parent.OnGameReload()

	playerref = game.getplayer()

	SetupPages()
EndFunction

int Function GetVersion()
	Return 12
EndFunction

Event OnVersionUpdate(int Version)
	SetupPages()
EndEvent

Function SetupPages()
	Pages = new string[16]
	Pages[0] = "$ostim_page_general"
	Pages[1] = "$ostim_page_controls"
	Pages[2] = "$ostim_page_auto_control"
	Pages[3] = "$ostim_page_camera"
	Pages[4] = "$ostim_page_excitement"
	Pages[5] = "$ostim_page_gender_roles"
	Pages[6] = "$ostim_page_furniture"
	Pages[7] = "$ostim_page_undress"
	Pages[8] = "$ostim_page_expression"
	Pages[9] = "$ostim_page_sound"
	Pages[10] = "$ostim_page_alignment"
	Pages[11] = "$ostim_page_actors"
	Pages[12] = "$ostim_page_toys"
	Pages[13] = "$ostim_page_debug"
	Pages[14] = "$ostim_page_about"
	Pages[15] = "$ostim_page_addons"

	RoleKeys = new string[3]
	RoleKeys[0] = "actor"
	RoleKeys[1] = "target"
	RoleKeys[2] = "performer"

	SynchronizationTypes = new string[5]
	SynchronizationTypes[0] = "player"
	SynchronizationTypes[1] = "male"
	SynchronizationTypes[2] = "female"
	SynchronizationTypes[3] = "scene"
	SynchronizationTypes[4] = "individual"

	ScalingTypes = new string[4]
	ScalingTypes[0] = "none"
	ScalingTypes[1] = "stimulation rate"
	ScalingTypes[2] = "stimulation value"
	ScalingTypes[3] = "speed"
EndFunction

Event OnConfigRegister()
	ImportSettings()
endEvent

Event OnConfigOpen()
	CurrentActor = PlayerRef
	CurrentActorID = 0x7
	CurrentEquipObjectType = "light"

	OSettings.MenuOpened()
EndEvent

Event OnConfigClose()
	If Main.AutoExportSettings
		ExportSettings()
	EndIf
EndEvent

Event OnPageReset(String Page)
	{Called when a new page is selected, including the initial empty page}
	currPage = page

	If (Page == "")
		LoadCustomContent("Ostim/logo.dds", 184, 31)
		Return
	Else
		UnloadCustomContent()
		SetInfoText(" ")
	EndIf

	If Page == "$ostim_page_general"
		DrawGeneralPage()
	ElseIf Page == "$ostim_page_controls"
		DrawControlsPage()
	ElseIf Page == "$ostim_page_auto_control"
		DrawAutoControlPage()
	ElseIf Page == "$ostim_page_camera"
		DrawCameraPage()
	ElseIf Page == "$ostim_page_excitement"
		DrawExcitementPage()
	ElseIf Page == "$ostim_page_gender_roles"
		DrawGenderRolesPage()
	ElseIf Page == "$ostim_page_furniture"
		DrawFurniturePage()
	ElseIf Page == "$ostim_page_undress"
		DrawUndressingPage()
	ElseIf Page == "$ostim_page_expression"
		DrawExpressionPage()
	ElseIf Page == "$ostim_page_sound"
		DrawSoundPage()
	ElseIf Page == "$ostim_page_alignment"
		DrawAlignmentPage()
	ElseIf Page == "$ostim_page_actors"
		DrawActorsPage()
	ElseIf Page == "$ostim_page_toys"
		DrawPage(OSettings.GetSettingPageCount() - 2)
	ElseIf Page == "$ostim_page_debug"
		DrawDebugPage()
	ElseIf (Page == "$ostim_page_about")
		UnloadCustomContent()
		SetInfoText(" ")
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)

		AddTextOption("OStim Standalone ", "-")
		
		AddTextOption("", "")
		AddColoredHeader("$ostim_authors")
		AddTextOption("OStim Standalone ", "$ostim_by{Kannonfodder, VersuchDrei}")
		AddTextOption("OStim ", "$ostim_by{Nem, Qudix, Sairion}")
		AddColoredHeader("$ostim_contributors")
		AddTextOption("Code ", "$ostim_by{Aietos}")
		AddTextOption("Icons ", "$ostim_by{Keed}")
		AddTextOption("Sounds ", "$ostim_by{BigTittyBoy, Migal130}")
		AddTextOption("Meshes ", "$ostim_by{Calyps, Egilvar}")
		AddTextOption("Animations ", "$ostim_by{AceAnimations, Moon}")
		AddTextOption("Facial Expressions", "$ostim_by{AceAnimations, GusCrow, Moon}")

		SetCursorPosition(1)
		AddTextOption("Powered By Sswaye's Reshade", "")

		AddTextOption("", "")
		AddColoredHeader("$ostim_links")
		AddTextOption("https://discord.gg/ostimofficial", "")
		AddTextOption("https://github.com/VersuchDrei/OStimNG", "")
	ElseIf Page == "$ostim_page_addons"
		DrawPage(OSettings.GetSettingPageCount() - 1)
	EndIf
EndEvent

Event OnOptionHighlight(int Option)
	If currPage == "$ostim_page_toys" || currPage == "$ostim_page_addons"
		OnOptionHighlightRefactored(Option)
	ElseIf currPage == "$ostim_page_excitement"
		OnOptionHighlightExcitement(Option)
	ElseIf currPage == "$ostim_page_undress"
		OnSlotMouseOver(Option)
	ElseIf currPage == "$ostim_page_sound"
		OnOptionHighlightSound(Option)
	ElseIf currPage == "$ostim_page_actors"
		OnOptionHighlightActors(Option)
	ElseIf currPage == "$ostim_page_debug"
		OnOptionHighlightDebug(Option)
	EndIf
EndEvent

Event OnOptionSelect(int Option)
	If currPage == "$ostim_page_toys" || currPage == "$ostim_page_addons"
		OnOptionSelectRefactored(Option)
	Elseif currPage == "$ostim_page_undress"
		OnSlotSelect(Option)
	ElseIf currPage == "$ostim_page_sound"
		OnOptionSelectSound(Option)
	ElseIf currPage == "$ostim_page_actors"
		OnOptionSelectActors(Option)
	ElseIf CurrPage == "$ostim_page_debug"
		OnOptionSelectDebug(Option)
	EndIf
EndEvent

Event OnOptionSliderOpen(int Option)
	If currPage == "$ostim_page_toys" || currPage == "$ostim_page_addons"
		OnOptionSliderOpenRefactored(Option)
	ElseIf currPage == "$ostim_page_excitement"
		OnOptionSliderOpenExcitement(Option)
	ElseIf currPage == "$ostim_page_actors"
		OnOptionSliderOpenActors(Option)
	EndIf
EndEvent

Event OnOptionSliderAccept(int Option, float Value)
	If currPage == "$ostim_page_toys" || currPage == "$ostim_page_addons"
		OnOptionSliderAcceptRefactored(Option, Value)
	ElseIf currPage == "$ostim_page_excitement"
		OnOptionSliderAcceptExcitement(Option, Value)
	ElseIf currPage == "$ostim_page_actors"
		OnOptionSliderAcceptActors(Option, Value)
	EndIf
EndEvent

Event OnOptionMenuOpen(int Option)
	If currPage == "$ostim_page_toys" || currPage == "$ostim_page_addons"
		OnOptionMenuOpenRefactored(Option)
	ElseIf currPage == "$ostim_page_sound"
		OnOptionMenuOpenSound(Option)
	ElseIf currPage == "$ostim_page_actors"
		OnOptionMenuOpenActors(Option)
	EndIf
EndEvent

Event OnOptionMenuAccept(int Option, int Index)
	If currPage == "$ostim_page_toys" || currPage == "$ostim_page_addons"
		OnOptionMenuAcceptRefactored(Option, Index)
	ElseIf currPage == "$ostim_page_sound"
		OnOptionMenuAcceptSound(Option, Index)
	ElseIf currPage == "$ostim_page_actors"
		OnOptionMenuAcceptActors(Option, Index)
	EndIf
EndEvent

Event OnOptionDefault(int Option)
	If currPage == "$ostim_page_toys" || currPage == "$ostim_page_addons"
		OnOptionDefaultRefactored(Option)
	ElseIf currPage == "$ostim_page_sound"
		OnOptionDefaultSound(Option)
	ElseIf currPage == "$ostim_page_actors"
		OnOptionDefaultActors(Option)
	EndIf
EndEvent

Function OnSlotSelect(int Option)
	int i = SlotSets.Length
	While i
		i -= 1
		If SlotSets[i] == Option
			int Mask = Math.Pow(2, i) as int
			UndressingSlotMask = Math.LogicalXor(UndressingSlotMask, Mask)
			OData.SetUndressingSlotMask(UndressingSlotMask)
			SetToggleOptionValue(Option, Math.LogicalAnd(UndressingSlotMask, Mask))

			Return
		EndIf
	EndWhile
	debug.messagebox("$ostim_message_slot_error")
EndFunction

Function OnSlotMouseOver(int option)
	int i = SlotSets.Length
	While i
		i -= 1
		If SlotSets[i] == option
			int Slot = i + 30
			armor equipped = playerref.getEquippedArmorInSlot(slot) ; se exclusive

			if equipped
				SetInfoText("$ostim_slot_contains{" + equipped.getname() + "}{" + equipped.GetSlotMask() + "}")
			else
				SetInfoText("$ostim_slots_empty")
			endif

			Return
		EndIf
	EndWhile
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
	ShowMessage("$ostim_message_export", false)

	osexintegrationmain.Console("Saving Ostim settings.")
	OData.ExportSettings()
	osexintegrationmain.Console("Saved Ostim settings.")
EndFunction

Function ImportSettings(bool default = false)
	osexintegrationmain.Console("Loading Ostim settings.")
	if default
		OData.ResetSettings()
	Else
		OData.ImportSettings()
	endif
	osexintegrationmain.Console("Loaded Ostim settings.")
	; Force page reset to show updated changes.
	ForcePageReset()
EndFunction


;  ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗     
; ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║     
; ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║     
; ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║     
; ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗
;  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

Function DrawGeneralPage()
	SetCursorFillMode(LEFT_TO_RIGHT)
	SetCursorPosition(0)
	AddColoredHeader("$ostim_header_scenes")
	SetCursorPosition(2)
	AddToggleOptionST("OID_ResetPosition", "$ostim_reset_position", Main.ResetPosAfterSceneEnd)
	SetCursorPosition(4)
	AddSliderOptionST("OID_CustomTimeScale", "$ostim_timescale", Main.CustomTimescale, "{0}")
	SetCursorPosition(6)
	AddToggleOptionST("OID_UseFades", "$ostim_use_fades", Main.UseFades)
	SetCursorPosition(8)
	AddToggleOptionST("OID_UseIntroScenes", "$ostim_use_intro_scenes", Main.UseIntroScenes)
	SetCursorPosition(10)
	AddToggleOptionST("OID_AddActorsAtStart", "$ostim_add_actors_at_start", Main.AddActorsAtStart)

	SetCursorPosition(14)
	AddColoredHeader("$ostim_header_lights")
	SetCursorPosition(16)
	AddMenuOptionST("OID_MaleLightMode", "$ostim_male_light_mode", OData.GetEquipObjectName(0x0, "light"))
	SetCursorPosition(18)
	AddMenuOptionST("OID_FemaleLightMode", "$ostim_female_light_mode", OData.GetEquipObjectName(0x1, "light"))
	SetCursorPosition(20)
	AddMenuOptionST("OID_PlayerLightMode", "$ostim_player_light_mode", OData.GetEquipObjectName(0x7, "light"))
	SetCursorPosition(22)
	AddToggleOptionST("OID_OnlyLightInDark", "$ostim_dark_light", Main.LowLightLevelLightsOnly)

	SetCursorPosition(1)
	AddColoredHeader("$ostim_header_save_load")
	SetCursorPosition(3)
	AddTextOptionST("OID_ExportSettings", "$ostim_export", "$ostim_done")
	SetCursorPosition(5)
	AddTextOptionST("OID_ImportSettings", "$ostim_import", "$ostim_done")
	SetCursorPosition(7)
	AddToggleOptionST("OID_AutoExportSettings", "$ostim_auto_export", Main.AutoExportSettings)
	SetCursorPosition(9)
	AddToggleOptionST("OID_AutoImportSettings", "$ostim_auto_import", Main.AutoImportSettings)
	SetCursorPosition(11)
	AddTextOptionST("OID_ResetSettings", "$ostim_import_default", "$ostim_done")
EndFunction


State OID_ResetPosition
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_reset_position")
	EndEvent

	Event OnSelectST()
		Main.ResetPosAfterSceneEnd = !Main.ResetPosAfterSceneEnd
		SetToggleOptionValueST(Main.ResetPosAfterSceneEnd)
	EndEvent
EndState

State OID_CustomTimeScale
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_custom_timescale")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.CustomTimescale)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 40)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.CustomTimescale = Value As int
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState

State OID_UseFades
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_fades")
	EndEvent

	Event OnSelectST()
		Main.UseFades = !Main.UseFades
		SetToggleOptionValueST(Main.UseFades)
	EndEvent
EndState

State OID_UseIntroScenes
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_intro_scenes")
	EndEvent

	Event OnSelectST()
		Main.UseIntroScenes = !Main.UseIntroScenes
		SetToggleOptionValueST(Main.UseIntroScenes)
	EndEvent
EndState

State OID_AddActorsAtStart
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_add_actors_at_start")
	EndEvent

	Event OnSelectST()
		Main.AddActorsAtStart = !Main.AddActorsAtStart
		SetToggleOptionValueST(Main.AddActorsAtStart)
	EndEvent
EndState


State OID_MaleLightMode
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_male_light_mode")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x0, "light")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x0, "light", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x0, "light")
	EndEvent
EndState

State OID_FemaleLightMode
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_female_light_mode")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x1, "light")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x1, "light", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x1, "light")
	EndEvent
EndState

State OID_PlayerLightMode
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_player_light_mode")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x7, "light")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x7, "light", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x7, "light")
	EndEvent
EndState

State OID_OnlyLightInDark
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_dark_light")
	EndEvent

	Event OnSelectST()
		Main.LowLightLevelLightsOnly = !Main.LowLightLevelLightsOnly
		SetToggleOptionValueST(Main.LowLightLevelLightsOnly)
	EndEvent
EndState


State OID_ExportSettings
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_export")
	EndEvent

	Event OnSelectST()
		ExportSettings()
	EndEvent
EndState

State OID_ImportSettings
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_import")
	EndEvent

	Event OnSelectST()
		ImportSettings()
	EndEvent
EndState

State OID_AutoExportSettings
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_export")
	EndEvent

	Event OnSelectST()
		Main.AutoExportSettings = !Main.AutoExportSettings
		SetToggleOptionValueST(Main.AutoExportSettings)
	EndEvent
EndState

State OID_AutoImportSettings
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_import")
	EndEvent

	Event OnSelectST()
		Main.AutoImportSettings = !Main.AutoImportSettings
		SetToggleOptionValueST(Main.AutoImportSettings)
	EndEvent
EndState

State OID_ResetSettings
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_import_default")
	EndEvent

	Event OnSelectST()
		ImportSettings(true)
	EndEvent
EndState


;  ██████╗ ██████╗ ███╗   ██╗████████╗██████╗  ██████╗ ██╗     ███████╗
; ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗██║     ██╔════╝
; ██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║██║     ███████╗
; ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║██║     ╚════██║
; ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║╚██████╔╝███████╗███████║
;  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝

Function DrawControlsPage()
	SetCursorFillMode(LEFT_TO_RIGHT)
	SetCursorPosition(0)
	AddColoredHeader("$ostim_header_ostim_keys")
	SetCursorPosition(2)
	AddKeyMapOptionST("OID_KeyMain", "$ostim_main_key", Main.KeyMap)
	SetCursorPosition(4)
	AddKeyMapOptionST("OID_KeyNPCStart", "$ostim_npc_start_key", Main.KeyNPCStart)
	SetCursorPosition(6)
	AddKeyMapOptionST("OID_KeySpeedUp", "$ostim_speed_up_key", Main.SpeedUpKey)
	SetCursorPosition(8)
	AddKeyMapOptionST("OID_KeySpeedDown", "$ostim_speed_down_key", Main.SpeedDownKey)
	SetCursorPosition(10)
	AddKeyMapOptionST("OID_KeyPullOut", "$ostim_pullout_key", Main.PullOutKey)
	SetCursorPosition(12)
	AddKeyMapOptionST("OID_KeyControlToggle", "$ostim_control_toggle_key", Main.ControlToggleKey)
	SetCursorPosition(14)
	AddKeyMapOptionST("OID_KeyFreeCamToggle", "$ostim_tfc_key", Main.FreecamKey)
	SetCursorPosition(16)
	AddKeyMapOptionST("OID_KeySearchMenu", "$ostim_key_search_menu", Main.SearchKey)
	SetCursorPosition(18)
	AddKeyMapOptionST("OID_KeyAlignmentMenu", "$ostim_key_alignment_menu", Main.AlignmentKey)
	SetCursorPosition(20)
	AddKeyMapOptionST("OID_KeyHideUI", "$ostim_key_hide_ui", Main.HideUIKey)

	SetCursorPosition(22)
	int UseRumbleFlags = OPTION_FLAG_NONE
	If !Game.UsingGamepad()
		UseRumbleFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_UseRumble", "$ostim_use_rumble", Main.UseRumble, UseRumbleFlags)

	SetCursorPosition(1)
	AddColoredHeader("$ostim_header_osa_keys")
	SetCursorPosition(3)
	AddKeyMapOptionST("OID_OSA_KeyUp", "$ostim_osaKeys_up", Main.KeyUp)
	SetCursorPosition(5)
	AddKeyMapOptionST("OID_OSA_KeyDown", "$ostim_osaKeys_down", Main.KeyDown)
	SetCursorPosition(7)
	AddKeyMapOptionST("OID_OSA_KeyLeft", "$ostim_osaKeys_left", Main.KeyLeft)
	SetCursorPosition(9)
	AddKeyMapOptionST("OID_OSA_KeyRight", "$ostim_osaKeys_right", Main.KeyRight)
	SetCursorPosition(11)
	AddKeyMapOptionST("OID_OSA_KeyTog", "$ostim_osaKeys_tog", Main.KeyToggle)
	SetCursorPosition(13)
	AddKeyMapOptionST("OID_OSA_KeyYes", "$ostim_osaKeys_yes", Main.KeyYes)
	SetCursorPosition(15)
	AddKeyMapOptionST("OID_OSA_KeyEnd", "$ostim_osaKeys_end", Main.KeyEnd)
	SetCursorPosition(17)
	AddToggleOptionST("OID_OSA_ResetKeys", "$ostim_osaKeys_reset", false)
EndFunction


State OID_KeyMain
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_main_key")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyMap = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeyNPCStart
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_npc_start_key")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyNPCStart = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeySpeedUp
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_speed_up_key")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.SpeedUpKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeySpeedDown
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_speed_down_key")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.SpeedDownKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeyPullOut
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_pullout_key")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.PullOutKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeyControlToggle
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_control_toggle_key")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.ControlToggleKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeyFreeCamToggle
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_tfc_key")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.FreecamKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeySearchMenu
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_key_search_menu")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.SearchKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeyAlignmentMenu
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_key_alignment_menu")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.AlignmentKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_KeyHideUI
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_key_hide_ui")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.HideUIKey = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState


State OID_OSA_KeyUp
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_osa_up")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyUp = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_OSA_KeyDown
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_osa_down")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyDown= KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_OSA_KeyLeft
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_osa_left")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyLeft = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_OSA_KeyRight
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_osa_right")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyRight = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_OSA_KeyTog
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_osa_tog")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyToggle = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_OSA_KeyYes
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_osa_yes")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyYes = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_OSA_KeyEnd
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_osa_end")
	EndEvent

	Event OnKeyMapChangeST(int KeyCode, string ConflictControl, string ConflictName)
		Main.KeyEnd = KeyCode
		SetKeyMapOptionValueST(KeyCode)
	EndEvent
EndState

State OID_OSA_ResetKeys
	Event OnHighlightST()
		SetInfoText("")
	EndEvent

	Event OnSelectST()
		Main.KeyUp = osaUpKeyDefault
		SetKeyMapOptionValueST(osaUpKeyDefault, false, "OID_OSA_KeyUp")

		Main.KeyDown = osaDownKeyDefault
		SetKeyMapOptionValueST(osaDownKeyDefault, false, "OID_OSA_KeyDown")

		Main.KeyLeft = osaLeftKeyDefault
		SetKeyMapOptionValueST(osaLeftKeyDefault, false, "OID_OSA_KeyLeft")

		Main.KeyRight = osaRightKeyDefault
		SetKeyMapOptionValueST(osaRightKeyDefault, false, "OID_OSA_KeyRight")

		Main.KeyToggle = osaTogKeyDefault
		SetKeyMapOptionValueST(osaTogKeyDefault, false, "OID_OSA_KeyTog")

		Main.KeyYes = osaYesKeyDefault
		SetKeyMapOptionValueST(osaYesKeyDefault, false, "OID_OSA_KeyYes")

		Main.KeyEnd = osaEndKeyDefault
		SetKeyMapOptionValueST(osaEndKeyDefault, false, "OID_OSA_KeyEnd")

		ShowMessage("$ostim_message_reset_osa_keys", false)
	EndEvent
EndState


State OID_UseRumble
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_rumble")
	EndEvent

	Event OnSelectST()
		Main.UseRumble = !Main.UseRumble
		SetToggleOptionValueST(Main.UseRumble)
	EndEvent
EndState


;  █████╗ ██╗   ██╗████████╗ ██████╗      ██████╗ ██████╗ ███╗   ██╗████████╗██████╗  ██████╗ ██╗
; ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗██║
; ███████║██║   ██║   ██║   ██║   ██║    ██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║██║
; ██╔══██║██║   ██║   ██║   ██║   ██║    ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║██║
; ██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║╚██████╔╝███████╗
; ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

Function DrawAutoControlPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddColoredHeader("$ostim_header_auto_speed_control")
	SetCursorPosition(2)
	AddToggleOptionST("OID_AutoSpeedControl", "$ostim_auto_speed_control", Main.EnableActorSpeedControl)
	SetCursorPosition(4)
	AddSliderOptionST("OID_AutoSpeedControlIntervalMin", "$ostim_auto_speed_control_interval_min", Main.AutoSpeedControlIntervalMin / 1000.0, "{1} s")
	SetCursorPosition(6)
	AddSliderOptionST("OID_AutoSpeedControlIntervalMax", "$ostim_auto_speed_control_interval_max", Main.AutoSpeedControlIntervalMax / 1000.0, "{1} s")
	SetCursorPosition(8)
	AddSliderOptionST("OID_AutoSpeedControlExcitementMin", "$ostim_auto_speed_control_excitement_min", Main.AutoSpeedControlExcitementMin, "{0}")
	SetCursorPosition(10)
	AddSliderOptionST("OID_AutoSpeedControlExcitementMax", "$ostim_auto_speed_control_excitement_max", Main.AutoSpeedControlExcitementMax, "{0}")

	SetCursorPosition(14)
	AddColoredHeader("$ostim_header_npc_scenes")
	SetCursorPosition(16)
	AddSliderOptionST("OID_NPCSceneDuration", "$ostim_npc_scene_duration", Main.NPCSceneDuration / 1000, "{0} s")
	SetCursorPosition(18)
	AddToggleOptionST("OID_EndNPCSceneOnOrgasm", "$ostim_end_npc_scene_on_orgasm", Main.EndNPCSceneOnOrgasm)

	SetCursorPosition(22)
	AddColoredHeader("$ostim_header_auto_navigation")
	SetCursorPosition(24)
	AddSliderOptionST("OID_NavigationDistanceMax", "$ostim_navigation_distance_max", Main.NavigationDistanceMax, "{0}")

	SetCursorPosition(1)
	AddColoredHeader("$ostim_header_auto_mode_toggle")
	SetCursorPosition(3)
	AddToggleOptionST("OID_UseAutoModeAlways", "$ostim_use_auto_mode_always", Main.UseAIControl)
	SetCursorPosition(5)
	int UseAutoModeConditionalFlags = OPTION_FLAG_NONE
	If Main.UseAIControl
		UseAutoModeConditionalFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_UseAutoModeSolo", "$ostim_use_auto_mode_solo", Main.UseAIMasturbation, UseAutoModeConditionalFlags)
	SetCursorPosition(7)
	AddToggleOptionST("OID_UseAutoModeDominant", "$ostim_use_auto_mode_dominant", Main.UseAIPlayerAggressor, UseAutoModeConditionalFlags)
	SetCursorPosition(9)
	AddToggleOptionST("OID_UseAutoModeSubmissive", "$ostim_use_auto_mode_submissive", Main.UseAIPlayerAggressed, UseAutoModeConditionalFlags)
	SetCursorPosition(11)
	AddToggleOptionST("OID_UseAutoModeVanilla", "$ostim_use_auto_mode_vanilla", Main.UseAINonAggressive, UseAutoModeConditionalFlags)

	SetCursorPosition(15)
	AddColoredHeader("$ostim_header_auto_mode_settings")
	SetCursorPosition(17)
	AddToggleOptionST("OID_AutoModeLimitToNavigationDistance", "$ostim_auto_mode_limit_to_navigation_distance", Main.AutoModeLimitToNavigationDistance)
	SetCursorPosition(19)
	int AutoModeUseFadesFlags = OPTION_FLAG_NONE
	If Main.AutoModeLimitToNavigationDistance
		AutoModeUseFadesFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_UseAutoModeFades", "$ostim_use_auto_mode_fades", Main.UseAutoFades, AutoModeUseFadesFlags)
	SetCursorPosition(21)
	AddSliderOptionST("OID_AutoModeAnimDurationMin", "$ostim_auto_mode_anim_duration_min", Main.AutoModeAnimDurationMin / 1000.0, "{1} s")
	SetCursorPosition(23)
	AddSliderOptionST("OID_AutoModeAnimDurationMax", "$ostim_auto_mode_anim_duration_max", Main.AutoModeAnimDurationMax / 1000.0, "{1} s")
	SetCursorPosition(25)
	AddSliderOptionST("OID_AutoModeForeplayChance", "$ostim_auto_mode_foreplay_chance", Main.AutoModeForeplayChance, "{0} %")
	SetCursorPosition(27)
	AddSliderOptionST("OID_AutoModeForeplayThresholdMin", "$ostim_auto_mode_foreplay_threshold_min", Main.AutoModeForeplayThresholdMin, "{0}")
	SetCursorPosition(29)
	AddSliderOptionST("OID_AutoModeForeplayThresholdMax", "$ostim_auto_mode_foreplay_threshold_max", Main.AutoModeForeplayThresholdMax, "{0}")
	SetCursorPosition(31)
	AddSliderOptionST("OID_AutoModePulloutChance", "$ostim_auto_mode_pullout_chance", Main.AutoModePulloutChance, "{0} %")
	SetCursorPosition(33)
	AddSliderOptionST("OID_AutoModePulloutThresholdMin", "$ostim_auto_mode_pullout_threshold_min", Main.AutoModePulloutThresholdMin, "{0}")
	SetCursorPosition(35)
	AddSliderOptionST("OID_AutoModePulloutThresholdMax", "$ostim_auto_mode_pullout_threshold_max", Main.AutoModePulloutThresholdMax, "{0}")
EndFunction


State OID_AutoSpeedControl
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_speed_control")
	EndEvent

	Event OnSelectST()
		Main.EnableActorSpeedControl = !Main.EnableActorSpeedControl
		SetToggleOptionValueST(Main.EnableActorSpeedControl)
	EndEvent
EndState

State OID_AutoSpeedControlIntervalMin
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_speed_control_interval_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoSpeedControlIntervalMin / 1000.0)
		SetSliderDialogDefaultValue(2.5)
		SetSliderDialogRange(0, 10)
		SetSliderDialogInterval(0.5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoSpeedControlIntervalMin = (Value * 1000) as int
		SetSliderOptionValueST(Main.AutoSpeedControlIntervalMin / 1000.0, "{1} s")
		SetSliderOptionValueST(Main.AutoSpeedControlIntervalMax / 1000.0, "{1} s", false, "OID_AutoSpeedControlIntervalMax")
	EndEvent
EndState

State OID_AutoSpeedControlIntervalMax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_speed_control_interval_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoSpeedControlIntervalMax / 1000.0)
		SetSliderDialogDefaultValue(7.5)
		SetSliderDialogRange(0, 10)
		SetSliderDialogInterval(0.5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoSpeedControlIntervalMax = (Value * 1000) as int
		SetSliderOptionValueST(Main.AutoSpeedControlIntervalMin / 1000.0, "{1} s", false, "OID_AutoSpeedControlIntervalMin")
		SetSliderOptionValueST(Main.AutoSpeedControlIntervalMax / 1000.0, "{1} s")
	EndEvent
EndState

State OID_AutoSpeedControlExcitementMin
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_speed_control_excitement_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoSpeedControlExcitementMin)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoSpeedControlExcitementMin = Value as int
		SetSliderOptionValueST(Main.AutoSpeedControlExcitementMin, "{0}")
		SetSliderOptionValueST(Main.AutoSpeedControlExcitementMax, "{0}", false, "OID_AutoSpeedControlExcitementMax")
	EndEvent
EndState

State OID_AutoSpeedControlExcitementMax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_speed_control_excitement_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoSpeedControlExcitementMax)
		SetSliderDialogDefaultValue(80)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoSpeedControlExcitementMax = Value as int
		SetSliderOptionValueST(Main.AutoSpeedControlExcitementMin, "{0}", false, "OID_AutoSpeedControlExcitementMin")
		SetSliderOptionValueST(Main.AutoSpeedControlExcitementMax, "{0}")
	EndEvent
EndState


State OID_NPCSceneDuration
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_npc_scene_duration")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.NPCSceneDuration / 1000)
		SetSliderDialogDefaultValue(300)
		SetSliderDialogRange(0, 600)
		SetSliderDialogInterval(15)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.NPCSceneDuration = (Value * 1000) as int
		SetSliderOptionValueST(Value, "{1} s")
	EndEvent
EndState

State OID_EndNPCSceneOnOrgasm
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_end_npc_scene_on_orgasm")
	EndEvent

	Event OnSelectST()
		Main.EndNPCSceneOnOrgasm = !Main.EndNPCSceneOnOrgasm
		SetToggleOptionValueST(Main.EndNPCSceneOnOrgasm)
	EndEvent
EndState


State OID_NavigationDistanceMax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_navigation_distance_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.NavigationDistanceMax)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 20)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.NavigationDistanceMax = Value As int
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState


State OID_UseAutoModeAlways
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_auto_mode_always")
	EndEvent

	Event OnSelectST()
		Main.UseAIControl = !Main.UseAIControl
		SetToggleOptionValueST(Main.UseAIControl)

		int UseAutoModeConditionalFlags = OPTION_FLAG_NONE
		If Main.UseAIControl
			UseAutoModeConditionalFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(UseAutoModeConditionalFlags, false, "OID_UseAutoModeSolo")
		SetOptionFlagsST(UseAutoModeConditionalFlags, false, "OID_UseAutoModeDominant")
		SetOptionFlagsST(UseAutoModeConditionalFlags, false, "OID_UseAutoModeSubmissive")
		SetOptionFlagsST(UseAutoModeConditionalFlags, false, "OID_UseAutoModeVanilla")
	EndEvent
EndState

State OID_UseAutoModeSolo
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_auto_mode_solo")
	EndEvent

	Event OnSelectST()
		Main.UseAIMasturbation = !Main.UseAIMasturbation
		SetToggleOptionValueST(Main.UseAIMasturbation)
	EndEvent
EndState

State OID_UseAutoModeDominant
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_auto_mode_dominant")
	EndEvent

	Event OnSelectST()
		Main.UseAIPlayerAggressor = !Main.UseAIPlayerAggressor
		SetToggleOptionValueST(Main.UseAIPlayerAggressor)
	EndEvent
EndState

State OID_UseAutoModeSubmissive
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_auto_mode_submissive")
	EndEvent

	Event OnSelectST()
		Main.UseAIPlayerAggressed = !Main.UseAIPlayerAggressed
		SetToggleOptionValueST(Main.UseAIPlayerAggressed)
	EndEvent
EndState

State OID_UseAutoModeVanilla
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_auto_mode_vanilla")
	EndEvent

	Event OnSelectST()
		Main.UseAINonAggressive = !Main.UseAINonAggressive
		SetToggleOptionValueST(Main.UseAINonAggressive)
	EndEvent
EndState


State OID_AutoModeLimitToNavigationDistance
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_mode_limit_to_navigation_distance")
	EndEvent

	Event OnSelectST()
		Main.AutoModeLimitToNavigationDistance = !Main.AutoModeLimitToNavigationDistance
		SetToggleOptionValueST(Main.AutoModeLimitToNavigationDistance)

		int AutoModeUseFadesFlags = OPTION_FLAG_NONE
		If Main.AutoModeLimitToNavigationDistance
			AutoModeUseFadesFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(AutoModeUseFadesFlags, false, "OID_UseAutoModeFades")
	EndEvent
EndState

State OID_UseAutoModeFades
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_auto_mode_fades")
	EndEvent

	Event OnSelectST()
		Main.UseAutoFades = !Main.UseAutoFades
		SetToggleOptionValueST(Main.UseAutoFades)
	EndEvent
EndState

State OID_AutoModeAnimDurationMin
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_anim_duration_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModeAnimDurationMin / 1000.0)
		SetSliderDialogDefaultValue(7.5)
		SetSliderDialogRange(2.5, 60)
		SetSliderDialogInterval(2.5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModeAnimDurationMin = (Value * 1000) as int
		SetSliderOptionValueST(Main.AutoModeAnimDurationMin / 1000.0, "{1} s")
		SetSliderOptionValueST(Main.AutoModeAnimDurationMax / 1000.0, "{1} s", false, "OID_AutoModeAnimDurationMax")
	EndEvent
EndState

State OID_AutoModeAnimDurationMax
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_anim_duration_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModeAnimDurationMax / 1000.0)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(2.5, 60)
		SetSliderDialogInterval(2.5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModeAnimDurationMax = (Value * 1000) as int
		SetSliderOptionValueST(Main.AutoModeAnimDurationMin / 1000.0, "{1} s", false, "OID_AutoModeAnimDurationMin")
		SetSliderOptionValueST(Main.AutoModeAnimDurationMax / 1000.0, "{1} s")
	EndEvent
EndState

State OID_AutoModeForeplayChance
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_foreplay_chance")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModeForeplayChance)
		SetSliderDialogDefaultValue(35)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModeForeplayChance = Value as int
		SetSliderOptionValueST(Value, "{0} %")
	EndEvent
EndState

State OID_AutoModeForeplayThresholdMin
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_foreplay_threshold_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModeForeplayThresholdMin)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModeForeplayThresholdMin = Value as int
		SetSliderOptionValueST(Main.AutoModeForeplayThresholdMin, "{0}")
		SetSliderOptionValueST(Main.AutoModeForeplayThresholdMax, "{0}", false, "OID_AutoModeForeplayThresholdMax")
	EndEvent
EndState

State OID_AutoModeForeplayThresholdMax
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_foreplay_threshold_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModeForeplayThresholdMax)
		SetSliderDialogDefaultValue(35)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModeForeplayThresholdMax = Value as int
		SetSliderOptionValueST(Main.AutoModeForeplayThresholdMin, "{0}", false, "OID_AutoModeForeplayThresholdMin")
		SetSliderOptionValueST(Main.AutoModeForeplayThresholdMax, "{0}")
	EndEvent
EndState

State OID_AutoModePulloutChance
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_pullout_chance")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModePulloutChance)
		SetSliderDialogDefaultValue(75)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModePulloutChance = Value as int
		SetSliderOptionValueST(Value, "{0} %")
	EndEvent
EndState

State OID_AutoModePulloutThresholdMin
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_pullout_threshold_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModePulloutThresholdMin)
		SetSliderDialogDefaultValue(80)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModePulloutThresholdMin = Value as int
		SetSliderOptionValueST(Main.AutoModePulloutThresholdMin, "{0}")
		SetSliderOptionValueST(Main.AutoModePulloutThresholdMax, "{0}", false, "OID_AutoModePulloutThresholdMax")
	EndEvent
EndState

State OID_AutoModePulloutThresholdMax
	Event OnHighlightST()
		SetInfoText("$ostim_auto_mode_pullout_threshold_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.AutoModePulloutThresholdMax)
		SetSliderDialogDefaultValue(90)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.AutoModePulloutThresholdMax = Value as int
		SetSliderOptionValueST(Main.AutoModePulloutThresholdMin, "{0}", false, "OID_AutoModePulloutThresholdMin")
		SetSliderOptionValueST(Main.AutoModePulloutThresholdMax, "{0}")
	EndEvent
EndState


;  ██████╗ █████╗ ███╗   ███╗███████╗██████╗  █████╗
; ██╔════╝██╔══██╗████╗ ████║██╔════╝██╔══██╗██╔══██╗
; ██║     ███████║██╔████╔██║█████╗  ██████╔╝███████║
; ██║     ██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██║
; ╚██████╗██║  ██║██║ ╚═╝ ██║███████╗██║  ██║██║  ██║
;  ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝

Function DrawCameraPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddColoredHeader("$ostim_header_freecam")
	SetCursorPosition(2)
	AddToggleOptionST("OID_UseFreeCam", "$ostim_freecam", Main.UseFreeCam)
	SetCursorPosition(4)
	AddSliderOptionST("OID_FreeCamFOV", "$ostim_freecam_fov", Main.FreecamFOV, "{0}")
	SetCursorPosition(6)
	AddSliderOptionST("OID_FreeCamSpeed", "$ostim_freecam_speed", Main.FreecamSpeed, "{1}")

	SetCursorPosition(1)
	AddToggleOptionST("OUD_UseScreenShake", "$ostim_screenshake", Main.UseScreenShake)
	SetCursorPosition(3)
	AddToggleOptionST("OID_ForceFirstPersonOnEnd", "$ostim_force_first", Main.ForceFirstPersonAfter)
EndFunction

State OID_UseFreeCam
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_fc")
	EndEvent

	Event OnSelectST()
		Main.UseFreeCam = !Main.UseFreeCam
		SetToggleOptionValueST(Main.UseFreeCam)
	EndEvent
EndState

State OID_FreeCamFOV
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_fov")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MaleSexExcitementMult)
		SetSliderDialogDefaultValue(45)
		SetSliderDialogRange(1, 120)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.FreecamFOV = Value As int
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState

State OID_FreeCamSpeed
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_fc_speed")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MaleSexExcitementMult)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(0.5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.FreecamSpeed = Value
		SetSliderOptionValueST(Value, "{1}")
	EndEvent
EndState


State OUD_UseScreenShake
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_screen_shake")
	EndEvent

	Event OnSelectST()
		Main.UseScreenShake = !Main.UseScreenShake
		SetToggleOptionValueST(Main.UseScreenShake)
	EndEvent
EndState

State OID_ForceFirstPersonOnEnd
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_force_first")
	EndEvent

	Event OnSelectST()
		Main.ForceFirstPersonAfter = !Main.ForceFirstPersonAfter
		SetToggleOptionValueST(Main.ForceFirstPersonAfter)
	EndEvent
EndState


; ███████╗██╗  ██╗ ██████╗██╗████████╗███████╗███╗   ███╗███████╗███╗   ██╗████████╗
; ██╔════╝╚██╗██╔╝██╔════╝██║╚══██╔══╝██╔════╝████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
; █████╗   ╚███╔╝ ██║     ██║   ██║   █████╗  ██╔████╔██║█████╗  ██╔██╗ ██║   ██║
; ██╔══╝   ██╔██╗ ██║     ██║   ██║   ██╔══╝  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║
; ███████╗██╔╝ ██╗╚██████╗██║   ██║   ███████╗██║ ╚═╝ ██║███████╗██║ ╚████║   ██║
; ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝

int OID_PostOrgasmExcitement = -1
int OID_PostOrgasmExcitementMax = -1

Function DrawExcitementPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddColoredHeader("$ostim_header_excitement_calculation")
	SetCursorPosition(2)
	AddSliderOptionST("OID_MaleExcitementMult", "$ostim_excitement_mult_male", Main.MaleSexExcitementMult, "{1} x")
	SetCursorPosition(4)
	AddSliderOptionST("OID_FemaleExcitementMult", "$ostim_excitement_mult_female", Main.FemaleSexExcitementMult, "{1} x")
	SetCursorPosition(6)
	AddSliderOptionST("OID_ExcitementDecayRate", "$ostim_excitement_decay_rate", Main.ExcitementDecayRate, "{2} /s")
	SetCursorPosition(8)
	AddSliderOptionST("OID_ExcitementDecayGracePeriod", "$ostim_excitement_decay_grace_period", Main.ExcitementDecayGracePeriod / 1000, "{1} s")
	SetCursorPosition(10)
	OID_PostOrgasmExcitement = AddSliderOption("$ostim_post_orgasm_excitement", Main.PostOrgasmExcitement, "{0}")
	SetCursorPosition(12)
	OID_PostOrgasmExcitementMax = AddSliderOption("$ostim_post_orgasm_excitement_max", Main.PostOrgasmExcitementMax, "{0}")

	SetCursorPosition(16)
	AddColoredHeader("$ostim_header_excitement_bars")
	SetCursorPosition(18)
	AddToggleOptionST("OID_EnablePlayerBar", "$ostim_player_bar", Main.EnablePlayerBar)
	SetCursorPosition(20)
	AddToggleOptionST("OID_EnableNpcBar", "$ostim_npc_bar", Main.EnableNpcBar)
	SetCursorPosition(22)
	AddToggleOptionST("OID_AutoHideBar", "$ostim_auto_hide_bar", Main.AutoHideBars)
	SetCursorPosition(24)
	AddToggleOptionST("OID_MatchBarColorToGender", "$ostim_match_color_gender", Main.MatchBarColorToGender)

	SetCursorPosition(1)
	AddColoredHeader("$ostim_header_orgasms")
	SetCursorPosition(3)
	int EndOnSingleOrgasmFlags = OPTION_FLAG_NONE
	If Main.EndOnAllOrgasm
		EndOnSingleOrgasmFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_EndOnPlayerOrgasm", "$ostim_orgasm_end_player", Main.EndOnPlayerOrgasm, EndOnSingleOrgasmFlags)
	SetCursorPosition(5)
	AddToggleOptionST("OID_EndOnMaleOrgasm", "$ostim_orgasm_end_male", Main.EndOnMaleOrgasm, EndOnSingleOrgasmFlags)
	SetCursorPosition(7)
	AddToggleOptionST("OID_EndOnFemaleOrgasm", "$ostim_orgasm_end_female", Main.EndOnFemaleOrgasm, EndOnSingleOrgasmFlags)
	SetCursorPosition(9)
	AddToggleOptionST("OID_EndOnAllOrgasm", "$ostim_orgasm_end_all", Main.EndOnAllOrgasm)
	SetCursorPosition(11)
	AddToggleOptionST("OID_SlowMoOnOrgasm", "$ostim_slowmo_orgasm", Main.SlowMoOnOrgasm)
	SetCursorPosition(13)
	AddToggleOptionST("OID_BlurOnOrgasm", "$ostim_blur_orgasm", Main.BlurOnOrgasm)
	SetCursorPosition(15)
	AddToggleOptionST("OID_AutoClimaxAnimations", "$ostim_auto_climax_anims", Main.AutoClimaxAnimations)
EndFunction

Function OnOptionHighlightExcitement(int Option)
	If Option == OID_PostOrgasmExcitement
		SetInfoText("$ostim_tooltip_post_orgasm_excitement")
	ElseIf Option == OID_PostOrgasmExcitementMax
		SetInfoText("$ostim_tooltip_post_orgasm_excitement_max")
	EndIf
EndFunction

Function OnOptionSliderOpenExcitement(int Option)
	If Option == OID_PostOrgasmExcitement
		SetSliderDialogStartValue(Main.PostOrgasmExcitement)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	ElseIf Option == OID_PostOrgasmExcitementMax
		SetSliderDialogStartValue(Main.PostOrgasmExcitementMax)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	EndIf
EndFunction

Function OnOptionSliderAcceptExcitement(int Option, float Value)
	If Option == OID_PostOrgasmExcitement
		Main.PostOrgasmExcitement = Value as int
		SetSliderOptionValue(Option, Main.PostOrgasmExcitement, "{0}")
	ElseIf Option == OID_PostOrgasmExcitementMax
		Main.PostOrgasmExcitementMax = Value as int
		SetSliderOptionValue(Option, Main.PostOrgasmExcitementMax, "{0}")
	EndIf
EndFunction


State OID_MaleExcitementMult
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_excitement_mult_male")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MaleSexExcitementMult)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0.1, 3.0)
		SetSliderDialogInterval(0.1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.MaleSexExcitementMult = Value
		SetSliderOptionValueST(Value, "{1} x")
	EndEvent
EndState

State OID_FemaleExcitementMult
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_excitement_mult_female")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.FemaleSexExcitementMult)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0.1, 3.0)
		SetSliderDialogInterval(0.1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.FemaleSexExcitementMult = Value
		SetSliderOptionValueST(Value, "{1} x")
	EndEvent
EndState

State OID_ExcitementDecayRate
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_excitement_decay_rate")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.ExcitementDecayRate)
		SetSliderDialogDefaultValue(0.5)
		SetSliderDialogRange(0.1, 5.0)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.ExcitementDecayRate = Value
		SetSliderOptionValueST(Value, "{2} /s")
	EndEvent
EndState

State OID_ExcitementDecayGracePeriod
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_excitement_decay_grace_period")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.ExcitementDecayGracePeriod / 1000)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0.0, 20.0)
		SetSliderDialogInterval(0.5)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.ExcitementDecayGracePeriod = (Value * 1000) as int
		SetSliderOptionValueST(Value, "{1} s")
	EndEvent
EndState


State OID_EnablePlayerBar
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_player_bar")
	EndEvent

	Event OnSelectST()
		Main.EnablePlayerBar = !Main.EnablePlayerBar
		SetToggleOptionValueST(Main.EnablePlayerBar)
	EndEvent
EndState

State OID_EnableNPCBar
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_npc_bar")
	EndEvent

	Event OnSelectST()
		Main.EnableNpcBar = !Main.EnableNpcBar
		SetToggleOptionValueST(Main.EnableNpcBar)
	EndEvent
EndState

State OID_AutoHideBar
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_hide_bar")
	EndEvent

	Event OnSelectST()
		Main.AutoHideBars = !Main.AutoHideBars
		SetToggleOptionValueST(Main.AutoHideBars)
	EndEvent
EndState

State OID_MatchBarColorToGender
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_gendered_colors")
	EndEvent

	Event OnSelectST()
		Main.MatchBarColorToGender = !Main.MatchBarColorToGender
		SetToggleOptionValueST(Main.MatchBarColorToGender)
	EndEvent
EndState


State OID_EndOnPlayerOrgasm
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_orgasm_end_player")
	EndEvent

	Event OnSelectST()
		Main.EndOnplayerOrgasm = !Main.EndOnplayerOrgasm
		SetToggleOptionValueST(Main.EndOnplayerOrgasm)
	EndEvent
EndState

State OID_EndOnMaleOrgasm
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_orgasm_end_male")
	EndEvent

	Event OnSelectST()
		Main.EndOnMaleOrgasm = !Main.EndOnMaleOrgasm
		SetToggleOptionValueST(Main.EndOnMaleOrgasm)
	EndEvent
EndState

State OID_EndOnFemaleOrgasm
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_orgasm_end_female")
	EndEvent

	Event OnSelectST()
		Main.EndOnFemaleOrgasm = !Main.EndOnFemaleOrgasm
		SetToggleOptionValueST(Main.EndOnFemaleOrgasm)
	EndEvent
EndState

State OID_EndOnAllOrgasm
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_orgasm_end_all")
	EndEvent

	Event OnSelectST()
		Main.EndOnAllOrgasm = !Main.EndOnAllOrgasm
		SetToggleOptionValueST(Main.EndOnAllOrgasm)

		int EndOnSingleOrgasmFlags = OPTION_FLAG_NONE
		If Main.EndOnAllOrgasm
			EndOnSingleOrgasmFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(EndOnSingleOrgasmFlags, false, "OID_EndOnPlayerOrgasm")
		SetOptionFlagsST(EndOnSingleOrgasmFlags, false, "OID_EndOnMaleOrgasm")
		SetOptionFlagsST(EndOnSingleOrgasmFlags, false, "OID_EndOnFemaleOrgasm")
	EndEvent
EndState

State OID_SlowMoOnOrgasm
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_slowmo_orgasms")
	EndEvent

	Event OnSelectST()
		Main.SlowMoOnOrgasm = !Main.SlowMoOnOrgasm
		SetToggleOptionValueST(Main.SlowMoOnOrgasm)
	EndEvent
EndState

State OID_BlurOnOrgasm
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_blur_orgasms")
	EndEvent

	Event OnSelectST()
		Main.BlurOnOrgasm = !Main.BlurOnOrgasm
		SetToggleOptionValueST(Main.BlurOnOrgasm)
	EndEvent
EndState

State OID_AutoClimaxAnimations
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_auto_climax_anims")
	EndEvent

	Event OnSelectST()
		Main.AutoClimaxAnimations = !Main.AutoClimaxAnimations
		SetToggleOptionValueST(Main.AutoClimaxAnimations)
	EndEvent
EndState


;  ██████╗ ███████╗███╗   ██╗██████╗ ███████╗██████╗     ██████╗  ██████╗ ██╗     ███████╗███████╗
; ██╔════╝ ██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗    ██╔══██╗██╔═══██╗██║     ██╔════╝██╔════╝
; ██║  ███╗█████╗  ██╔██╗ ██║██║  ██║█████╗  ██████╔╝    ██████╔╝██║   ██║██║     █████╗  ███████╗
; ██║   ██║██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██╔══██╗    ██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║
; ╚██████╔╝███████╗██║ ╚████║██████╔╝███████╗██║  ██║    ██║  ██║╚██████╔╝███████╗███████╗███████║
;  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝

Function DrawGenderRolesPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddColoredHeader("$ostim_header_animation_settings")
	SetCursorPosition(2)
	AddToggleOptionST("OID_IntendedSexOnly", "$ostim_intended_sex_only", Main.IntendedSexOnly)

	SetCursorPosition(6)
	AddColoredHeader("$ostim_header_player_roles")
	SetCursorPosition(8)
	int PlayerAlwaysDomStraightFlags = OPTION_FLAG_NONE
	If Main.PlayerSelectRoleStraight
		PlayerAlwaysDomStraightFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_PlayerAlwaysDomStraight", "$ostim_always_dom_straight", Main.PlayerAlwaysDomStraight, PlayerAlwaysDomStraightFlags)
	SetCursorPosition(10)
	int PlayerAlwaysSubStraightFlags = OPTION_FLAG_NONE
	If Main.PlayerSelectRoleStraight || Main.PlayerAlwaysDomStraight
		PlayerAlwaysSubStraightFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_PlayerAlwaysSubStraight", "$ostim_always_sub_straight", Main.PlayerAlwaysSubStraight, PlayerAlwaysSubStraightFlags)
	SetCursorPosition(12)
	int PlayerAlwaysDomGayFlags = OPTION_FLAG_NONE
	If Main.PlayerSelectRoleGay
		PlayerAlwaysDomGayFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_PlayerAlwaysDomGay", "$ostim_always_dom_gay", Main.PlayerAlwaysDomGay, PlayerAlwaysDomGayFlags)
	SetCursorPosition(14)
	int PlayerAlwaysSubGayFlags = OPTION_FLAG_NONE
	If Main.PlayerSelectRoleGay || Main.PlayerAlwaysDomGay
		PlayerAlwaysSubGayFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_PlayerAlwaysSubGay", "$ostim_always_sub_gay", Main.PlayerAlwaysSubGay, PlayerAlwaysSubGayFlags)
	SetCursorPosition(16)
	AddToggleOptionST("OID_PlayerSelectRoleStraight", "$ostim_select_role_straight", Main.PlayerSelectRoleStraight)
	SetCursorPosition(18)
	AddToggleOptionST("OID_PlayerSelectRoleGay", "$ostim_select_role_gay", Main.PlayerSelectRoleGay)
	SetCursorPosition(20)
	AddToggleOptionST("OID_PlayerSelectRoleThreesome", "$ostim_select_role_threesome", Main.PlayerSelectRoleThreesome)


	SetCursorPosition(1)
	AddColoredHeader("$ostim_header_strap_ons")
	SetCursorPosition(3)
	AddToggleOptionST("OID_UnequipStrapOnIfNotNeeded", "$ostim_unequip_strap_on_if_not_needed", Main.UnequipStrapOnIfNotNeeded)

	SetCursorPosition(7)
	AddMenuOptionST("OID_DefaultStrapOn", "$ostim_default_strap_on", OData.GetEquipObjectName(0x1, "strapon"))
	SetCursorPosition(9)
	AddMenuOptionST("OID_PlayerStrapOn", "$ostim_player_strap_on", OData.GetEquipObjectName(0x7, "strapon"))

	SetCursorPosition(13)
	AddColoredHeader("$ostim_header_futanari")
	SetCursorPosition(15)
	int UseSoSSexFlags = OPTION_FLAG_NONE
	If !Main.SoSInstalled
		UseSoSSexFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_UseSoSSex", "$ostim_use_sos_sex", Main.UseSoSSex, UseSoSSexFlags)
	SetCursorPosition(17)
	int UseTNGSexFlags = OPTION_FLAG_NONE
	If !Main.TNGInstalled
		UseTNGSexFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_UseTNGSex", "$ostim_use_tng_sex", Main.UseTNGSex, UseTNGSexFlags)
	SetCursorPosition(19)
	int FutaUseMaleRoleFlags = OPTION_FLAG_NONE
	If !Main.IntendedSexOnly || (!Main.SoSInstalled || !Main.UseSoSSex) && (!Main.TNGInstalled || !Main.UseTNGSex)
		FutaUseMaleRoleFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_FutaUseMaleRole", "$ostim_futa_use_male_role", Main.FutaUseMaleRole, FutaUseMaleRoleFlags)
	SetCursorPosition(21)
	int FutaFlags = OPTION_FLAG_NONE
	If (!Main.SoSInstalled || !Main.UseSoSSex) && (!Main.TNGInstalled || !Main.UseTNGSex)
		FutaFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_FutaUseMaleExcitement", "$ostim_futa_use_male_excitement", Main.FutaUseMaleExcitement, FutaFlags)
	SetCursorPosition(23)
	AddToggleOptionST("OID_FutaUseMaleClimax", "$ostim_futa_use_male_orgasm", Main.FutaUseMaleClimax, FutaFlags)
EndFunction


State OID_IntendedSexOnly
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_intended_sex_only")
	EndEvent

	Event OnSelectST()
		Main.IntendedSexOnly = !Main.IntendedSexOnly
		SetToggleOptionValueST(Main.IntendedSexOnly)

		int FutaUseMaleRoleFlags = OPTION_FLAG_NONE
		If !Main.IntendedSexOnly || !Main.SoSInstalled || !Main.UseSoSSex
			FutaUseMaleRoleFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(FutaUseMaleRoleFlags, false, "OID_FutaUseMaleRole")
	EndEvent
EndState

State OID_PlayerAlwaysDomStraight
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_always_dom_straight")
	EndEvent

	Event OnSelectST()
		Main.PlayerAlwaysDomStraight = !Main.PlayerAlwaysDomStraight
		SetToggleOptionValueST(Main.PlayerAlwaysDomStraight)

		int PlayerAlwaysSubStraightFlags = OPTION_FLAG_NONE
		If Main.PlayerAlwaysDomStraight
			PlayerAlwaysSubStraightFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(PlayerAlwaysSubStraightFlags, false, "OID_PlayerAlwaysSubStraight")
	EndEvent
EndState

State OID_PlayerAlwaysSubStraight
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_always_sub_straight")
	EndEvent

	Event OnSelectST()
		Main.PlayerAlwaysSubStraight = !Main.PlayerAlwaysSubStraight
		SetToggleOptionValueST(Main.PlayerAlwaysSubStraight)
	EndEvent
EndState

State OID_PlayerAlwaysDomGay
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_always_dom_gay")
	EndEvent

	Event OnSelectST()
		Main.PlayerAlwaysDomGay = !Main.PlayerAlwaysDomGay
		SetToggleOptionValueST(Main.PlayerAlwaysDomGay)
		
		int PlayerAlwaysSubGayFlags = OPTION_FLAG_NONE
		If Main.PlayerAlwaysDomGay
			PlayerAlwaysSubGayFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(PlayerAlwaysSubGayFlags, false, "OID_PlayerAlwaysSubGay")
	EndEvent
EndState

State OID_PlayerAlwaysSubGay
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_always_sub_gay")
	EndEvent

	Event OnSelectST()
		Main.PlayerAlwaysSubGay = !Main.PlayerAlwaysSubGay
		SetToggleOptionValueST(Main.PlayerAlwaysSubGay)
	EndEvent
EndState

State OID_PlayerSelectRoleStraight
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_select_role_straight")
	EndEvent

	Event OnSelectST()
		Main.PlayerSelectRoleStraight = !Main.PlayerSelectRoleStraight
		SetToggleOptionValueST(Main.PlayerSelectRoleStraight)

		int PlayerAlwaysDomStraightFlags = OPTION_FLAG_NONE
		If Main.PlayerSelectRoleStraight
			PlayerAlwaysDomStraightFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(PlayerAlwaysDomStraightFlags, false, "OID_PlayerAlwaysDomStraight")

		int PlayerAlwaysSubStraightFlags = OPTION_FLAG_NONE
		If Main.PlayerSelectRoleStraight || Main.PlayerAlwaysDomStraight
			PlayerAlwaysSubStraightFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(PlayerAlwaysSubStraightFlags, false, "OID_PlayerAlwaysSubStraight")
	EndEvent
EndState

State OID_PlayerSelectRoleGay
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_select_role_gay")
	EndEvent

	Event OnSelectST()
		Main.PlayerSelectRoleGay = !Main.PlayerSelectRoleGay
		SetToggleOptionValueST(Main.PlayerSelectRoleGay)

		int PlayerAlwaysDomGayFlags = OPTION_FLAG_NONE
		If Main.PlayerSelectRoleGay
			PlayerAlwaysDomGayFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(PlayerAlwaysDomGayFlags, false, "OID_PlayerAlwaysDomGay")

		int PlayerAlwaysSubGayFlags = OPTION_FLAG_NONE
		If Main.PlayerSelectRoleGay || Main.PlayerAlwaysDomGay
			PlayerAlwaysSubGayFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(PlayerAlwaysSubGayFlags, false, "OID_PlayerAlwaysSubGay")
	EndEvent
EndState

State OID_PlayerSelectRoleThreesome
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_select_role_threesome")
	EndEvent

	Event OnSelectST()
		Main.PlayerSelectRoleThreesome = !Main.PlayerSelectRoleThreesome
		SetToggleOptionValueST(Main.PlayerSelectRoleThreesome)
	EndEvent
EndState


State OID_UnequipStrapOnIfNotNeeded
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_unequip_strap_on_if_not_needed")
	EndEvent

	Event OnSelectST()
		Main.UnequipStrapOnIfNotNeeded = !Main.UnequipStrapOnIfNotNeeded
		SetToggleOptionValueST(Main.UnequipStrapOnIfNotNeeded)

		int UnequipStrapOnIfInWayFlags = OPTION_FLAG_NONE
		If Main.UnequipStrapOnIfNotNeeded
			UnequipStrapOnIfInWayFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(UnequipStrapOnIfInWayFlags, false, "OID_UnequipStrapOnIfInWay")
	EndEvent
EndState

State OID_DefaultStrapOn
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_default_strap_on")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x1, "strapon")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x1, "strapon", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x1, "strapon")
	EndEvent
EndState

State OID_PlayerStrapOn
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_player_strap_on")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x7, "strapon")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x7, "strapon", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x7, "strapon")
	EndEvent
EndState


State OID_UseSoSSex
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_sos_sex")
	EndEvent

	Event OnSelectST()
		Main.UseSoSSex = !Main.UseSoSSex
		SetToggleOptionValueST(Main.UseSoSSex)

		int FutaUseMaleRoleFlags = OPTION_FLAG_NONE
		If !Main.IntendedSexOnly || !Main.UseSoSSex
			FutaUseMaleRoleFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(FutaUseMaleRoleFlags, false, "OID_FutaUseMaleRole")

		int FutaFlags = OPTION_FLAG_NONE
		If !Main.UseSoSSex
			FutaFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(FutaFlags, false, "OID_FutaUseMaleExcitement")
		SetOptionFlagsST(FutaFlags, false, "OID_FutaUseMaleClimax")
	EndEvent
EndState

State OID_UseTNGSex
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_use_tng_sex")
	EndEvent

	Event OnSelectST()
		Main.UseTNGSex = !Main.UseTNGSex
		SetToggleOptionValueST(Main.UseTNGSex)

		int FutaUseMaleRoleFlags = OPTION_FLAG_NONE
		If !Main.IntendedSexOnly || !Main.UseTNGSex
			FutaUseMaleRoleFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(FutaUseMaleRoleFlags, false, "OID_FutaUseMaleRole")

		int FutaFlags = OPTION_FLAG_NONE
		If !Main.UseTNGSex
			FutaFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(FutaFlags, false, "OID_FutaUseMaleExcitement")
		SetOptionFlagsST(FutaFlags, false, "OID_FutaUseMaleClimax")
	EndEvent
EndState

State OID_FutaUseMaleRole
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_futa_use_male_role")
	EndEvent

	Event OnSelectST()
		Main.FutaUseMaleRole = !Main.FutaUseMaleRole
		SetToggleOptionValueST(Main.FutaUseMaleRole)
	EndEvent
EndState

State OID_FutaUseMaleExcitement
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_futa_use_male_excitement")
	EndEvent

	Event OnSelectST()
		Main.FutaUseMaleExcitement = !Main.FutaUseMaleExcitement
		SetToggleOptionValueST(Main.FutaUseMaleExcitement)
	EndEvent
EndState

State OID_FutaUseMaleClimax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_futa_use_male_orgasm")
	EndEvent

	Event OnSelectST()
		Main.FutaUseMaleClimax = !Main.FutaUseMaleClimax
		SetToggleOptionValueST(Main.FutaUseMaleClimax)
	EndEvent
EndState


; ███████╗██╗   ██╗██████╗ ███╗   ██╗██╗████████╗██╗   ██╗██████╗ ███████╗
; ██╔════╝██║   ██║██╔══██╗████╗  ██║██║╚══██╔══╝██║   ██║██╔══██╗██╔════╝
; █████╗  ██║   ██║██████╔╝██╔██╗ ██║██║   ██║   ██║   ██║██████╔╝█████╗  
; ██╔══╝  ██║   ██║██╔══██╗██║╚██╗██║██║   ██║   ██║   ██║██╔══██╗██╔══╝  
; ██║     ╚██████╔╝██║  ██║██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║███████╗
; ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝

Function DrawFurniturePage()
	SetCursorPosition(0)
	AddToggleOptionST("OID_UseFurniture", "$ostim_use_furniture", Main.UseFurniture)
	SetCursorPosition(2)
	int FurnitureFlags = OPTION_FLAG_NONE
	If !Main.UseFurniture
		FurnitureFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_SelectFurniture", "$ostim_select_furniture", Main.SelectFurniture, FurnitureFlags)
	SetCursorPosition(4)
	AddSliderOptionST("OID_FurnitureSearchDistance", "$ostim_furniture_search_rad", Main.FurnitureSearchDistance, "{0} meters", FurnitureFlags)

	SetCursorPosition(8)
	AddToggleOptionST("OID_ResetClutter", "$ostim_reset_clutter", Main.ResetClutter, FurnitureFlags)
	SetCursorPosition(10)
	int ResetClutterRadiusFlags = OPTION_FLAG_NONE
	If !Main.UseFurniture || !Main.ResetClutter
		ResetClutterRadiusFlags = OPTION_FLAG_DISABLED
	EndIf
	AddSliderOptionST("OID_ResetClutterRadius", "$ostim_reset_clutter_radius", Main.ResetClutterRadius, "{0} meters", ResetClutterRadiusFlags)

	SetCursorPosition(14)
	AddSliderOptionST("OID_BedRealignment", "$ostim_bed_realignment", Main.BedRealignment, "{0} units", FurnitureFlags)
	SetCursorPosition(16)
	AddSliderOptionST("OID_BedOffset", "$ostim_bed_offset", Main.BedOffset, "{2} units", FurnitureFlags)
EndFunction

State OID_UseFurniture
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_enable_furniture")
	EndEvent

	Event OnSelectST()
		Main.UseFurniture = !Main.UseFurniture
		SetToggleOptionValueST(Main.UseFurniture)

		int FurnitureFlags = OPTION_FLAG_NONE
		If !Main.UseFurniture
			FurnitureFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(FurnitureFlags, false, "OID_SelectFurniture")
		SetOptionFlagsST(FurnitureFlags, false, "OID_FurnitureSearchDistance")
		SetOptionFlagsST(FurnitureFlags, false, "OID_ResetClutter")
		int ResetClutterRadiusFlags = OPTION_FLAG_NONE
		If !Main.UseFurniture || !Main.ResetClutter
			ResetClutterRadiusFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(ResetClutterRadiusFlags, false, "OID_ResetClutterRadius")
		SetOptionFlagsST(FurnitureFlags, false, "OID_BedRealignment")
		SetOptionFlagsST(FurnitureFlags, false, "OID_BedOffset")
	EndEvent
EndState

State OID_SelectFurniture
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_select_furniture")
	EndEvent

	Event OnSelectST()
		Main.SelectFurniture = !Main.SelectFurniture
		SetToggleOptionValueST(Main.SelectFurniture)
	EndEvent
EndState

State OID_FurnitureSearchDistance
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_furniture_search_dist")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.RemoveWeaponsWithSlot)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(1, 30)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.FurnitureSearchDistance = Value As int
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState


State OID_ResetClutter
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_reset_clutter")
	EndEvent

	Event OnSelectST()
		Main.ResetClutter = !Main.ResetClutter
		SetToggleOptionValueST(Main.ResetClutter)

		int ResetClutterRadiusFlags = OPTION_FLAG_NONE
		If !Main.UseFurniture || !Main.ResetClutter
			ResetClutterRadiusFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(ResetClutterRadiusFlags, false, "OID_ResetClutterRadius")
	EndEvent
EndState

State OID_ResetClutterRadius
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_reset_clutter_radius")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.RemoveWeaponsWithSlot)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(1, 30)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.ResetClutterRadius = Value As int
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState


State OID_BedRealignment
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_bed_realignment")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.BedRealignment)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-50, 50)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.BedRealignment = Value
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState

State OID_BedOffset
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_bed_offset")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.BedOffset)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(-10, 10)
		SetSliderDialogInterval(0.25)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.BedOffset = Value
		SetSliderOptionValueST(Value, "{2}")
	EndEvent
EndState


; ██╗   ██╗███╗   ██╗██████╗ ██████╗ ███████╗███████╗███████╗██╗███╗   ██╗ ██████╗ 
; ██║   ██║████╗  ██║██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝██║████╗  ██║██╔════╝ 
; ██║   ██║██╔██╗ ██║██║  ██║██████╔╝█████╗  ███████╗███████╗██║██╔██╗ ██║██║  ███╗
; ██║   ██║██║╚██╗██║██║  ██║██╔══██╗██╔══╝  ╚════██║╚════██║██║██║╚██╗██║██║   ██║
; ╚██████╔╝██║ ╚████║██████╔╝██║  ██║███████╗███████║███████║██║██║ ╚████║╚██████╔╝
;  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 

Function DrawUndressingPage()
		SetCursorFillMode(LEFT_TO_RIGHT)
		SetCursorPosition(0)
		AddToggleOptionST("OID_FullyUndressAtStart", "$ostim_undress_start", Main.AlwaysUndressAtAnimStart)
		SetCursorPosition(2)
		AddToggleOptionST("OID_FullyUndressMidScene", "$ostim_undress_need", Main.AutoUndressIfNeeded)
		SetCursorPosition(4)
		AddToggleOptionST("OID_PartialUndressing", "$ostim_partial_undressing", Main.PartialUndressing)
		SetCursorPosition(6)
		AddToggleOptionST("OID_AnimateRedress", "$ostim_animate_redress", Main.FullyAnimateRedress)

		SetCursorPosition(1)
		int RemoveWeaponsAtStartFlags = OPTION_FLAG_NONE
		If Main.AlwaysUndressAtAnimStart
			RemoveWeaponsAtStartFlags = OPTION_FLAG_DISABLED
		EndIf
		AddToggleOptionST("OID_RemoveWeaponsAtStart", "$ostim_remove_weapons_start", Main.RemoveWeaponsAtStart, RemoveWeaponsAtStartFlags)
		SetCursorPosition(3)
		AddSliderOptionST("OID_RemoveWeaponsWithSlot" ,"$ostim_remove_weapons_slot", Main.RemoveWeaponsWithSlot, "{0}")
		SetCursorPosition(5)
		AddToggleOptionST("OID_UndressWigs", "$ostim_undress_wigs", Main.UndressWigs)

		SetCursorPosition(10)
		AddTextOptionST("OID_UndressAbout", "$ostim_undress_about", "")
		SetCursorPosition(11)
		AddTextOptionST("OID_UndressAbout", "$ostim_undress_text{OStim}", "")
		SetCursorPosition(12)
		AddColoredHeader("$ostim_undress_slots_header")
		SetCursorPosition(13)
		AddColoredHeader("")

	; undressing slots
	SetCursorPosition(14)
	UndressingSlotMask = OData.GetUndressingSlotMask()
	SlotSets = new int[31]

	int i = 0
	int slot = 1

	While i < 31
		SlotSets[i] = AddToggleOption("$ostim_slot_" + (30 + i), Math.LogicalAnd(UndressingSlotMask, slot))
		i += 1
		slot *= 2
	EndWhile
EndFunction

State OID_FullyUndressAtStart
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_always_undress")
	EndEvent

	Event OnSelectST()
		Main.AlwaysUndressAtAnimStart = !Main.AlwaysUndressAtAnimStart
		SetToggleOptionValueST(Main.AlwaysUndressAtAnimStart)

		int RemoveWeaponsAtStartFlags = OPTION_FLAG_NONE
		If Main.AlwaysUndressAtAnimStart
			RemoveWeaponsAtStartFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(RemoveWeaponsAtStartFlags, false, "OID_RemoveWeaponsAtStart")
	EndEvent
EndState

State OID_FullyUndressMidScene
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_undress_if_need")
	EndEvent

	Event OnSelectST()
		Main.AutoUndressIfNeeded = !Main.AutoUndressIfNeeded
		SetToggleOptionValueST(Main.AutoUndressIfNeeded)
	EndEvent
EndState

State OID_PartialUndressing
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_partial_undressing")
	EndEvent

	Event OnSelectST()
		Main.PartialUndressing = !Main.PartialUndressing
		SetToggleOptionValueST(Main.PartialUndressing)
	EndEvent
EndState

State OID_AnimateRedress
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_animate_redress")
	EndEvent

	Event OnSelectST()
		Main.FullyAnimateRedress = !Main.FullyAnimateRedress
		SetToggleOptionValueST(Main.FullyAnimateRedress)
	EndEvent
EndState

State OID_RemoveWeaponsAtStart
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_remove_weapons_start")
	EndEvent

	Event OnSelectST()
		Main.RemoveWeaponsAtStart = !Main.RemoveWeaponsAtStart
		SetToggleOptionValueST(Main.RemoveWeaponsAtStart)
	EndEvent
EndState

State OID_RemoveWeaponsWithSlot
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_remove_weapons_slot")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.RemoveWeaponsWithSlot)
		SetSliderDialogDefaultValue(32)
		SetSliderDialogRange(30, 60)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.RemoveWeaponsWithSlot = Value as int
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState

State OID_UndressWigs
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_undress_wigs")
	EndEvent

	Event OnSelectST()
		Main.UndressWigs = !Main.UndressWigs
		SetToggleOptionValueST(Main.UndressWigs)
	EndEvent
EndState

State OID_UndressAbout
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_undressing_about")
	EndEvent
EndState


; ███████╗██╗  ██╗██████╗ ██████╗ ███████╗███████╗███████╗██╗ ██████╗ ███╗   ██╗███████╗
; ██╔════╝╚██╗██╔╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝██║██╔═══██╗████╗  ██║██╔════╝
; █████╗   ╚███╔╝ ██████╔╝██████╔╝█████╗  ███████╗███████╗██║██║   ██║██╔██╗ ██║███████╗
; ██╔══╝   ██╔██╗ ██╔═══╝ ██╔══██╗██╔══╝  ╚════██║╚════██║██║██║   ██║██║╚██╗██║╚════██║
; ███████╗██╔╝ ██╗██║     ██║  ██║███████╗███████║███████║██║╚██████╔╝██║ ╚████║███████║
; ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

Function DrawExpressionPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddSliderOptionST("OID_ExpressionDurationMin", "$ostim_expression_duration_min", Main.ExpressionDurationMin / 1000.0, "{2} s")
	SetCursorPosition(2)
	AddSliderOptionST("OID_ExpressionDurationMax", "$ostim_expression_duration_max", Main.ExpressionDurationMax / 1000.0, "{2} s")


	SetCursorPosition(1)
	AddMenuOptionST("OID_DefaultTongueMale", "$ostim_default_tongue_male", OData.GetEquipObjectName(0x0, "tongue"))
	SetCursorPosition(3)
	AddMenuOptionST("OID_DefaultTongueFemale", "$ostim_default_tongue_female", OData.GetEquipObjectName(0x1, "tongue"))
	SetCursorPosition(5)
	AddMenuOptionST("OID_PlayerTongue", "$ostim_player_tongue", OData.GetEquipObjectName(0x7, "tongue"))
EndFunction

State OID_ExpressionDurationMin
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_expression_duration_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.ExpressionDurationMin / 1000.0)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0.1, 10)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.ExpressionDurationMin = (Value * 1000) as int
		SetSliderOptionValueST(Main.ExpressionDurationMin / 1000.0, "{2} s")
		SetSliderOptionValueST(Main.ExpressionDurationMax / 1000.0, "{2} s", false, "OID_ExpressionDurationMax")
	EndEvent
EndState

State OID_ExpressionDurationMax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_expression_duration_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.ExpressionDurationMax / 1000.0)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(0.1, 10)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.ExpressionDurationMax = (Value * 1000) as int
		SetSliderOptionValueST(Main.ExpressionDurationMin / 1000.0, "{2} s", false, "OID_ExpressionDurationMin")
		SetSliderOptionValueST(Main.ExpressionDurationMax / 1000.0, "{2} s")
	EndEvent
EndState

State OID_DefaultTongueMale
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_default_tongue_male")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x0, "tongue")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x0, "tongue", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x0, "tongue")
	EndEvent
EndState

State OID_DefaultTongueFemale
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_default_tongue_female")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x1, "tongue")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x1, "tongue", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x1, "tongue")
	EndEvent
EndState

State OID_PlayerTongue
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_player_tongue")
	EndEvent

	Event OnMenuOpenST()
		OpenEquipObjectMenu(0x7, "tongue")
	EndEvent

	Event OnMenuAcceptST(int Index)
		SetEquipObjectIDST(0x7, "tongue", Index)
	EndEvent

	Event OnDefaultST()
		SetEquipObjectIDToDefaultST(0x7, "tongue")
	EndEvent
EndState


; ███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗
; ██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
; ███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
; ╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
; ███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
; ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝

int OID_PlayerVoice = -1
int OID_PlayerDialogue = -1

Function DrawSoundPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddColoredHeader("$ostim_header_moans")
	SetCursorPosition(2)
	AddSliderOptionST("OID_MoanIntervalMin", "$ostim_moan_interval_min", Main.MoanIntervalMin / 1000.0, "{2} s")
	SetCursorPosition(4)
	AddSliderOptionST("OID_MoanIntervalMax", "$ostim_moan_interval_max", Main.MoanIntervalMax / 1000.0, "{2} s")
	SetCursorPosition(6)
	AddSliderOptionST("OID_MoanVolume", "$ostim_moan_volume", Main.MoanVolume, "{2}")
	SetCursorPosition(8)
	OID_PlayerVoice = AddMenuOption("$ostim_player_voice", OData.GetVoiceSetName(0x7))
	SetCursorPosition(10)
	OID_PlayerDialogue = AddToggleOption("$ostim_player_dialogue", Main.PlayerDialogue)

	SetCursorPosition(14)
	AddColoredHeader("$ostim_header_dialogue")
	SetCursorPosition(16)
	AddSliderOptionST("OID_MaleDialogueCountdownMin", "$ostim_male_dialogue_countdown_min", Main.MaleDialogueCountdownMin, "{0}")
	SetCursorPosition(18)
	AddSliderOptionST("OID_MaleDialogueCountdownMax", "$ostim_male_dialogue_countdown_max", Main.MaleDialogueCountdownMax, "{0}")
	SetCursorPosition(20)
	AddSliderOptionST("OID_FemaleDialogueCountdownMin", "$ostim_female_dialogue_countdown_min", Main.FemaleDialogueCountdownMin, "{0}")
	SetCursorPosition(22)
	AddSliderOptionST("OID_FemaleDialogueCountdownMax", "$ostim_female_dialogue_countdown_max", Main.FemaleDialogueCountdownMax, "{0}")

	SetCursorPosition(1)
	AddColoredHeader("$ostim_header_sounds")
	SetCursorPosition(3)
	AddSliderOptionST("OID_SoundVolume", "$ostim_sound_volume", Main.SoundVolume, "{2}")
EndFunction


Function OnOptionHighlightSound(int Option)
	If Option == OID_PlayerVoice
		SetInfoText("$ostim_tooltip_player_voice")
	ElseIf Option == OID_PlayerDialogue
		SetInfoText("$ostim_tooltip_player_dialogue")
	EndIf
EndFunction

Function OnOptionSelectSound(int Option)
	If Option == OID_PlayerDialogue
		Main.PlayerDialogue = !Main.PlayerDialogue
		SetToggleOptionValue(Option, Main.PlayerDialogue)
	EndIf
EndFunction

Function OnOptionMenuOpenSound(int Option)
	If Option == OID_PlayerVoice
		OpenVoiceSetMenu(0x7)
	EndIf
EndFunction

Function OnOptionMenuAcceptSound(int Option, int Index)
	If Option == OID_PlayerVoice
		SetVoiceSet(Option, 0x7, Index)
	EndIf
EndFunction

Function OnOptionDefaultSound(int Option)
	If Option == OID_PlayerVoice
		SetVoiceSetToDefault(Option, 0x7)
	EndIf
EndFunction


State OID_MoanIntervalMin
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_moan_interval_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MoanIntervalMin / 1000.0)
		SetSliderDialogDefaultValue(2.5)
		SetSliderDialogRange(0.1, 10)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.MoanIntervalMin = (Value * 1000) as int
		SetSliderOptionValueST(Main.MoanIntervalMin / 1000.0, "{2} s")
		SetSliderOptionValueST(Main.MoanIntervalMax / 1000.0, "{2} s", false, "OID_MoanIntervalMax")
	EndEvent
EndState

State OID_MoanIntervalMax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_moan_interval_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MoanIntervalMax / 1000.0)
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(0.1, 10)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.MoanIntervalMax = (Value * 1000) as int
		SetSliderOptionValueST(Main.MoanIntervalMin / 1000.0, "{2} s", false, "OID_MoanIntervalMin")
		SetSliderOptionValueST(Main.MoanIntervalMax / 1000.0, "{2} s")
	EndEvent
EndState

State OID_MoanVolume
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_moan_volume")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MoanVolume)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0.1, 1)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.MoanVolume = Value
		SetSliderOptionValueST(Value, "{2}")
	EndEvent
EndState


State OID_MaleDialogueCountdownMin
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_male_dialogue_countdown_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MaleDialogueCountdownMin)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 10)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.MaleDialogueCountdownMin = Value as int
		SetSliderOptionValueST(Main.MaleDialogueCountdownMin, "{0}")
		SetSliderOptionValueST(Main.MaleDialogueCountdownMax, "{0}", false, "OID_MaleDialogueCountdownMax")
	EndEvent
EndState

State OID_MaleDialogueCountdownMax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_male_dialogue_countdown_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.MaleDialogueCountdownMax)
		SetSliderDialogDefaultValue(6)
		SetSliderDialogRange(1, 10)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.MaleDialogueCountdownMax = Value as int
		SetSliderOptionValueST(Main.MaleDialogueCountdownMin, "{0}", false, "OID_MaleDialogueCountdownMin")
		SetSliderOptionValueST(Main.MaleDialogueCountdownMax, "{0}")
	EndEvent
EndState

State OID_FemaleDialogueCountdownMin
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_female_dialogue_countdown_min")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.FemaleDialogueCountdownMin)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, 10)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.FemaleDialogueCountdownMin = Value as int
		SetSliderOptionValueST(Main.FemaleDialogueCountdownMin, "{0}")
		SetSliderOptionValueST(Main.FemaleDialogueCountdownMax, "{0}", false, "OID_FemaleDialogueCountdownMax")
	EndEvent
EndState

State OID_FemaleDialogueCountdownMax
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_female_dialogue_countdown_max")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.FemaleDialogueCountdownMax)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 10)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.FemaleDialogueCountdownMax = Value as int
		SetSliderOptionValueST(Main.FemaleDialogueCountdownMin, "{0}", false, "OID_FemaleDialogueCountdownMin")
		SetSliderOptionValueST(Main.FemaleDialogueCountdownMax, "{0}")
	EndEvent
EndState


State OID_SoundVolume
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_sound_volume")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Main.SoundVolume)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0.1, 1)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Main.SoundVolume = Value
		SetSliderOptionValueST(Value, "{2}")
	EndEvent
EndState


;  █████╗ ██╗     ██╗ ██████╗ ███╗   ██╗███╗   ███╗███████╗███╗   ██╗████████╗
; ██╔══██╗██║     ██║██╔════╝ ████╗  ██║████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
; ███████║██║     ██║██║  ███╗██╔██╗ ██║██╔████╔██║█████╗  ██╔██╗ ██║   ██║ 
; ██╔══██║██║     ██║██║   ██║██║╚██╗██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║ 
; ██║  ██║███████╗██║╚██████╔╝██║ ╚████║██║ ╚═╝ ██║███████╗██║ ╚████║   ██║ 
; ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝ 

Function DrawAlignmentPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddToggleOptionST("OID_DisableScaling", "$ostim_scaling", Main.DisableScaling)
	SetCursorPosition(2)
	AddToggleOptionST("OID_DisableSchlongBending", "$ostim_schlong_bending", Main.DisableSchlongBending)

	SetCursorPosition(1)
	AddHeaderOption("$ostim_header_alignment_menu")
	SetCursorPosition(3)
	AddToggleOptionST("OID_AlignmentGroupBySex", "$ostim_alignment_group_by_sex", Main.AlignmentGroupBySex)
	SetCursorPosition(5)
	int AlignmentGroupByHeightFlags = OPTION_FLAG_NONE
	If !Main.DisableScaling
		AlignmentGroupByHeightFlags = OPTION_FLAG_DISABLED
	EndIf
	AddToggleOptionST("OID_AlignmentGroupByHeight", "$ostim_alignment_group_by_height", Main.AlignmentGroupByHeight, AlignmentGroupByHeightFlags)
	SetCursorPosition(7)
	AddToggleOptionST("OID_AlignmentGroupByHeels", "$ostim_alignment_group_by_heels", Main.AlignmentGroupByHeels)
EndFunction

State OID_DisableScaling
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_scaling")
	EndEvent

	Event OnSelectST()
		Main.DisableScaling = !Main.DisableScaling
		SetToggleOptionValueST(Main.DisableScaling)

		int AlignmentGroupByHeightFlags = OPTION_FLAG_NONE
		If !Main.DisableScaling
			AlignmentGroupByHeightFlags = OPTION_FLAG_DISABLED
		EndIf
		SetOptionFlagsST(AlignmentGroupByHeightFlags, false, "OID_AlignmentGroupByHeight")
	EndEvent
EndState

State OID_DisableSchlongBending
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_schlong_bending")
	EndEvent
	
	Event OnSelectST()
		Main.DisableSchlongBending = !Main.DisableSchlongBending
		SetToggleOptionValueST(Main.DisableSchlongBending)
	EndEvent
EndState

State OID_AlignmentGroupBySex
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_alignment_group_by_sex")
	EndEvent

	Event OnSelectST()
		Main.AlignmentGroupBySex = !Main.AlignmentGroupBySex
		SetToggleOptionValueST(Main.AlignmentGroupBySex)
	EndEvent
EndState

State OID_AlignmentGroupByHeight
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_alignment_group_by_height")
	EndEvent

	Event OnSelectST()
		Main.AlignmentGroupByHeight = !Main.AlignmentGroupByHeight
		SetToggleOptionValueST(Main.AlignmentGroupByHeight)
	EndEvent
EndState

State OID_AlignmentGroupByHeels
	Event OnHighlightST()
		SetInfoText("$ostim_tooltip_alignment_group_by_heels")
	EndEvent

	Event OnSelectST()
		Main.AlignmentGroupByHeels = !Main.AlignmentGroupByHeels
		SetToggleOptionValueST(Main.AlignmentGroupByHeels)
	EndEvent
EndState


;  █████╗  ██████╗████████╗ ██████╗ ██████╗ ███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝
; ███████║██║        ██║   ██║   ██║██████╔╝███████╗
; ██╔══██║██║        ██║   ██║   ██║██╔══██╗╚════██║
; ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║███████║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝

Actor CurrentActor = None
int CurrentActorID = 0x0
Actor[] Actors

string CurrentEquipObjectType = "light"
string[] EquipObjectTypes

int OID_SelectActor = -1
int OID_ActorVoice = -1

int OID_EquipObjectType = -1
int OID_ActorEquipObject = -1

string CurrentAction = ""
string[] Actions
string CurrentEvent = ""
string[] Events

int OID_SelectAction = -1
int[] OIDs_ActionStimulation
int[] OIDs_ActionMaxStimulation

int OID_SelectEvent = -1
int[] OIDs_EventStimulation
int[] OIDs_EventMaxStimulation

Function DrawActorsPage()
	Actions = OData.GetActions()
	CurrentAction = Actions[0]
	Events = OData.GetEvents()
	CurrentEvent = Events[0]

	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	OID_SelectActor = AddMenuOption("$ostim_select_actor", CurrentActor.GetDisplayName())
	OID_ActorVoice = AddMenuOption("$ostim_actor_voice", OData.GetVoiceSetName(CurrentActorID))
	AddEmptyOption()

	AddColoredHeader("$ostim_header_equip_objects")
	OID_EquipObjectType = AddMenuOption("$ostim_equip_object_type", CurrentEquipObjectType)
	OID_ActorEquipObject = AddMenuOption("$ostim_actor_equip_object", OData.GetEquipObjectName(CurrentActorID, CurrentEquipObjectType))

	SetCursorPosition(1)
	AddColoredHeader("$ostim_header_preferences")

	OID_SelectAction = AddMenuOption("$ostim_select_action", CurrentAction)
	OIDs_ActionStimulation = new int[3]
	OIDs_ActionMaxStimulation = new int[3]
	int i = 0
	While i < 3
		OIDs_ActionStimulation[i] = AddSliderOption(OData.Localize("$ostim_" + RoleKeys[i] + "_stimulation"), OData.GetActionStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentAction), "{2}")
		OIDs_ActionMaxStimulation[i] = AddSliderOption(OData.Localize("$ostim_" + RoleKeys[i] + "_max_stimulation"), OData.GetActionMaxStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentAction), "{0}")
		i += 1
	EndWhile

	AddEmptyOption()

	OID_SelectEvent = AddMenuOption("$ostim_select_event", CurrentEvent)
	OIDs_EventStimulation = new int[3]
	OIDs_EventMaxStimulation = new int[3]
	i = 0
	While i < 3
		OIDs_EventStimulation[i] = AddSliderOption(OData.Localize("$ostim_" + RoleKeys[i] + "_stimulation"), OData.GetEventStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentEvent), "{2}")
		OIDs_EventMaxStimulation[i] = AddSliderOption(OData.Localize("$ostim_" + RoleKeys[i] + "_max_stimulation"), OData.GetEventMaxStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentEvent), "{0}")
		i += 1
	EndWhile
EndFunction

Function OnOptionHighlightActors(int Option)
	If Option == OID_SelectActor
		SetInfoText("$ostim_tooltip_select_actor")
	ElseIf Option == OID_ActorVoice
		SetInfoText("$ostim_tooltip_actor_voice")

	ElseIf Option == OID_EquipObjectType
		SetInfoText("$ostim_tooltip_equip_object_type")
	ElseIf Option == OID_ActorEquipObject
		SetInfoText("$ostim_tooltip_actor_equip_object")

	ElseIf Option == OID_SelectAction
		SetInfoText("$ostim_tooltip_select_action")
	ElseIf OIDs_ActionStimulation.Find(Option) >= 0
		SetInfoText(OData.Localize("$ostim_tooltip_" + RoleKeys[OIDs_ActionStimulation.Find(Option)] + "_stimulation"))
	ElseIf OIDs_ActionMaxStimulation.Find(Option) >= 0
		SetInfoText(OData.Localize("$ostim_tooltip_" + RoleKeys[OIDs_ActionMaxStimulation.Find(Option)] + "_max_stimulation"))

	ElseIf Option == OID_SelectEvent
		SetInfoText("$ostim_tooltip_select_event")
	ElseIf OIDs_EventStimulation.Find(Option) >= 0
		SetInfoText(OData.Localize("$ostim_tooltip_" + RoleKeys[OIDs_EventStimulation.Find(Option)] + "_stimulation"))
	ElseIf OIDs_EventMaxStimulation.Find(Option) >= 0
		SetInfoText(OData.Localize("$ostim_tooltip_" + RoleKeys[OIDs_EventMaxStimulation.Find(Option)] + "_max_stimulation"))
	EndIf
EndFunction

Function OnOptionSelectActors(int Option)

EndFunction

Function OnOptionSliderOpenActors(int Option)
	int Index = OIDs_ActionStimulation.Find(Option)
	If Index >= 0
		SetSliderDialogStartValue(OData.GetActionStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction))
		SetSliderDialogDefaultValue(OData.GetActionDefaultStimulation(Math.Pow(2, Index) As int, CurrentAction))
		SetSliderDialogRange(-5, 5)
		SetSliderDialogInterval(0.05)
		Return
	EndIf

	Index = OIDs_ActionMaxStimulation.Find(Option)
	If Index >= 0
		SetSliderDialogStartValue(OData.GetActionMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction))
		SetSliderDialogDefaultValue(OData.GetActionDefaultMaxStimulation(Math.Pow(2, Index) As int, CurrentAction))
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
		Return
	EndIf

	Index = OIDs_EventStimulation.Find(Option)
	If Index >= 0
		SetSliderDialogStartValue(OData.GetEventStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent))
		SetSliderDialogDefaultValue(OData.GetEventDefaultStimulation(Math.Pow(2, Index) As int, CurrentEvent))
		SetSliderDialogRange(-25, 25)
		SetSliderDialogInterval(0.25)
		Return
	EndIf

	Index = OIDs_EventMaxStimulation.Find(Option)
	If Index >= 0
		SetSliderDialogStartValue(OData.GetEventMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent))
		SetSliderDialogDefaultValue(OData.GetEventDefaultMaxStimulation(Math.Pow(2, Index) As int, CurrentEvent))
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
		Return
	EndIf
EndFunction

Function OnOptionSliderAcceptActors(int Option, float Value)
	int Index = OIDs_ActionStimulation.Find(Option)
	If Index >= 0
		OData.SetActionStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction, Value)
		SetSliderOptionValue(Option, Value, "{2}")
		Return
	EndIf

	Index = OIDs_ActionMaxStimulation.Find(Option)
	If Index >= 0
		OData.SetActionMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction, Value)
		SetSliderOptionValue(Option, Value, "{0}")
		Return
	EndIf

	Index = OIDs_EventStimulation.Find(Option)
	If Index >= 0
		OData.SetEventStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent, Value)
		SetSliderOptionValue(Option, Value, "{2}")
		Return
	EndIf

	Index = OIDs_EventMaxStimulation.Find(Option)
	If Index >= 0
		OData.SetEventMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent, Value)
		SetSliderOptionValue(Option, Value, "{0}")
		Return
	EndIf

EndFunction

Function OnOptionMenuOpenActors(int Option)
	If Option == OID_SelectActor
		Actors = OActorUtil.GetActorsInRangeV2(PlayerRef, 1000, true, true, true, None)
		SetMenuDialogOptions(OActorUtil.ActorsToNames(Actors))
		SetMenuDialogStartIndex(Actors.Find(CurrentActor))
		SetMenuDialogDefaultIndex(Actors.Find(PlayerRef))
	ElseIf Option == OID_ActorVoice
		OpenVoiceSetMenu(CurrentActorID)

	ElseIf Option == OID_EquipObjectType
		EquipObjectTypes = OData.GetEquipObjectTypes()
		SetMenuDialogOptions(EquipObjectTypes)
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)
	ElseIf Option == OID_ActorEquipObject
		OpenEquipObjectMenu(CurrentActorID, CurrentEquipObjectType)

	ElseIf Option == OID_SelectAction
		SetMenuDialogOptions(Actions)
		SetMenuDialogStartIndex(Actions.Find(CurrentAction))
		SetMenuDialogDefaultIndex(0)
	ElseIf Option == OID_SelectEvent
		SetMenuDialogOptions(Events)
		SetMenuDialogStartIndex(Events.Find(CurrentEvent))
		SetMenuDialogDefaultIndex(0)
	EndIf
EndFunction

Function OnOptionMenuAcceptActors(int Option, int Index)
	If Option == OID_SelectActor
		CurrentActor = Actors[Index]
		CurrentActorID = CurrentActor.GetActorBase().GetFormID()
		ForcePageReset()
	ElseIf Option == OID_ActorVoice
		SetVoiceSet(Option, CurrentActorID, Index)

	ElseIf Option == OID_EquipObjectType
		CurrentEquipObjectType = EquipObjectTypes[Index]
		SetMenuOptionValue(Option, CurrentEquipObjectType)
		SetMenuOptionValue(OID_ActorEquipObject, OData.GetEquipObjectName(CurrentActorID, CurrentEquipObjectType))
	ElseIf Option == OID_ActorEquipObject
		SetEquipObjectID(Option, CurrentActorID, CurrentEquipObjectType, Index)

	ElseIf Option == OID_SelectAction
		CurrentAction = Actions[Index]
		SetMenuOptionValue(Option, CurrentAction)
		int i = OIDs_ActionStimulation.Length
		While i
			i -= 1
			SetSliderOptionValue(OIDs_ActionStimulation[i], OData.GetActionStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentAction), "{2}")
		EndWhile

		i = OIDs_ActionMaxStimulation.Length
		While i
			i -= 1
			SetSliderOptionValue(OIDs_ActionMaxStimulation[i], OData.GetActionMaxStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentAction), "{2}")
		EndWhile
	ElseIf Option == OID_SelectEvent
		CurrentEvent = Events[Index]
		SetMenuOptionValue(Option, CurrentEvent)
		int i = OIDs_EventStimulation.Length
		While i
			i -= 1
			SetSliderOptionValue(OIDs_EventStimulation[i], OData.GetEventStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentAction), "{2}")
		EndWhile

		i = OIDs_EventMaxStimulation.Length
		While i
			i -= 1
			SetSliderOptionValue(OIDs_EventMaxStimulation[i], OData.GetEventMaxStimulation(Math.Pow(2, i) as int, CurrentActorID, CurrentAction), "{2}")
		EndWhile
	EndIf
EndFunction

Function OnOptionDefaultActors(int Option)
	If Option == OID_SelectActor
		CurrentActor == PlayerRef
		ForcePageReset()
		Return
	ElseIf Option == OID_ActorVoice
		SetVoiceSetToDefault(Option, CurrentActorID)
		Return
	ElseIf Option == OID_EquipObjectType
		CurrentEquipObjectType = "light"
		SetMenuOptionValue(Option, "light")
		SetMenuOptionValue(OID_ActorEquipObject, OData.GetEquipObjectName(CurrentActorID, CurrentEquipObjectType))
		Return
	ElseIf Option == OID_ActorEquipObject
		SetEquipObjectIDToDefault(Option, CurrentActorID, CurrentEquipObjectType)
		Return
	ElseIf Option == OID_SelectAction
		CurrentAction = Actions[0]
		SetMenuOptionValue(Option, CurrentAction)
		Return
	ElseIf Option == OID_SelectEvent
		CurrentEvent = Events[0]
		SetMenuOptionValue(Option, CurrentEvent)
		Return
	EndIf

	int Index = OIDs_ActionStimulation.Find(Option)
	If Index >= 0
		OData.ResetActionStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction)
		SetSliderOptionValue(Option, OData.GetActionStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction), "{2}")
		Return
	EndIf

	Index = OIDs_ActionMaxStimulation.Find(Option)
	If Index >= 0
		OData.ResetActionMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction)
		SetSliderOptionValue(Option, OData.GetActionMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentAction), "{2}")
		Return
	EndIf

	Index = OIDs_EventStimulation.Find(Option)
	If Index >= 0
		OData.ResetEventStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent)
		SetSliderOptionValue(Option, OData.GetEventStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent), "{2}")
		Return
	EndIf

	Index = OIDs_EventMaxStimulation.Find(Option)
	If Index >= 0
		OData.ResetEventMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent)
		SetSliderOptionValue(Option, OData.GetEventMaxStimulation(Math.Pow(2, Index) as int, CurrentActorID, CurrentEvent), "{2}")
		Return
	EndIf
EndFunction


; ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
; ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
; ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
; ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
; ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
; ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝

int OID_UnrestrictedNavigation = -1
int OID_NoFacialExpressions = -1
int OID_FixDarkFace = -1

Function DrawDebugPage()
	SetCursorFillMode(TOP_TO_BOTTOM)
	OID_UnrestrictedNavigation = AddToggleOption("$ostim_unrestricted_navigation", Main.UnrestrictedNavigation)
	OID_NoFacialExpressions = AddToggleOption("$ostim_no_facial_expressions", Main.NoFacialExpressions)
	OID_FixDarkFace = AddToggleOption("$ostim_fix_dark_face", Main.FixDarkFace)
EndFunction

Function OnOptionHighlightDebug(int Option)
	If Option == OID_UnrestrictedNavigation
		SetInfoText("$ostim_tooltip_unrestricted_navigation")
	ElseIf Option == OID_NoFacialExpressions
		SetInfoText("$ostim_tooltip_no_facial_expressions")
	ElseIf Option == OID_FixDarkFace
		SetInfoText("$ostim_tooltip_fix_dark_face")
	EndIf
EndFunction

Function OnOptionSelectDebug(int Option)
	If Option == OID_UnrestrictedNavigation
		Main.UnrestrictedNavigation = !Main.UnrestrictedNavigation
		SetToggleOptionValue(Option, Main.UnrestrictedNavigation)
	ElseIf Option == OID_NoFacialExpressions
		Main.NoFacialExpressions = !Main.NoFacialExpressions
		SetToggleOptionValue(Option, Main.NoFacialExpressions)
	ElseIf Option == OID_FixDarkFace
		Main.FixDarkFace = !Main.FixDarkFace
		SetToggleOptionValue(Option, Main.FixDarkFace)
	EndIf
EndFunction


; ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
; ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
; ██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝ 
; ██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
; ╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
;  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝

string[] EquipObjectPairs

Function OpenEquipObjectMenu(int FormID, string Type)
	EquipObjectPairs = OData.GetEquipObjectPairs(FormID, Type)
	SetMenuDialogOptions(OData.PairsToNames(EquipObjectPairs))
	SetMenuDialogStartIndex(0)
	SetMenuDialogDefaultIndex(0)
EndFunction

Function SetEquipObjectID(int Option, int FormID, string Type, int Index)
	OData.SetEquipObjectID(FormID, Type, EquipObjectPairs[Index * 2])
	SetMenuOptionValue(Option, EquipObjectPairs[Index * 2 + 1])
EndFunction

Function SetEquipObjectIDST(int FormID, string Type, int Index)
	OData.SetEquipObjectID(FormID, Type, EquipObjectPairs[Index * 2])
	SetMenuOptionValueST(EquipObjectPairs[Index * 2 + 1])
EndFunction

Function SetEquipObjectIDToDefault(int Option, int FormID, string Type)
	string ID = "default"
	If FormID < 2
		ID = "random"
	EndIf
	OData.SetEquipObjectID(FormID, Type, ID)
	SetMenuOptionValue(Option, ID)
EndFunction

Function SetEquipObjectIDToDefaultST(int FormID, string Type)
	string ID = "default"
	If FormID < 2
		ID = "random"
	EndIf
	OData.SetEquipObjectID(FormID, Type, ID)
	SetMenuOptionValueST(ID)
EndFunction


string[] VoiceSetPairs

Function OpenVoiceSetMenu(int FormID)
	VoiceSetPairs = OData.GetVoiceSetPairs()
	SetMenuDialogOptions(OData.PairsToNames(VoiceSetPairs))
	SetMenuDialogStartIndex(0)
	SetMenuDialogDefaultIndex(0)
EndFunction

Function SetVoiceSet(int Option, int FormID, int Index)
	OData.SetVoiceSet(FormID, VoiceSetPairs[Index * 2])
	SetMenuOptionValue(Option, VoiceSetPairs[Index * 2 + 1])
EndFunction

Function SetVoiceSetToDefault(int Option, int FormID)
	OData.SetVoiceSet(FormID, 0)
	SetMenuOptionValue(Option, "default")
EndFunction


; ██████╗ ███████╗███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗ ███████╗██████╗ 
; ██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝██╔══██╗
; ██████╔╝█████╗  █████╗  ███████║██║        ██║   ██║   ██║██████╔╝█████╗  ██║  ██║
; ██╔══██╗██╔══╝  ██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗██╔══╝  ██║  ██║
; ██║  ██║███████╗██║     ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║███████╗██████╔╝
; ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝

int SETTING_TYPE_TOGGLE = 0
int SETTING_TYPE_SLIDER = 1
int SETTING_TYPE_DROP_DOWN = 2
int SETTING_TYPE_TEXT_INPUT = 3
int SETTING_TYPE_KEY_MAP = 4
int SETTING_TYPE_BUTTON = 5

int DrawnPage = -1

int[] Settings
int[] SettingIndices
int[] SettingGroups

Function DrawPage(int Page)
	DrawnPage = Page

	DrawPageTopToBottom(Page)
EndFunction

Function DrawPageTopToBottom(int Page)
	SetCursorFillMode(TOP_TO_BOTTOM)

	int GroupCount = OSettings.GetSettingGroupCount(Page)
	int Middle = (GroupCount + 1) / 2
	int Group = GroupCount

	int TotalSettingCount = 0
	int TotalSettingIndex = 0

	While Group
		Group -= 1
		TotalSettingCount += OSettings.GetSettingCount(Page, Group)
	EndWhile

	Settings = OIntUtil.CreateArray(TotalSettingCount, -1)
	SettingIndices = OIntUtil.CreateArray(TotalSettingCount, -1)
	SettingGroups = OIntUtil.CreateArray(TotalSettingCount, -1)

	Group = 0
	While Group < GroupCount
		If Group == Middle
			SetCursorPosition(1)
		EndIf

		AddColoredHeader(OSettings.GetSettingGroupName(Page, Group))

		int SettingCount = OSettings.GetSettingCount(Page, Group)
		int Setting = 0

		While Setting < SettingCount
			SettingIndices[TotalSettingIndex] = Setting
			SettingGroups[TotalSettingIndex] = Group

			int SettingType = OSettings.GetSettingType(Page, Group, Setting)
			string SettingName = OSettings.GetSettingName(Page, Group, Setting)

			int SettingFlags = OPTION_FLAG_NONE
			If !OSettings.IsSettingEnabled(Page, Group, Setting)
				SettingFlags = OPTION_FLAG_DISABLED
			EndIf

			int SettingID = -1
			If SettingType == SETTING_TYPE_TOGGLE
				SettingID = AddToggleOption(SettingName, OSettings.IsSettingActivated(Page, Group, Setting), SettingFlags)
			ElseIf SettingType == SETTING_TYPE_SLIDER
				SettingID = AddSliderOption(SettingName, OSettings.GetCurrentSettingValue(Page, Group, Setting), "{2}", SettingFlags)
			ElseIf SettingType == SETTING_TYPE_DROP_DOWN
				SettingID = AddMenuOption(SettingName, OSettings.GetCurrentSettingOption(Page, Group, Setting), SettingFlags)
			ElseIf SettingType == SETTING_TYPE_TEXT_INPUT
				SettingID = AddInputOption(SettingName, OSettings.GetCurrentSettingText(Page, Group, Setting), SettingFlags)
			ElseIf SettingType == SETTING_TYPE_KEY_MAP
				SettingID = AddKeyMapOption(SettingName, OSettings.GetCurrentSettingKey(Page, Group, Setting), SettingFlags)
			ElseIf SettingType == SETTING_TYPE_BUTTON
				SettingID = AddTextOption(SettingName, "")
			EndIf
			Settings[TotalSettingIndex] = SettingID

			Setting += 1
			TotalSettingIndex += 1
		EndWhile

		AddEmptyOption()

		Group += 1
	EndWhile
EndFunction

Function OnOptionHighlightRefactored(int Option)
	int Setting = Settings.Find(Option)
	SetInfoText(OSettings.GetSettingTooltip(DrawnPage, SettingGroups[Setting], SettingIndices[Setting]))
EndFunction

Function OnOptionSelectRefactored(int Option)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]

	int SettingType = OSettings.GetSettingType(DrawnPage, Group, Setting)

	If SettingType == SETTING_TYPE_TOGGLE
		If OSettings.ToggleSetting(DrawnPage, Group, Setting)
			ForcePageReset()
		Else
			SetToggleOptionValue(Option, OSettings.IsSettingActivated(DrawnPage, Group, Setting))
		EndIf
	ElseIf SettingType == SETTING_TYPE_BUTTON
		If OSettings.ClickSetting(DrawnPage, Group, Setting)
			ForcePageReset()
		EndIf
	EndIf	
EndFunction

Function OnOptionSliderOpenRefactored(int Option)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]

	SetSliderDialogStartValue(OSettings.GetCurrentSettingValue(DrawnPage, Group, Setting))
	SetSliderDialogDefaultValue(OSettings.GetDefaultSettingValue(DrawnPage, Group, Setting))
	SetSliderDialogRange(OSettings.GetMinSettingValue(DrawnPage, Group, Setting), OSettings.GetMaxSettingValue(DrawnPage, Group, Setting))
	SetSliderDialogInterval(OSettings.GetSettingValueStep(DrawnPage, Group, Setting))
EndFunction

Function OnOptionSliderAcceptRefactored(int Option, float Value)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]

	If OSettings.SetSettingValue(DrawnPage, Group, Setting, Value)
		ForcePageReset()
	Else
		SetSliderOptionValue(Option, Value, "{2}")
	EndIf
EndFunction

Function OnOptionMenuOpenRefactored(int Option)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]

	SetMenuDialogStartIndex(OSettings.GetCurrentSettingIndex(DrawnPage, Group, Setting))
	SetMenuDialogDefaultIndex(OSettings.GetDefaultSettingIndex(DrawnPage, Group, Setting))
	SetMenuDialogOptions(OSettings.GetSettingOptions(DrawnPage, Group, Setting))
EndFunction

Function OnOptionMenuAcceptRefactored(int Option, int Index)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]

	If OSettings.SetSettingIndex(DrawnPage, Group, Setting, Index)
		ForcePageReset()
	Else
		SetMenuOptionValue(Option, OSettings.GetCurrentSettingOption(DrawnPage, Group, Setting))
	EndIf
EndFunction

Event OnOptionInputAccept(int Option, string Text)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]

	If OSettings.SetSettingText(DrawnPage, Group, Setting, Text)
		ForcePageReset()
	Else
		SetInputOptionValue(Option, Text)
	EndIf
EndEvent

Event OnOptionKeyMapChange(int Option, int KeyCode, string ConflictControl, string ConflictName)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]

	If OSettings.SetSettingKey(DrawnPage, Group, Setting, KeyCode)
		ForcePageReset()
	Else
		SetKeyMapOptionValue(Option, KeyCode)
	EndIf
EndEvent

Function OnOptionDefaultRefactored(int Option)
	int SettingID = Settings.Find(Option)
	int Group = SettingGroups[SettingID]
	int Setting = SettingIndices[SettingID]
	int SettingType = OSettings.GetSettingType(DrawnPage, Group, Setting)

	If SettingType == SETTING_TYPE_TOGGLE
		bool IsActivated = OSettings.IsSettingActivated(DrawnPage, Group, Setting)
		If IsActivated != OSettings.IsSettingActivatedByDefault(DrawnPage, Group, Setting)
			If OSettings.ToggleSetting(DrawnPage, Group, Setting)
				ForcePageReset()
			Else
				SetToggleOptionValue(Option, !IsActivated)
			EndIf
		EndIf
	ElseIf SettingType == SETTING_TYPE_SLIDER
		float DefaultValue = OSettings.GetDefaultSettingValue(DrawnPage, Group, Setting)
		If OSettings.SetSettingValue(DrawnPage, Group, Setting, DefaultValue)
			ForcePageReset()
		Else
			SetSliderOptionValue(Option, DefaultValue, "{2}")
		EndIf
	ElseIf SettingType == SETTING_TYPE_DROP_DOWN
		int DefaultIndex = OSettings.GetDefaultSettingIndex(DrawnPage, Group, Setting)
		If OSettings.SetSettingIndex(DrawnPage, Group, Setting, DefaultIndex)
			ForcePageReset()
		Else
			SetMenuOptionValue(Option, OSettings.GetCurrentSettingOption(DrawnPage, Group, Setting))
		EndIf
	ElseIf SettingType == SETTING_TYPE_TEXT_INPUT
		string DefaultText = OSettings.GetDefaultSettingText(DrawnPage, Group, Setting)
		If OSettings.SetSettingText(DrawnPage, Group, Setting, DefaultText)
			ForcePageReset()
		Else
			SetTextOptionValue(Option, DefaultText)
		EndIf
	ElseIf SettingType == SETTING_TYPE_KEY_MAP
		int DefaultKey = OSettings.GetDefaultSettingKey(DrawnPage, Group, Setting)
		If OSettings.SetSettingKey(Drawnpage, Group, Setting, DefaultKey)
			ForcePageReset()
		Else
			SetKeyMapOptionValue(Option, DefaultKey)
		EndIf
	EndIf
EndFunction