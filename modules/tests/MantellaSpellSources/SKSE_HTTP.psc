scriptName SKSE_HTTP hidden

function sendLocalhostHttpRequest(int typedDictionaryHandle, int port, string route, int timeout = 0) global native

function raiseOnHttpReplyReceived(int typedDictionaryHandle) global
    int handle = ModEvent.Create("SKSE_HTTP_OnHttpReplyReceived")
    if (handle)
        ModEvent.PushInt(handle, typedDictionaryHandle)
        ModEvent.Send(handle)
    endIf    
endFunction

function raiseOnHttpErrorReceived(int typedDictionaryHandle) global
    int handle = ModEvent.Create("SKSE_HTTP_OnHttpErrorReceived")
    if (handle)
        ModEvent.PushInt(handle, typedDictionaryHandle)
        ModEvent.Send(handle)
    endIf    
endFunction

; Dictionary

Int function createDictionary() global native
function clearAllDictionaries() global native

;/  Returns the value associated with the @key. If not, returns @default value
/;
String function getString(Int object, String key, String default="") global native
Int function getInt(Int object, String key, Int default=0) global native
Float function getFloat(Int object, String key, Float default=0.0) global native
Bool function getBool(Int object, String key, Bool default=false) global native
Int function getNestedDictionary(Int object, String key, Int default=0) global native
Int[] function getIntArray(Int object, String key) global native
Float[] function getFloatArray(Int object, String key) global native
String[] function getStringArray(Int object, String key) global native
Bool[] function getBoolArray(Int object, String key) global native
Int[] function getNestedDictionariesArray(Int object, String key) global native

;/  Inserts @key: @value pair. Replaces existing pair with the same @key
/;
Bool function setString(Int object, String key, String value) global native
function setInt(Int object, String key, Int value) global native
function setFloat(Int object, String key, Float value) global native
function setBool(Int object, String key, Bool value) global native
function setNestedDictionary(Int object, String key, Int value) global native
function setIntArray(Int object, String key, Int[] value) global native
function setFloatArray(Int object, String key, Float[] value) global native
Bool function setStringArray(Int object, String key, String[] value) global native
function setBoolArray(Int object, String key, Bool[] value) global native
function setNestedDictionariesArray(Int object, String key, Int[] value) global native

;/  Returns true, if the container has @key: value pair
/;
Bool function hasKey(Int object, String key) global native

;/  Returns type of the value associated with the @key.
    0 - no value, 1 - none, 2 - int, 3 - float, 4 - form, 5 - object, 6 - string
/;
Int function valueType(Int object, String key) global native

Function TakeScreenshot() global native
Function RenameScreenshot(String filename) global native
VoiceType Function GetVoiceType(Actor actor) global native
Function SetVoiceType(Actor actor, VoiceType voice) global native
VoiceType Function GetRaceDefaultVoiceType(Actor actor) global native
Function SetRaceDefaultVoiceType(Actor actor, VoiceType voice) global native
