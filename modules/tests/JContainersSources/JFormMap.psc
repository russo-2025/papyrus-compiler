
;/  Associative key-value container.
    Inherits JValue functionality
/;
ScriptName JFormMap

;/  creates new container object. returns container's identifier (unique integer number).
/;
Int function object() global native

;/  Returns the value associated with the @key. If not, returns @default value
/;
Int function getInt(Int object, Form key, Int default=0) global native
Float function getFlt(Int object, Form key, Float default=0.0) global native
String function getStr(Int object, Form key, String default="") global native
Int function getObj(Int object, Form key, Int default=0) global native
Form function getForm(Int object, Form key, Form default=None) global native

;/  Inserts @key: @value pair. Replaces existing pair with the same @key
/;
function setInt(Int object, Form key, Int value) global native
function setFlt(Int object, Form key, Float value) global native
function setStr(Int object, Form key, String value) global native
function setObj(Int object, Form key, Int container) global native
function setForm(Int object, Form key, Form value) global native

;/  Returns true, if the container has @key: value pair
/;
Bool function hasKey(Int object, Form key) global native

;/  Returns type of the value associated with the @key.
    0 - no value, 1 - none, 2 - int, 3 - float, 4 - form, 5 - object, 6 - string
/;
Int function valueType(Int object, Form key) global native

;/  Returns a new array containing all keys
/;
Int function allKeys(Int object) global native
Form[] function allKeysPArray(Int object) global native

;/  Returns a new array containing all values
/;
Int function allValues(Int object) global native

;/  Removes the pair from the container where the key equals to the @key
/;
Bool function removeKey(Int object, Form key) global native

;/  Returns count of pairs in the conainer
/;
Int function count(Int object) global native

;/  Removes all pairs from the container
/;
function clear(Int object) global native

;/  Inserts key-value pairs from the source container
/;
function addPairs(Int object, Int source, Bool overrideDuplicates) global native

;/  Simplifies iteration over container's contents.
    Accepts the @previousKey, returns the next key.
    If @previousKey == @endKey the function returns the first key.
    The function always returns so-called 'valid' keys (the ones != @endKey).
    The function returns @endKey ('invalid' key) only once to signal that iteration has reached its end.
    In most cases, if the map doesn't contain an invalid key ("" for JMap, None form-key for JFormMap)
    it's ok to omit the @endKey.
    
    Usage:
    
        string key = JMap.nextKey(map, previousKey="", endKey="")
        while key != ""
          <retrieve values here>
          key = JMap.nextKey(map, key, endKey="")
        endwhile
    
/;
Form function nextKey(Int object, Form previousKey=None, Form endKey=None) global native

;/  Retrieves N-th key. negative index accesses items from the end of container counting backwards.
    Worst complexity is O(n/2)
/;
Form function getNthKey(Int object, Int keyIndex) global native
