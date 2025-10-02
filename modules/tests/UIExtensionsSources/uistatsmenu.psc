Scriptname UIStatsMenu extends UIMenuBase

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.ActorStatsPanelFader.actorStatsPanel." autoReadonly

Form _form = None

string Function GetMenuName()
	return "UIStatsMenu"
EndFunction

int Function OpenMenu(Form inForm = None, Form akReceiver = None)
	_form = inForm

	If !BlockUntilClosed() || !WaitForReset()
		return 0
	Endif

	RegisterForModEvent("UIStatsMenu_LoadMenu", "OnLoadMenu")
	RegisterForModEvent("UIStatsMenu_CloseMenu", "OnUnloadMenu")

	UI.OpenCustomMenu("statssheetmenu")
	return 1
EndFunction

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	UpdateStatsForm()
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
	UnregisterForModEvent("UIStatsMenu_LoadMenu")
	UnregisterForModEvent("UIStatsMenu_CloseMenu")
EndEvent

Function UpdateStatsForm()
	UI.InvokeForm(ROOT_MENU, MENU_ROOT + "setActorStatsPanelForm", _form)
EndFunction

