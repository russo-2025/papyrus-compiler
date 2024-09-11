Scriptname Shout extends Form Hidden

; SKSE additions built 2015-05-24 00:46:48.937000 UTC
WordOfPower Function GetNthWordOfPower(int n) native
Spell Function GetNthSpell(int n) native
float Function GetNthRecoveryTime(int n) native

Function SetNthWordOfPower(int n, WordOfPower aWoop) native
Function SetNthSpell(int n, Spell aSpell) native
Function SetNthRecoveryTime(int n, float time) native