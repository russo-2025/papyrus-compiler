;/* OData
* * bunch of native functions for data serialization
* * meant for internal use and not to be called by addons
* * might still document it at some point... maybe..
*/;
ScriptName OData

int Function GetUndressingSlotMask() Global Native

Function SetUndressingSlotMask(int Mask) Global Native


string[] Function PairsToNames(string[] Pairs) Global Native


string[] Function GetEquipObjectTypes() Global Native

string[] Function GetEquipObjectPairs(int FormID, string Type) Global Native

string Function GetEquipObjectName(int FormID, string Type) Global Native

Function SetEquipObjectID(int FormID, string Type, string ID) Global Native


string[] Function GetVoiceSetPairs() Global Native

string Function GetVoiceSetName(int FormID) Global Native

Function SetVoiceSet(int FormID, string Voice) Global Native


string[] Function GetActions() Global Native

float Function GetActionStimulation(int Role, int FormID, string Actn) Global Native
Function SetActionStimulation(int Role, int FormID, string Actn, float Stimulation) Global Native
float Function GetActionMaxStimulation(int Role, int FormID, string Actn) Global Native
Function SetActionMaxStimulation(int Role, int FormID, string Actn, float Stimulation) Global Native
float Function GetActionDefaultStimulation(int Role, string Actn) Global Native
Function ResetActionStimulation(int Role, int FormID, string Actn) Global Native
float Function GetActionDefaultMaxStimulation(int Role, string Actn) Global Native
Function ResetActionMaxStimulation(int Role, int FormID, string Actn) Global Native

string[] Function GetEvents() Global Native

float Function GetEventStimulation(int Role, int FormID, string Evt) Global Native
Function SetEventStimulation(int Role, int FormID, string Evt, float Stimulation) Global Native
float Function GetEventMaxStimulation(int Role, int FormID, string Evt) Global Native
Function SetEventMaxStimulation(int Role, int FormID, string Evt, float Stimulation) Global Native
float Function GetEventDefaultStimulation(int Role, string Evt) Global Native
Function ResetEventStimulation(int Role, int FormID, string Evt) Global Native
float Function GetEventDefaultMaxStimulation(int Role, string Evt) Global Native
Function ResetEventMaxStimulation(int Role, int FormID, string Evt) Global Native


Function ResetSettings() Global Native

Function ExportSettings() Global Native

Function ImportSettings() Global Native

string Function Localize(string Text) Global Native