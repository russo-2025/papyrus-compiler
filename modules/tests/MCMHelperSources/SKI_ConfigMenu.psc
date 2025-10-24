scriptname SKI_ConfigMenu extends MCM_ConfigBase

; SCRIPT VERSION ----------------------------------------------------------------------------------

int function GetVersion()
	return 9
endFunction

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; -- Version 1 --

; Lists
string[]	_alignmentValues

; Internal
float		_itemXBase
float		_itemXBaseW


; -- Version 2 --

; Lists
string[]	_categoryIconThemeValues

; -- Version 3 --

; Internal
float		_fInventory3DItemPosXWide
float		_fInventory3DItemPosX
float		_fMagic3DItemPosXWide
float		_fMagic3DItemPosX

; -- Version 4 --

; Lists
string[]	_orientationValues

string[]	_vertAlignmentValues

float[]		_effectWidgetIconSizeValues

float[]		_alignmentBaseOffsets
float[]		_vertAlignmentBaseOffsets

; -- Version 5 --

; Internal
float		_fInventory3DItemPosZWide
float		_fInventory3DItemPosZ
float		_fMagic3DItemPosZWide
float		_fMagic3DItemPosZ

float		_fInventory3DItemPosScaleWide
float		_fMagic3DItemPosScaleWide
float		_fInventory3DItemPosScale
float		_fMagic3DItemPosScale


; PROPERTIES --------------------------------------------------------------------------------------

; -- Version 1 --

SKI_SettingsManager property		SKI_SettingsManagerInstance auto
SKI_Main property					SKI_MainInstance auto

; -- Version 4 --

SKI_ActiveEffectsWidget property	SKI_ActiveEffectsWidgetInstance auto

; -- Version 6 --

SKI_FavoritesManager property		SKI_FavoritesManagerInstance auto

; -- MCM Helper --

bool property						IsGamepad auto
int property						FavoriteCurrentGroup auto
bool property						UnequipArmor auto
bool property						UnequipHands auto


; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnConfigInit()
	; Strings used as variable values
	_alignmentValues = new string[3]
	_alignmentValues[0] = "left"
	_alignmentValues[1] = "right"
	_alignmentValues[2] = "center"

	_categoryIconThemeValues = new string[4]
	_categoryIconThemeValues[0] = "skyui\\icons_category_psychosteve.swf"
	_categoryIconThemeValues[1] = "skyui\\icons_category_celtic.swf"
	_categoryIconThemeValues[2] = "skyui\\icons_category_curved.swf"
	_categoryIconThemeValues[3] = "skyui\\icons_category_straight.swf"

	_orientationValues = new string[2]
	_orientationValues[0] = "horizontal"
	_orientationValues[1] = "vertical"

	_vertAlignmentValues = new string[3]
	_vertAlignmentValues[0] = "top"
	_vertAlignmentValues[1] = "bottom"
	_vertAlignmentValues[2] = "center"

	_effectWidgetIconSizeValues = new float[3]
	_effectWidgetIconSizeValues[0] = 32.0
	_effectWidgetIconSizeValues[1] = 48.0
	_effectWidgetIconSizeValues[2] = 64.0

	_alignmentBaseOffsets = new float[3]
	_alignmentBaseOffsets[0] = 0.0
	_alignmentBaseOffsets[1] = 1280.0
	_alignmentBaseOffsets[2] = 640.0

	_vertAlignmentBaseOffsets = new float[3]
	_vertAlignmentBaseOffsets[0] = 0.0
	_vertAlignmentBaseOffsets[1] = 720.0
	_vertAlignmentBaseOffsets[2] = 360.0

	; Give SKI_FavoritesManager time to initialize
	Utility.Wait(5)

	LoadSettings()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	parent.OnGameReload()
	LoadSettings()
endEvent

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnConfigOpen()
	IsGamepad = Game.UsingGamepad()

	int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
	int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_HANDS

	FavoriteCurrentGroup = 0
	UnequipArmor = SKI_FavoritesManagerInstance.GetGroupFlag(0, ARMOR_FLAG)
	UnequipHands = SKI_FavoritesManagerInstance.GetGroupFlag(0, HANDS_FLAG)
endEvent

event OnSettingChange(string a_ID)
	; ItemList
	if a_ID == "iQuantityMinCount:ItemList"
		SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", GetModSettingInt(a_ID))
	elseif a_ID == "iCategoryIconTheme:ItemList"
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[GetModSettingInt(a_ID)])
	elseif a_ID == "bNoIconColors:ItemList"
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", GetModSettingBool(a_ID))

	; EffectWidget
	elseif a_ID == "bEnabled:EffectWidget"
		SKI_ActiveEffectsWidgetInstance.Enabled = GetModSettingBool(a_ID)
	elseif a_ID == "iIconSize:EffectWidget"
		SKI_ActiveEffectsWidgetInstance.EffectSize = _effectWidgetIconSizeValues[GetModSettingInt(a_ID)]
	elseif a_ID == "iOrientation:EffectWidget"
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientationValues[GetModSettingInt(a_ID)]
	elseif a_ID == "iHorizontalAnchor:EffectWidget"
		int idx = GetModSettingInt(a_ID)
		SKI_ActiveEffectsWidgetInstance.HAnchor = _alignmentValues[idx]
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[idx] + GetModSettingInt("iXOffset:EffectWidget")
	elseif a_ID == "iVerticalAnchor:EffectWidget"
		int idx = GetModSettingInt(a_ID)
		SKI_ActiveEffectsWidgetInstance.VAnchor = _vertAlignmentValues[idx]
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[idx] + GetModSettingInt("iYOffset:EffectWidget")
	elseif a_ID == "iMinTimeLeft:EffectWidget"
		SKI_ActiveEffectsWidgetInstance.MinimumTimeLeft = GetModSettingInt(a_ID)
	elseif a_ID == "iGroupEffectCount:EffectWidget"
		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = GetModSettingInt(a_ID)
	elseif a_ID == "iXOffset:EffectWidget"
		int effectWidgetHAnchorIdx = GetModSettingInt("iHorizontalAnchor:EffectWidget")
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[effectWidgetHAnchorIdx] + GetModSettingInt(a_ID)
	elseif a_ID == "iYOffset:EffectWidget"
		int effectWidgetVAnchorIdx = GetModSettingInt("iVerticalAnchor:EffectWidget")
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[effectWidgetVAnchorIdx] + GetModSettingInt(a_ID)

	; ItemCard
	elseif a_ID == "iAlign:ItemCard"
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[GetModSettingInt(a_ID)])
	elseif a_ID == "iXOffset:ItemCard"
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", GetModSettingInt(a_ID))
	elseif a_ID == "iYOffset:ItemCard"
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", GetModSettingInt(a_ID))

	; FavoritesMenu
	elseif a_ID == "bHelpEnabled:FavoritesMenu"
		SKI_FavoritesManagerInstance.ButtonHelpEnabled = GetModSettingBool(a_ID)

	; SWFVersionCheck
	elseif a_ID == "bMapMenu:SWFVersionCheck"
		SKI_MainInstance.MapMenuCheckEnabled = GetModSettingBool(a_ID)
	elseif a_ID == "bFavoritesMenu:SWFVersionCheck"
		SKI_MainInstance.FavoritesMenuCheckEnabled = GetModSettingBool(a_ID)
	elseif a_ID == "bInventoryMenu:SWFVersionCheck"
		SKI_MainInstance.InventoryMenuCheckEnabled = GetModSettingBool(a_ID)
	elseif a_ID == "bMagicMenu:SWFVersionCheck"
		SKI_MainInstance.MagicMenuCheckEnabled = GetModSettingBool(a_ID)
	elseif a_ID == "bBarterMenu:SWFVersionCheck"
		SKI_MainInstance.BarterMenuCheckEnabled = GetModSettingBool(a_ID)
	elseif a_ID == "bContainerMenu:SWFVersionCheck"
		SKI_MainInstance.ContainerMenuCheckEnabled = GetModSettingBool(a_ID)
	elseif a_ID == "bCraftingMenu:SWFVersionCheck"
		SKI_MainInstance.CraftingMenuCheckEnabled = GetModSettingBool(a_ID)
	elseif a_ID == "bGiftMenu:SWFVersionCheck"
		SKI_MainInstance.GiftMenuCheckEnabled = GetModSettingBool(a_ID)

	; Controls
	elseif a_ID == "iSearchKey:Controls"
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", GetModSettingInt(a_ID))
	elseif a_ID == "iSwitchTabKey:Controls"
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", GetModSettingInt(a_ID))
	elseif a_ID == "iEquipModeKey:Controls"
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", GetModSettingInt(a_ID))
	elseif a_ID == "iSwitchTabButton:Controls"
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", GetModSettingInt(a_ID))
	elseif a_ID == "iPreviousColumnButton:Controls"
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", GetModSettingInt(a_ID))
	elseif a_ID == "iNextColumnButton:Controls"
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", GetModSettingInt(a_ID))
	elseif a_ID == "iSortOrderButton:Controls"
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", GetModSettingInt(a_ID))

	elseif a_ID == "iFavoriteGroupAddKey:Controls"
		SKI_FavoritesManagerInstance.GroupAddKey = GetModSettingInt(a_ID)
	elseif a_ID == "iFavoriteGroupUseKey:Controls"
		SKI_FavoritesManagerInstance.GroupUseKey = GetModSettingInt(a_ID)
	elseif a_ID == "iFavoriteSetIconKey:Controls"
		SKI_FavoritesManagerInstance.SetIconKey = GetModSettingInt(a_ID)
	elseif a_ID == "iFavoriteEquipStateKey:Controls"
		SKI_FavoritesManagerInstance.SaveEquipStateKey = GetModSettingInt(a_ID)
	elseif a_ID == "iFavoriteToggleFocusKey:Controls"
		SKI_FavoritesManagerInstance.ToggleFocusKey = GetModSettingInt(a_ID)
	elseif a_ID == "iFavoriteGroupUseHotkey1:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(0, GetModSettingInt(a_ID))
	elseif a_ID == "iFavoriteGroupUseHotkey2:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(1, GetModSettingInt(a_ID))
	elseif a_ID == "iFavoriteGroupUseHotkey3:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(2, GetModSettingInt(a_ID))
	elseif a_ID == "iFavoriteGroupUseHotkey4:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(3, GetModSettingInt(a_ID))
	elseif a_ID == "iFavoriteGroupUseHotkey5:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(4, GetModSettingInt(a_ID))
	elseif a_ID == "iFavoriteGroupUseHotkey6:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(5, GetModSettingInt(a_ID))
	elseif a_ID == "iFavoriteGroupUseHotkey7:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(6, GetModSettingInt(a_ID))
	elseif a_ID == "iFavoriteGroupUseHotkey8:Controls"
		SKI_FavoritesManagerInstance.SetGroupHotkey(7, GetModSettingInt(a_ID))
	endif

	CheckGamepad()
endEvent


; ACTIONS -----------------------------------------------------------------------------------------

function ApplyItemListFontSize(int a_value)
	; Small
	if (a_value == 0)
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "12")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "13")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "16")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 0.3, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-25")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 2, 2>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 3, 2, 2>")
	; Medium
	elseIf (a_value == 1)
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "12")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "14")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "18")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 1.1, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-28")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 3, 3>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 3, 3, 3>")
	; Large
	else
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "14")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "18")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "20")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 0.4, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-30")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 3.2, 3.2>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 4, 3.2, 3.2>")
	endIf
endFunction

function Apply3DItemXOffset(float a_value)
	; Negative values shift the 3D item to the right
	if (DisablePositioning3DItem)
		Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", _fInventory3DItemPosXWide)
		Utility.SetINIFloat("fInventory3DItemPosX:Interface", _fInventory3DItemPosX)
		Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", _fMagic3DItemPosXWide)
		Utility.SetINIFloat("fMagic3DItemPosX:Interface", _fMagic3DItemPosX)
	else
		Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", (_itemXBaseW + a_value))
		Utility.SetINIFloat("fInventory3DItemPosX:Interface", (_itemXBase + a_value))
		Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", (_itemXBaseW + a_value))
		Utility.SetINIFloat("fMagic3DItemPosX:Interface", (_itemXBase + a_value))
	endIf
endFunction

function Apply3DItemYOffset(float a_value)
	; Negative values shift the 3D item to the bottom
	if (DisablePositioning3DItem)
		Utility.SetINIFloat("fInventory3DItemPosZWide:Interface", _fInventory3DItemPosZWide)
		Utility.SetINIFloat("fInventory3DItemPosZ:Interface", _fInventory3DItemPosZ)
		Utility.SetINIFloat("fMagic3DItemPosZWide:Interface", _fMagic3DItemPosZWide)
		Utility.SetINIFloat("fMagic3DItemPosZ:Interface", _fMagic3DItemPosZ)
	else
		Utility.SetINIFloat("fInventory3DItemPosZWide:Interface", (12 + a_value))
		Utility.SetINIFloat("fInventory3DItemPosZ:Interface", (16 + a_value))
		Utility.SetINIFloat("fMagic3DItemPosZWide:Interface", (12 + a_value))
		Utility.SetINIFloat("fMagic3DItemPosZ:Interface", (16 + a_value))
	endIf
endFunction

function Apply3DItemScale(float a_value)
	if (DisablePositioning3DItem)
		Utility.SetINIFloat("fInventory3DItemPosScaleWide:Interface", _fInventory3DItemPosScaleWide)
		Utility.SetINIFloat("fMagic3DItemPosScaleWide:Interface", _fMagic3DItemPosScaleWide)
		Utility.SetINIFloat("fInventory3DItemPosScale:Interface", _fInventory3DItemPosScale)
		Utility.SetINIFloat("fMagic3DItemPosScale:Interface", _fMagic3DItemPosScale)
	else
		Utility.SetINIFloat("fInventory3DItemPosScaleWide:Interface", a_value)
		Utility.SetINIFloat("fMagic3DItemPosScaleWide:Interface", a_value)
		Utility.SetINIFloat("fInventory3DItemPosScale:Interface", a_value)
		Utility.SetINIFloat("fMagic3DItemPosScale:Interface", a_value)
	endIf
endFunction

function ChooseFavoriteGroup(int a_value)
	int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
	int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_HANDS

	UnequipArmor = SKI_FavoritesManagerInstance.GetGroupFlag(a_value, ARMOR_FLAG)
	UnequipHands = SKI_FavoritesManagerInstance.GetGroupFlag(a_value, HANDS_FLAG)

	RefreshMenu()
endFunction

function ToggleUnequipArmor(bool a_value)
	int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
	SKI_FavoritesManagerInstance.SetGroupFlag(FavoriteCurrentGroup, ARMOR_FLAG, a_value)
	SetModSettingBool("bUnequipArmor:FavoriteGroup" + (FavoriteCurrentGroup + 1), a_value)
endFunction

function ToggleUnequipHands(bool a_value)
	int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_HANDS
	SKI_FavoritesManagerInstance.SetGroupFlag(FavoriteCurrentGroup, HANDS_FLAG, a_value)
	SetModSettingBool("bUnequipHands:FavoriteGroup" + (FavoriteCurrentGroup + 1), a_value)
endFunction


; FUNCTIONS ---------------------------------------------------------------------------------------

bool property DisablePositioning3DItem
	bool function get()
		return GetModSettingBool("bDisablePositioning:3DItem")
	endFunction
endProperty

function LoadSettings()
	if !MCM.IsInstalled()
		Debug.Trace("MCM Helper DLL is not installed or not correctly loaded.")
		return
	endIf

	; ItemList
	ApplyItemListFontSize(GetModSettingInt("iFontSize:ItemList"))
	SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", \
		GetModSettingInt("iQuantityMinCount:ItemList"))
	SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", \
		_categoryIconThemeValues[GetModSettingInt("iCategoryIconTheme:ItemList")])
	SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", \
		GetModSettingBool("bNoIconColors:ItemList"))

	; EffectWidget
	SKI_ActiveEffectsWidgetInstance.Enabled = GetModSettingBool("bEnabled:EffectWidget")
	SKI_ActiveEffectsWidgetInstance.EffectSize = _effectWidgetIconSizeValues[GetModSettingInt("iIconSize:EffectWidget")]
	SKI_ActiveEffectsWidgetInstance.Orientation = _orientationValues[GetModSettingInt("iOrientation:EffectWidget")]

	int effectWidgetHAnchorIdx = GetModSettingInt("iHorizontalAnchor:EffectWidget")
	SKI_ActiveEffectsWidgetInstance.HAnchor = _alignmentValues[effectWidgetHAnchorIdx]
	SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[effectWidgetHAnchorIdx] + GetModSettingInt("iXOffset:EffectWidget")

	int effectWidgetVAnchorIdx = GetModSettingInt("iVerticalAnchor:EffectWidget")
	SKI_ActiveEffectsWidgetInstance.VAnchor = _vertAlignmentValues[effectWidgetVAnchorIdx]
	SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[effectWidgetVAnchorIdx] + GetModSettingInt("iYOffset:EffectWidget")

	SKI_ActiveEffectsWidgetInstance.MinimumTimeLeft = GetModSettingInt("iMinTimeLeft:EffectWidget")
	SKI_ActiveEffectsWidgetInstance.GroupEffectCount = GetModSettingInt("iGroupEffectCount:EffectWidget")

	; ItemCard
	SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[GetModSettingInt("iAlign:ItemCard")])
	SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", GetModSettingInt("iXOffset:ItemCard"))
	SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", GetModSettingInt("iYOffset:ItemCard"))

	; FavoritesMenu
	SKI_FavoritesManagerInstance.ButtonHelpEnabled = GetModSettingBool("bHelpEnabled:FavoritesMenu")

	; FavoriteGroups
	int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
	int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_HANDS

	int GroupIdx = 0
	while GroupIdx < 8
		bool armorSetting = GetModSettingBool("bUnequipArmor:FavoriteGroup" + (GroupIdx + 1))
		bool handsSetting = GetModSettingBool("bUnequipHands:FavoriteGroup" + (GroupIdx + 1))
		SKI_FavoritesManagerInstance.SetGroupFlag(GroupIdx, ARMOR_FLAG, armorSetting)
		SKI_FavoritesManagerInstance.SetGroupFlag(GroupIdx, HANDS_FLAG, handsSetting)
		GroupIdx += 1
	endWhile

	; SWFVersionCheck
	SKI_MainInstance.MapMenuCheckEnabled = GetModSettingBool("bMapMenu:SWFVersionCheck")
	SKI_MainInstance.FavoritesMenuCheckEnabled = GetModSettingBool("bFavoritesMenu:SWFVersionCheck")
	SKI_MainInstance.InventoryMenuCheckEnabled = GetModSettingBool("bInventoryMenu:SWFVersionCheck")
	SKI_MainInstance.MagicMenuCheckEnabled = GetModSettingBool("bMagicMenu:SWFVersionCheck")
	SKI_MainInstance.BarterMenuCheckEnabled = GetModSettingBool("bBarterMenu:SWFVersionCheck")
	SKI_MainInstance.ContainerMenuCheckEnabled = GetModSettingBool("bContainerMenu:SWFVersionCheck")
	SKI_MainInstance.CraftingMenuCheckEnabled = GetModSettingBool("bCraftingMenu:SWFVersionCheck")
	SKI_MainInstance.GiftMenuCheckEnabled = GetModSettingBool("bGiftMenu:SWFVersionCheck")

	; Controls
	SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", GetModSettingInt("iSearchKey:Controls"))
	SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", GetModSettingInt("iSwitchTabKey:Controls"))
	SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", GetModSettingInt("iEquipModeKey:Controls"))
	SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", GetModSettingInt("iSwitchTabButton:Controls"))
	SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", GetModSettingInt("iPreviousColumnButton:Controls"))
	SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", GetModSettingInt("iNextColumnButton:Controls"))
	SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", GetModSettingInt("iSortOrderButton:Controls"))

	SKI_FavoritesManagerInstance.GroupAddKey = GetModSettingInt("iFavoriteGroupAddKey:Controls")
	SKI_FavoritesManagerInstance.GroupUseKey = GetModSettingInt("iFavoriteGroupUseKey:Controls")
	SKI_FavoritesManagerInstance.SetIconKey = GetModSettingInt("iFavoriteSetIconKey:Controls")
	SKI_FavoritesManagerInstance.SaveEquipStateKey = GetModSettingInt("iFavoriteEquipStateKey:Controls")
	SKI_FavoritesManagerInstance.ToggleFocusKey = GetModSettingInt("iFavoriteToggleFocusKey:Controls")
	SKI_FavoritesManagerInstance.SetGroupHotkey(0, GetModSettingInt("iFavoriteGroupUseHotkey1:Controls"))
	SKI_FavoritesManagerInstance.SetGroupHotkey(1, GetModSettingInt("iFavoriteGroupUseHotkey2:Controls"))
	SKI_FavoritesManagerInstance.SetGroupHotkey(2, GetModSettingInt("iFavoriteGroupUseHotkey3:Controls"))
	SKI_FavoritesManagerInstance.SetGroupHotkey(3, GetModSettingInt("iFavoriteGroupUseHotkey4:Controls"))
	SKI_FavoritesManagerInstance.SetGroupHotkey(4, GetModSettingInt("iFavoriteGroupUseHotkey5:Controls"))
	SKI_FavoritesManagerInstance.SetGroupHotkey(5, GetModSettingInt("iFavoriteGroupUseHotkey6:Controls"))
	SKI_FavoritesManagerInstance.SetGroupHotkey(6, GetModSettingInt("iFavoriteGroupUseHotkey7:Controls"))
	SKI_FavoritesManagerInstance.SetGroupHotkey(7, GetModSettingInt("iFavoriteGroupUseHotkey8:Controls"))

	ApplySettings()
endFunction

function ApplySettings()
	; Apply settings that aren't handled by SKI_SettingsManagerInstance

	_fInventory3DItemPosXWide		= Utility.GetINIFloat("fInventory3DItemPosXWide:Interface")
	_fInventory3DItemPosX 			= Utility.GetINIFloat("fInventory3DItemPosX:Interface")
	_fMagic3DItemPosXWide 			= Utility.GetINIFloat("fMagic3DItemPosXWide:Interface")
	_fMagic3DItemPosX 				= Utility.GetINIFloat("fMagic3DItemPosX:Interface")

	_fInventory3DItemPosZWide		= Utility.GetINIFloat("fInventory3DItemPosZWide:Interface")
	_fInventory3DItemPosZ 			= Utility.GetINIFloat("fInventory3DItemPosZ:Interface")
	_fMagic3DItemPosZWide 			= Utility.GetINIFloat("fMagic3DItemPosZWide:Interface")
	_fMagic3DItemPosZ 				= Utility.GetINIFloat("fMagic3DItemPosZ:Interface")

	_fInventory3DItemPosScaleWide	= Utility.GetINIFloat("fInventory3DItemPosScaleWide:Interface")
	_fMagic3DItemPosScaleWide		= Utility.GetINIFloat("fMagic3DItemPosScaleWide:Interface")
	_fInventory3DItemPosScale		= Utility.GetINIFloat("fInventory3DItemPosScale:Interface")
	_fMagic3DItemPosScale			= Utility.GetINIFloat("fMagic3DItemPosScale:Interface")

	float h = Utility.GetINIInt("iSize H:Display")
	float w = Utility.GetINIInt("iSize W:Display")
	float ar = w / h

	; Widescreen
	if (ar == 1.6) ; 16:10, 1920×1200
		_itemXBaseW = -32.458335876465
	else
		_itemXBaseW = -29.122497558594
	endIf

	; Non-widescreen
	if (ar == 1.25) ; 5:4, 1280x1024
		_itemXBase = -41.622497558594
	else
		_itemXBase = -39.122497558594
	endIf

	Apply3DItemXOffset(GetModSettingFloat("fXOffset:3DItem"))
	Apply3DItemYOffset(GetModSettingFloat("fYOffset:3DItem"))
	Apply3DItemScale(GetModSettingFloat("fScale:3DItem"))
endFunction

function CheckGamepad()
	bool wasGamepad = IsGamepad
	IsGamepad = Game.UsingGamepad()

	if wasGamepad != IsGamepad
		ForcePageReset()
	endif
endFunction


; REMOVED DATA  -----------------------------------------------------------------------------------
											
; -- Version 1 --							; (remove version)

; int		_itemlistFontSizeOID_T			; (4)
; int		_itemlistQuantityMinCountOID_S	; (4)
; int		_itemcardAlignOID_T				; (4)
; int		_itemcardXOffsetOID_S			; (4)
; int		_itemcardYOffsetOID_S			; (4)
; int		_3DItemXOffsetOID_S				; (4)
; int		_3DItemYOffsetOID_S				; (4)
; int		_3DItemScaleOID_S				; (4)
; int		_checkInventoryMenuOID_B		; (4)
; int		_checkMagicMenuOID_B			; (4)
; int		_checkBarterMenuOID_B			; (4)
; int		_checkContainerMenuOID_B		; (4)
; int		_checkGiftMenuOID_B				; (4)
; int		_searchKeyOID_K					; (4)
; int		_switchTabKeyOID_K				; (4)
; int		_equipModeKeyOID_K				; (4)
; string[]	_alignments						; (MCM Helper)
; string[]	_sizes							; (MCM Helper)
; int		_itemlistFontSizeIdx			; (MCM Helper)
; int		_itemlistQuantityMinCount		; (MCM Helper)
; int		_itemcardAlignIdx				; (MCM Helper)
; float		_itemcardXOffset				; (MCM Helper)
; float		_itemcardYOffset				; (MCM Helper)
; float		_3DItemXOffset					; (MCM Helper)
; float		_3DItemYOffset					; (MCM Helper)
; float		_3DItemScale					; (MCM Helper)
; int		_searchKey						; (MCM Helper)
; int		_switchTabKey					; (MCM Helper)
; int		_equipModeKey					; (MCM Helper)


; -- Version 2 --

; int		_itemlistCategoryIconThemeOID_M	; (4)
; int		_itemlistNoIconColorsOID_B 		; (4)
; int		_switchTabButtonOID_K 			; (4)
; int		_prevColumnButtonOID_K 			; (4)
; int		_nextColumnButtonOID_K 			; (4)
; int		_sortOrderButtonOID_K 			; (4)
; string[]	_categoryIconThemeShortNames	; (MCM Helper)
; string[]	_categoryIconThemeLongNames		; (MCM Helper)
; int		_categoryIconThemeIdx			; (MCM Helper)
; bool		_itemlistNoIconColors			; (MCM Helper)
; int		_switchTabButton				; (MCM Helper)
; int		_prevColumnButton				; (MCM Helper)
; int		_nextColumnButton				; (MCM Helper)
; int		_sortOrderButton				; (MCM Helper)


; -- Version 3 --

; int		_3DItemDisablePositioningOID_B	; (4)
; bool		_3DItemDisablePositioning		; (MCM Helper)
; int		_3DItemFlags					; (MCM Helper)


; -- Version 4 --
; string[]	_orientations					; (MCM Helper)
; string[]	_vertAlignments					; (MCM Helper)
; int		_effectWidgetIconSizeIdx		; (MCM Helper)
; int		_effectWidgetVAnchorIdx			; (MCM Helper)
; int		_effectWidgetHAnchorIdx			; (MCM Helper)
; int		_effectWidgetGroupCount			; (MCM Helper)
; int		_effectWidgetOrientationIdx		; (MCM Helper)
; float		_effectWidgetXOffset			; (MCM Helper)
; float		_effectWidgetYOffset			; (MCM Helper)
; int		_effectWidgetFlags				; (MCM Helper)


; -- Version 6 --

; string[]	_favGroupNames					; (MCM Helper)
; int		_favCurGroupIdx					; (MCM Helper)
