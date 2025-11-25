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


OSexIntegrationMain Property OStim Auto

;--------- bars
OSexBar Property DomBar Auto
OSexBar Property SubBar Auto
OSexBar Property ThirdBar Auto
;---------

Int Blue = 0xADD8E6
Int Pink = 0xFFB6C1
Int Purple = 0xB19CD9
Int Gray = 0xB0B0B0
Int White = 0xFFFFFF

bool Orgasming

Float LastSmackTime
Int LastSpeed

Event OnInit()
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
		Bar.SetColors(gray, purple, white)
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

Function ColorBar(OSexBar Bar, Bool Female = True, Bool Schlong = True, Int ColorZ = -1)
	Int Color
	If (!Female)
		Color = Blue
	ElseIf (!Schlong)
		Color = Pink
	Else
		Color = Purple
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
EndFunction

Function ForceBarPercent(OSexBar Bar, Float Percent)
	Bar.ForcePercent(Percent / 100.0)
EndFunction

float Function GetBarPercent(OSexBar Bar)
	return Bar.Percent * 100.0
EndFunction

Function FlashBar(OSexBar Bar)
	Bar.ForceFlash()
EndFunction

Event OstimStart(String eventName, String strArg, Float numArg, Form sender)
	Orgasming = false

	if OStim.MatchBarColorToGender
		ColorBar(DomBar, OStim.AppearsFemale(OStim.GetDomActor()), !OStim.IsFemale(OStim.GetDomActor()))
		ColorBar(SubBar, OStim.AppearsFemale(OStim.GetSubActor()), !OStim.IsFemale(OStim.GetSubActor()))
		ColorBar(ThirdBar, OStim.AppearsFemale(OStim.GetThirdActor()), !OStim.IsFemale(OStim.GetThirdActor()))
	else
		ColorBar(DomBar, ColorZ = Blue)
		ColorBar(SubBar, ColorZ = Pink)
		ColorBar(ThirdBar, ColorZ = Purple)
	endif

	If IsBarEnabled(OStim.GetDomActor())
    	SetBarPercent(DomBar, 0.0)
    	SetBarVisible(DomBar, True)
	EndIf

	If IsBarEnabled(OStim.GetSubActor())
		SetBarPercent(SubBar, 0.0)
    	SetBarVisible(SubBar, True)
	EndIf

	If IsBarEnabled(OStim.GetThirdActor())
		SetBarPercent(ThirdBar, 0.0)
    	SetBarVisible(ThirdBar, True)
	EndIf

	While OStim.AnimationRunning()
		While Orgasming
			Utility.Wait(0.2)
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
        
		Utility.wait(0.1)
	EndWhile


	SetBarVisible(DomBar, False)
	SetBarPercent(DomBar, 0.0)
	SetBarVisible(SubBar, False)
	SetBarPercent(SubBar, 0.0)
	SetBarVisible(ThirdBar, False)
	SetBarPercent(ThirdBar, 0.0)
EndEvent

Event OStimOrgasm(String eventName, String strArg, Float numArg, Form sender)
	Orgasming = True
	Actor Act = sender As Actor

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
	If OStim.EnableNpcBar
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

bool Function IsBarEnabled(Actor Act)
	If !Act
		Return false
	EndIf

	If Act == OStim.PlayerRef
		Return OStim.EnablePlayerBar
	Else
		Return OStim.EnableNpcBar
	EndIf
EndFunction

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
