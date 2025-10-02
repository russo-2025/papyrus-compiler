Scriptname UISelectionMenu extends UIMenuBase

FormList Property SelectedForms  Auto  

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.MenuHolder.Menu_mc." autoReadonly

Form _form = None
Form _receiver = None
Form _selected = None

int _mode = 0

Form Function GetResultForm()
	if _mode == 0
		return _selected
	elseif _mode == 1
		return SelectedForms
	endif
	return None
EndFunction

Function SetPropertyInt(string propertyName, int value)
	If propertyName == "menuMode"
		_mode = value
	Endif
EndFunction

Function ResetMenu()
	isResetting = true
	_selected = None
	SelectedForms.Revert()
	isResetting = false
EndFunction

int Function OpenMenu(Form aForm = None, Form aReceiver = None)
	_form = aForm
	_receiver = aReceiver
	
	If !BlockUntilClosed() || !WaitForReset()
		return 0
	Endif

	RegisterForModEvent("UISelectionMenu_LoadMenu", "OnLoadMenu")
	RegisterForModEvent("UISelectionMenu_CloseMenu", "OnUnloadMenu")
	RegisterForModEvent("UISelectionMenu_SelectForm", "OnSelect")
	RegisterForModEvent("UISelectionMenu_SelectionReady", "OnSelectForm")
	If _receiver
		_receiver.RegisterForModEvent("UISelectionMenu_SelectionChanged", "OnSelectForm")
	Endif
	
	Lock()
	UI.OpenCustomMenu("selectionmenu")
	If !WaitLock()
		return 0
	Endif
	return 1
EndFunction

string Function GetMenuName()
	return "UISelectionMenu"
EndFunction

; Push forms to FormList
Event OnSelect(string eventName, string strArg, float numArg, Form formArg)
	if _mode == 0
		_selected = formArg
	elseif _mode == 1
		SelectedForms.AddForm(formArg)
	endif
EndEvent

; Unlock selection menu
Event OnSelectForm(string eventName, string strArg, float numArg, Form formArg)
	Unlock()
EndEvent

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	UI.InvokeForm(ROOT_MENU, MENU_ROOT + "SetSelectionMenuFormData", _form)
	UI.InvokeFloat(ROOT_MENU, MENU_ROOT + "SetSelectionMenuMode", _mode as float)
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
	UnregisterForModEvent("UISelectionMenu_LoadMenu")
	UnregisterForModEvent("UISelectionMenu_CloseMenu")
	UnregisterForModEvent("UISelectionMenu_SelectForm")
	UnregisterForModEvent("UISelectionMenu_SelectionReady")
	If _receiver
		_receiver.UnregisterForModEvent("UISelectionMenu_SelectionChanged")
	Endif
EndEvent
