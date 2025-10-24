Scriptname CosmeticMenu extends RaceMenu

Function RegisterEvents()
	RegisterDynamicEvents("TTM")

	; RaceSexMenu Data Transfer
	RegisterForModEvent("RSMDT_SendTargetActor", "OnReceiveTargetActor")
	RegisterForModEvent("RSMDT_SendMenuName", "OnReceiveMenuName")
	RegisterForModEvent("RSMDT_SendRootName", "OnReceiveRootName")
	RegisterForModEvent("RSMDT_SendPrefix", "OnReceivePrefix")
	RegisterForModEvent("RSMDT_SendDataRequest", "OnReceiveDataRequest")
	RegisterForModEvent("RSMDT_SendRestore", "OnReceiveRestore")
	; --------------------------------------------
EndFunction

Function RegisterDynamicEvents(string type)
	RegisterForModEvent(type + "_Initialized", "OnMenuInitialized")
	RegisterForModEvent(type + "_Reinitialized", "OnMenuReinitialized")
	RegisterForModEvent(type + "_CategoriesInitialized", "OnCategoriesInitialized")
	RegisterForModEvent(type + "_SliderChange", "OnMenuSliderChange") ; Event sent when a slider's value is changed
	RegisterForModEvent(type + "_LoadPlugins", "OnMenuLoadPlugins")

	RegisterForModEvent(type + "_TintColorChange", "OnTintColorChange") ; Event sent when a tint changes color
	RegisterForModEvent(type + "_TintTextureChange", "OnTintTextureChange") ; Event sent when a tint changes texture
	RegisterForModEvent(type + "_SliderChange", "OnMenuSliderChange") ; Event sent when a slider's value is changed

	; Overlay Management
	RegisterForModEvent(type + "_OverlayTextureChange", "OnOverlayTextureChange") ; Event sent when an overlay's texture changes
	RegisterForModEvent(type + "_OverlayColorChange", "OnOverlayColorChange") ; Event sent when an overlay's color changes
	RegisterForModEvent(type + "_OverlayGlowColorChange", "OnOverlayGlowColorChange") ; Event sent when an overlay's color changes
	RegisterForModEvent(type + "_ShadersInvalidated", "OnShadersInvalidated") ; Event sent when a tint changes
EndFunction

Function UnregisterDynamicEvents(string type)
	UnregisterForModEvent(type + "_Initialized")
	UnregisterForModEvent(type + "_Reinitialized")
	UnregisterForModEvent(type + "_SliderChange") ; Event sent when a slider's value is changed
	UnregisterForModEvent(type + "_LoadPlugins")

	UnregisterForModEvent(type + "_TintColorChange") ; Event sent when a tint changes color
	UnregisterForModEvent(type + "_TintTextureChange") ; Event sent when a tint changes texture
	UnregisterForModEvent(type + "_SliderChange") ; Event sent when a slider's value is changed

	; Overlay Management
	UnregisterForModEvent(type + "_OverlayTextureChange") ; Event sent when an overlay's texture changes
	UnregisterForModEvent(type + "_OverlayColorChange") ; Event sent when an overlay's color changes
	UnregisterForModEvent(type + "_OverlayGlowColorChange") ; Event sent when an overlay's color changes
	UnregisterForModEvent(type + "_ShadersInvalidated") ; Event sent when a tint changes
EndFunction

Function UnregisterEvents()
	UnregisterDynamicEvents("RSM")
	UnregisterDynamicEvents("TTM")
EndFunction

Function OnStartup()

EndFunction

Event OnMenuInitialized(string eventName, string strArg, float numArg, Form formArg)

EndEvent

Event OnMenuReinitialized(string eventName, string strArg, float numArg, Form formArg)

EndEvent

Event OnReceivePrefix(string eventName, string strArg, float numArg, Form formArg)

EndEvent

Event OnReceiveDataRequest(string eventName, string strArg, float numArg, Form formArg)
	LoadDefaults()
	SaveTints()
	UpdateColors()
	UpdateOverlays()
	parent.OnReceiveDataRequest(eventName, strArg, numArg, formArg)
EndEvent

Event OnGameReload()
	LoadDefaults()
EndEvent

Function UpdateTints()
	
EndFunction

Event On3DLoaded(ObjectReference akRef)

EndEvent

Event OnMenuOpen(string menuName)

EndEvent

Event OnMenuClose(string menuName)

EndEvent
