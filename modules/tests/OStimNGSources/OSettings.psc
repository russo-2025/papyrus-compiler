;/* OSettings
* * internal script, not meant for external use
* * don't use any of this unless you know exactly what you are doing
* *
* * required API Version: 7.3.1 (0x07030010)
*/;
ScriptName OSettings

Function MenuOpened() Global Native
	
int Function GetSettingPageCount() Global Native
string Function GetSettingPageName(int Page) Global Native
int Function GetSettingPageDisplayOrder(int Page) Global Native

int Function GetSettingGroupCount(int Page) Global Native
string Function GetSettingGroupName(int Page, int Group) Global Native
int Function GetSettingGroupDisplayOrder(int Page, int Group) Global Native

int Function GetSettingCount(int Page, int Group) Global Native
string Function GetSettingName(int Page, int Group, int Setting) Global Native
string Function GetSettingTooltip(int Page, int Group, int Setting) Global Native
int Function GetSettingType(int Page, int Group, int Setting) Global Native
bool Function IsSettingEnabled(int Page, int Group, int Setting) Global Native

bool Function IsSettingActivatedByDefault(int Page, int Group, int Setting) Global Native
bool Function IsSettingActivated(int Page, int Group, int Setting) Global Native
bool Function ToggleSetting(int Page, int Group, int Setting) Global Native

float Function GetDefaultSettingValue(int Page, int Group, int Setting) Global Native
float Function GetCurrentSettingValue(int Page, int Group, int Setting) Global Native
float Function GetSettingValueStep(int Page, int Group, int Setting) Global Native
float Function GetMinSettingValue(int Page, int Group, int Setting) Global Native
float Function GetMaxSettingValue(int Page, int Group, int Setting) Global Native
bool Function SetSettingValue(int Page, int Group, int Setting, float Value) Global Native

int Function GetDefaultSettingIndex(int Page, int Group, int Setting) Global Native
int Function GetCurrentSettingIndex(int Page, int Group, int Setting) Global Native
string Function GetCurrentSettingOption(int Page, int Group, int Setting) Global Native
string[] Function GetSettingOptions(int Page, int Group, int Setting) Global Native
bool Function SetSettingIndex(int Page, int Group, int Setting, int Index) Global Native

string Function GetDefaultSettingText(int Page, int Group, int Setting) Global Native
string Function GetCurrentSettingText(int Page, int Group, int Setting) Global Native
bool Function SetSettingText(int Page, int Group, int Setting, string Text) Global Native

int Function GetDefaultSettingKey(int Page, int Group, int Setting) Global Native
int Function GetCurrentSettingKey(int Page, int Group, int Setting) Global Native
bool Function SetSettingKey(int Page, int Group, int Setting, int KeyCode) Global Native

bool Function ClickSetting(int Page, int Group, int Setting) Global Native