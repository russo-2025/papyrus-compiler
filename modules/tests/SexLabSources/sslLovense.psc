ScriptName sslLovense Hidden

bool Function IsLovenseInstalled() global
  return SKSE.GetPluginVersion("SkyrimLovense") > -1
EndFunction

bool Function IsLovenseConnected() global
  return IsLovenseInstalled() && Lovense.GetConnectedCount() > 0
EndFunction

; ------------------------------------------------------- ;
; --- Start Actions                                   --- ;
; ------------------------------------------------------- ;

Function StartAction(int aiStrength) global
  String[] toys = Lovense.GetToyIDs()
  StartDefaultActions(toys, aiStrength, abStopPrevious = false)
EndFunction

Function StartOrgasmAction(int aiStrength, float duration) global
  String[] toys = new String[1]
  StartDefaultActions(toys, aiStrength, duration, true)
EndFunction

Function StartDefaultActions(String[] toys, int strength, float duration = 0.0, bool abStopPrevious) global
  If (strength <= 0)
    return
  EndIf
  int[] argStrength = new int[1]
  argStrength[0] = strength
  String[] argType = new String[1]
  argType[0] = "All"
  int i = 0
  While (i < toys.Length)
    Lovense.FunctionRequest(argType, argStrength, duration, asToy = toys[i], abStopPrevious = abStopPrevious)
    i += 1
  EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Stop Actions                                    --- ;
; ------------------------------------------------------- ;

Function StopAllActions() global
  Lovense.StopRequest()
EndFunction
