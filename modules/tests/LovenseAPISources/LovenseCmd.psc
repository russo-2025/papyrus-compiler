ScriptName LovenseCmd Hidden

bool Function SetPort(int asPort) global native
bool Function SetAddress(String asAddress) global native

bool Function ConnectImpl() global native
String Function Connect() global
  If (!ConnectImpl())
    Return "Failed to connect to Lovense API"
  EndIf
  return "Connected to Lovense API. Connected Toys: " + GetConnectedToys()
EndFunction

String Function GetConnectedToys() global
  return Lovense.GetToyNames()
EndFunction
