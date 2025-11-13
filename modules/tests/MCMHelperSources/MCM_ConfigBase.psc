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

; Event raised when a config menu is first initialized.
Event OnConfigInit()
EndEvent

; Event raised when a config menu is opened.
Event OnConfigOpen()
EndEvent

; Event raised when a config menu is closed.
Event OnConfigClose()
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
