
;/  Evaluates Lua code. Unstable API - I'm free to change or remove it anytime
/;
ScriptName JLua

;/  Evaluates piece of Lua code. The arguments are carried by @transport object.
    The @transport is any kind of object, not just JMap.
    If @minimizeLifetime is True the function will invoke JValue.zeroLifetime on the @transport object.
    It is more than wise to re-use @transport when evaluating lot of lua code at once.
    Returns @default value if evaluation fails.
    Usage example:
    
        ; 7 from the end until 9 from the end. Returns "Lua" string
        string input = "Hello Lua user"
        string s = JLua.evaLuaStr("return string.sub(args.string, args.low, args.high)",\
            JLua.setStr("string",input, JLua.setInt("low",7, JLua.setInt("high",9 )))\
        )
    
/;
Float function evalLuaFlt(String luaCode, Int transport, Float default=0.0, Bool minimizeLifetime=true) global native
Int function evalLuaInt(String luaCode, Int transport, Int default=0, Bool minimizeLifetime=true) global native
String function evalLuaStr(String luaCode, Int transport, String default="", Bool minimizeLifetime=true) global native
Int function evalLuaObj(String luaCode, Int transport, Int default=0, Bool minimizeLifetime=true) global native
Form function evalLuaForm(String luaCode, Int transport, Form default=None, Bool minimizeLifetime=true) global native

;/  Inserts new (or replaces existing) {key -> value} pair. Expects that @transport is JMap object, if @transport is 0 it creates new JMap object.
    Returns @transport
/;
Int function setStr(String key, String value, Int transport=0) global native
Int function setFlt(String key, Float value, Int transport=0) global native
Int function setInt(String key, Int value, Int transport=0) global native
Int function setForm(String key, Form value, Int transport=0) global native
Int function setObj(String key, Int value, Int transport=0) global native
