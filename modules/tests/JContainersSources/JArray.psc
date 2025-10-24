
;/  Ordered collection of values (value is float, integer, string, form or another container).
    Inherits JValue functionality
/;
ScriptName JArray

;/  creates new container object. returns container's identifier (unique integer number).
/;
Int function object() global native

;/  Creates a new array of given size, filled with empty (None) items
/;
Int function objectWithSize(Int size) global native

;/  Creates a new array that contains given values
    objectWithBooleans converts booleans into integers
/;
Int function objectWithInts(Int[] values) global native
Int function objectWithStrings(String[] values) global native
Int function objectWithFloats(Float[] values) global native
Int function objectWithBooleans(Bool[] values) global native
Int function objectWithForms(Form[] values) global native

;/  Creates a new array containing all the values from the source array in range [startIndex, endIndex)
/;
Int function subArray(Int object, Int startIndex, Int endIndex) global native

;/  Inserts the values from the source array into this array. If insertAtIndex is -1 (default behaviour) it appends to the end.
    negative index accesses items from the end of container counting backwards.
/;
function addFromArray(Int object, Int source, Int insertAtIndex=-1) global native
function addFromFormList(Int object, FormList source, Int insertAtIndex=-1) global native

;/  Returns the item at the index of the array.
    negative index accesses items from the end of container counting backwards.
/;
Int function getInt(Int object, Int index, Int default=0) global native
Float function getFlt(Int object, Int index, Float default=0.0) global native
String function getStr(Int object, Int index, String default="") global native
Int function getObj(Int object, Int index, Int default=0) global native
Form function getForm(Int object, Int index, Form default=None) global native

;/  Returns the index of the first found value/container that equals to given the value/container (default behaviour if searchStartIndex is 0).
    If nothing was found it returns -1.
    @searchStartIndex - index of the array where to start search
    negative index accesses items from the end of container counting backwards.
/;
Int function findInt(Int object, Int value, Int searchStartIndex=0) global native
Int function findFlt(Int object, Float value, Int searchStartIndex=0) global native
Int function findStr(Int object, String value, Int searchStartIndex=0) global native
Int function findObj(Int object, Int container, Int searchStartIndex=0) global native
Int function findForm(Int object, Form value, Int searchStartIndex=0) global native

;/  Replaces existing value at the @index of the array with the new @value.
    negative index accesses items from the end of container counting backwards.
/;
function setInt(Int object, Int index, Int value) global native
function setFlt(Int object, Int index, Float value) global native
function setStr(Int object, Int index, String value) global native
function setObj(Int object, Int index, Int container) global native
function setForm(Int object, Int index, Form value) global native

;/  Appends the @value/@container to the end of the array.
    If @addToIndex >= 0 it inserts value at given index. negative index accesses items from the end of container counting backwards.
/;
function addInt(Int object, Int value, Int addToIndex=-1) global native
function addFlt(Int object, Float value, Int addToIndex=-1) global native
function addStr(Int object, String value, Int addToIndex=-1) global native
function addObj(Int object, Int container, Int addToIndex=-1) global native
function addForm(Int object, Form value, Int addToIndex=-1) global native

;/  Returns count of the items in the array
/;
Int function count(Int object) global native

;/  Removes all the items from the array
/;
function clear(Int object) global native

;/  Erases the item at the index. negative index accesses items from the end of container counting backwards.
/;
function eraseIndex(Int object, Int index) global native

;/  Erases [first, last] index range of the items. negative index accesses items from the end of container counting backwards.
    For ex. with [1,-1] range it will erase everything except the first item
/;
function eraseRange(Int object, Int first, Int last) global native

;/  Returns type of the value at the @index. negative index accesses items from the end of container counting backwards.
    0 - no value, 1 - none, 2 - int, 3 - float, 4 - form, 5 - object, 6 - string
/;
Int function valueType(Int object, Int index) global native

;/  Exchanges the items at @index1 and @index2. negative index accesses items from the end of container counting backwards.
/;
function swapItems(Int object, Int index1, Int index2) global native

;/  Sorts the items into ascending order (none < int < float < form < object < string). Returns the array itself
/;
Int function sort(Int object) global native

;/  Sorts the items, removes duplicates. Returns array itself. You can treat it as JSet now
/;
Int function unique(Int object) global native

;/  Writes the array's items into the @targetArray array starting at @destIndex
     @writeAtIdx -    [-1, 0] - writes all the items in reverse order
       [0, -1] - writes all the items in straight order
       [1, 3] - writes 3 items in straight order
/;
Bool function writeToIntegerPArray(Int object, Int[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, Int defaultRead=0) global native
Bool function writeToFloatPArray(Int object, Float[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, Float defaultRead=0.0) global native
Bool function writeToFormPArray(Int object, Form[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, Form defaultRead=None) global native
Bool function writeToStringPArray(Int object, String[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, String defaultRead="") global native
