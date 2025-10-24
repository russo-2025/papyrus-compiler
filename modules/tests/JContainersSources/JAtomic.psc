
;/  
    This way you can even, probably, implement true locks and etc
/;
ScriptName JAtomic

;/  A group of the functions that perform various math on the value at the @path of the container. Returns previos value:
    
        T previousValue = container.path
        container.path = someMathFunction(container.path, value)
        return previousValue
    
    If the value at the @path is None, then the @initialValue being read and passed into math function instead of None.
    If @createMissingKeys is True, the function attemps to create missing @path elements.
/;
Int function fetchAddInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function fetchAddFlt(Int object, String path, Float value, Float initialValue=0.0, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native

;/  x *= v
/;
Int function fetchMultInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function fetchMultFlt(Int object, String path, Float value, Float initialValue=0.0, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native

;/  x %= v
/;
Int function fetchModInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native

;/  x /= v
/;
Int function fetchDivInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function fetchDivFlt(Int object, String path, Float value, Float initialValue=0.0, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native

;/  x &= v
/;
Int function fetchAndInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native

;/  x ^= v
/;
Int function fetchXorInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native

;/  x |= v
/;
Int function fetchOrInt(Int object, String path, Int value, Int initialValue=0, Bool createMissingKeys=false, Int onErrorReturn=0) global native

;/  Exchanges the value at the @path with the @value. Returns previous value.
/;
Int function exchangeInt(Int object, String path, Int value, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function exchangeFlt(Int object, String path, Float value, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native
String function exchangeStr(Int object, String path, String value, Bool createMissingKeys=false, String onErrorReturn="") global native
Form function exchangeForm(Int object, String path, Form value, Bool createMissingKeys=false, Form onErrorReturn=None) global native
Int function exchangeObj(Int object, String path, Int value, Bool createMissingKeys=false, Int onErrorReturn=0) global native

;/  Compares the value at the @path with the @comparand and, if they are equal, exchanges the value at the @path with the @value. Returns previous value.
/;
Int function compareExchangeInt(Int object, String path, Int value, Int comparand, Bool createMissingKeys=false, Int onErrorReturn=0) global native
Float function compareExchangeFlt(Int object, String path, Float value, Float comparand, Bool createMissingKeys=false, Float onErrorReturn=0.0) global native
Form function compareExchangeForm(Int object, String path, Form value, Form comparand, Bool createMissingKeys=false, Form onErrorReturn=None) global native
Int function compareExchangeObj(Int object, String path, Int value, Int comparand, Bool createMissingKeys=false, Int onErrorReturn=0) global native
