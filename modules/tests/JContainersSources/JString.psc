
;/  various string utility methods
/;
ScriptName JString

;/  Breaks source text onto set of lines of almost equal size.
    Returns JArray object containing lines.
    Accepts ASCII and UTF-8 encoded strings only
/;
Int function wrap(String sourceText, Int charactersPerLine=60) global native

;/  FormId|Form <-> "__formData|<pluginName>|<lowFormId>"-string converisons
/;
Int function decodeFormStringToFormId(String formString) global native
Form function decodeFormStringToForm(String formString) global native
String function encodeFormToString(Form value) global native
String function encodeFormIdToString(Int formId) global native

;/  Generates random uuid-string like 2e80251a-ab22-4ad8-928c-2d1c9561270e
/;
String function generateUUID() global native
