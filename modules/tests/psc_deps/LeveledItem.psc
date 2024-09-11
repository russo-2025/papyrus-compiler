Scriptname LeveledItem extends Form Hidden

; Adds the given count of the given form to the under the given level in this leveled list
Function AddForm(Form apForm, int aiLevel, int aiCount) native

; Removes all script added forms from this leveled list
Function Revert() native

; SKSE additions built 2015-05-24 00:46:48.937000 UTC
int function GetChanceNone() native
Function SetChanceNone(int chance) native

GlobalVariable Function GetChanceGlobal() native
Function SetChanceGlobal(GlobalVariable glob) native

int Function GetNumForms() native
Form Function GetNthForm(int n) native

int Function GetNthLevel(int n) native
Function SetNthLevel(int n, int level) native

int Function GetNthCount(int n) native
Function SetNthCount(int n, int count) native