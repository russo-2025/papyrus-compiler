scriptName CPConvert Hidden

;Converts Str from the InCharset codepage into the OutCharset codepage
string Function CPConv(string InCharset, string OutCharset, string Str) global native

;Verifies is the codepage specified by MyCharset parameter valid or not
bool Function CPIsValid(string MyCharset) global native

;Loads the codepage specified in the CPConvert.ini file for MyLng language
string Function GetCPForGameLng(string MyLng = "AUTO") global native

;Changes or removes the codepage in the CPConvert.ini file for MyLng language
bool Function SetCPForGameLng(string MyLng, string MyCharset = "DELETE") global native

;Returns the current language of the game specified in the Skyrim.ini file
string Function GetGameLng() global native

;Retrieves the current Windows ANSI code page identifier for the operating system
string Function GetSystemCP() global native

;Removes the leading and trailing spaces from the string
string Function Trim(string Text) global native

;Transforms string to uppercase (This function is experimental, it does not work and can be removed in next version)
string Function ToUpper(string Text) global native

;Transforms string to lowercase (This function is experimental, it does not work and can be removed in next version)
string Function ToLower(string Text) global native