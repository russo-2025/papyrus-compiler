ScriptName OStimAddon Extends Quest Hidden

; 	HOW TO USE THIS
; This script contains some common things addons need to function
; Have your addon script extend this one, then at the end of the addon's oninit, call InstallAddon()



;███████╗████████╗ █████╗ ██████╗ ████████╗██╗███╗   ██╗ ██████╗ 
;██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝██║████╗  ██║██╔════╝ 
;███████╗   ██║   ███████║██████╔╝   ██║   ██║██╔██╗ ██║██║  ███╗
;╚════██║   ██║   ██╔══██║██╔══██╗   ██║   ██║██║╚██╗██║██║   ██║
;███████║   ██║   ██║  ██║██║  ██║   ██║   ██║██║ ╚████║╚██████╔╝
;╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                                
; Call this from a child script's OnInit() to set up the addon backend

Function InstallAddon(string name)
	ostim = outils.GetOStim()
	playerref = game.GetPlayer()

	AddonName = name


	if ostim.GetAPIVersion() < RequiredVersion
		debug.MessageBox("Your OStim version is out of date. Please update for " + name + " to function.")
		debug.MessageBox("Your OStim version is: " + ostim.GetAPIVersion())
		return 
	endif  

	
	outils.RegisterForOUpdate(self) ;register to update system

	if LoadGameEvents
		OStim.RegisterForGameLoadEvent(self) ; register for OnGameLoad() 
		osanative.SendEvent(self, "OnGameLoad") ; call ongameload once.
	endif 

	outils.console(name + " installed")
	debug.Notification(name + " installed")
EndFunction


;██████╗  █████╗ ████████╗ █████╗ 
;██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
;██║  ██║███████║   ██║   ███████║
;██║  ██║██╔══██║   ██║   ██╔══██║
;██████╔╝██║  ██║   ██║   ██║  ██║
;╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
                                 
; Properties with some useful data you have access to in all scripts that extend this one

; Only functional after calling InstallAddon()
OSexIntegrationMain property ostim auto 
actor property PlayerRef auto 
string property AddonName auto




;███████╗███████╗████████╗████████╗██╗███╗   ██╗ ██████╗ ███████╗
;██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗  ██║██╔════╝ ██╔════╝
;███████╗█████╗     ██║      ██║   ██║██╔██╗ ██║██║  ███╗███████╗
;╚════██║██╔══╝     ██║      ██║   ██║██║╚██╗██║██║   ██║╚════██║
;███████║███████╗   ██║      ██║   ██║██║ ╚████║╚██████╔╝███████║
;╚══════╝╚══════╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
  
; Some settings you can tweak. Tweak them before calling InstallAddon()

; Throws an error is user has a version older than this
int property RequiredVersion = 24 auto 

; Insert events into here to register for them on each load
; You cannot use this system while extending OnGameLoad.  
string[] property RegisteredEvents auto      

; Needed for OnGameLoad() to function.
; If not needed, can be disabled to free up resources
bool property LoadGameEvents = true auto                                                       



;███████╗██╗  ██╗████████╗███████╗███╗   ██╗██████╗  █████╗ ██████╗ ██╗     ███████╗
;██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝
;█████╗   ╚███╔╝    ██║   █████╗  ██╔██╗ ██║██║  ██║███████║██████╔╝██║     █████╗  
;██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║╚██╗██║██║  ██║██╔══██║██╔══██╗██║     ██╔══╝  
;███████╗██╔╝ ██╗   ██║   ███████╗██║ ╚████║██████╔╝██║  ██║██████╔╝███████╗███████╗
;╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝
                                                                                   

Event OnGameLoad() ; You can either extend this, or not extend it and use RegisteredEvents
	if RegisteredEvents
		RegisterSavedEvents()
	endif 
EndEvent

Event OnInit()
	Debug.messagebox("Extend me!")
EndEvent


;████████╗ ██████╗  ██████╗ ██╗     ███████╗
;╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
;   ██║   ██║   ██║██║   ██║██║     ███████╗
;   ██║   ██║   ██║██║   ██║██║     ╚════██║
;   ██║   ╚██████╔╝╚██████╔╝███████╗███████║
;   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
                                           

Function RegisterSavedEvents()
	int i = 0 
	int l = RegisteredEvents.Length
	while i < l 
		registerforoevent(RegisteredEvents[i])

		i += 1
	endwhile
EndFunction

;███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
;██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
;█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
;██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
;███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
;╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
                                                    
; Some common OStim events. Add them to your script and use RegisterForOEvent if you aren't using the addon event registration system above

Function RegisterForOEvent(string EventName)
	RegisterForModEvent(EventName, EventName)
EndFunction


Event OStim_PreStart(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_Start(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_AnimationChanged(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_SceneChanged(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_Orgasm(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_End(string eventName, string strArg, float numArg, Form sender)
EndEvent
