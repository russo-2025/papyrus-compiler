
;/  Global entry point to store mod information. Main intent - replace global variables
    Manages keys and values associations (like JMap)
/;
ScriptName JDB

;/  Attempts to retrieve the value associated with the @path.
    For ex. the following information associated with 'frosfall' key:
    
    "frostfall" : {
        "exposureRate" : 0.5,
        "arrayC" : ["stringValue", 1.5, 10, 1.14]
    }
    
    then JDB.solveFlt(".frostfall.exposureRate") will return 0.5 and
    JDB.solveObj(".frostfall.arrayC") will return the array containing ["stringValue", 1.5, 10, 1.14] values
/;
Float function solveFlt(String path, Float default=0.0) global native
Int function solveInt(String path, Int default=0) global native
String function solveStr(String path, String default="") global native
Int function solveObj(String path, Int default=0) global native
Form function solveForm(String path, Form default=None) global native

;/  Attempts to assign the @value. Returns false if no such path.
    If 'createMissingKeys=true' it creates any missing path elements: JDB.solveIntSetter(".frostfall.keyB", 10, true) creates {frostfall: {keyB: 10}} structure
/;
Bool function solveFltSetter(String path, Float value, Bool createMissingKeys=false) global native
Bool function solveIntSetter(String path, Int value, Bool createMissingKeys=false) global native
Bool function solveStrSetter(String path, String value, Bool createMissingKeys=false) global native
Bool function solveObjSetter(String path, Int value, Bool createMissingKeys=false) global native
Bool function solveFormSetter(String path, Form value, Bool createMissingKeys=false) global native

;/  Associates(and replaces previous association) container object with a string key.
    destroys association if object is zero
    for ex. JDB.setObj("frostfall", frostFallInformation) will associate 'frostall' key and frostFallInformation so you can access it later
/;
function setObj(String key, Int object) global native

;/  Returns true, if JDB capable resolve given @path, i.e. if it able to execute solve* or solver*Setter functions successfully
/;
Bool function hasPath(String path) global native

;/  returns new array containing all JDB keys
/;
Int function allKeys() global native

;/  returns new array containing all containers associated with JDB
/;
Int function allValues() global native

;/  writes storage data into JSON file at given path
/;
function writeToFile(String path) global native

;/  DEPRECATED. Reads information from a JSON file at given path and replaces JDB content with the file content
/;
function readFromFile(String path) global native

;/  Returns underlying JDB's container - an instance of JMap.
    The object being owned (retained) internally, so you don't have to (but can) retain or release it.
/;
Int function root() global native
