ScriptName Osexbar Extends SKI_WidgetBase


; -------------------------------------------------------------------------------------------------
; PRIVATE VARIABLES -------------------------------------------------------------------------------


Float	_Width			= 292.8
Float	_Height			= 25.2
Int		_PrimaryColor	= 4259840
Int		_SecondaryColor	= 3342336
Int		_FlashColor		= -1
String 	_FillDirection	= "both"
Float	_Percent		= 0.0


; -------------------------------------------------------------------------------------------------
; PROPERTIES --------------------------------------------------------------------------------------

Bool Property FadedOut Auto

Float Property Width
	{Width of the meter in pixels at a resolution of 1280x720. Default: 292.8}
	Float Function get()
		Return _Width
	EndFunction

	Function set(Float a_val)
		_Width = a_val
		If (Ready)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setWidth", _Width)
		EndIf
	EndFunction
EndProperty

Float Property Height
	{Height of the meter in pixels at a resolution of 1280x720. Default: 25.2}
	Float Function get()
		Return _Height
	EndFunction

	Function set(Float a_val)
		_Height = a_val
		If (Ready)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setHeight", _Height)
		EndIf
	EndFunction
EndProperty

Int Property PrimaryColor
	{Primary color of the meter gradient RRGGBB [0x000000, 0xFFFFFF]. Default: 0xFF0000. Convert to decimal when editing this in the CK}
	Int Function get()
		Return _PrimaryColor
	EndFunction

	Function set(Int a_val)
		_PrimaryColor = a_val
		If (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setColor", _PrimaryColor)
		EndIf
	EndFunction
EndProperty

Int Property SecondaryColor
	{Secondary color of the meter gradient, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
	Int Function get()
		Return _SecondaryColor
	EndFunction

	Function set(Int a_val)
		SetColors(_PrimaryColor, a_val, _FlashColor)
	EndFunction
EndProperty

Int Property FlashColor
	{Color of the meter warning flash, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
	Int Function get()
		Return _FlashColor
	EndFunction

	Function set(Int a_val)
		_FlashColor = a_val
		If (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setFlashColor", _FlashColor)
		EndIf
	EndFunction
EndProperty

String Property FillDirection
	{The position at which the meter fills from, ["left", "center", "right"] . Default: center}
	String Function get()
		Return _FillDirection
	EndFunction

	Function set(String a_val)
		_FillDirection = a_val
		If (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setFillDirection", _FillDirection)
		EndIf
	EndFunction
EndProperty

Float Property Percent
	{Percent of the meter [0.0, 1.0]. Default: 0.0}
	Float Function get()
		Return _Percent
	EndFunction

	Function set(Float a_val)
		_Percent = a_val
		If (Ready)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setPercent", _Percent)
		EndIf
	EndFunction
EndProperty


; -------------------------------------------------------------------------------------------------
; EVENTS ------------------------------------------------------------------------------------------


; @override SKI_WidgetBase
Event OnWidgetReset()
	Parent.OnWidgetReset()

	; Init numbers
	Float[] NumberArgs = new Float[6]
	NumberArgs[0] = _Width
	NumberArgs[1] = _Height
	NumberArgs[2] = _PrimaryColor as Float
	NumberArgs[3] = _SecondaryColor as Float
	NumberArgs[4] = _FlashColor as Float
	NumberArgs[5] = _Percent
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".initNumbers", NumberArgs)

	; Init strings
	String[] StringArgs = new String[1] ;This is an array because I want to add more to it later...
	StringArgs[0] = _FillDirection
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", StringArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
EndEvent


; -------------------------------------------------------------------------------------------------
; FUNCTIONS ---------------------------------------------------------------------------------------


; @overrides SKI_WidgetBase
String Function GetWidgetSource()
	Return "skyui/meter.swf"
EndFunction

; @overrides SKI_WidgetBase
String Function GetWidgetType()
	Return "OsexBar"
EndFunction

Bool Function IsExtending()
	Return True
EndFunction

Function SetPercent(Float a_percent, Bool a_force = False)
	{Sets the meter percent, a_force sets the meter percent without animation}
	_Percent = a_percent
	If (Ready)
		Float[] Args = new Float[2]
		Args[0] = a_percent
		Args[1] = a_force as Float
		UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".setPercent", Args)
	EndIf
EndFunction

Function ForcePercent(Float a_percent)
	{Convenience function for SetPercent(a_percent, True)}
	SetPercent(a_percent, True)
EndFunction

Function StartFlash(Bool a_force = False)
	{Starts meter flashing. a_force starts the meter flashing If it's already animating}
	If (Ready)
		UI.InvokeBool(HUD_MENU, WidgetRoot + ".startFlash", a_force)
	EndIf
EndFunction

Function ForceFlash()
	{Convenience function for StartFlash(True)}
	StartFlash(True)
EndFunction

Function SetColors(Int a_primaryColor, Int a_secondaryColor = -1, Int a_flashColor = -1)
	{Sets the meter percent, a_force sets the meter percent without animation}
	_PrimaryColor = a_primaryColor;
	_SecondaryColor = a_secondaryColor;
	_FlashColor = a_flashColor;

	If (Ready)
		Int[] Args = new Int[3]
		Args[0] = a_primaryColor
		Args[1] = a_secondaryColor
		Args[2] = a_flashColor
		UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setColors", Args)
	EndIf
EndFunction

Function TransitionColors(Int a_primaryColor, Int a_secondaryColor = -1, Int a_flashColor = -1, Int a_duration = 1000)
	{Sets the meter percent, a_force sets the meter percent without animation}
	_PrimaryColor = a_primaryColor;
	_SecondaryColor = a_secondaryColor;
	_FlashColor = a_flashColor;

	If (Ready)
		Int[] Args = new Int[4]
		Args[0] = a_primaryColor
		Args[1] = a_secondaryColor
		Args[2] = a_flashColor
		Args[3] = a_duration
		UI.InvokeIntA(HUD_MENU, WidgetRoot + ".transitionColors", Args)
	EndIf
EndFunction







;==================================================
; New functions

Function SetBarVisible(bool Visible)
	If (Visible)
		FadeTo(100.0, 1.0)
		FadedOut = False
	Else
		FadeTo(0.0, 1.0)
		FadedOut = True
	EndIf
EndFunction
