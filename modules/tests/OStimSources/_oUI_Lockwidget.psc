Scriptname _oUI_Lockwidget extends SKI_WidgetBase
{Lock symbol widget to indicate when OSA controls are locked.}

; code

bool Property visible
    bool Function Get()
        Return Ui.GetBool(HUD_MENU, WidgetRoot + "._visible")
    EndFunction
EndProperty

Event OnWidgetReset()
    parent.OnWidgetReset()
EndEvent

String Function GetWidgetSource()
    Return "ostim/LockSymbolWidget.swf"
EndFunction

Function FlashVisibililty(float seconds = 2.0) ; Will set itself visible true when it starts, and set visible false when it ends.
    UI.InvokeFloat(HUD_MENU, WidgetRoot + ".FlashVisibility", seconds)
endfunction

bool Function ToggleVisiblity()
    return SetVisible(!visible)
endfunction 

Bool Function SetVisible(bool IsVisible)
    UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", IsVisible)
    Return visible
EndFunction