ScriptName _oPlayer extends ReferenceAlias
 
_oOmni Property OSO hidden
    _oOmni function get()
        return Quest.GetQuest("0SA") as _oOmni 
    endFunction
endProperty

Event OnPlayerLoadGame()
    OSO.Maintenance()
EndEvent