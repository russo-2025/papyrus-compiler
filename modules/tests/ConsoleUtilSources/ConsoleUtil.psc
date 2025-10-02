ScriptName ConsoleUtil


; @brief Executes the command.
; @param a_command - The command to execute, i.e. "player.setav attackdamagemult 100".
Function ExecuteCommand(String a_command) Global Native


; @brief Returns the console's selected reference.
; @return Returns NONE if no reference is selected, else returns the console's selected reference.
ObjectReference Function GetSelectedReference() Global Native

; @brief Sets the console's selected reference to the specified reference.
; @param a_reference - The reference to set the selected reference to.
Function SetSelectedReference(ObjectReference a_reference) Global Native


; @brief Reads the last message printed to the console.
; @return The last message printed to the console.
String Function ReadMessage() Global Native


; @brief Prints the given message to the console.
; @param a_message - The message to print to the console.
Function PrintMessage(String a_message) Global Native


; @brief Returns the API version.
; @return Returns 0 if not installed, else returns the API version.
Int Function GetVersion() Global Native