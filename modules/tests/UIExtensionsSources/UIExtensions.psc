Scriptname UIExtensions Hidden

UIMenuBase Function GetMenu(string menuName, bool reset = true) global
	UIMenuBase menuBase = None
	If menuName == "UIMagicMenu"
		menuBase = (Game.GetFormFromFile(0xE02, "UIExtensions.esp") as UIMenuBase)
	Elseif menuName == "UIListMenu"
		menuBase = (Game.GetFormFromFile(0xE05, "UIExtensions.esp") as UIMenuBase)
	Elseif menuName == "UIStatsMenu"
		menuBase = (Game.GetFormFromFile(0xE03, "UIExtensions.esp") as UIMenuBase)
	Elseif menuName == "UITextEntryMenu"
		menuBase = (Game.GetFormFromFile(0xE04, "UIExtensions.esp") as UIMenuBase)
	Elseif menuName == "UIWheelMenu"
		menuBase = (Game.GetFormFromFile(0xE01, "UIExtensions.esp") as UIMenuBase)
	Elseif menuName == "UISelectionMenu"
		menuBase = (Game.GetFormFromFile(0xE00, "UIExtensions.esp") as UIMenuBase)
	Elseif menuName == "UICosmeticMenu"
		menuBase = (Game.GetFormFromFile(0xE06, "UIExtensions.esp") as UIMenuBase)
	Elseif menuName == "UIDyeMenu"
		menuBase = (Game.GetFormFromFile(0xE07, "UIExtensions.esp") as UIMenuBase)
	Endif
	if menuBase
		if reset
			menuBase.ResetMenu()
		Endif
		return menuBase
	Endif
	return None
EndFunction

; These are going to be slower than directly referencing but they won't require
; the UIMenuBase script as a dependency
Function InitMenu(string menuName) global
	GetMenu(menuName, true)
EndFunction

int Function OpenMenu(string menuName, Form akForm = None, Form akReceiver = None) global
	return GetMenu(menuName, false).OpenMenu(akForm, akReceiver)
EndFunction

float Function GetMenuResultFloat(string menuName) global
	return GetMenu(menuName, false).GetResultFloat()
EndFunction

int Function GetMenuResultInt(string menuName) global
	return GetMenu(menuName, false).GetResultInt()
EndFunction

string Function GetMenuResultString(string menuName) global
	return GetMenu(menuName, false).GetResultString()
EndFunction

Form Function GetMenuResultForm(string menuName) global
	return GetMenu(menuName, false).GetResultForm()
EndFunction

; Getters
int Function GetMenuPropertyInt(string menuName, string propertyName) global
	return GetMenu(menuName, false).GetPropertyInt(propertyName)
EndFunction

bool Function GetMenuPropertyBool(string menuName, string propertyName) global
	return GetMenu(menuName, false).GetPropertyBool(propertyName)
EndFunction

string Function GetMenuPropertyString(string menuName, string propertyName) global
	return GetMenu(menuName, false).GetPropertyString(propertyName)
EndFunction

float Function GetMenuPropertyFloat(string menuName, string propertyName) global
	return GetMenu(menuName, false).GetPropertyFloat(propertyName)
EndFunction

Form Function GetMenuPropertyForm(string menuName, string propertyName) global
	return GetMenu(menuName, false).GetPropertyForm(propertyName)
EndFunction

Alias Function GetMenuPropertyAlias(string menuName, string propertyName) global
	return GetMenu(menuName, false).GetPropertyAlias(propertyName)
EndFunction

; Setters
Function SetMenuPropertyInt(string menuName, string propertyName, int value) global
	GetMenu(menuName, false).SetPropertyInt(propertyName, value)
EndFunction

Function SetMenuPropertyBool(string menuName, string propertyName, bool value) global
	GetMenu(menuName, false).SetPropertyBool(propertyName, value)
EndFunction

Function SetMenuPropertyString(string menuName, string propertyName, string value) global
	GetMenu(menuName, false).SetPropertyString(propertyName, value)
EndFunction

Function SetMenuPropertyFloat(string menuName, string propertyName, float value) global
	GetMenu(menuName, false).SetPropertyFloat(propertyName, value)
EndFunction

Function SetMenuPropertyForm(string menuName, string propertyName, Form value) global
	GetMenu(menuName, false).SetPropertyForm(propertyName, value)
EndFunction

Function SetMenuPropertyAlias(string menuName, string propertyName, Alias value) global
	GetMenu(menuName, false).SetPropertyAlias(propertyName, value)
EndFunction

; Property Index functions
Function SetMenuPropertyIndexInt(string menuName, string propertyName, int index, int value) global
	GetMenu(menuName, false).SetPropertyIndexInt(propertyName, index, value)
EndFunction

Function SetMenuPropertyIndexBool(string menuName, string propertyName, int index, bool value) global
	GetMenu(menuName, false).SetPropertyIndexBool(propertyName, index, value)
EndFunction

Function SetMenuPropertyIndexString(string menuName, string propertyName, int index, string value) global
	GetMenu(menuName, false).SetPropertyIndexString(propertyName, index, value)
EndFunction

Function SetMenuPropertyIndexFloat(string menuName, string propertyName, int index, float value) global
	GetMenu(menuName, false).SetPropertyIndexFloat(propertyName, index, value)
EndFunction

Function SetMenuPropertyIndexForm(string menuName, string propertyName, int index, Form value) global
	GetMenu(menuName, false).SetPropertyIndexForm(propertyName, index, value)
EndFunction

Function SetMenuPropertyIndexAlias(string menuName, string propertyName, int index, Alias value) global
	GetMenu(menuName, false).SetPropertyIndexAlias(propertyName, index, value)
EndFunction

; Array Functions
Function SetMenuPropertyIntA(string menuName, string propertyName, int[] value) global
	GetMenu(menuName, false).SetPropertyIntA(propertyName, value)
EndFunction

Function SetMenuPropertyBoolA(string menuName, string propertyName, bool[] value) global
	GetMenu(menuName, false).SetPropertyBoolA(propertyName, value)
EndFunction

Function SetMenuPropertyStringA(string menuName, string propertyName, string[] value) global
	GetMenu(menuName, false).SetPropertyStringA(propertyName, value)
EndFunction

Function SetMenuPropertyFloatA(string menuName, string propertyName, float[] value) global
	GetMenu(menuName, false).SetPropertyFloatA(propertyName, value)
EndFunction

Function SetMenuPropertyFormA(string menuName, string propertyName, Form[] value) global
	GetMenu(menuName, false).SetPropertyFormA(propertyName, value)
EndFunction

Function SetMenuPropertyAliasA(string menuName, string propertyName, Alias[] value) global
	GetMenu(menuName, false).SetPropertyAliasA(propertyName, value)
EndFunction