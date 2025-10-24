Scriptname MCM_ConfigBase extends SKI_ConfigBase

;-----------------
; Events
;-----------------

; Event raised when an MCM setting is changed.
Event OnSettingChange(string a_ID)
EndEvent

; Event raised when a new page is selected, including the initial empty page.
Event OnPageSelect(string a_page)
EndEvent

;-----------------
; MCM
;-----------------

; Refreshes currently displayed values in the MCM if it is currently open.
; Call this if you have changed values in response to an OnSettingChange event.
Function RefreshMenu() native

; Dynamically override menu options via script.
; The supplied ID must refer to a menu control.
Function SetMenuOptions(string a_ID, string[] a_options, string[] a_shortNames = None) native

;-----------------
; Mod Settings
;-----------------

; Obtains the value of a mod setting.
int Function GetModSettingInt(string a_settingName) native
bool Function GetModSettingBool(string a_settingName) native
float Function GetModSettingFloat(string a_settingName) native
string Function GetModSettingString(string a_settingName) native

; Sets the value of a mod setting.
Function SetModSettingInt(string a_settingName, int a_value) native
Function SetModSettingBool(string a_settingName, bool a_value) native
Function SetModSettingFloat(string a_settingName, float a_value) native
Function SetModSettingString(string a_settingName, string a_value) native

;-------------------
; SkyUI Overrides
;-------------------

; SkyUI functions delegated to MCM Helper's SKSE plugin.
Event OnPageReset(string a_page) native
Event OnOptionHighlight(int a_option) native
Event OnOptionSelect(int a_option) native
Event OnOptionDefault(int a_option) native
Event OnOptionSliderOpen(int a_option) native
Event OnOptionSliderAccept(int a_option, float a_value) native
Event OnOptionMenuOpen(int a_option) native
Event OnOptionMenuAccept(int a_option, int a_index) native
Event OnOptionColorOpen(int a_option) native
Event OnOptionColorAccept(int a_option, int a_color) native
Event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName) native
Event OnOptionInputOpen(int a_option) native
Event OnOptionInputAccept(int a_option, string a_input) native

Event OnConfigManagerReady(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	LoadConfig()
	parent.OnConfigManagerReady(a_eventName, a_strArg, a_numArg, a_sender)
EndEvent

string Function GetCustomControl(int a_keyCode) native

Function LoadConfig() native
