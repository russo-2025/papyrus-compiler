
;/  Utility functionality
/;
ScriptName JContainers

;/  It's NOT part of public API
/;
Bool function __isInstalled() global native

;/  Version information.
    It's a good practice to validate installed JContainers version with the following code:
        bool isJCValid = JContainers.APIVersion() == AV && JContainers.featureVersion() >= FV
    where AV and FV are hardcoded API and feature version numbers.
    Current API version is 3
    Current feature version is 3
/;
Int function APIVersion() global native
Int function featureVersion() global native

;/  Returns true if the file at a specified @path exists
/;
Bool function fileExistsAtPath(String path) global native
String[] function contentsOfDirectoryAtPath(String directoryPath, String extension="") global native

;/  Deletes the file or directory identified by the @path
/;
function removeFileAtPath(String path) global native

;/  A path to user-specific directory - My Games/Skyrim/JCUser/
/;
String function userDirectory() global native

;/  DEPRECATED. Returns last occured error (error code):
    0 - JError_NoError
    1 - JError_ArrayOutOfBoundAccess
/;
Int function lastError() global native

;/  DEPRECATED. Returns string that describes last error
/;
String function lastErrorString() global native

; Returns true if JContainers plugin installed properly
bool function isInstalled() global
    return __isInstalled() && 3 == APIVersion() && 3 == featureVersion()
endfunction

