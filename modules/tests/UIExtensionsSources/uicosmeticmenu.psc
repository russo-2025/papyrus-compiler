Scriptname UICosmeticMenu extends UIMenuBase

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.cosmeticMenu.RaceMenuInstance." autoReadonly
string Property 	THIS_ROOT		= "_root.cosmeticMenu." autoReadonly

string Property 	COSMETIC_CATEGORY_WARPAINT = 1 autoReadonly
string Property 	COSMETIC_CATEGORY_BODYPAINT = 2 autoReadonly
string Property 	COSMETIC_CATEGORY_HANDPAINT = 4 autoReadonly
string Property 	COSMETIC_CATEGORY_FEETPAINT = 8 autoReadonly
string Property 	COSMETIC_CATEGORY_FACEPAINT = 16 autoReadonly
string Property 	COSMETIC_CATEGORY_SLIDERS = 32 autoReadonly
string Property 	COSMETIC_CATEGORY_CATEGORIES = 64 autoReadonly

Form _form = None
int _categories = 0

int Function OpenMenu(Form aForm = None, Form aReceiver = None)
	_form = aForm

	If !BlockUntilClosed() || !WaitForReset()
		return 0
	Endif

	RegisterForModEvent("UICosmeticMenu_LoadMenu", "OnLoadMenu")
	RegisterForModEvent("UICosmeticMenu_CloseMenu", "OnUnloadMenu")
	RegisterForModEvent("UICosmeticMenu_FailedLoadMenu", "OnFailedLoadMenu")

	((self as Quest) as CosmeticMenu).RegisterEvents()
	((self as Quest) as CosmeticMenu).Reinitialize()

	UI.OpenCustomMenu("cosmeticmenu")
	return 1
EndFunction

string Function GetMenuName()
	return "UICosmeticMenu"
EndFunction

Function SetPropertyInt(string propertyName, int value)
	If propertyName == "categories"
		_categories = value
	Endif
EndFunction

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	Actor targetActor = _form as Actor
	ActorBase targetBase = targetActor.GetActorBase()
	Race targetRace = targetActor.GetRace()

	((self as Quest) as CosmeticMenu)._targetMenu = ROOT_MENU
	((self as Quest) as CosmeticMenu)._targetRoot = MENU_ROOT

	SendModEvent("RSMDT_SendMenuName", ROOT_MENU)
	SendModEvent("RSMDT_SendRootName", MENU_ROOT)
	SendModEvent("RSMDT_SendPrefix", "TTM")

	int handle = ModEvent.Create("RSMDT_SendTargetActor")
	ModEvent.PushForm(handle, targetActor)
	ModEvent.Send(handle)

	UI.InvokeString(ROOT_MENU, MENU_ROOT + "SetNameText", targetBase.GetName())
	UI.InvokeString(ROOT_MENU, MENU_ROOT + "SetRaceText", targetRace.GetName())

	UI.InvokeInt(ROOT_MENU, THIS_ROOT + "TTM_ShowCategories", _categories)

	; Wait some time for all the events to propagate
	Utility.WaitMenuMode(0.5)

	SendModEvent("RSMDT_SendDataRequest", "", _categories as float)
EndEvent

Event OnFailedLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	Debug.Notification("RaceMenu version incompatible with cosmetic menu.")
	
	UnregisterForModEvent("UICosmeticMenu_LoadMenu")
	UnregisterForModEvent("UICosmeticMenu_CloseMenu")

	SendModEvent("RSMDT_SendRestore")
	SendModEvent("RSMDT_SendPrefix", "RSM")

	((self as Quest) as CosmeticMenu).UnregisterEvents()
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
	UnregisterForModEvent("UICosmeticMenu_LoadMenu")
	UnregisterForModEvent("UICosmeticMenu_CloseMenu")

	SendModEvent("RSMDT_SendRestore")
	SendModEvent("RSMDT_SendPrefix", "RSM")

	((self as Quest) as CosmeticMenu).UnregisterEvents()
EndEvent