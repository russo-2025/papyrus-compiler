Scriptname UIDyeMenu extends UIMenuBase

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.dyeMenu." autoReadonly

Form _form = None
Form _dyes = None

bool _consumeItems = true
int _maxBlend = 3

string Function GetMenuName()
	return "UIDyeMenu"
EndFunction

int Function OpenMenu(Form inForm = None, Form akReceiver = None)
	_form = inForm
	_dyes = akReceiver
	If !_dyes || !(_dyes as ObjectReference)
		_dyes = Game.GetPlayer()
	Endif

	If !BlockUntilClosed() || !WaitForReset()
		return 0
	Endif

	RegisterForModEvent("UIDyeMenu_LoadMenu", "OnLoadMenu")
	RegisterForModEvent("UIDyeMenu_CloseMenu", "OnUnloadMenu")
	RegisterForModEvent("UIDyeMenu_ConsumeItem", "OnConsumeItem")

	UI.OpenCustomMenu("dyemenu")
	return 1
EndFunction

Function ResetMenu()
	_consumeItems = true
	_maxBlend = 3
EndFunction

Function SetPropertyBool(string propertyName, bool value)
	If propertyName == "consumeItems"
		_consumeItems = value
	Endif
EndFunction

Function SetPropertyInt(string propertyName, int value)
	If propertyName == "maxBlend"
		_maxBlend = value
	Endif
EndFunction

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	NiOverride.EnableTintTextureCache()
	UpdateItemSourceForm()
	UpdateDyeSourceForm()
	UpdateConsumeItems()
	UpdateMaxBlending()
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
	UnregisterForModEvent("UIDyeMenu_LoadMenu")
	UnregisterForModEvent("UIDyeMenu_CloseMenu")
	NiOverride.ReleaseTintTextureCache()
EndEvent

Event OnConsumeItem(string eventName, string strArg, float numArg, Form formArg)
	ObjectReference akContainer = (_dyes as ObjectReference)
	akContainer.RemoveItem(formArg, 1, true)
EndEvent

Function UpdateItemSourceForm()
	UI.InvokeForm(ROOT_MENU, MENU_ROOT + "setItemSourceForm", _form)
EndFunction

Function UpdateDyeSourceForm()
	UI.InvokeForm(ROOT_MENU, MENU_ROOT + "setDyeSourceForm", _dyes)
EndFunction

Function UpdateConsumeItems()
	UI.InvokeBool(ROOT_MENU, MENU_ROOT + "setConsumeItems", _consumeItems)
EndFunction

Function UpdateMaxBlending()
	UI.InvokeInt(ROOT_MENU, MENU_ROOT + "setMaxBlending", _maxBlend)
EndFunction