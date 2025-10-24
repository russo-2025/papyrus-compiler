Scriptname MCM Hidden

; Checks to see whether MCM Helper is installed.
bool Function IsInstalled() native global

; Returns the version code of MCM Helper. This value is incremented for every public release of MCM Helper.
int Function GetVersionCode() native global

;-----------------
; Mod Settings
;-----------------

; Obtains the value of a mod setting.
int Function GetModSettingInt(string a_modName, string a_settingName) native global
bool Function GetModSettingBool(string a_modName, string a_settingName) native global
float Function GetModSettingFloat(string a_modName, string a_settingName) native global
string Function GetModSettingString(string a_modName, string a_settingName) native global

; Sets the value of a mod setting.
Function SetModSettingInt(string a_modName, string a_settingName, int a_value) native global
Function SetModSettingBool(string a_modName, string a_settingName, bool a_value) native global
Function SetModSettingFloat(string a_modName, string a_settingName, float a_value) native global
Function SetModSettingString(string a_modName, string a_settingName, string a_value) native global
