Scriptname UIMagicMenu extends UIMenuBase  

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root." autoReadonly
string property		CONFIG_ROOT		= "_global.skyui.util.ConfigManager" autoReadonly

Actor _actor = None
Actor _tradeActor = None
bool _restricted = true

Form _receiver = None

string Function GetMenuName()
	return "UIMagicMenu"
EndFunction

int Function OpenMenu(Form akForm = None, Form akReceiver = None)
	_actor = akForm as Actor
	_receiver = akReceiver

	If !BlockUntilClosed() || !WaitForReset()
		return 0
	Endif

	RegisterForModEvent("UIMagicMenu_LoadMenu", "OnLoadMenu")
	RegisterForModEvent("UIMagicMenu_CloseMenu", "OnUnloadMenu")
	RegisterForModEvent("UIMagicMenu_AddRemoveSpell", "OnAddRemoveSpell")
	If _receiver
		_receiver.RegisterForModEvent("UIMagicMenu_AddRemoveSpell", "OnAddRemoveSpell")
	Endif

	UI.OpenCustomMenu("magicmenuext")
	return 1
EndFunction

Function SetPropertyString(string propertyName, String value)
	If propertyName == "Notification"
		UI.InvokeString(ROOT_MENU, MENU_ROOT + "Menu_mc.MagicMenu_PushMessage", value)
	Endif
EndFunction

Function SetPropertyBool(string propertyName, bool value)
	If propertyName == "Restricted"
		_restricted = value
	Endif
EndFunction

Function SetPropertyForm(string propertyName, Form value)
	If propertyName == "receivingActor"
		_tradeActor = value as Actor
	Elseif propertyName == "AddSpell"
		UI.InvokeForm(ROOT_MENU, MENU_ROOT + "Menu_mc.MagicMenu_AddSpell", value)
	Elseif propertyName == "RemoveSpell"
		UI.InvokeForm(ROOT_MENU, MENU_ROOT + "Menu_mc.MagicMenu_RemoveSpell", value)
	Endif
EndFunction

Event OnAddRemoveSpell(string eventName, string strArg, float numArg, Form formArg)
	Spell akSpell = formArg as Spell
	ActorBase akBase = _actor.GetActorBase()
	If akSpell
		If numArg == 0
			_actor.RemoveSpell(akSpell)
			If !_actor.HasSpell(akSpell)
				SetPropertyForm("RemoveSpell", akSpell)
				SetPropertyString("Notification", "${" + akBase.GetName() + "} forgot {" + akSpell.GetName() +"}.")
			Else
				SetPropertyString("Notification", "${" + akBase.GetName() + "} could not forget {" + akSpell.GetName() +"}.")
			Endif
		Elseif numArg == 1
			If !_actor.HasSpell(akSpell)
				_actor.AddSpell(akSpell)
				SetPropertyForm("AddSpell", formArg)
				SetPropertyString("Notification", "$Taught {" + akSpell.GetName() +"} to {" + akBase.GetName() + "}.")
			Else
				SetPropertyString("Notification", "${" + akBase.GetName() + "} already knows this spell.")
			Endif
		Endif
	Endif
EndEvent

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	UI.SetBool(ROOT_MENU, MENU_ROOT + "bRestrictTrade", _restricted)

	UI.InvokeForm(ROOT_MENU, MENU_ROOT + "Menu_mc.MagicMenu_SetActor", _actor)
	UI.InvokeForm(ROOT_MENU, MENU_ROOT + "Menu_mc.MagicMenu_SetSecondaryActor", _tradeActor)

	string[] overrideKeys = new string[1]
	string[] overrideValues = new string[1]
	UI.InvokeStringA(ROOT_MENU, CONFIG_ROOT + ".setExternalOverrideKeys", overrideKeys)
	UI.InvokeStringA(ROOT_MENU, CONFIG_ROOT + ".setExternalOverrideValues", overrideValues)
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
	UnregisterForModEvent("UIMagicMenu_LoadMenu")
	UnregisterForModEvent("UIMagicMenu_CloseMenu")
	UnregisterForModEvent("UIMagicMenu_AddRemoveSpell")
	If _receiver
		_receiver.UnregisterForModEvent("UIMagicMenu_AddRemoveSpell")
	Endif
EndEvent
