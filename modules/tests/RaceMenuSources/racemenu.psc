Scriptname RaceMenu extends RaceMenuBase

; --------- Constants DO NOT EDIT ----------------
int Property TINT_TYPE_HAIR = 128 AutoReadOnly
int Property TINT_TYPE_BODYPAINT = 256 AutoReadOnly
int Property TINT_TYPE_HANDPAINT = 257 AutoReadOnly
int Property TINT_TYPE_FEETPAINT = 258 AutoReadOnly
int Property TINT_TYPE_FACEPAINT = 259 AutoReadOnly

int Property MAX_PRESETS = 4 AutoReadOnly
int Property MAX_MORPHS = 19 AutoReadOnly
;--------------------------------------------------

; Minimum SKSE version statistics
int Property SKSE_MAJOR_VERSION = 2 AutoReadOnly
int Property SKSE_MINOR_VERSION = 0 AutoReadOnly
int Property SKSE_BETA_VERSION = 7 AutoReadOnly
int Property SKSE_RELEASE_VERSION = 56 AutoReadOnly

; Minimum RaceMenuBase version
int Property RACEMENUBASE_SCRIPT_VERSION = 7 AutoReadOnly

; CharGen version data
int Property CHARGEN_SCRIPT_VERSION = 4 AutoReadOnly

; NiOverride version data
int Property SKEE_VERSION = 1 AutoReadOnly
int Property NIOVERRIDE_SCRIPT_VERSION = 6 AutoReadOnly

string Property DEFAULT_OVERLAY = "Actors\\Character\\Overlays\\Default.dds" AutoReadOnly
; -------------------------------------------------

ColorForm _hairColor = None
Form _lightForm = None
ObjectReference _light = None
int _color = 0
bool _customHair = false
int[] _tintTypes = None
int[] _tintColors = None
string[] _tintTextures = None
int[] _presets = None
float[] _morphs = None

bool hasInitialized = false


Event OnInitialized()
	parent.OnInitialized()

	_hairColor = Game.GetFormFromFile(0x801, "RaceMenu.esp") as ColorForm
	_lightForm = Game.GetFormFromFile(0x803, "RaceMenu.esp")
	
	_tintTextures = new string[128]
	_tintTypes = new int[128]
	_tintColors = new int[128]
	_presets = new int[4]
	_morphs = new float[19]
EndEvent


Function RegisterEvents()
	RegisterForModEvent("RSM_Initialized", "OnMenuInitialized") ; Event sent when the menu initializes enough to load data
	RegisterForModEvent("RSM_Reinitialized", "OnMenuReinitialized") ; Event sent when sliders have re-initialized
	RegisterForModEvent("RSM_HairColorChange", "OnHairColorChange") ; Event sent when hair color changes
	RegisterForModEvent("RSM_TintColorChange", "OnTintColorChange") ; Event sent when a tint changes color
	RegisterForModEvent("RSM_TintTextureChange", "OnTintTextureChange") ; Event sent when a tint changes texture
	RegisterForModEvent("RSM_ToggleLight", "OnToggleLight") ; Event sent when the Light button is pressed
	RegisterForModEvent("RSM_RequestTintSave", "OnTintSave") ; User-sent event to request tint save
	RegisterForModEvent("RSM_RequestTintLoad", "OnTintLoad") ; User-sent event to request tint load
	RegisterForModEvent("RSM_SliderChange", "OnMenuSliderChange") ; Event sent when a slider's value is changed

	; Overlay Management
	RegisterForModEvent("RSM_OverlayTextureChange", "OnOverlayTextureChange") ; Event sent when an overlay's texture changes
	RegisterForModEvent("RSM_OverlayColorChange", "OnOverlayColorChange") ; Event sent when an overlay's color changes
	RegisterForModEvent("RSM_OverlayGlowColorChange", "OnOverlayGlowColorChange") ; Event sent when an overlay's color changes
	RegisterForModEvent("RSM_ShadersInvalidated", "OnShadersInvalidated")

	; Handles clipboard data transfer DO NOT EDIT
	RegisterForModEvent("RSM_RequestLoadClipboard", "OnLoadClipboard")
	RegisterForModEvent("RSM_RequestSaveClipboard", "OnSaveClipboard")

	RegisterForModEvent("RSM_ClipboardData", "OnClipboardData")
	RegisterForModEvent("RSM_ClipboardFinished", "OnClipboardFinished")
	; --------------------------------------------

	; RaceSexMenu Data Transfer
	RegisterForModEvent("RSMDT_SendMenuName", "OnReceiveMenuName")
	RegisterForModEvent("RSMDT_SendRootName", "OnReceiveRootName")
	RegisterForModEvent("RSMDT_SendDataRequest", "OnReceiveDataRequest")
	RegisterForModEvent("RSMDT_SendRestore", "OnReceiveRestore")
	; --------------------------------------------

	RegisterForNiNodeUpdate()
EndFunction


Function OnStartup()
	RegisterForMenu(RACESEX_MENU)

	RegisterEvents()

	Utility.SetINIFloat("fPlayerBodyEditDistance:Interface", 190.0)
	Utility.SetINIFloat("fPlayerFaceEditDistance:Interface", 70.0)

	; Re-initialization in case of init failure?
	Reinitialize()

	string startupError = ""
	string errorCodes = ""
	
	; SKSE Version Check
	If SKSE.GetVersionRelease() < SKSE_RELEASE_VERSION
		startupError += ("You are running SKSE Version " + SKSE.GetVersion() + "." + SKSE.GetVersionMinor() + "." + SKSE.GetVersionBeta() + "." + SKSE.GetVersionRelease() + " expected "+SKSE_MAJOR_VERSION+"."+SKSE_MINOR_VERSION+"."+SKSE_BETA_VERSION+"."+SKSE_RELEASE_VERSION+" or greater. ")
		errorCodes += "(0)"
	Endif
	If SKSE.GetVersionRelease() != SKSE.GetScriptVersionRelease()
		startupError += ("SKSE script version mismatch detected (" + SKSE.GetScriptVersionRelease() + ") expected (" + SKSE.GetVersionRelease() + "). Please reinstall your SKSE scripts to match your version. ")
		errorCodes += "(1)"
	Endif

	; RaceMenu version check
	If RaceMenuBase.GetScriptVersionRelease() < RACEMENUBASE_SCRIPT_VERSION
		startupError += ("Invalid RaceMenuBase script version detected (" + RaceMenuBase.GetScriptVersionRelease() + ") expected (" + RACEMENUBASE_SCRIPT_VERSION + "). Please update your base script. ")
		errorCodes += "(2)"
	Endif

	; Plugin version check
	int skeeVersion = SKSE.GetPluginVersion("skee")

	int chargenScriptVersion = CharGen.GetScriptVersion()
	int nioverrideScriptVersion = NiOverride.GetScriptVersion()

	; Plugins not installed
	If skeeVersion == 0
		startupError += ("NiOverride plugin not detected, various features may be unavailable. ")
		errorCodes += "(3)"
	Endif

	; Scripts not installed
	If nioverrideScriptVersion == 0
		startupError += ("NiOverride script not detected, various features may be unavailable. ")
		errorCodes += "(5)"
	Endif
	If chargenScriptVersion == 0
		startupError += ("CharGen script not detected, various features may be unavailable. ")
		errorCodes += "(6)"
	Endif

	; Plugin installed but wrong version
	If skeeVersion > 0 && skeeVersion < SKEE_VERSION
		startupError += ("Invalid NiOverride plugin version detected (" + skeeVersion + ") expected (" + SKEE_VERSION + "). ")
		errorCodes += "(7)"
	Endif

	; Plugins installed but scripts wrong version
	If nioverrideScriptVersion > 0 && nioverrideScriptVersion < NIOVERRIDE_SCRIPT_VERSION
		startupError += ("Invalid NiOverride script version detected (" + nioverrideScriptVersion + ") expected (" + NIOVERRIDE_SCRIPT_VERSION + "). ")
		errorCodes += "(9)"
	Endif
	If chargenScriptVersion > 0 && chargenScriptVersion < CHARGEN_SCRIPT_VERSION
		startupError += ("Invalid CharGen script version detected (" + chargenScriptVersion + ") expected (" + CHARGEN_SCRIPT_VERSION + "). ")
		errorCodes += "(10)"
	Endif

	If startupError != ""
		Debug.MessageBox("RaceMenu Error(s): " + startupError + "\nError Codes: " + errorCodes)
	Endif

	_targetRoot = RACESEX_MENU
	_targetMenu = MENU_ROOT
	_targetActor = _playerActor
	_targetActorBase = _targetActor.GetActorBase()
EndFunction


Function Reinitialize()
	If !_hairColor
		_hairColor = Game.GetFormFromFile(0x801, "RaceMenu.esp") as ColorForm
	Endif
	If !_lightForm
		_lightForm = Game.GetFormFromFile(0x803, "RaceMenu.esp")
	Endif
	If !_tintTextures
		_tintTextures = new string[128]
	Endif
	If !_tintTypes
		_tintTypes = new int[128]
	Endif
	If !_tintColors
		_tintColors = new int[128]
	EndIf
	If !_presets
		_presets = new int[4]
	Endif
	If !_morphs
		_morphs = new float[19]
	Endif
	parent.Reinitialize()
EndFunction


Event OnGameReload()
	OnStartup()

	LoadDefaults()

	; Reload player settings
	LoadHair()
	LoadTints()
	UpdateTints()
	SendModEvent("RSM_LoadPlugins")
EndEvent


Function UpdateTints()
	If _playerActor.IsOnMount()
		Game.UpdateHairColor()
		Game.UpdateTintMaskColors()
		SendModEvent("RSM_ShadersInvalidated") ; Needs to be an event for sufficient update time
	Else
		_playerActor.QueueNiNodeUpdate()
	Endif
EndFunction


Event OnNiNodeUpdate(ObjectReference akRef)
	If akRef == _targetActor
		InvalidateShaders()
	Endif
EndEvent


Event On3DLoaded(ObjectReference akRef)
	If !UI.IsMenuOpen(RACESEX_MENU)
		LoadHair()
		LoadTints()
		UpdateTints()
	Endif
EndEvent


Event OnMenuOpen(string menuName)
	If menuName == RACESEX_MENU
		If SKSE.GetPluginVersion("skee") >= 1
			NiOverride.EnableTintTextureCache()
		Endif

		_targetMenu = RACESEX_MENU
		_targetRoot = MENU_ROOT
		_targetActor = _playerActor

		UpdateRaces()
		_light = _playerActor.placeAtMe(_lightForm)
		float zOffset = _light.GetHeadingAngle(_playerActor)
		_light.SetAngle(_light.GetAngleX(), _light.GetAngleY(), _light.GetAngleZ() + zOffset)
		_light.MoveTo(_playerActor, 60 * Math.Sin(_playerActor.GetAngleZ()), 60 * Math.Cos(_playerActor.GetAngleZ()), _playerActor.GetHeight())
	Endif
EndEvent


Event OnMenuClose(string menuName)
	If menuName == RACESEX_MENU
		_light.Delete()
		_light = None
		SaveHair()
		SaveTints()
		If SKSE.GetPluginVersion("skee") >= 1
			NiOverride.ReleaseTintTextureCache()
		Endif
	Endif
EndEvent


Event OnMenuInitialized(string eventName, string strArg, float numArg, Form formArg)
	LoadDefaults()
	UpdateColors()
	UpdateOverlays()
	LoadTints()
	LoadHair()
	UpdateTints()
	parent.OnMenuInitialized(eventName, strArg, numArg, formArg)
EndEvent


Event OnMenuReinitialized(string eventName, string strArg, float numArg, Form formArg)
	SaveHair()
	SaveTints()
	UpdateColors()
	UpdateOverlays()
EndEvent


Event OnMenuSliderChange(string eventName, string strArg, float numArg, Form formArg)
	If strArg == "ChangeTintingMask" || strArg == "ChangeMaskColor"
		SaveTints()
		UpdateColors()
	Elseif strArg == "ChangeHairColorPreset"
		SaveHair()
		UpdateColors()
	Endif
EndEvent


Function LoadHair()
	If _customHair
		_hairColor.SetColor(_color)
		_playerActorBase.SetHairColor(_hairColor)
	EndIf
EndFunction


Function SaveHair()
	ColorForm hairColor = _playerActorBase.GetHairColor()
	If hairColor == _hairColor
		_color = hairColor.GetColor() + 0xFF000000
		_customHair = true
	Elseif hairColor != None
		_color = hairColor.GetColor() + 0xFF000000
		_customHair = false
	Else
		_color = 0xFF000000
		_customHair = false
	EndIf
EndFunction


Function LoadTints()
	int i = 0
	int totalTints = Game.GetNumTintMasks()
	While i < totalTints
		int color = _tintColors[i]
		string texture = _tintTextures[i]
		If texture != ""
			Game.SetNthTintMaskTexturePath(texture, i)
		Endif
		If color != 0
			Game.SetNthTintMaskColor(i, color)
		Endif
		i += 1
	EndWhile
EndFunction


Function SaveTints()
	int totalTints = Game.GetNumTintMasks()
	int i = 0
	While i < totalTints
		_tintTypes[i] = Game.GetNthTintMaskType(i)
		_tintColors[i] = Game.GetNthTintMaskColor(i)
		_tintTextures[i] = Game.GetNthTintMaskTexturePath(i)
		i += 1
	EndWhile
	; Clear the remaining tints
	totalTints = _tintTypes.length
	While i < totalTints
		_tintTypes[i] = 0
		_tintColors[i] = 0
		_tintTextures[i] = ""
		i += 1
	EndWhile
EndFunction


Function LoadPresets()
	int totalPresets = MAX_PRESETS
	int i = 0
	While i < totalPresets
		_playerActorBase.SetFacePreset(_presets[i], i)
		i += 1
	EndWhile
EndFunction


Function SavePresets()
	int totalPresets = MAX_PRESETS
	int i = 0
	While i < totalPresets
		_presets[i] = _playerActorBase.GetFacePreset(i)
		i += 1
	EndWhile
EndFunction


Function LoadMorphs()
	int totalMorphs = MAX_MORPHS
	int i = 0
	While i < totalMorphs
		_playerActorBase.SetFaceMorph(_morphs[i], i)
		i += 1
	EndWhile
EndFunction


Function SaveMorphs()
	int totalMorphs = MAX_MORPHS
	int i = 0
	While i < totalMorphs
		_morphs[i] = _playerActorBase.GetFaceMorph(i)
		i += 1
	EndWhile
EndFunction


Function ClearTints()
	int i = 0
	int totalTints = _tintTypes.length
	While i < totalTints
		_tintTypes[i] = 0
		_tintColors[i] = 0
		_tintTextures[i] = ""
		i += 1
	EndWhile
EndFunction


Event OnHairColorChange(string eventName, string strArg, float numArg, Form formArg)
	_color = strArg as int
 	_hairColor.SetColor(_color)
	_playerActorBase.SetHairColor(_hairColor)
	Game.UpdateHairColor()
EndEvent


Event OnTintColorChange(string eventName, string strArg, float numArg, Form formArg)
	int color = strArg as int
	int arg = numArg as int
	int type = arg / 1000
	int index = arg - (type * 1000)
	Game.SetTintMaskColor(color, type, index)
	Game.UpdateTintMaskColors()
	SendModEvent("RSM_ShadersInvalidated")
EndEvent


Event OnTintTextureChange(string eventName, string strArg, float numArg, Form formArg)
	string texture = strArg
	int arg = numArg as int
	int type = arg / 1000
	int index = arg - (type * 1000)
	Game.SetTintMaskTexturePath(strArg, type, index)
	Game.UpdateTintMaskColors()
	SendModEvent("RSM_ShadersInvalidated")
EndEvent


Event OnOverlayGlowColorChange(string eventName, string strArg, float numArg, Form formArg)
	int color = strArg as int
	int arg = numArg as int
	int type = arg / 1000
	int index = arg - (type * 1000)

	string nodeName = ""
	If type == TINT_TYPE_BODYPAINT
		nodeName += "Body [Ovl"
	Elseif type == TINT_TYPE_HANDPAINT
		nodeName += "Hands [Ovl"
	Elseif type == TINT_TYPE_FEETPAINT
		nodeName += "Feet [Ovl"
	Elseif type == TINT_TYPE_FACEPAINT
		nodeName += "Face [Ovl"
	Endif
	nodeName += index + "]"

	ActorBase targetBase = _targetActor.GetActorBase()
	bool isFemale = targetBase.GetSex() as bool
	If SKSE.GetPluginVersion("skee") >= 1 ; Checks to make sure the NiOverride plugin exists
		int alpha = Math.RightShift(color, 24)
		NiOverride.AddNodeOverrideInt(_targetActor, isFemale, nodeName, 0, -1, color, true) ; Set the emissive color
		NiOverride.AddNodeOverrideFloat(_targetActor, isFemale, nodeName, 1, -1, alpha / 10.0, true) ; Set the emissive multiple
	Endif
EndEvent


Event OnOverlayColorChange(string eventName, string strArg, float numArg, Form formArg)
	int color = strArg as int
	int arg = numArg as int
	int type = arg / 1000
	int index = arg - (type * 1000)

	string nodeName = ""
	If type == TINT_TYPE_BODYPAINT
		nodeName += "Body [Ovl"
	Elseif type == TINT_TYPE_HANDPAINT
		nodeName += "Hands [Ovl"
	Elseif type == TINT_TYPE_FEETPAINT
		nodeName += "Feet [Ovl"
	Elseif type == TINT_TYPE_FACEPAINT
		nodeName += "Face [Ovl"
	Endif
	nodeName += index + "]"

	ActorBase targetBase = _targetActor.GetActorBase()
	bool isFemale = targetBase.GetSex() as bool
	If SKSE.GetPluginVersion("skee") >= 1 ; Checks to make sure the NiOverride plugin exists
		int alpha = Math.RightShift(color, 24)
		NiOverride.AddNodeOverrideInt(_targetActor, isFemale, nodeName, 7, -1, color, true) ; Set the tint color
		NiOverride.AddNodeOverrideFloat(_targetActor, isFemale, nodeName, 8, -1, alpha / 255.0, true) ; Set the alpha
	Endif
EndEvent


Event OnOverlayTextureChange(string eventName, string strArg, float numArg, Form formArg)
	string texture = strArg
	int arg = numArg as int
	int type = arg / 1000
	int index = arg - (type * 1000)

	int overlayMask = 0
	string nodeName = ""
	If type == TINT_TYPE_BODYPAINT
		nodeName += "Body [Ovl"
		overlayMask = 4
	Elseif type == TINT_TYPE_HANDPAINT
		nodeName += "Hands [Ovl"
		overlayMask = 8
	Elseif type == TINT_TYPE_FEETPAINT
		nodeName += "Feet [Ovl"
		overlayMask = 128
	Elseif type == TINT_TYPE_FACEPAINT
		nodeName += "Face [Ovl"
	Endif
	nodeName += index + "]"

	ActorBase targetBase = _targetActor.GetActorBase()
	bool isFemale = targetBase.GetSex() as bool
	If SKSE.GetPluginVersion("skee") >= 1
		If type == TINT_TYPE_BODYPAINT || type == TINT_TYPE_HANDPAINT || type == TINT_TYPE_FEETPAINT
			NiOverride.RevertOverlay(_targetActor, nodeName, overlayMask, overlayMask)
		Elseif type == TINT_TYPE_FACEPAINT
			NiOverride.RevertHeadOverlay(_targetActor, nodeName, 1, 4) ; FacePart, FaceTint
		Endif
		int strIndex = StringUtil.Find(strArg, "|", 0)
		int i = 0
		If strIndex != -1
			int lastIndex = 0
			While strIndex != -1 && i < 9
				string texturePath = StringUtil.Substring(strArg, lastIndex, strIndex - lastIndex)
				if texturePath != "ignore"
					NiOverride.AddNodeOverrideString(_targetActor, isFemale, nodeName, 9, i, texturePath, true)
				Endif
				lastIndex = strIndex + 1
				strIndex = StringUtil.Find(strArg, "|", lastIndex)
				i += 1
			EndWhile
		Else
			NiOverride.AddNodeOverrideString(_targetActor, isFemale, nodeName, 9, 0, texture, true) ; Set the tint texture
		Endif
	Endif
EndEvent


Function InvalidateShaders()
	If SKSE.GetPluginVersion("skee") >= 1
		NiOverride.ApplyOverrides(_targetActor)
		NiOverride.ApplyNodeOverrides(_targetActor)
		NiOverride.ApplySkinOverrides(_targetActor)
	Endif
EndFunction


Event OnShadersInvalidated(string eventName, string strArg, float numArg, Form formArg)
	InvalidateShaders()
EndEvent


Event OnToggleLight(string eventName, string strArg, float numArg, Form formArg)
	bool lightOn = numArg as bool
	If _light
		if lightOn
			_light.EnableNoWait()
		Else
			_light.DisableNoWait()
		Endif
	Endif
EndEvent


Event OnTintSave(string eventName, string strArg, float numArg, Form formArg)
	SaveHair()
	SaveTints()
EndEvent


Event OnTintLoad(string eventName, string strArg, float numArg, Form formArg)
	LoadTints()
	UpdateColors()
	UpdateOverlays()
	Game.UpdateTintMaskColors()
	SendModEvent("RSM_ShadersInvalidated")
EndEvent

; ------------------------------- Clipboard Events -----------------------------------

Event OnLoadClipboard(string eventName, string strArg, float numArg, Form formArg)
	UI.InvokeBool(_targetMenu, _targetRoot + "RSM_ToggleLoader", true)
	UI.Invoke(_targetMenu, _targetRoot + "RSM_LoadClipboard")
EndEvent


Event OnSaveClipboard(string eventName, string strArg, float numArg, Form formArg)
	SavePresets()
	SaveMorphs()
	float[] args = new float[23]
	int i = 0
	While i < MAX_PRESETS
		args[i] = _presets[i]
		i += 1
	EndWhile
	i = 0
	While i < MAX_MORPHS
		args[i + 4] = _morphs[i]
		i += 1
	EndWhile

	UI.InvokeFloatA(_targetMenu, _targetRoot + "RSM_SaveClipboard", args)
EndEvent


Event OnClipboardData(string eventName, string strArg, float numArg, Form formArg)
	int index = strArg as int
	If index < 4
		_presets[index] = numArg as int
	Else
		index = index - 4
		_morphs[index] = numArg
	Endif
EndEvent


Event OnClipboardFinished(string eventName, string strArg, float numArg, Form formArg)
	LoadPresets()
	LoadMorphs()
	_playerActor.QueueNiNodeUpdate()
	UI.InvokeBool(_targetMenu, _targetRoot + "RSM_ToggleLoader", false)
EndEvent
; ------------------------------------------------------------------------------------

; VoiceType Function GetVoiceType(bool female, int index)
; 	If female == false
; 		return _maleVoiceTypes[index]
; 	Elseif female == true
; 		return _femaleVoiceTypes[index]
; 	Endif
; 	return None
; EndFunction

; int Function GetVoiceTypeIndex(bool female, VoiceType aVoice)
; 	If female == false
; 		int i = 0
; 		While i < 25
; 			If _maleVoiceTypes[i] == aVoice
; 				return i
; 			Endif
; 			i += 1
; 		EndWhile
; 	Elseif female == true
; 		int i = 0
; 		While i < 18
; 			If _femaleVoiceTypes[i] == aVoice
; 				return i
; 			Endif
; 			i += 1
; 		EndWhile
; 	EndIf
; 	return -1
; EndFunction

; Function LoadVoiceTypes()
; 	; Avoid adding properties to script
; 	_maleVoiceTypes[0] = Game.GetFormFromFile(0xea267, "Skyrim.esm") as VoiceType ; MaleEvenTonedAccented
; 	_maleVoiceTypes[1] = Game.GetFormFromFile(0xea266, "Skyrim.esm") as VoiceType ; MaleCommonerAccented
; 	_maleVoiceTypes[2] = Game.GetFormFromFile(0xaa8d3, "Skyrim.esm") as VoiceType ; MaleGuard
; 	_maleVoiceTypes[3] = Game.GetFormFromFile(0x9844f, "Skyrim.esm") as VoiceType ; MaleForsworn
; 	_maleVoiceTypes[4] = Game.GetFormFromFile(0x9843b, "Skyrim.esm") as VoiceType ; MaleBandit
; 	_maleVoiceTypes[5] = Game.GetFormFromFile(0x9843a, "Skyrim.esm") as VoiceType ; MaleWarlock
; 	_maleVoiceTypes[6] = Game.GetFormFromFile(0xe5003, "Skyrim.esm") as VoiceType ; MaleNordCommander
; 	_maleVoiceTypes[7] = Game.GetFormFromFile(0x13af2, "Skyrim.esm") as VoiceType ; MaleDarkElf
; 	_maleVoiceTypes[8] = Game.GetFormFromFile(0x13af0, "Skyrim.esm") as VoiceType ; MaleElfHaughty
; 	_maleVoiceTypes[9] = Game.GetFormFromFile(0x13aee, "Skyrim.esm") as VoiceType ; MaleArgonian
; 	_maleVoiceTypes[10] = Game.GetFormFromFile(0x13aec, "Skyrim.esm") as VoiceType ; MaleKhajiit
; 	_maleVoiceTypes[11] = Game.GetFormFromFile(0x13aea, "Skyrim.esm") as VoiceType ; MaleOrc
; 	_maleVoiceTypes[12] = Game.GetFormFromFile(0x13ae8, "Skyrim.esm") as VoiceType ; MaleChild
; 	_maleVoiceTypes[13] = Game.GetFormFromFile(0x13ae6, "Skyrim.esm") as VoiceType ; MaleNord
; 	_maleVoiceTypes[14] = Game.GetFormFromFile(0x13adb, "Skyrim.esm") as VoiceType ; MaleCoward
; 	_maleVoiceTypes[15] = Game.GetFormFromFile(0x13ada, "Skyrim.esm") as VoiceType ; MaleBrute
; 	_maleVoiceTypes[16] = Game.GetFormFromFile(0x13ad9, "Skyrim.esm") as VoiceType ; MaleCondescending
; 	_maleVoiceTypes[17] = Game.GetFormFromFile(0x13ad8, "Skyrim.esm") as VoiceType ; MaleCommander
; 	_maleVoiceTypes[18] = Game.GetFormFromFile(0x13ad7, "Skyrim.esm") as VoiceType ; MaleOldGrumpy
; 	_maleVoiceTypes[19] = Game.GetFormFromFile(0x13ad6, "Skyrim.esm") as VoiceType ; MaleOldKindly
; 	_maleVoiceTypes[20] = Game.GetFormFromFile(0x13ad5, "Skyrim.esm") as VoiceType ; MaleSlyCynical
; 	_maleVoiceTypes[21] = Game.GetFormFromFile(0x13ad4, "Skyrim.esm") as VoiceType ; MaleDrunk
; 	_maleVoiceTypes[22] = Game.GetFormFromFile(0x13ad3, "Skyrim.esm") as VoiceType ; MaleCommoner
; 	_maleVoiceTypes[23] = Game.GetFormFromFile(0x13ad2, "Skyrim.esm") as VoiceType ; MaleEvenToned
; 	_maleVoiceTypes[24] = Game.GetFormFromFile(0x13ad1, "Skyrim.esm") as VoiceType ; MaleYoungEager

; 	_femaleVoiceTypes[0] = Game.GetFormFromFile(0x1b560, "Skyrim.esm") as VoiceType ; FemaleSoldier
; 	_femaleVoiceTypes[1] = Game.GetFormFromFile(0x13bc3, "Skyrim.esm") as VoiceType ; FemaleShrill
; 	_femaleVoiceTypes[2] = Game.GetFormFromFile(0x13af3, "Skyrim.esm") as VoiceType ; FemaleDarkElf
; 	_femaleVoiceTypes[3] = Game.GetFormFromFile(0x13af1, "Skyrim.esm") as VoiceType ; FemaleElfHaughty
; 	_femaleVoiceTypes[4] = Game.GetFormFromFile(0x13aef, "Skyrim.esm") as VoiceType ; FemaleArgonian
; 	_femaleVoiceTypes[5] = Game.GetFormFromFile(0x13aed, "Skyrim.esm") as VoiceType ; FemaleKhajiit
; 	_femaleVoiceTypes[6] = Game.GetFormFromFile(0x13aeb, "Skyrim.esm") as VoiceType ; FemaleOrc
; 	_femaleVoiceTypes[7] = Game.GetFormFromFile(0x13ae9, "Skyrim.esm") as VoiceType ; FemaleChild
; 	_femaleVoiceTypes[8] = Game.GetFormFromFile(0x13ae7, "Skyrim.esm") as VoiceType ; FemaleNord
; 	_femaleVoiceTypes[9] = Game.GetFormFromFile(0x13ae5, "Skyrim.esm") as VoiceType ; FemaleCoward
; 	_femaleVoiceTypes[10] = Game.GetFormFromFile(0x13ae4, "Skyrim.esm") as VoiceType ; FemaleCondescending
; 	_femaleVoiceTypes[11] = Game.GetFormFromFile(0x13ae3, "Skyrim.esm") as VoiceType ; FemaleCommander
; 	_femaleVoiceTypes[12] = Game.GetFormFromFile(0x13ae2, "Skyrim.esm") as VoiceType ; FemaleOldGrumpy
; 	_femaleVoiceTypes[13] = Game.GetFormFromFile(0x13ae1, "Skyrim.esm") as VoiceType ; FemaleOldKindly
; 	_femaleVoiceTypes[14] = Game.GetFormFromFile(0x13ae0, "Skyrim.esm") as VoiceType ; FemaleSultry
; 	_femaleVoiceTypes[15] = Game.GetFormFromFile(0x13ade, "Skyrim.esm") as VoiceType ; FemaleCommoner
; 	_femaleVoiceTypes[16] = Game.GetFormFromFile(0x13add, "Skyrim.esm") as VoiceType ; FemaleEvenToned
; 	_femaleVoiceTypes[17] = Game.GetFormFromFile(0x13adc, "Skyrim.esm") as VoiceType ; FemaleYoungEager
; EndFunction


Function OnWarpaintRequest()
	AddWarpaint("$Male Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_01.dds")
	AddWarpaint("$Male Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_02.dds")
	AddWarpaint("$Male Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_03.dds")
	AddWarpaint("$Male Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_04.dds")
	AddWarpaint("$Male Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_05.dds")
	AddWarpaint("$Male Warpaint 06", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_06.dds")
	AddWarpaint("$Male Warpaint 07", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_07.dds")
	AddWarpaint("$Male Warpaint 08", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_08.dds")
	AddWarpaint("$Male Warpaint 09", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_09.dds")
	AddWarpaint("$Male Warpaint 10", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWarPaint_10.dds")
	AddWarpaint("$Male Nord Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadNordWarPaint_01.dds")
	AddWarpaint("$Male Nord Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadNordWarPaint_02.dds")
	AddWarpaint("$Male Nord Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadNordWarPaint_03.dds")
	AddWarpaint("$Male Nord Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadNordWarPaint_04.dds")
	AddWarpaint("$Male Nord Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadNordWarPaint_05.dds")
	AddWarpaint("$Female Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_01.dds")
	AddWarpaint("$Female Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_02.dds")
	AddWarpaint("$Female Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_03.dds")
	AddWarpaint("$Female Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_04.dds")
	AddWarpaint("$Female Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_05.dds")
	AddWarpaint("$Female Warpaint 06", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_06.dds")
	AddWarpaint("$Female Warpaint 07", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_07.dds")
	AddWarpaint("$Female Warpaint 08", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_08.dds")
	AddWarpaint("$Female Warpaint 09", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_09.dds")
	AddWarpaint("$Female Warpaint 10", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWarPaint_10.dds")
	AddWarpaint("$Female Nord Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadNordWarPaint_01.dds")
	AddWarpaint("$Female Nord Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadNordWarPaint_02.dds")
	AddWarpaint("$Female Nord Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadNordWarPaint_03.dds")
	AddWarpaint("$Female Nord Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadNordWarPaint_04.dds")
	AddWarpaint("$Female Nord Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadNordWarPaint_05.dds")
	AddWarpaint("$Argonian Stripes 01", "Actors\\Character\\Character Assets\\TintMasks\\ArgonianStripes01.dds")
	AddWarpaint("$Argonian Stripes 02", "Actors\\Character\\Character Assets\\TintMasks\\ArgonianStripes02.dds")
	AddWarpaint("$Argonian Stripes 03", "Actors\\Character\\Character Assets\\TintMasks\\ArgonianStripes03.dds")
	AddWarpaint("$Argonian Stripes 04", "Actors\\Character\\Character Assets\\TintMasks\\ArgonianStripes04.dds")
	AddWarpaint("$Argonian Stripes 05", "Actors\\Character\\Character Assets\\TintMasks\\ArgonianStripes05.dds")
	AddWarpaint("$Argonian Stripes 06", "Actors\\Character\\Character Assets\\TintMasks\\ArgonianStripes06.dds")
	AddWarpaint("$Female High Elf Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadHighElfWarPaint_01.dds")
	AddWarpaint("$Female High Elf Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadHighElfWarPaint_02.dds")
	AddWarpaint("$Female High Elf Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadHighElfWarPaint_03.dds")
	AddWarpaint("$Female High Elf Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadHighElfWarPaint_04.dds")
	AddWarpaint("$Male Dark Elf Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadDarkElfWarPaint_01.dds")
	AddWarpaint("$Male Dark Elf Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadDarkElfWarPaint_02.dds")
	AddWarpaint("$Male Dark Elf Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadDarkElfWarPaint_03.dds")
	AddWarpaint("$Male Dark Elf Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadDarkElfWarPaint_04.dds")
	AddWarpaint("$Male Dark Elf Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadDarkElfWarPaint_05.dds")
	AddWarpaint("$Male Dark Elf Warpaint 06", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadDarkElfWarPaint_06.dds")
	AddWarpaint("$Female Dark Elf Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadDarkElfWarPaint_01.dds")
	AddWarpaint("$Female Dark Elf Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadDarkElfWarPaint_02.dds")
	AddWarpaint("$Female Dark Elf Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadDarkElfWarPaint_03.dds")
	AddWarpaint("$Female Dark Elf Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadDarkElfWarPaint_04.dds")
	AddWarpaint("$Female Dark Elf Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadDarkElfWarPaint_05.dds")
	AddWarpaint("$Female Dark Elf Warpaint 06", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadDarkElfWarPaint_06.dds")
	AddWarpaint("$Male Imperial Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadImperialWarPaint_01.dds")
	AddWarpaint("$Male Imperial Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadImperialWarPaint_02.dds")
	AddWarpaint("$Male Imperial Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadImperialWarPaint_03.dds")
	AddWarpaint("$Male Imperial Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadImperialWarPaint_04.dds")
	AddWarpaint("$Male Imperial Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadImperialWarPaint_05.dds")
	AddWarpaint("$Female Imperial Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadImperialWarPaint_01.dds")
	AddWarpaint("$Female Imperial Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadImperialWarPaint_02.dds")
	AddWarpaint("$Female Imperial Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadImperialWarPaint_03.dds")
	AddWarpaint("$Female Imperial Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadImperialWarPaint_04.dds")
	AddWarpaint("$Female Imperial Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadImperialWarPaint_05.dds")
	AddWarpaint("$Khajiit Stripes 01", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitStripes01.dds")
	AddWarpaint("$Khajiit Stripes 02", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitStripes02.dds")
	AddWarpaint("$Khajiit Stripes 03", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitStripes03.dds")
	AddWarpaint("$Khajiit Stripes 04", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitStripes04.dds")
	AddWarpaint("$Khajiit Paint 01", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitPaint01.dds")
	AddWarpaint("$Khajiit Paint 02", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitPaint02.dds")
	AddWarpaint("$Khajiit Paint 03", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitPaint03.dds")
	AddWarpaint("$Khajiit Paint 04", "Actors\\Character\\Character Assets\\TintMasks\\KhajiitPaint04.dds")
	AddWarpaint("$Male Orc Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadOrcWarPaint_01.dds")
	AddWarpaint("$Male Orc Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadOrcWarPaint_02.dds")
	AddWarpaint("$Male Orc Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadOrcWarPaint_03.dds")
	AddWarpaint("$Male Orc Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadOrcWarPaint_04.dds")
	AddWarpaint("$Male Orc Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadOrcWarPaint_05.dds")
	AddWarpaint("$Female Orc Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadOrcWarPaint_01.dds")
	AddWarpaint("$Female Orc Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadOrcWarPaint_02.dds")
	AddWarpaint("$Female Orc Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadOrcWarPaint_03.dds")
	AddWarpaint("$Female Orc Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadOrcWarPaint_04.dds")
	AddWarpaint("$Female Orc Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadOrcWarPaint_05.dds")
	AddWarpaint("$Male Redguard Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadRedguardWarPaint_01.dds")
	AddWarpaint("$Male Redguard Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadRedguardWarPaint_02.dds")
	AddWarpaint("$Male Redguard Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadRedguardWarPaint_03.dds")
	AddWarpaint("$Male Redguard Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadRedguardWarPaint_04.dds")
	AddWarpaint("$Male Redguard Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadRedguardWarPaint_05.dds")
	AddWarpaint("$Female Redguard Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadRedguardWarPaint_01.dds")
	AddWarpaint("$Female Redguard Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadRedguardWarPaint_02.dds")
	AddWarpaint("$Female Redguard Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadRedguardWarPaint_03.dds")
	AddWarpaint("$Female Redguard Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadRedguardWarPaint_04.dds")
	AddWarpaint("$Female Redguard Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadRedguardWarPaint_05.dds")
	AddWarpaint("$Male Wood Elf Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWoodElfWarPaint_01.dds")
	AddWarpaint("$Male Wood Elf Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWoodElfWarPaint_02.dds")
	AddWarpaint("$Male Wood Elf Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWoodElfWarPaint_03.dds")
	AddWarpaint("$Male Wood Elf Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWoodElfWarPaint_04.dds")
	AddWarpaint("$Male Wood Elf Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadWoodElfWarPaint_05.dds")
	AddWarpaint("$Female Wood Elf Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWoodElfWarPaint_01.dds")
	AddWarpaint("$Female Wood Elf Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWoodElfWarPaint_02.dds")
	AddWarpaint("$Female Wood Elf Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWoodElfWarPaint_03.dds")
	AddWarpaint("$Female Wood Elf Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWoodElfWarPaint_04.dds")
	AddWarpaint("$Female Wood Elf Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadWoodElfWarPaint_05.dds")
	AddWarpaint("$Male Breton Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadBretonWarPaint_01.dds")
	AddWarpaint("$Male Breton Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadBretonWarPaint_02.dds")
	AddWarpaint("$Male Breton Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadBretonWarPaint_03.dds")
	AddWarpaint("$Male Breton Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadBretonWarPaint_04.dds")
	AddWarpaint("$Male Breton Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadBretonWarPaint_05.dds")
	AddWarpaint("$Female Breton Warpaint 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadBretonWarPaint_01.dds")
	AddWarpaint("$Female Breton Warpaint 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadBretonWarPaint_02.dds")
	AddWarpaint("$Female Breton Warpaint 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadBretonWarPaint_03.dds")
	AddWarpaint("$Female Breton Warpaint 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadBretonWarPaint_04.dds")
	AddWarpaint("$Female Breton Warpaint 05", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadBretonWarPaint_05.dds")
	AddWarpaint("$Male Forsworn Tattoo 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadForswornTattoo_01.dds")
	AddWarpaint("$Male Forsworn Tattoo 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadForswornTattoo_02.dds")
	AddWarpaint("$Male Forsworn Tattoo 03", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadForswornTattoo_03.dds")
	AddWarpaint("$Male Forsworn Tattoo 04", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadForswornTattoo_04.dds")
	AddWarpaint("$Female Forsworn Tattoo 01", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadForswornTattoo_01.dds")
	AddWarpaint("$Female Forsworn Tattoo 02", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadForswornTattoo_02.dds")
	AddWarpaint("$Female Forsworn Tattoo 03", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadForswornTattoo_03.dds")
	AddWarpaint("$Female Forsworn Tattoo 04", "Actors\\Character\\Character Assets\\TintMasks\\FemaleHeadForswornTattoo_04.dds")
	AddWarpaint("$Male Black Blood Tattoo 01", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadBlackBloodTattoo_01.dds")
	AddWarpaint("$Male Black Blood Tattoo 02", "Actors\\Character\\Character Assets\\TintMasks\\MaleHeadBlackBloodTattoo_02.dds")
EndFunction


Event OnBodyPaintRequest()
	AddBodyPaint("Default", DEFAULT_OVERLAY)
EndEvent


Event OnHandPaintRequest()
	AddHandPaint("Default", DEFAULT_OVERLAY)
EndEvent


Event OnFeetPaintRequest()
	AddFeetPaint("Default", DEFAULT_OVERLAY)
EndEvent


Event OnFacePaintRequest()
	AddFacePaint("Default", DEFAULT_OVERLAY)
EndEvent


Function LoadDefaults()
	If _tintTypes[0] == 0
		SaveHair()
		SaveTints()
		hasInitialized = true
		If _tintTypes[0] == 0
			LoadDefaultTypes(_tintTypes)
		Endif
	Endif
EndFunction


Function LoadDefaultTypes(int[] loadedTypes)
	loadedTypes[0] = 6;;-4744047;;Actors\Character\Character Assets\TintMasks\SkinTone.dds
	loadedTypes[1] = 4;;16777215;;Actors\Character\Character Assets\TintMasks\MaleUpperEyeSocket.dds
	loadedTypes[2] = 5;;16777215;;Actors\Character\Character Assets\TintMasks\MaleLowerEyeSocket.dds
	loadedTypes[3] = 2;;1799554049;;Actors\Character\Character Assets\TintMasks\MaleHead_Cheeks.dds
	loadedTypes[4] = 9;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHead_Cheeks2.dds
	loadedTypes[5] = 8;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHead_FrownLines.dds
	loadedTypes[6] = 1;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadNord_Lips.dds
	loadedTypes[7] = 10;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHead_Nose.dds
	loadedTypes[8] = 13;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadHuman_ForeHead.dds
	loadedTypes[9] = 11;;1799554049;;Actors\Character\Character Assets\TintMasks\MaleHeadHuman_Chin.dds
	loadedTypes[10] = 12;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadHuman_Neck.dds
	loadedTypes[11] = 0;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHead_Frekles_01.dds
	loadedTypes[12] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_01.dds
	loadedTypes[13] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_02.dds
	loadedTypes[14] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_03.dds
	loadedTypes[15] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_04.dds
	loadedTypes[16] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_05.dds
	loadedTypes[17] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_06.dds
	loadedTypes[18] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_07.dds
	loadedTypes[19] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_08.dds
	loadedTypes[20] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_09.dds
	loadedTypes[21] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadWarPaint_10.dds
	loadedTypes[22] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadNordWarPaint_01.dds
	loadedTypes[23] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadNordWarPaint_02.dds
	loadedTypes[24] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadNordWarPaint_03.dds
	loadedTypes[25] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadNordWarPaint_04.dds
	loadedTypes[26] = 7;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadNordWarPaint_05.dds
	loadedTypes[27] = 0;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadBothiahTattoo_01.dds
	loadedTypes[28] = 0;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadBlackBloodTattoo_01.dds
	loadedTypes[29] = 0;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadBlackBloodTattoo_02.dds
	loadedTypes[30] = 3;;16777215;;Actors\Character\Character Assets\TintMasks\RedGuardMaleEyeLinerStyle_01.dds
	loadedTypes[31] = 14;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadDirt_01.dds
	loadedTypes[32] = 14;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadDirt_02.dds
	loadedTypes[33] = 14;;16777215;;Actors\Character\Character Assets\TintMasks\MaleHeadDirt_03.dds
EndFunction

; Updates tint colors

Function UpdateColors()
	int i = 0
	string[] tints = new string[128]
	int totalTints = _tintTypes.length - 1
	tints[0] = TINT_TYPE_HAIR + ";;" + _color + ";;"
	While i < totalTints
		tints[i + 1] = _tintTypes[i] + ";;" + _tintColors[i] + ";;" + _tintTextures[i]
		i += 1
	EndWhile
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddTints", tints)
EndFunction

; Indexes the races for extended bonus descriptions

Function UpdateRaces()
	int totalRaces = Race.GetNumPlayableRaces()
	int i = 0
	While i < totalRaces
		Race playableRace = Race.GetNthPlayableRace(i)
		UI.InvokeForm(_targetMenu, _targetRoot + "RSM_ExtendRace", playableRace)
		i += 1
	EndWhile
EndFunction

; Update the color and selection listing of overlays

Function UpdateOverlays()
	If SKSE.GetPluginVersion("skee") >= 1 ; Checks to make sure the NiOverride plugin exists
		UpdateOverlay(TINT_TYPE_BODYPAINT, "Body [Ovl", NiOverride.GetNumBodyOverlays(), "RSM_AddBodyTints")
		UpdateOverlay(TINT_TYPE_HANDPAINT, "Hands [Ovl", NiOverride.GetNumHandOverlays(), "RSM_AddHandTints")
		UpdateOverlay(TINT_TYPE_FEETPAINT, "Feet [Ovl", NiOverride.GetNumFeetOverlays(), "RSM_AddFeetTints")
		UpdateOverlay(TINT_TYPE_FACEPAINT, "Face [Ovl", NiOverride.GetNumFaceOverlays(), "RSM_AddFaceTints")
	Endif
EndFunction


Function UpdateOverlay(int tintType, string tintTemplate, int tintCount, string tintEvent)
	int i = 0
	ActorBase targetBase = _targetActor.GetActorBase()
	string[] tints = new string[128]
	While i < tintCount
		string nodeName = tintTemplate + i + "]"
		int rgb = 0
		int glow = 0
		float multiple = 0.0
		float alpha = 0
		string texture = ""
		If NetImmerse.HasNode(_targetActor, nodeName, false) ; Actor has the node, get the immediate property
			rgb = NiOverride.GetNodePropertyInt(_targetActor, false, nodeName, 7, -1)
			glow = NiOverride.GetNodePropertyInt(_targetActor, false, nodeName, 0, -1)
			alpha = NiOverride.GetNodePropertyFloat(_targetActor, false, nodeName, 8, -1)
			texture = NiOverride.GetNodePropertyString(_targetActor, false, nodeName, 9, 0)
			multiple = NiOverride.GetNodePropertyFloat(_targetActor, false, nodeName, 1, -1)
		Else ; Doesn't have the node, get it from the override
			bool isFemale = targetBase.GetSex() as bool
			rgb = NiOverride.GetNodeOverrideInt(_targetActor, isFemale, nodeName, 7, -1)
			glow = NiOverride.GetNodeOverrideInt(_targetActor, isFemale, nodeName, 0, -1)
			alpha = NiOverride.GetNodeOverrideFloat(_targetActor, isFemale, nodeName, 8, -1)
			texture = NiOverride.GetNodeOverrideString(_targetActor, isFemale, nodeName, 9, 0)
			multiple = NiOverride.GetNodeOverrideFloat(_targetActor, isFemale, nodeName, 1, -1)
		Endif
		int color = Math.LogicalOr(Math.LogicalAnd(rgb, 0xFFFFFF), Math.LeftShift((alpha * 255) as Int, 24))
		glow = Math.LogicalOr(Math.LeftShift(((multiple * 10.0) as Int), 24), glow)
		If texture == ""
			texture = DEFAULT_OVERLAY
		Endif
		tints[i] = tintType + ";;" + color + ";;" + texture + ";;" + glow
		i += 1
	EndWhile
	UI.InvokeStringA(_targetMenu, _targetRoot + tintEvent, tints)
EndFunction