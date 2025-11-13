ScriptName Lovense Hidden
{
  API Script to control Lovense toys. Each function in this script is blocking and
  will pause the script until the command is either fully processed or timed out.
}

; Get the number of currently connected toys
int Function GetConnectedCount() native global

; Get a list of all currently connected Toys
String[] Function GetToyIDs() native global

; Get a list of all names of currently connected Toys
String[] Function GetToyNames() native global
String Function GetToyName(String asId) native global

; Get the category of a toy. For a list of categories see:
; https://github.com/Scrabx3/SkyrimLovense/blob/main/src/Lovense/Define/Category.h
String Function GetToyCategory(String asId) native global

; Get all toys of a specific category. For category names see:
; https://github.com/Scrabx3/SkyrimLovense/blob/main/src/Lovense/Define/Category.h
String[] Function GetToysByCategory(String asCategory) native global

; Stop the current request on a toy
bool Function StopRequest(String asToy = "") native global

; Request a behavior from a toy. For more information see:
; https://developer.lovense.com/docs/standard-solutions/standard-api.html#function-request
; --- Params ---
; asActions: Array of actions to perform, see https://github.com/Scrabx3/SkyrimLovense/blob/main/src/Lovense/Define/Action.h
; asStrengths: Array of integers, specifying the strength of each action. (int[i] is the strength of act[i]) (Must be of the same length as asActions)
; asTimeSec: Time in seconds how long the actions are being performed (0 is indefinite, else should be greater than 1)
; loopRunningSec: Time in seconds how long a single loop lasts. If specified, should be greater than 1
; loopPauseSec: Time in seconds to pause between loops. If specified, should be greater than 1
; asToy: ID of the toy to perform the actions on. If empty, all connected toys will be used
; aiStopPrevious: Stop the previous action before starting the new one
; --- Return ---
; True if the request was successful, false otherwise
bool Function FunctionRequest(String[] asActions, int[] aiStrengths, float afTimeSec, float afLoopRunningSec = 0.0, float afLoopPauseSec = 0.0, String asToy = "", bool abStopPrevious = true) native global

; Request a complex behavior from a toy. For more information see:
; https://developer.lovense.com/docs/standard-solutions/standard-api.html#pattern-request
; --- Params ---
; asActions: Array of actions to perform. See https://github.com/Scrabx3/SkyrimLovense/blob/main/src/Lovense/Define/Action.h
; asStrengths: Array of strengths for each interval (int[i] is the strength of the i'th interval) (Array length <= 50)
; intervalMs: Time in milliseconds for each interval
; afTimeSec: Time in seconds how long the actions are being performed (0 is indefinite, else should be greater than 1)
; asToy: ID of the toy to perform the actions on. If empty, all connected toys will be used
; --- Return ---
; True if the request was successful, false otherwise
bool Function PatternRequest(String[] asActions, int[] aiStrengths, int aiIntervalMs, float afTimeSec, String asToy = "") native global

; Request a default behaviour from a toy. For more information see:
; https://developer.lovense.com/docs/standard-solutions/standard-api.html#preset-request
; --- Params ---
; asPreset: Name of the preset to use. See https://github.com/Scrabx3/SkyrimLovense/blob/main/src/Lovense/Define/Preset.h
; timeSec: Time in seconds how long the preset is being performed (0 is indefinite, else should be greater than 1)
; asToy: ID of the toy to perform the actions on. If empty, all connected toys will be used
; --- Return ---
; True if the request was successful, false otherwise
bool Function PresetReqest(String asPreset, float afTimeSec, String asToy = "") native global
