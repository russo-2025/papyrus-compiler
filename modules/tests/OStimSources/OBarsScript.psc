ScriptName OBarsScript Extends Quest

;
;			██████╗  █████╗ ██████╗ ███████╗
;			██╔══██╗██╔══██╗██╔══██╗██╔════╝
;			██████╔╝███████║██████╔╝███████╗
;			██╔══██╗██╔══██║██╔══██╗╚════██║
;			██████╔╝██║  ██║██║  ██║███████║
;			╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
;
;				Code related to the on-screen bars


OSexIntegrationMain OStim

;--------- bars
OSexBar Property DomBar Auto
OSexBar Property SubBar Auto
OSexBar Property ThirdBar Auto
;---------

Int Blue
Int Pink
Int Gray
Int Yellow
Int White

actor PlayerRef

Event OnInit()
	OStim = (Self as Quest) as OSexIntegrationMain

	DomBar = (Self as Quest) as OSexBar
	SubBar = (Game.GetFormFromFile(0x000804, "OStim.esp")) as OSexBar
	ThirdBar = (Game.GetFormFromFile(0x000802, "OStim.esp")) as OSexBar

	PlayerRef = Game.getplayer()

	Blue = 0xADD8E6
	Pink = 0xFFB6C1
	Yellow = 0xE6E0AD
	Gray = 0xB0B0B0
	White = 0xFFFFFF

	InititializeAllBars()

	OnGameLoad()

	LastSmackTime = 0
EndEvent

Function InititializeAllBars()
	InitBar(DomBar, 0)
	InitBar(SubBar, 1)
	InitBar(ThirdBar, 2)
EndFunction

Function InitBar(OSexBar Bar, Int ID)
	Bar.HAnchor = "left"
	Bar.VAnchor = "bottom"
	Bar.X = 200
	Bar.Alpha = 0.0
	Bar.SetPercent(0.0)
	Bar.FillDirection = "Right"

	If (ID == 0)
		Bar.Y = 692
		Bar.SetColors(gray, blue, white)
	Elseif (ID == 1)
		Bar.Y = 647
		Bar.SetColors(gray, pink, white)
	ElseIf (ID == 2)
		Bar.Y = 602
		Bar.SetColors(gray, yellow, white)
	EndIf

	SetBarVisible(Bar, False)
EndFunction

Function SetBarVisible(OSexBar Bar, Bool Visible)
	If (Visible)
		Bar.FadeTo(100.0, 1.0)
		Bar.FadedOut = False
	Else
		Bar.FadeTo(0.0, 1.0)
		Bar.FadedOut = True
	EndIf
EndFunction

Function ColorBar(OSexBar Bar, Bool Female = True, Int ColorZ = -1)
	Int Color
	If (!Female)
		Color = Blue
	Else
		Color = Pink
	EndIf

	If (ColorZ > 0)
		Color = ColorZ
	endif

	Bar.SetColors(Gray, Color, White)
Endfunction

Bool Function IsBarVisible(OSexBar Bar)
	Return (!Bar.FadedOut)
EndFunction

Function SetBarPercent(OSexBar Bar, Float Percent)
	Bar.SetPercent(Percent / 100.0)
	Float zPercent = Percent / 100.0
	If (zPercent >= 1.0)
		FlashBar(Bar)
	EndIf
EndFunction

float Function GetBarPercent(OSexBar Bar)
	return Bar.Percent * 100.0
EndFunction

Function FlashBar(OSexBar Bar)
	Bar.ForceFlash()
EndFunction

Event OstimStart(String eventName, String strArg, Float numArg, Form sender)
	Orgasming = false

	If !OStim.IsActorActive(playerref) && OStim.HideBarsInNPCScenes
		return 
	EndIf 

	if OStim.MatchBarColorToGender
		ColorBar(DomBar, OStim.AppearsFemale(OStim.GetDomActor()))
		ColorBar(SubBar, OStim.AppearsFemale(OStim.GetSubActor()))
		ColorBar(ThirdBar, OStim.AppearsFemale(OStim.GetThirdActor()))
	else
		ColorBar(DomBar, ColorZ = Blue)
		ColorBar(SubBar, ColorZ = Pink)
		ColorBar(ThirdBar, ColorZ = Yellow)
	endif

	If (OStim.EnableDomBar)
    	SetBarPercent(DomBar, 0.0)
    	SetBarVisible(DomBar, True)
	EndIf

	If (OStim.EnableSubBar && (OStim.GetSubActor() != None))
		SetBarPercent(SubBar, 0.0)
    	SetBarVisible(SubBar, True)
	EndIf

	If (OStim.EnableThirdBar) && (OStim.GetThirdActor() != none)
		SetBarPercent(ThirdBar, 0.0)
    	SetBarVisible(ThirdBar, True)
	EndIf

	While OStim.AnimationRunning()
		While Orgasming
			Utility.Wait(0.3)
		EndWhile

		If (OStim.AutoHideBars && (OStim.GetTimeSinceLastPlayerInteraction() > 15.0)) ; fade out if needed
    		If (IsBarVisible(DomBar))
    			SetBarVisible(DomBar, False)
    		EndIf
    		If (IsBarVisible(SubBar))
    			SetBarVisible(SubBar, False)
    		EndIf
    		If (IsBarVisible(ThirdBar))
    			SetBarVisible(ThirdBar, False)
    		EndIf
    	EndIf

    	
    	SetBarFullnessProper()
        

		Utility.wait(1)
	EndWhile


	SetBarVisible(DomBar, False)
	SetBarPercent(DomBar, 0.0)
	SetBarVisible(SubBar, False)
	SetBarPercent(SubBar, 0.0)
	SetBarVisible(ThirdBar, False)
	SetBarPercent(ThirdBar, 0.0)
EndEvent
bool orgasming

Event OStimOrgasm(String eventName, String strArg, Float numArg, Form sender)
	Orgasming = True
	Actor Act = OStim.GetMostRecentOrgasmedActor()

	If (Act == OStim.GetDomActor())
		SetBarPercent(DomBar, 100)
		FlashBar(DomBar)
		Utility.Wait(2)
		SetBarPercent(DomBar, 0)
	ElseIf (Act == OStim.GetSubActor())
		SetBarPercent(SubBar, 100)
		FlashBar(SubBar)
		Utility.Wait(2)
		SetBarPercent(SubBar, 0)
	ElseIf (Act == OStim.GetThirdActor())
		SetBarPercent(ThirdBar, 100)
		FlashBar(ThirdBar)
		Utility.Wait(2)
		SetBarPercent(ThirdBar, 0)
	EndIf
	Orgasming = False
endevent

Event OstimThirdJoin(String eventName, String strArg, Float numArg, Form sender)
	If !OStim.IsActorActive(playerref) && OStim.HideBarsInNPCScenes
		return 
	EndIf 
	
	If (OStim.EnableThirdBar)
		OSexIntegrationMain.Console("Launching third actor bar")
		SetBarPercent(ThirdBar, 0.0)
    	SetBarVisible(ThirdBar, True)
	EndIf
Endevent

Event OstimThirdLeave(String eventName, String strArg, Float numArg, Form sender)
	OsexIntegrationMain.Console("Closing third actor bar")
	SetBarVisible(ThirdBar, False)
	SetBarPercent(ThirdBar, 0.0)
Endevent

Float LastSmackTime
Int LastSpeed

;/
Event OnOSASound(string eventName, string args, float nothing, Form sender)
	if orgasming
		return
	endif

	string[] argz = new string[3]
	argz = StringUtil.Split(args, ",")

	int formID = argz[1] as Int

	If (formID == 50) || (formID == 60) ; we are getting a smacking sound, bodies have collided.
		;osexintegrationmain.Console("Smack recieved")
		if formid == 60 ;better sync with spank
			Utility.Wait(0.2)
		endif
		float currTime = Game.GetRealHoursPassed() * 60 * 60
		float timediff = currTime - lastSmackTime ; time since last smack sound

		if (timediff > 2.5) ; it's been a long time since we got a smacking sound
			SetBarFullnessProper() ; set bar to the correct value
		elseif (timediff < 0.25)
			return ; events are coming too rapidly to safely handle here
		Else
			float correctnessdiffdom
			float correctnessdiffsub
			float correctnessdiffthird

			correctnessdiffdom = GetBarCorrectnessDifference(0) ;get how far off the current dom bar is
			correctnessdiffsub = GetBarCorrectnessDifference(1)
			if ostim.getthirdActor()
				correctnessdiffthird = GetBarCorrectnessDifference(2)
			EndIf
			;osexintegrationmain.console("Bar difference: " + correctnessdiffdom)

			if timediff < 1
				 ; events are coming in at a rate of more than 1/second. Change the error correction to be smaller
				correctnessdiffdom = correctnessdiffdom * timediff
				correctnessdiffsub = correctnessdiffsub * timediff
				correctnessdiffthird = correctnessdiffthird * timediff
			endif


			;osexintegrationmain.console("adding: " + correctnessdiffdom)
			AddBarFullness(0, correctnessdiffdom)
			AddBarFullness(1, correctnessdiffsub)
			AddBarFullness(2, correctnessdiffthird)


		EndIf

		lastSmackTime = currtime
	EndIf


endevent
/;

Function SetBarFullnessProper()
	SetBarPercent(DomBar, OStim.GetActorExcitement(OStim.GetDomActor()))
	If OStim.GetSubActor()
		SetBarPercent(SubBar, OStim.GetActorExcitement(OStim.GetSubActor()))
	EndIf
	If OStim.GetThirdActor()
		SetBarPercent(ThirdBar, OStim.GetActorExcitement(OStim.GetThirdActor()))
	EndIf
EndFunction

Function AddBarFullness(Int Bar, Float Amount)
	If (Bar == 0)
		SetBarPercent(DomBar, GetBarPercent(DomBar) + Amount)
	ElseIf (Bar == 1)
		SetBarPercent(SubBar, GetBarPercent(SubBar) + Amount)
    ElseIf (Bar == 2)
		SetBarPercent(ThirdBar, GetBarPercent(ThirdBar) + Amount)
	EndIf
EndFunction

Float Function GetBarCorrectnessDifference(Int BarID)
	If (BarID == 0)
		Return OStim.GetActorExcitement(OStim.GetDomActor()) - GetBarPercent(DomBar)
	ElseIf (BarID == 1)
		Return OStim.GetActorExcitement(OStim.GetSubActor()) - GetBarPercent(SubBar)
	ElseIf (BarID == 2)
		Return OStim.GetActorExcitement(OStim.GetThirdActor()) - GetBarPercent(ThirdBar)
	EndIf
EndFunction

Function OnGameLoad()
	RegisterForModEvent("ostim_start", "OStimStart")
	RegisterForModEvent("ostim_orgasm", "OStimOrgasm")

	RegisterForModEvent("ostim_thirdactor_join", "OStimThirdJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OStimThirdLeave")

	;RegisterForModEvent("ostim_osasound", "OnOSASound")

	;OSexintegrationMain.Console("Fixing Bars thread")
EndFunction
