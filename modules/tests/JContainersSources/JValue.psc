
;/  Common functionality, shared by JArray, JMap, JFormMap, JIntMap
/;
ScriptName JValue

;/  --- Lifetime management functionality.
    Read this https://github.com/SilverIce/JContainers/wiki/Lifetime-Management before using any of lifetime management functions
    
    Retains and returns the object.
/;
Int function retain(Int object, String tag="") global native

;/  Releases the object and returns zero, so you can release and nullify with one line of code: object = JValue.release(object)
/;
Int function release(Int object) global native

;/  Just a union of retain-release calls. Releases @previousObject, retains and returns @newObject.
/;
Int function releaseAndRetain(Int previousObject, Int newObject, String tag="") global native

;/  For cleanup purposes only - releases all objects tagged with the @tag.
    Internally invokes JValue.release on the objects the same amount of times the objects were retained.
/;
function releaseObjectsWithTag(String tag) global native

;/  Minimizes the time JC temporarily owns the object, returns the object.
    By using this function you help JC to delete unused objects as soon as possible.
    Has zero effect if the object is being retained or if another object contains/references it.
/;
Int function zeroLifetime(Int object) global native

;/  Handly for temporary objects (objects with no owners) - the pool 'locationName' owns any amount of objects, preventing their destuction, extends lifetime.
    Do not forget to clean the pool later! Typical use:
    int jTempMap = JValue.addToPool(JMap.object(), "uniquePoolName")
    int jKeys = JValue.addToPool(JMap.allKeys(someJMap), "uniquePoolName")
    and anywhere later:
    JValue.cleanPool("uniquePoolName")
/;
Int function addToPool(Int object, String poolName) global native
function cleanPool(String poolName) global native

;/  --- Mics. functionality
    
    Returns shallow copy (won't copy child objects)
/;
Int function shallowCopy(Int object) global native

;/  Returns deep copy
/;
Int function deepCopy(Int object) global native

;/  Tests whether given object identifier points to existing object
/;
Bool function isExists(Int object) global native

;/  Returns true if the object is map, array or formmap container
/;
Bool function isArray(Int object) global native
Bool function isMap(Int object) global native
Bool function isFormMap(Int object) global native
Bool function isIntegerMap(Int object) global native

;/  Returns true, if the container is empty
/;
Bool function empty(Int object) global native

;/  Returns amount of items in the container
/;
Int function count(Int object) global native

;/  Removes all items from the container
/;
function clear(Int object) global native

;/  JSON serialization/deserialization:
    
    Creates and returns a new container object containing contents of JSON file
/;
Int function readFromFile(String filePath) global native

;/  Parses JSON files in a directory (non recursive) and returns JMap containing {filename, container-object} pairs.
    Note: by default it does not filter files by extension and will try to parse everything
/;
Int function readFromDirectory(String directoryPath, String extension="") global native

;/  Creates a new container object using given JSON string-prototype
/;
Int function objectFromPrototype(String prototype) global native

;/  Writes the object into JSON file
/;
function writeToFile(Int object, String filePath) global native

;/  Path resolving:
    
    Returns true, if it's possible to resolve given path, i.e. if it's possible to retrieve the value at the path.
    For ex. JValue.hasPath(container, ".player.health") will test whether @container structure close to this one - {'player': {'health': health_value}}
/;
Bool function hasPath(Int object, String path) global native

;/  Returns type of resolved value. 0 - no value, 1 - none, 2 - int, 3 - float, 4 - form, 5 - object, 6 - string
/;
Int function solvedValueType(Int object, String path) global native

;/  Attempts to retrieve value at given path. If fails, returns @default value
/;
Float function solveFlt(Int object, String path, Float default=0.0) global native
Int function solveInt(Int object, String path, Int default=0) global native
String function solveStr(Int object, String path, String default="") global native
Int function solveObj(Int object, String path, Int default=0) global native
Form function solveForm(Int object, String path, Form default=None) global native

;/  Attempts to assign the value. If @createMissingKeys is False it may fail to assign - if no such path exist.
    With 'createMissingKeys=true' it creates any missing path element: solveIntSetter(map, ".keyA.keyB", 10, true) on empty JMap creates {keyA: {keyB: 10}} structure
/;
Bool function solveFltSetter(Int object, String path, Float value, Bool createMissingKeys=false) global native
Bool function solveIntSetter(Int object, String path, Int value, Bool createMissingKeys=false) global native
Bool function solveStrSetter(Int object, String path, String value, Bool createMissingKeys=false) global native
Bool function solveObjSetter(Int object, String path, Int value, Bool createMissingKeys=false) global native
Bool function solveFormSetter(Int object, String path, Form value, Bool createMissingKeys=false) global native

;/  Evaluates piece of lua code. Lua support is experimental
/;
Float function evalLuaFlt(Int object, String luaCode, Float default=0.0) global native
Int function evalLuaInt(Int object, String luaCode, Int default=0) global native
String function evalLuaStr(Int object, String luaCode, String default="") global native
Int function evalLuaObj(Int object, String luaCode, Int default=0) global native
Form function evalLuaForm(Int object, String luaCode, Form default=None) global native
