scriptname ConsoleUtil Hidden

; Get version of mod.
int function GetVersion() global native

; This will print message to console (with newline).
function PrintMessage(string text) global native

; This will read last message from console.
string function ReadMessage() global native

; Execute command in console silently.
function ExecuteCommand(string text) global native

; Get reference that is currently selected in the console.
ObjectReference function GetSelectedReference() global native

; Set this object as console commands target.
function SetSelectedReference(ObjectReference obj) global native
