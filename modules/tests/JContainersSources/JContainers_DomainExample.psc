ScriptName JContainers_DomainExample

; JArray

Int function JArray_object() global native
Int function JArray_objectWithSize(Int size) global native
Int function JArray_objectWithInts(Int[] values) global native
Int function JArray_objectWithStrings(String[] values) global native
Int function JArray_objectWithFloats(Float[] values) global native
Int function JArray_objectWithBooleans(Bool[] values) global native
Int function JArray_objectWithForms(Form[] values) global native
Int function JArray_subArray(Int object, Int startIndex, Int endIndex) global native
function JArray_addFromArray(Int object, Int source, Int insertAtIndex=-1) global native
function JArray_addFromFormList(Int object, FormList source, Int insertAtIndex=-1) global native
Int function JArray_getInt(Int object, Int index, Int default=0) global native
Float function JArray_getFlt(Int object, Int index, Float default=0.0) global native
String function JArray_getStr(Int object, Int index, String default="") global native
Int function JArray_getObj(Int object, Int index, Int default=0) global native
Form function JArray_getForm(Int object, Int index, Form default=None) global native
Int function JArray_findInt(Int object, Int value, Int searchStartIndex=0) global native
Int function JArray_findFlt(Int object, Float value, Int searchStartIndex=0) global native
Int function JArray_findStr(Int object, String value, Int searchStartIndex=0) global native
Int function JArray_findObj(Int object, Int container, Int searchStartIndex=0) global native
Int function JArray_findForm(Int object, Form value, Int searchStartIndex=0) global native
function JArray_setInt(Int object, Int index, Int value) global native
function JArray_setFlt(Int object, Int index, Float value) global native
function JArray_setStr(Int object, Int index, String value) global native
function JArray_setObj(Int object, Int index, Int container) global native
function JArray_setForm(Int object, Int index, Form value) global native
function JArray_addInt(Int object, Int value, Int addToIndex=-1) global native
function JArray_addFlt(Int object, Float value, Int addToIndex=-1) global native
function JArray_addStr(Int object, String value, Int addToIndex=-1) global native
function JArray_addObj(Int object, Int container, Int addToIndex=-1) global native
function JArray_addForm(Int object, Form value, Int addToIndex=-1) global native
Int function JArray_count(Int object) global native
function JArray_clear(Int object) global native
function JArray_eraseIndex(Int object, Int index) global native
function JArray_eraseRange(Int object, Int first, Int last) global native
Int function JArray_valueType(Int object, Int index) global native
function JArray_swapItems(Int object, Int index1, Int index2) global native
Int function JArray_sort(Int object) global native
Int function JArray_unique(Int object) global native
Bool function JArray_writeToIntegerPArray(Int object, Int[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, Int defaultRead=0) global native
Bool function JArray_writeToFloatPArray(Int object, Float[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, Float defaultRead=0.0) global native
Bool function JArray_writeToFormPArray(Int object, Form[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, Form defaultRead=None) global native
Bool function JArray_writeToStringPArray(Int object, String[] targetArray, Int writeAtIdx=0, Int stopWriteAtIdx=-1, Int readIdx=0, String defaultRead="") global native

; JAtomic

Int function JAtomic_fetchAddInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function JAtomic_fetchAddFlt(Int object, String path, Float value, Float initialValue=0.0, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native
Int function JAtomic_fetchMultInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function JAtomic_fetchMultFlt(Int object, String path, Float value, Float initialValue=0.0, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native
Int function JAtomic_fetchModInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Int function JAtomic_fetchDivInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function JAtomic_fetchDivFlt(Int object, String path, Float value, Float initialValue=0.0, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native
Int function JAtomic_fetchAndInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Int function JAtomic_fetchXorInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Int function JAtomic_fetchOrInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Int function JAtomic_exchangeInt(Int object, String path, Int value, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function JAtomic_exchangeFlt(Int object, String path, Float value, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native
String function JAtomic_exchangeStr(Int object, String path, String value, Bool createMissingKeys=false, String onErrorReturn="") global native
Form function JAtomic_exchangeForm(Int object, String path, Form value, Bool createMissingKeys=false, Form onErrorReturn=None) global native
Int function JAtomic_exchangeObj(Int object, String path, Int value, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Int function JAtomic_compareExchangeInt(Int object, String path, Int value, Int comparand, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function JAtomic_compareExchangeFlt(Int object, String path, Float value, Float comparand, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native
Form function JAtomic_compareExchangeForm(Int object, String path, Form value, Form comparand, Bool createMissingKeys=false, Form onErrorReturn=None) global native
Int function JAtomic_compareExchangeObj(Int object, String path, Int value, Int comparand, Bool createMissingKeys=false, Int onErrorReturn=0) global native

; JContainers


; JDB

Float function JDB_solveFlt(String path, Float default=0.0) global native
Int function JDB_solveInt(String path, Int default=0) global native
String function JDB_solveStr(String path, String default="") global native
Int function JDB_solveObj(String path, Int default=0) global native
Form function JDB_solveForm(String path, Form default=None) global native
Bool function JDB_solveFltSetter(String path, Float value, Bool createMissingKeys=false) global native
Bool function JDB_solveIntSetter(String path, Int value, Bool createMissingKeys=false) global native
Bool function JDB_solveStrSetter(String path, String value, Bool createMissingKeys=false) global native
Bool function JDB_solveObjSetter(String path, Int value, Bool createMissingKeys=false) global native
Bool function JDB_solveFormSetter(String path, Form value, Bool createMissingKeys=false) global native
function JDB_setObj(String key, Int object) global native
Bool function JDB_hasPath(String path) global native
Int function JDB_allKeys() global native
Int function JDB_allValues() global native
function JDB_writeToFile(String path) global native
function JDB_readFromFile(String path) global native
Int function JDB_root() global native

; JFormDB

function JFormDB_setEntry(String storageName, Form fKey, Int entry) global native
Int function JFormDB_makeEntry(String storageName, Form fKey) global native
Int function JFormDB_findEntry(String storageName, Form fKey) global native
Float function JFormDB_solveFlt(Form fKey, String path, Float default=0.0) global native
Int function JFormDB_solveInt(Form fKey, String path, Int default=0) global native
String function JFormDB_solveStr(Form fKey, String path, String default="") global native
Int function JFormDB_solveObj(Form fKey, String path, Int default=0) global native
Form function JFormDB_solveForm(Form fKey, String path, Form default=None) global native
Bool function JFormDB_solveFltSetter(Form fKey, String path, Float value, Bool createMissingKeys=false) global native
Bool function JFormDB_solveIntSetter(Form fKey, String path, Int value, Bool createMissingKeys=false) global native
Bool function JFormDB_solveStrSetter(Form fKey, String path, String value, Bool createMissingKeys=false) global native
Bool function JFormDB_solveObjSetter(Form fKey, String path, Int value, Bool createMissingKeys=false) global native
Bool function JFormDB_solveFormSetter(Form fKey, String path, Form value, Bool createMissingKeys=false) global native
Bool function JFormDB_hasPath(Form fKey, String path) global native
Int function JFormDB_allKeys(Form fKey, String key) global native
Int function JFormDB_allValues(Form fKey, String key) global native
Int function JFormDB_getInt(Form fKey, String key) global native
Float function JFormDB_getFlt(Form fKey, String key) global native
String function JFormDB_getStr(Form fKey, String key) global native
Int function JFormDB_getObj(Form fKey, String key) global native
Form function JFormDB_getForm(Form fKey, String key) global native
function JFormDB_setInt(Form fKey, String key, Int value) global native
function JFormDB_setFlt(Form fKey, String key, Float value) global native
function JFormDB_setStr(Form fKey, String key, String value) global native
function JFormDB_setObj(Form fKey, String key, Int container) global native
function JFormDB_setForm(Form fKey, String key, Form value) global native

; JFormMap

Int function JFormMap_object() global native
Int function JFormMap_getInt(Int object, Form key, Int default=0) global native
Float function JFormMap_getFlt(Int object, Form key, Float default=0.0) global native
String function JFormMap_getStr(Int object, Form key, String default="") global native
Int function JFormMap_getObj(Int object, Form key, Int default=0) global native
Form function JFormMap_getForm(Int object, Form key, Form default=None) global native
function JFormMap_setInt(Int object, Form key, Int value) global native
function JFormMap_setFlt(Int object, Form key, Float value) global native
function JFormMap_setStr(Int object, Form key, String value) global native
function JFormMap_setObj(Int object, Form key, Int container) global native
function JFormMap_setForm(Int object, Form key, Form value) global native
Bool function JFormMap_hasKey(Int object, Form key) global native
Int function JFormMap_valueType(Int object, Form key) global native
Int function JFormMap_allKeys(Int object) global native
Form[] function JFormMap_allKeysPArray(Int object) global native
Int function JFormMap_allValues(Int object) global native
Bool function JFormMap_removeKey(Int object, Form key) global native
Int function JFormMap_count(Int object) global native
function JFormMap_clear(Int object) global native
function JFormMap_addPairs(Int object, Int source, Bool overrideDuplicates) global native
Form function JFormMap_nextKey(Int object, Form previousKey=None, Form endKey=None) global native
Form function JFormMap_getNthKey(Int object, Int keyIndex) global native

; JIntMap

Int function JIntMap_object() global native
Int function JIntMap_getInt(Int object, Int key, Int default=0) global native
Float function JIntMap_getFlt(Int object, Int key, Float default=0.0) global native
String function JIntMap_getStr(Int object, Int key, String default="") global native
Int function JIntMap_getObj(Int object, Int key, Int default=0) global native
Form function JIntMap_getForm(Int object, Int key, Form default=None) global native
function JIntMap_setInt(Int object, Int key, Int value) global native
function JIntMap_setFlt(Int object, Int key, Float value) global native
function JIntMap_setStr(Int object, Int key, String value) global native
function JIntMap_setObj(Int object, Int key, Int container) global native
function JIntMap_setForm(Int object, Int key, Form value) global native
Bool function JIntMap_hasKey(Int object, Int key) global native
Int function JIntMap_valueType(Int object, Int key) global native
Int function JIntMap_allKeys(Int object) global native
Int[] function JIntMap_allKeysPArray(Int object) global native
Int function JIntMap_allValues(Int object) global native
Bool function JIntMap_removeKey(Int object, Int key) global native
Int function JIntMap_count(Int object) global native
function JIntMap_clear(Int object) global native
function JIntMap_addPairs(Int object, Int source, Bool overrideDuplicates) global native
Int function JIntMap_nextKey(Int object, Int previousKey=0, Int endKey=0) global native
Int function JIntMap_getNthKey(Int object, Int keyIndex) global native

; JLua

Float function JLua_evalLuaFlt(String luaCode, Int transport, Float default=0.0, Bool minimizeLifetime=true) global native
Int function JLua_evalLuaInt(String luaCode, Int transport, Int default=0, Bool minimizeLifetime=true) global native
String function JLua_evalLuaStr(String luaCode, Int transport, String default="", Bool minimizeLifetime=true) global native
Int function JLua_evalLuaObj(String luaCode, Int transport, Int default=0, Bool minimizeLifetime=true) global native
Form function JLua_evalLuaForm(String luaCode, Int transport, Form default=None, Bool minimizeLifetime=true) global native
Int function JLua_setStr(String key, String value, Int transport=0) global native
Int function JLua_setFlt(String key, Float value, Int transport=0) global native
Int function JLua_setInt(String key, Int value, Int transport=0) global native
Int function JLua_setForm(String key, Form value, Int transport=0) global native
Int function JLua_setObj(String key, Int value, Int transport=0) global native

; JMap

Int function JMap_object() global native
Int function JMap_getInt(Int object, String key, Int default=0) global native
Float function JMap_getFlt(Int object, String key, Float default=0.0) global native
String function JMap_getStr(Int object, String key, String default="") global native
Int function JMap_getObj(Int object, String key, Int default=0) global native
Form function JMap_getForm(Int object, String key, Form default=None) global native
function JMap_setInt(Int object, String key, Int value) global native
function JMap_setFlt(Int object, String key, Float value) global native
function JMap_setStr(Int object, String key, String value) global native
function JMap_setObj(Int object, String key, Int container) global native
function JMap_setForm(Int object, String key, Form value) global native
Bool function JMap_hasKey(Int object, String key) global native
Int function JMap_valueType(Int object, String key) global native
Int function JMap_allKeys(Int object) global native
String[] function JMap_allKeysPArray(Int object) global native
Int function JMap_allValues(Int object) global native
Bool function JMap_removeKey(Int object, String key) global native
Int function JMap_count(Int object) global native
function JMap_clear(Int object) global native
function JMap_addPairs(Int object, Int source, Bool overrideDuplicates) global native
String function JMap_nextKey(Int object, String previousKey="", String endKey="") global native
String function JMap_getNthKey(Int object, Int keyIndex) global native

; JString

Int function JString_wrap(String sourceText, Int charactersPerLine=60) global native

; JValue

Int function JValue_retain(Int object, String tag="") global native
Int function JValue_release(Int object) global native
Int function JValue_releaseAndRetain(Int previousObject, Int newObject, String tag="") global native
function JValue_releaseObjectsWithTag(String tag) global native
Int function JValue_zeroLifetime(Int object) global native
Int function JValue_addToPool(Int object, String poolName) global native
function JValue_cleanPool(String poolName) global native
Int function JValue_shallowCopy(Int object) global native
Int function JValue_deepCopy(Int object) global native
Bool function JValue_isExists(Int object) global native
Bool function JValue_isArray(Int object) global native
Bool function JValue_isMap(Int object) global native
Bool function JValue_isFormMap(Int object) global native
Bool function JValue_isIntegerMap(Int object) global native
Bool function JValue_empty(Int object) global native
Int function JValue_count(Int object) global native
function JValue_clear(Int object) global native
Int function JValue_readFromFile(String filePath) global native
Int function JValue_readFromDirectory(String directoryPath, String extension="") global native
Int function JValue_objectFromPrototype(String prototype) global native
function JValue_writeToFile(Int object, String filePath) global native
Bool function JValue_hasPath(Int object, String path) global native
Int function JValue_solvedValueType(Int object, String path) global native
Float function JValue_solveFlt(Int object, String path, Float default=0.0) global native
Int function JValue_solveInt(Int object, String path, Int default=0) global native
String function JValue_solveStr(Int object, String path, String default="") global native
Int function JValue_solveObj(Int object, String path, Int default=0) global native
Form function JValue_solveForm(Int object, String path, Form default=None) global native
Bool function JValue_solveFltSetter(Int object, String path, Float value, Bool createMissingKeys=false) global native
Bool function JValue_solveIntSetter(Int object, String path, Int value, Bool createMissingKeys=false) global native
Bool function JValue_solveStrSetter(Int object, String path, String value, Bool createMissingKeys=false) global native
Bool function JValue_solveObjSetter(Int object, String path, Int value, Bool createMissingKeys=false) global native
Bool function JValue_solveFormSetter(Int object, String path, Form value, Bool createMissingKeys=false) global native
Float function JValue_evalLuaFlt(Int object, String luaCode, Float default=0.0) global native
Int function JValue_evalLuaInt(Int object, String luaCode, Int default=0) global native
String function JValue_evalLuaStr(Int object, String luaCode, String default="") global native
Int function JValue_evalLuaObj(Int object, String luaCode, Int default=0) global native
Form function JValue_evalLuaForm(Int object, String luaCode, Form default=None) global native
