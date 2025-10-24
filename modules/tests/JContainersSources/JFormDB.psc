
;/  Manages form related information (entry).
    
/;
ScriptName JFormDB

;/  associates given form key and entry (container). set entry to zero to destroy association
/;
function setEntry(String storageName, Form fKey, Int entry) global native

;/  returns (or creates new if not found) JMap entry for given storage and form
/;
Int function makeEntry(String storageName, Form fKey) global native

;/  search for entry for given storage and form
/;
Int function findEntry(String storageName, Form fKey) global native

;/  attempts to get value associated with path.
/;
Float function solveFlt(Form fKey, String path, Float default=0.0) global native
Int function solveInt(Form fKey, String path, Int default=0) global native
String function solveStr(Form fKey, String path, String default="") global native
Int function solveObj(Form fKey, String path, Int default=0) global native
Form function solveForm(Form fKey, String path, Form default=None) global native

;/  Attempts to assign value. Returns false if no such path
    With 'createMissingKeys=true' it creates any missing path elements: JFormDB.solveIntSetter(formKey, ".frostfall.keyB", 10, true) creates {frostfall: {keyB: 10}} structure
/;
Bool function solveFltSetter(Form fKey, String path, Float value, Bool createMissingKeys=false) global native
Bool function solveIntSetter(Form fKey, String path, Int value, Bool createMissingKeys=false) global native
Bool function solveStrSetter(Form fKey, String path, String value, Bool createMissingKeys=false) global native
Bool function solveObjSetter(Form fKey, String path, Int value, Bool createMissingKeys=false) global native
Bool function solveFormSetter(Form fKey, String path, Form value, Bool createMissingKeys=false) global native

;/  returns true, if capable resolve given path, e.g. it able to execute solve* or solver*Setter functions successfully
/;
Bool function hasPath(Form fKey, String path) global native

;/  JMap-like interface functions:
    
    returns new array containing all keys
/;
Int function allKeys(Form fKey, String key) global native

;/  returns new array containing all values
/;
Int function allValues(Form fKey, String key) global native

;/  returns value associated with key
/;
Int function getInt(Form fKey, String key) global native
Float function getFlt(Form fKey, String key) global native
String function getStr(Form fKey, String key) global native
Int function getObj(Form fKey, String key) global native
Form function getForm(Form fKey, String key) global native

;/  creates key-value association. replaces existing value if any
/;
function setInt(Form fKey, String key, Int value) global native
function setFlt(Form fKey, String key, Float value) global native
function setStr(Form fKey, String key, String value) global native
function setObj(Form fKey, String key, Int container) global native
function setForm(Form fKey, String key, Form value) global native
