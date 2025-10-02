Scriptname UIWheelMenu extends UIMenuBase

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.WheelPhase.WheelBase." autoReadonly

Form _form = None
bool _enabled = true
int _lastIndex = 0
bool _selectionLock = false
int _returnValue = 0

string[] _optionText
string[] _optionLabelText
string[] _optionIcon
int[] _optionIconColor
bool[] _optionEnabled
int[] _optionTextColor

string Function GetMenuName()
	return "UIWheelMenu"
EndFunction

Function OnInit()
	_optionText = new String[8]
	_optionLabelText = new String[8]
	_optionIcon = new String[8]
	_optionIconColor = new Int[8]
	_optionEnabled = new Bool[8]
	_optionTextColor = new Int[8]
	ResetMenu()
EndFunction

int Function OpenMenu(Form akForm = None, Form akReceiver = None)
	_form = akForm

	If !BlockUntilClosed() || !WaitForReset()
		return 255
	Endif

	RegisterForModEvent("UIWheelMenu_ChooseOption", "OnChooseOption")
	RegisterForModEvent("UIWheelMenu_SetOption", "OnSelectOption")
	RegisterForModEvent("UIWheelMenu_LoadMenu", "OnLoadMenu")
	RegisterForModEvent("UIWheelMenu_CloseMenu", "OnUnloadMenu")

	Lock()
	UI.OpenCustomMenu("wheelmenu")
	If !WaitLock()
		return 255
	Endif

	return _returnValue
EndFunction

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	UpdateWheelEnabledOptions()
	UpdateWheelForm()
	UpdateWheelOptions()
	UpdateWheelOptionLabels()
	UpdateWheelIcons()
	UpdateWheelIconColors()
	UpdateWheelSelection()
	UpdateWheelTextColors()
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
	UnregisterForModEvent("UIWheelMenu_ChooseOption")
	UnregisterForModEvent("UIWheelMenu_SetOption")
	UnregisterForModEvent("UIWheelMenu_LoadMenu")
	UnregisterForModEvent("UIWheelMenu_CloseMenu")
EndEvent

Event OnChooseOption(string eventName, string strArg, float numArg, Form formArg)
	_returnValue = numArg as Int
	Unlock()
EndEvent

Event OnSelectOption(string eventName, string strArg, float numArg, Form formArg)
	_lastIndex = numArg as Int
EndEvent

Function ResetMenu()
	isResetting = true
	_optionText[0] = ""
	_optionText[1] = ""
	_optionText[2] = ""
	_optionText[3] = ""
	_optionText[4] = ""
	_optionText[5] = ""
	_optionText[6] = ""
	_optionText[7] = ""

	_optionLabelText[0] = ""
	_optionLabelText[1] = ""
	_optionLabelText[2] = ""
	_optionLabelText[3] = ""
	_optionLabelText[4] = ""
	_optionLabelText[5] = ""
	_optionLabelText[6] = ""
	_optionLabelText[7] = ""

	_optionIcon[0] = ""
	_optionIcon[1] = ""
	_optionIcon[2] = ""
	_optionIcon[3] = ""
	_optionIcon[4] = ""
	_optionIcon[5] = ""
	_optionIcon[6] = ""
	_optionIcon[7] = ""

	_optionIconColor[0] = 0xFFFFFF
	_optionIconColor[1] = 0xFFFFFF
	_optionIconColor[2] = 0xFFFFFF
	_optionIconColor[3] = 0xFFFFFF
	_optionIconColor[4] = 0xFFFFFF
	_optionIconColor[5] = 0xFFFFFF
	_optionIconColor[6] = 0xFFFFFF
	_optionIconColor[7] = 0xFFFFFF

	_optionTextColor[0] = 0xFFFFFF
	_optionTextColor[1] = 0xFFFFFF
	_optionTextColor[2] = 0xFFFFFF
	_optionTextColor[3] = 0xFFFFFF
	_optionTextColor[4] = 0xFFFFFF
	_optionTextColor[5] = 0xFFFFFF
	_optionTextColor[6] = 0xFFFFFF
	_optionTextColor[7] = 0xFFFFFF

	_optionEnabled[0] = false
	_optionEnabled[1] = false
	_optionEnabled[2] = false
	_optionEnabled[3] = false
	_optionEnabled[4] = false
	_optionEnabled[5] = false
	_optionEnabled[6] = false
	_optionEnabled[7] = false
	isResetting = false
EndFunction

Function SetPropertyInt(string propertyName, int value)
	if propertyName == "lastIndex"
		_lastIndex = value
	Endif
EndFunction

Function SetPropertyIndexInt(string propertyName, int index, int value)
	If index < 0 || index > 7
		return
	Endif
	If propertyName == "optionIconColor"
		_optionIconColor[index] = value
	Elseif propertyName == "optionTextColor"
		_optionTextColor[index] = value
	Endif
EndFunction

Function SetPropertyIndexBool(string propertyName, int index, bool value)
	If index < 0 || index > 7
		return
	Endif
	If propertyName == "optionEnabled"
		_optionEnabled[index] = value
	Endif
EndFunction

Function SetPropertyIndexString(string propertyName, int index, string value)
	If index < 0 || index > 7
		return
	Endif
	If propertyName == "optionText"
		_optionText[index] = value
	Elseif propertyName == "optionLabelText"
		_optionLabelText[index] = value
	Elseif propertyName == "optionIcon"
		_optionIcon[index] = value
	Endif
EndFunction

; Functions only to be used while the menu is open
Function UpdateWheelSelection()
	float[] params = new float[2]
	params[0] = _lastIndex as float
	params[1] = true as float
	UI.InvokeFloatA(ROOT_MENU, MENU_ROOT + "setWheelSelection", params)
EndFunction

Function UpdateWheelForm()
	UI.InvokeForm(ROOT_MENU, MENU_ROOT + "setWheelForm", _form)
EndFunction

Function UpdateWheelVisibility()
	UI.SetBool(ROOT_MENU, MENU_ROOT + "enabled", _enabled)
	UI.SetBool(ROOT_MENU, MENU_ROOT + "_visible", _enabled)
EndFunction

Function UpdateWheelEnabledOptions()
	UI.InvokeBoolA(ROOT_MENU, MENU_ROOT + "setWheelOptionsEnabled", _optionEnabled)
EndFunction

Function UpdateWheelOptions()
	UI.InvokeStringA(ROOT_MENU, MENU_ROOT + "setWheelOptions", _optionText)
EndFunction

Function UpdateWheelOptionLabels()
	UI.InvokeStringA(ROOT_MENU, MENU_ROOT + "setWheelOptionLabels", _optionLabelText)
EndFunction

Function UpdateWheelIcons()
	UI.InvokeStringA(ROOT_MENU, MENU_ROOT + "setWheelOptionIcons", _optionIcon)
EndFunction

Function UpdateWheelIconColors()
	UI.InvokeIntA(ROOT_MENU, MENU_ROOT + "setWheelOptionIconColors", _optionIconColor)
EndFunction

Function UpdateWheelTextColors()
	UI.InvokeIntA(ROOT_MENU, MENU_ROOT + "setWheelOptionTextColors", _optionTextColor)
EndFunction